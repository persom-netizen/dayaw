"""
backend/baybayin_model.py

- Loads a saved TensorFlow Keras model (SavedModel or .h5 or .keras).
- Provides preprocess helpers to convert data-URI or stroke JSON to model input.
- Exposes predict_image(data_uri) and predict_from_strokes(strokes) helpers.
"""
import os
import io
import base64
import json
from typing import Tuple, Dict, List

import numpy as np
from PIL import Image, ImageDraw, ImageOps
import tensorflow as tf
import cv2

# Model path (set via env var or default)
# Try .keras first (modern TensorFlow format), then fall back to legacy names
def _find_model_path():
    candidates = [
        os.environ.get("BAYBAYIN_MODEL_PATH"),  # explicit env var
        "baybayin_model.keras",  # new format
        "baybayin_model",  # legacy format (SavedModel directory)
    ]
    for path in candidates:
        if path and os.path.exists(path):
            return path
    # if none found, return the env var or default to .keras
    return os.environ.get("BAYBAYIN_MODEL_PATH", "baybayin_model.keras")

MODEL_PATH = _find_model_path()
CLASSES_FILE = None

def _find_classes_file():
    """Find the classes file, trying both .keras.classes.txt and _classes.txt formats."""
    candidates = [
        MODEL_PATH + ".classes.txt",  # new format (matches train_baybayin.py output)
        MODEL_PATH.replace(".keras", "") + "_classes.txt",  # legacy format
        "baybayin_model.keras.classes.txt",
        "baybayin_model_classes.txt",
    ]
    for path in candidates:
        if os.path.exists(path):
            return path
    return candidates[0]  # default to new format

# Lazy-loaded objects
_model = None
_classes = None

def load_model():
    global _model, _classes, MODEL_PATH, CLASSES_FILE
    if _model is None:
        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(f"Model path not found: {MODEL_PATH}")
        _model = tf.keras.models.load_model(MODEL_PATH)
    if _classes is None:
        if CLASSES_FILE is None:
            CLASSES_FILE = _find_classes_file()
        if os.path.exists(CLASSES_FILE):
            with open(CLASSES_FILE, "r", encoding="utf-8") as f:
                _classes = [l.strip() for l in f.readlines() if l.strip()]
        else:
            # fallback: create placeholder labels by model output size (if possible)
            try:
                out_dim = _model.output_shape[-1]
                _classes = [str(i) for i in range(out_dim)]
            except Exception:
                _classes = []
    return _model, _classes

def data_uri_to_pil(data_uri: str) -> Image.Image:
    # Accept either "data:image/png;base64,..." or raw base64
    if "," in data_uri:
        _, encoded = data_uri.split(",", 1)
    else:
        encoded = data_uri
    img_bytes = base64.b64decode(encoded)
    return Image.open(io.BytesIO(img_bytes)).convert("L")  # grayscale

def strokes_to_image(strokes: List[List[Dict]], size=(128,128), stroke_width=10) -> Image.Image:
    """
    strokes: list of strokes, each stroke is a list of points {x:, y:} where coordinates are in canvas space (0..w,0..h).
    We rasterize strokes to a white background and return PIL grayscale.
    """
    # Accept normalized coordinates if floats between 0..1
    W, H = size
    canvas = Image.new("L", (W, H), color=255)
    draw = ImageDraw.Draw(canvas)
    for stroke in strokes:
        if not stroke:
            continue
        # convert to tuple list
        pts = []
        for p in stroke:
            x = p.get("x", 0)
            y = p.get("y", 0)
            # if coordinates look normalized (0..1), scale to image
            if 0.0 <= x <= 1.0 and 0.0 <= y <= 1.0:
                pts.append((x * W, y * H))
            else:
                pts.append((x, y))
        if len(pts) == 1:
            # draw small dot
            x, y = pts[0]
            draw.ellipse((x- stroke_width/2, y-stroke_width/2, x+stroke_width/2, y+stroke_width/2), fill=0)
        else:
            draw.line(pts, fill=0, width=stroke_width, joint="round")
    return canvas

def preprocess_pil_image(pil_img: Image.Image, size=(128,128)) -> np.ndarray:
    """
    Auto-crop to content, keep aspect, pad, invert so glyph is white-on-black, normalize [0,1].
    Returns shape (h,w,1)
    """
    arr = np.array(pil_img)
    # threshold to find content (dark strokes)
    _, thr = cv2.threshold(arr, 250, 255, cv2.THRESH_BINARY_INV)
    coords = cv2.findNonZero(thr)
    if coords is not None:
        x, y, w, h = cv2.boundingRect(coords)
        cropped = arr[y:y+h, x:x+w]
    else:
        cropped = arr
    # resize preserving aspect
    target_h, target_w = size
    h0, w0 = cropped.shape
    if h0 == 0 or w0 == 0:
        resized = cv2.resize(arr, (target_w, target_h))
    else:
        scale = min(target_w / w0, target_h / h0)
        new_w, new_h = max(1, int(w0 * scale)), max(1, int(h0 * scale))
        resized = cv2.resize(cropped, (new_w, new_h), interpolation=cv2.INTER_AREA)
        # pad to target
        top = (target_h - new_h) // 2
        left = (target_w - new_w) // 2
        canvas = np.full((target_h, target_w), 255, dtype=np.uint8)
        canvas[top:top+new_h, left:left+new_w] = resized
        resized = canvas
    # invert so strokes are white (1.0)
    resized = 255 - resized
    resized = resized.astype("float32") / 255.0
    resized = np.expand_dims(resized, -1)
    return resized

def prepare_from_data_uri(data_uri: str, size=(128,128)) -> np.ndarray:
    pil = data_uri_to_pil(data_uri)
    return preprocess_pil_image(pil, size=size)

def prepare_from_stroke_json(stroke_json, size=(128,128), stroke_width=10) -> np.ndarray:
    # stroke_json can be a list-of-strokes or JSON string
    if isinstance(stroke_json, str):
        strokes = json.loads(stroke_json)
    else:
        strokes = stroke_json
    pil = strokes_to_image(strokes, size=size, stroke_width=stroke_width)
    return preprocess_pil_image(pil, size=size)

def predict_from_array(x: np.ndarray) -> Dict:
    """
    x: preprocessed single sample shape (h,w,1) or batch shape (n,h,w,1)
    Returns: {label, confidence, raw_probs, predicted_index}
    """
    model, classes = load_model()
    if x.ndim == 3:
        x = np.expand_dims(x, 0)
    preds = model.predict(x)
    probs = preds[0]
    idx = int(np.argmax(probs))
    confidence = float(probs[idx])
    label = classes[idx] if classes and idx < len(classes) else str(idx)
    return {"label": label, "confidence": confidence, "predicted_index": idx, "raw_probs": probs.tolist()}

def predict_from_data_uri(data_uri: str) -> Dict:
    arr = prepare_from_data_uri(data_uri)
    return predict_from_array(arr)

def predict_from_strokes(stroke_json) -> Dict:
    arr = prepare_from_stroke_json(stroke_json)
    return predict_from_array(arr)