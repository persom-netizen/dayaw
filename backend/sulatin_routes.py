"""
backend/sulatin_routes.py

Flask blueprint implementing:
- /api/sulatin/predict  (POST)
- /api/sulatin/save-sample (POST)
- /api/sulatin/lessons (GET)

Also defines DB models for Samples and Attempts so you can collect dataset and user attempts.
"""
import os
import json
from datetime import datetime
from flask import Blueprint, request, jsonify, current_app
from sqlalchemy import Column, Integer, String, DateTime, Text, JSON, Boolean, ForeignKey
from sqlalchemy.orm import relationship

from app import db  # import your application's db
from baybayin_model import predict_from_data_uri, predict_from_strokes, prepare_from_stroke_json

sulatin_bp = Blueprint("sulatin_bp", __name__, url_prefix="/api/sulatin")

# -------------------------
# DB MODELS
# -------------------------
class SulatinSample(db.Model):
    __tablename__ = "sulatin_samples"
    id = Column(Integer, primary_key=True)
    label = Column(String(100), nullable=False)          # ground truth
    source = Column(String(50), default="user")         # user | synthetic | teacher
    stroke_json = Column(JSON, nullable=True)           # save strokes for stroke-based analysis
    image_path = Column(String(255), nullable=True)     # saved PNG path (optional)
    created_at = Column(DateTime, default=datetime.utcnow)

class SulatinAttempt(db.Model):
    __tablename__ = "sulatin_attempts"
    id = Column(Integer, primary_key=True)
    username = Column(String(80), nullable=True)
    expected = Column(String(100), nullable=True)
    predicted = Column(String(100), nullable=True)
    confidence = Column(String(50), nullable=True)
    correct = Column(Boolean, default=False)
    stroke_json = Column(JSON, nullable=True)
    image_path = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# -------------------------
# Helper: save PNG to disk
# -------------------------
DATA_DIR = os.environ.get("SULATIN_DATA_DIR", os.path.join(os.getcwd(), "sulatin_data"))
os.makedirs(DATA_DIR, exist_ok=True)

def save_data_uri_to_disk(data_uri: str, prefix: str = "sample") -> str:
    # returns file path
    header, encoded = (data_uri.split(",", 1) if "," in data_uri else (None, data_uri))
    img_bytes = base64.b64decode(encoded)
    ts = datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    filename = f"{prefix}_{ts}.png"
    path = os.path.join(DATA_DIR, filename)
    with open(path, "wb") as f:
        f.write(img_bytes)
    return path

# -------------------------
# ROUTES
# -------------------------
@sulatin_bp.route("/predict", methods=["POST"])
def predict():
    """
    Accepts:
    {
      "image": "<data-uri>"            # optional
      "strokes": [ [ {x:,y:}, ... ], ... ]  # optional
      "expected": "KA"                # optional label provided by frontend
      "username": "user1"             # optional
    }
    Returns:
    { label, confidence, correct (if expected provided), predicted_index }
    """
    try:
        payload = request.get_json() or {}
        data_uri = payload.get("image")
        strokes = payload.get("strokes")
        expected = payload.get("expected")
        username = payload.get("username")
        result = None
        saved_path = None

        if data_uri:
            # optionally save the PNG for dataset
            try:
                # avoid heavy disk writes in production unless enabled
                if payload.get("save", False):
                    saved_path = save_data_uri_to_disk(data_uri, prefix="attempt")
                result = predict_from_data_uri(data_uri)
            except Exception as e:
                return jsonify({"error": "Failed to process image: " + str(e)}), 400
        elif strokes:
            result = predict_from_strokes(strokes)
            if payload.get("save", False):
                # rasterize strokes and save image for dataset
                arr = prepare_from_stroke_json(strokes, size=(256,256))
                import imageio
                ts = datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
                filename = f"attempt_{ts}.png"
                path = os.path.join(DATA_DIR, filename)
                # arr is normalized float in (h,w,1) with inverted stroke color; convert back
                img = (255*(1.0 - arr[:,:,0])).astype("uint8")
                imageio.imwrite(path, img)
                saved_path = path
        else:
            return jsonify({"error": "Provide either 'image' (data-uri) or 'strokes' JSON"}), 400

        label = result.get("label")
        confidence = float(result.get("confidence", 0.0))
        correct = None
        if expected:
            # basic rule: require confidence threshold to consider correct
            correct = (expected == label) and (confidence >= 0.6)

        # persist attempt
        attempt = SulatinAttempt(
            username=username,
            expected=expected,
            predicted=label,
            confidence=str(confidence),
            correct=bool(correct),
            stroke_json=strokes if strokes else None,
            image_path=saved_path
        )
        db.session.add(attempt)
        db.session.commit()

        resp = {"label": label, "confidence": confidence, "predicted_index": result.get("predicted_index")}
        if expected is not None:
            resp["expected"] = expected
            resp["correct"] = bool(correct)
        return jsonify(resp), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@sulatin_bp.route("/save-sample", methods=["POST"])
def save_sample():
    """
    Save a labeled sample to the dataset for training.

    Body:
    {
      "label": "KA",
      "image": "<data-uri>",        # or
      "strokes": [...],
      "source": "user|teacher|synthetic"
    }
    """
    try:
        payload = request.get_json() or {}
        label = payload.get("label")
        if not label:
            return jsonify({"error": "label is required"}), 400

        data_uri = payload.get("image")
        strokes = payload.get("strokes")
        source = payload.get("source", "user")
        saved_path = None

        if data_uri:
            saved_path = save_data_uri_to_disk(data_uri, prefix=f"sample_{label}")
        elif strokes:
            # rasterize strokes
            arr = prepare_from_stroke_json(strokes, size=(256,256))
            import imageio
            ts = datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
            filename = f"sample_{label}_{ts}.png"
            path = os.path.join(DATA_DIR, filename)
            img = (255*(1.0 - arr[:,:,0])).astype("uint8")
            imageio.imwrite(path, img)
            saved_path = path
        else:
            return jsonify({"error": "Provide image or strokes"}), 400

        sample = SulatinSample(
            label=label,
            source=source,
            stroke_json=strokes if strokes else None,
            image_path=saved_path
        )
        db.session.add(sample)
        db.session.commit()
        return jsonify({"success": True, "sample_id": sample.id, "image_path": saved_path}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@sulatin_bp.route("/lessons", methods=["GET"])
def get_lessons():
    """
    Return the 'skriptong baybayin' curriculum structure so frontend can render.
    For now we return the static module you provided; later this can be editable.
    """
    curriculum = {
        "title": "Skriptong Baybayin",
        "chapters": [
            {"id": "k1", "title": "Kabanata 1 - Panimula sa Baybayin",
             "lessons": [
                 {"id":"1.1", "title":"Ano ang Baybayin?", "sections":["Kasaysayan ng pagsusulat","Kahalagahang kultural","Saan ito ginagamit ngayon","Mini-quiz"]},
                 {"id":"1.2", "title":"Estruktura ng Baybayin", "sections":["Katinig","Patinig","Kudlit system","Aktibidad: Interactive card matching"]}
             ]},
            {"id":"k2", "title":"Kabanata 2 - Mga Pangunahing Hagod", "lessons":[
                {"id":"2.1","title":"Tatlong Pangunahing Uri ng Hagod","sections":["Kurba","Hook / liko","Pahilis","Visual demo","Tracing exercise"]},
                {"id":"2.2","title":"Pahina ng Pagsasanay sa Hagod","sections":["Trace shapes","TF checks: direction, smoothness, angle, completion"]},
                {"id":"2.3","title":"Tamang Pagkakapit at Paggalaw ng Panulat","sections":["Techniques","Proportion","Timed tracing"]}
            ]},
            # (Add other chapters similarly or return the full structure later)
        ]
    }
    return jsonify(curriculum), 200