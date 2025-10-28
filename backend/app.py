# backend/app.py
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy import text
import hashlib
import sys
import os
import random
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from openai_client import ask_openai  # Optional for hybrid trivia

app = Flask(__name__)
app.secret_key = "raindayaw"
CORS(app)

# ✅ MySQL connection (update if needed)
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+mysqlconnector://root:@localhost/dayaw"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# ===================================================
# MODELS
# ===================================================

class SignUp(db.Model):
    __tablename__ = "sign_up"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100), nullable=False, unique=True)
    password = db.Column(db.String(255), nullable=False)
    confirm_password = db.Column(db.String(255), nullable=False)


class Login(db.Model):
    __tablename__ = "login"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    password = db.Column(db.String(255), nullable=False)


class Alaala(db.Model):
    __tablename__ = "alaala"
    id = db.Column(db.Integer, primary_key=True)
    salita = db.Column(db.String(255), nullable=False)
    depinisyon = db.Column(db.Text, nullable=False)
    bigkas = db.Column(db.String(255))
    etimolohiya = db.Column(db.Text)
    gamit = db.Column(db.Text)
    kontekstong_kultural = db.Column(db.Text)
    petsa = db.Column(db.DateTime)


# ===================================================
# HELPER FUNCTIONS
# ===================================================

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()


# ===================================================
# ROUTES
# ===================================================

# ------------------------------
# 🔹 AUTH ROUTES
# ------------------------------
@app.route("/api/signup", methods=["POST"])
def signup():
    try:
        data = request.get_json() or {}
        username = data.get("username")
        email = data.get("email")
        password = data.get("password")
        confirm_password = data.get("confirm_password")

        if not all([username, email, password, confirm_password]):
            return jsonify({"success": False, "message": "All fields are required!"}), 400

        if password != confirm_password:
            return jsonify({"success": False, "message": "Passwords do not match!"}), 400

        existing_user = SignUp.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({"success": False, "message": "Email already registered!"}), 400

        hashed_password = hash_password(password)

        new_user = SignUp(
            username=username,
            email=email,
            password=hashed_password,
            confirm_password=hashed_password
        )
        db.session.add(new_user)
        db.session.add(Login(username=username, email=email, password=hashed_password))
        db.session.commit()

        return jsonify({"success": True, "message": "User registered successfully!", "username": username}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/login", methods=["POST"])
def login():
    try:
        data = request.get_json()
        username = data.get("username")
        email = data.get("email")
        password = data.get("password")

        if not all([username, email, password]):
            return jsonify({"success": False, "message": "All fields are required!"}), 400

        hashed_password = hash_password(password)
        user = Login.query.filter_by(username=username, email=email, password=hashed_password).first()

        if user:
            return jsonify({"success": True, "username": user.username}), 200
        else:
            return jsonify({"success": False, "message": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"success": False, "message": f"Login failed: {str(e)}"}), 500


# ------------------------------
# 🔹 SYSTEM / DEBUG ROUTES
# ------------------------------
@app.route("/api/db-ping", methods=["GET"])
def db_ping():
    try:
        db.session.execute(text("SELECT 1"))
        return jsonify({"ok": True, "message": "Database connection successful"})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500


# ------------------------------
# 🔹 ALAALA (TRIVIA) ROUTES
# ------------------------------
@app.route("/api/trivia", methods=["GET"])
def get_random_trivia():
    """
    Fetch a random trivia (Alaala) from database.
    Optional: if no local trivia, call AI to generate one.
    """
    try:
        trivia_list = Alaala.query.all()
        if not trivia_list:
            # Optional: fallback if DB is empty (generate via AI)
            # ai_text = ask_openai("Give a short Filipino cultural trivia with definition, usage, and context.")
            return jsonify({"message": "Walang trivia sa database."}), 404

        trivia = random.choice(trivia_list)

        return jsonify({
            "id": trivia.id,
            "salita": trivia.salita,
            "depinisyon": trivia.depinisyon,
            "bigkas": trivia.bigkas,
            "etimolohiya": trivia.etimolohiya,
            "gamit": trivia.gamit,
            "kontekstong_kultural": trivia.kontekstong_kultural,
            "petsa": trivia.petsa.isoformat() if trivia.petsa else None
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/trivia", methods=["POST"])
def add_trivia():
    """Add a new trivia (used for seeding or AI saving)."""
    try:
        data = request.get_json() or {}
        trivia = Alaala(
            salita=data.get("salita"),
            depinisyon=data.get("depinisyon"),
            bigkas=data.get("bigkas"),
            etimolohiya=data.get("etimolohiya"),
            gamit=data.get("gamit"),
            kontekstong_kultural=data.get("kontekstong_kultural")
        )
        db.session.add(trivia)
        db.session.commit()
        return jsonify({"success": True, "message": "Trivia added!", "id": trivia.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# ===================================================
# RUN
# ===================================================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
