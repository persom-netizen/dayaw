# backend/app.py
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy import text
import hashlib
import sys
import os
import random
from datetime import datetime
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from openai_client import ask_openai

app = Flask(__name__)
app.secret_key = "raindayaw"
CORS(app)

# ✅ MySQL connection
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


# ✅ NEW: Chat Models
class ChatSession(db.Model):
    __tablename__ = "chat_sessions"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False)
    title = db.Column(db.String(255), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class ChatMessage(db.Model):
    __tablename__ = "chat_messages"
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.Integer, db.ForeignKey('chat_sessions.id'), nullable=False)
    role = db.Column(db.String(10), nullable=False)  # 'user' or 'assistant'
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


# ===================================================
# HELPER FUNCTIONS
# ===================================================

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()


# ===================================================
# ROUTES
# ===================================================

# ✅ AUTH ROUTES
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


# ✅ SYSTEM / DEBUG ROUTES
@app.route("/api/db-ping", methods=["GET"])
def db_ping():
    try:
        db.session.execute(text("SELECT 1"))
        return jsonify({"ok": True, "message": "Database connection successful"})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500


# ✅ ALAALA (TRIVIA) ROUTES
@app.route("/api/trivia", methods=["GET"])
def get_random_trivia():
    try:
        trivia_list = Alaala.query.all()
        if not trivia_list:
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


# ✅ CHAT ROUTES (NEW)
@app.route("/api/chat/sessions", methods=["GET"])
def get_chat_sessions():
    """Get all chat sessions for a user."""
    try:
        username = request.args.get("username")
        if not username:
            return jsonify({"error": "Username required"}), 400

        sessions = ChatSession.query.filter_by(username=username).order_by(ChatSession.updated_at.desc()).all()
        
        return jsonify({
            "success": True,
            "sessions": [{
                "id": s.id,
                "title": s.title or f"Chat {s.id}",
                "created_at": s.created_at.isoformat(),
                "updated_at": s.updated_at.isoformat()
            } for s in sessions]
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/api/chat/sessions", methods=["POST"])
def create_chat_session():
    """Create a new chat session."""
    try:
        data = request.get_json() or {}
        username = data.get("username")
        
        if not username:
            return jsonify({"error": "Username required"}), 400

        new_session = ChatSession(username=username, title="New Chat")
        db.session.add(new_session)
        db.session.commit()

        return jsonify({
            "success": True,
            "session_id": new_session.id,
            "message": "Chat session created"
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/api/chat/sessions/<int:session_id>", methods=["DELETE"])
def delete_chat_session(session_id):
    """Delete a chat session and all its messages."""
    try:
        session = ChatSession.query.get(session_id)
        if not session:
            return jsonify({"success": False, "error": "Session not found"}), 404

        # Delete all messages in this session
        ChatMessage.query.filter_by(session_id=session_id).delete()
        db.session.delete(session)
        db.session.commit()

        return jsonify({"success": True, "message": "Chat session deleted"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/api/chat/messages/<int:session_id>", methods=["GET"])
def get_chat_messages(session_id):
    """Get all messages for a chat session."""
    try:
        messages = ChatMessage.query.filter_by(session_id=session_id).order_by(ChatMessage.created_at.asc()).all()
        
        return jsonify({
            "success": True,
            "messages": [{
                "id": m.id,
                "role": m.role,
                "content": m.content,
                "created_at": m.created_at.isoformat()
            } for m in messages]
        }), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/api/chat/send", methods=["POST"])
def send_chat_message():
    """Send a message and get AI response."""
    try:
        data = request.get_json() or {}
        session_id = data.get("session_id")
        user_message = data.get("message")
        
        if not session_id or not user_message:
            return jsonify({"success": False, "error": "Session ID and message required"}), 400

        # Verify session exists
        session = ChatSession.query.get(session_id)
        if not session:
            return jsonify({"success": False, "error": "Session not found"}), 404

        # Save user message
        user_msg = ChatMessage(session_id=session_id, role="user", content=user_message)
        db.session.add(user_msg)
        db.session.commit()

        # Get AI response (in Filipino)
        ai_prompt = f"You are a helpful assistant. Respond in Filipino language. User message: {user_message}"
        ai_response = ask_openai(ai_prompt)

        # Save AI response
        ai_msg = ChatMessage(session_id=session_id, role="assistant", content=ai_response)
        db.session.add(ai_msg)
        
        # Update session's updated_at timestamp
        session.updated_at = datetime.utcnow()
        db.session.commit()

        return jsonify({
            "success": True,
            "user_message": user_message,
            "ai_response": ai_response,
            "user_message_id": user_msg.id,
            "ai_message_id": ai_msg.id
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 500


# ===================================================
# RUN
# ===================================================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)