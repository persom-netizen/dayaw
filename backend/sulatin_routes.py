"""
backend/sulatin_routes.py

Flask blueprint implementing:
- /api/sulatin/predict  (POST)
- /api/sulatin/save-sample (POST)
- /api/sulatin/lessons (GET)

This version avoids importing the Flask app or its `db` object at module import time
to prevent circular imports. It uses the DATABASE_URI from backend.__init__.py and
a standalone SQLAlchemy engine for simple INSERTs (no ORM models required here).
"""
import os
import json
import base64
from datetime import datetime
from flask import Blueprint, request, jsonify, current_app
from sqlalchemy import create_engine, text as sa_text

from baybayin_model import predict_from_data_uri, predict_from_strokes, prepare_from_stroke_json

sulatin_bp = Blueprint("sulatin_bp", __name__, url_prefix="/api/sulatin")

# -------------------------
# DB engine (used for simple persistence)
# -------------------------
_engine = None

def get_engine():
    global _engine
    if _engine is None:
        uri = current_app.config["SQLALCHEMY_DATABASE_URI"]
        _engine = create_engine(uri, future=True)
    return _engine

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
# DB persistence helpers (use raw SQL via the engine)
# -------------------------
def insert_sulatin_attempt(username, expected, predicted, confidence, correct, stroke_json, image_path):
    engine = get_engine()
    sql = sa_text("""
        INSERT INTO sulatin_attempts (username, expected, predicted, confidence, correct, stroke_json, image_path, created_at)
        VALUES (:username, :expected, :predicted, :confidence, :correct, :stroke_json, :image_path, NOW())
    """)
    params = {
        "username": username,
        "expected": expected,
        "predicted": predicted,
        "confidence": str(confidence) if confidence is not None else None,
        "correct": 1 if correct else 0,
        "stroke_json": json.dumps(stroke_json) if stroke_json is not None else None,
        "image_path": image_path
    }
    with engine.begin() as conn:
        conn.execute(sql, params)

def insert_sulatin_sample(label, source, stroke_json, image_path):
    engine = get_engine()
    sql = sa_text("""
        INSERT INTO sulatin_samples (label, source, stroke_json, image_path, created_at)
        VALUES (:label, :source, :stroke_json, :image_path, NOW())
    """)
    params = {
        "label": label,
        "source": source,
        "stroke_json": json.dumps(stroke_json) if stroke_json is not None else None,
        "image_path": image_path
    }
    with engine.begin() as conn:
        conn.execute(sql, params)

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
      "save": true|false              # optional (persist attempt image)
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
        save_flag = bool(payload.get("save", False))
        result = None
        saved_path = None

        if data_uri:
            try:
                if save_flag:
                    saved_path = save_data_uri_to_disk(data_uri, prefix="attempt")
                result = predict_from_data_uri(data_uri)
            except Exception as e:
                return jsonify({"error": "Failed to process image: " + str(e)}), 400
        elif strokes:
            try:
                result = predict_from_strokes(strokes)
            except Exception as e:
                return jsonify({"error": "Failed to process strokes: " + str(e)}), 400

            if save_flag:
                arr = prepare_from_stroke_json(strokes, size=(256,256))
                import imageio
                ts = datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
                filename = f"attempt_{ts}.png"
                path = os.path.join(DATA_DIR, filename)
                img = (255*(1.0 - arr[:,:,0])).astype("uint8")
                imageio.imwrite(path, img)
                saved_path = path
        else:
            return jsonify({"error": "Provide either 'image' (data-uri) or 'strokes' JSON"}), 400

        label = result.get("label") if result else None
        confidence = float(result.get("confidence", 0.0)) if result else 0.0
        correct = None
        if expected is not None and label is not None:
            correct = (expected == label) and (confidence >= 0.6)

        # persist attempt (via raw SQL engine) - non-blocking for prediction correctness,
        # but keep it synchronous here to make sure attempts are recorded.
        try:
            insert_sulatin_attempt(username=username, expected=expected, predicted=label,
                                   confidence=confidence, correct=bool(correct),
                                   stroke_json=strokes if strokes else None, image_path=saved_path)
        except Exception as e:
            # don't fail the whole request on DB logging errors; just warn in response
            current_app.logger.warning("Failed to persist sulatin attempt: %s", e)

        resp = {"label": label, "confidence": confidence}
        if expected is not None:
            resp["expected"] = expected
            resp["correct"] = bool(correct)
        return jsonify(resp), 200

    except Exception as e:
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

        try:
            insert_sulatin_sample(label=label, source=source, stroke_json=strokes if strokes else None, image_path=saved_path)
        except Exception as e:
            current_app.logger.warning("Failed to persist sulatin sample: %s", e)

        return jsonify({"success": True, "label": label, "image_path": saved_path}), 201
    except Exception as e:
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
        ]
    }
    return jsonify(curriculum), 200