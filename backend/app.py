# backend/app.py
from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy import text
from datetime import datetime, timezone, timedelta
from werkzeug.utils import secure_filename
import hashlib
import sys
import os
import random

# Timezone setup for Asia/Manila (UTC+8)
MANILA_TZ = timezone(timedelta(hours=8))

def get_manila_time():
    """Get current time in Manila timezone (UTC+8)"""
    return datetime.now(MANILA_TZ)

def utc_to_manila(utc_dt):
    """Convert UTC datetime to Manila timezone"""
    if utc_dt is None:
        return None
    if utc_dt.tzinfo is None:
        utc_dt = utc_dt.replace(tzinfo=timezone.utc)
    return utc_dt.astimezone(MANILA_TZ)

# ensure backend folder on sys.path so local modules can be imported
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Use Gemini client (Google Generative AI)
from gemini_client import ask_gemini

app = Flask(__name__)
app.secret_key = "raindayaw"
CORS(app)

# ✅ MySQL connection
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+mysqlconnector://root:@localhost/dayaw"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# ✅ File Upload Configuration
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
MAX_FILE_SIZE = 16 * 1024 * 1024  # 16MB

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

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
    """Filipino Trivia - 24-hour rotation"""
    __tablename__ = "alaala"
    id = db.Column(db.Integer, primary_key=True)
    alammoba = db.Column(db.String(255), nullable=False)  # Title
    deskription = db.Column(db.Text, nullable=False)  # Description


class Salita(db.Model):
    """Word of the Day - 24-hour rotation"""
    __tablename__ = "salita"
    id = db.Column(db.Integer, primary_key=True)
    salita = db.Column(db.String(255), nullable=False)  # The word
    depinisyon = db.Column(db.Text, nullable=False)  # Definition
    bigkas = db.Column(db.String(255))  # Pronunciation
    etimolohiya = db.Column(db.Text)  # Etymology
    gamit = db.Column(db.Text)  # Usage example
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)


class ChatHistory(db.Model):
    __tablename__ = "chat_history"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False)
    user_message = db.Column(db.Text, nullable=False)
    ai_response = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)


class ChatThread(db.Model):
    __tablename__ = "chat_threads"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False)
    title = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class Post(db.Model):
    """Community Feed Posts"""
    __tablename__ = "posts"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False)
    profile_image = db.Column(db.String(500))
    title = db.Column(db.String(500))  # Changed from 255 to 500 to match DB
    content = db.Column(db.Text, nullable=False)
    image_url = db.Column(db.String(500))
    video_url = db.Column(db.String(500))
    likes_count = db.Column(db.Integer, default=0)
    comments_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)


class PostLike(db.Model):
    """Likes on Community Feed Posts"""
    __tablename__ = "post_likes"
    id = db.Column(db.Integer, primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.id', ondelete='CASCADE'), nullable=False)
    username = db.Column(db.String(50), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    
    __table_args__ = (db.UniqueConstraint('post_id', 'username', name='unique_post_like'),)


class PostComment(db.Model):
    """Comments on Community Feed Posts"""
    __tablename__ = "post_comments"
    id = db.Column(db.Integer, primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.id', ondelete='CASCADE'), nullable=False)
    username = db.Column(db.String(50), nullable=False)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

# ===================================================
# HELPER FUNCTIONS
# ===================================================

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_trivia_index_for_today():
    """Calculate which trivia to show based on current date in Manila timezone (24-hour rotation)"""
    total_items = Alaala.query.count()
    if total_items == 0:
        return None
    
    today = get_manila_time().date()
    days_since_epoch = (today - datetime(2000, 1, 1).date()).days
    trivia_index = days_since_epoch % total_items
    return trivia_index

def get_salita_index_for_today():
    """Calculate which Salita to show based on current date in Manila timezone (24-hour rotation)"""
    total_items = Salita.query.count()
    if total_items == 0:
        return None
    
    today = get_manila_time().date()
    days_since_epoch = (today - datetime(2000, 1, 1).date()).days
    salita_index = days_since_epoch % total_items
    return salita_index

# ===================================================
# ROUTES
# ===================================================

# ----------------------
# AUTH ROUTES
# ----------------------
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
        new_user = SignUp(username=username, email=email, password=hashed_password, confirm_password=hashed_password)
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


# ----------------------
# SYSTEM ROUTES
# ----------------------
@app.route("/api/db-ping", methods=["GET"])
def db_ping():
    try:
        db.session.execute(text("SELECT 1"))
        return jsonify({"ok": True, "message": "Database connection successful"})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500


# ----------------------
# CHAT ROUTES (now using Gemini)
# ----------------------
@app.route("/api/ask", methods=["POST"])
def ask_gemini_endpoint():
    """Send a question to Gemini (Google Generative AI) and save conversation history."""
    try:
        data = request.get_json() or {}
        question = data.get("question")
        username = data.get("username", "anonymous")

        if not question:
            return jsonify({"error": "Question is required"}), 400

        # call Gemini wrapper
        answer = ask_gemini(question)

        # Save to chat history
        chat_entry = ChatHistory(
            username=username,
            user_message=question,
            ai_response=answer,
            created_at=datetime.utcnow()
        )
        db.session.add(chat_entry)
        db.session.commit()

        return jsonify({
            "success": True,
            "question": question,
            "answer": answer,
            "chat_id": chat_entry.id,
            "timestamp": chat_entry.created_at.isoformat()
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


@app.route("/api/gemini-status", methods=["GET"])
def gemini_status():
    """
    Returns simple diagnostics about the Gemini client and environment.
    Useful to check whether GOOGLE_API_KEY is seen by the Flask process.
    """
    from gemini_client import _configure_client  # runtime import to use inner helper
    configured, reason = _configure_client()
    return jsonify({
        "gemini_sdk_installed": True if 'google' in globals() or configured else (False),
        "configured": configured,
        "reason": reason,
        "GOOGLE_API_KEY_present": bool(os.getenv("GOOGLE_API_KEY") or os.environ.get("GOOGLE_API_KEY"))
    }), 200


@app.route("/api/chat-history", methods=["GET"])
def get_chat_history():
    """Retrieve chat history for a user."""
    try:
        username = request.args.get("username", "anonymous")
        limit = request.args.get("limit", 50, type=int)
        chats = ChatHistory.query.filter_by(username=username).order_by(ChatHistory.created_at.desc()).limit(limit).all()
        chat_list = [{"id": chat.id, "user_message": chat.user_message, "ai_response": chat.ai_response, "created_at": chat.created_at.isoformat()} for chat in chats]
        return jsonify({"success": True, "username": username, "count": len(chat_list), "chats": chat_list}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/chat-history/<int:chat_id>", methods=["DELETE"])
def delete_chat(chat_id):
    """Delete a specific chat message."""
    try:
        chat = ChatHistory.query.get(chat_id)
        if not chat:
            return jsonify({"error": "Chat not found"}), 404
        db.session.delete(chat)
        db.session.commit()
        return jsonify({"success": True, "message": "Chat deleted"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


@app.route("/api/chat-threads", methods=["POST"])
def create_chat_thread():
    """Create a new chat thread (conversation)."""
    try:
        data = request.get_json() or {}
        username = data.get("username", "anonymous")
        title = data.get("title", "New Chat")
        thread = ChatThread(username=username, title=title, created_at=datetime.utcnow())
        db.session.add(thread)
        db.session.commit()
        return jsonify({"success": True, "thread_id": thread.id, "title": thread.title, "created_at": thread.created_at.isoformat()}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


@app.route("/api/chat-threads", methods=["GET"])
def get_chat_threads():
    """Get all chat threads for a user."""
    try:
        username = request.args.get("username", "anonymous")
        threads = ChatThread.query.filter_by(username=username).order_by(ChatThread.updated_at.desc()).all()
        thread_list = [{"id": thread.id, "title": thread.title, "created_at": thread.created_at.isoformat(), "updated_at": thread.updated_at.isoformat()} for thread in threads]
        return jsonify({"success": True, "threads": thread_list}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/chat-threads/<int:thread_id>", methods=["DELETE"])
def delete_chat_thread(thread_id):
    """Delete a chat thread and its associated messages."""
    try:
        thread = ChatThread.query.get(thread_id)
        if not thread:
            return jsonify({"error": "Thread not found"}), 404
        db.session.delete(thread)
        db.session.commit()
        return jsonify({"success": True, "message": "Thread deleted"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# ===========================
# ALAALA (24-HOUR TRIVIA)
# ===========================

@app.route("/api/alaala/today", methods=["GET"])
def get_alaala_today():
    """Get today's Alaala (trivia) - rotates every 24 hours."""
    try:
        trivia_index = get_trivia_index_for_today()
        if trivia_index is None:
            return jsonify({"success": False, "message": "Walang Alaala sa database."}), 404
        
        trivia = Alaala.query.offset(trivia_index).first()
        if not trivia:
            return jsonify({"success": False, "message": "Walang Alaala available."}), 404
        
        return jsonify({"success": True, "id": trivia.id, "alammoba": trivia.alammoba, "deskription": trivia.deskription}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/alaala/all", methods=["GET"])
def get_all_alaala():
    """Get all Alaala for browsing."""
    try:
        limit = request.args.get("limit", 100, type=int)
        trivias = Alaala.query.limit(limit).all()
        if not trivias:
            return jsonify({"success": False, "message": "Walang Alaala sa database."}), 404
        trivia_list = [{"id": trivia.id, "alammoba": trivia.alammoba, "deskription": trivia.deskription} for trivia in trivias]
        return jsonify({"success": True, "count": len(trivia_list), "trivias": trivia_list}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ===========================
# SALITA (WORD OF THE DAY)
# ===========================

@app.route("/api/salita/today", methods=["GET"])
def get_salita_today():
    """Get today's Salita (Word of the Day) - rotates every 24 hours."""
    try:
        salita_index = get_salita_index_for_today()
        if salita_index is None:
            return jsonify({"success": False, "message": "Walang Salita sa database."}), 404
        
        salita = Salita.query.offset(salita_index).first()
        if not salita:
            return jsonify({"success": False, "message": "Walang Salita available."}), 404
        
        return jsonify({
            "success": True,
            "id": salita.id,
            "salita": salita.salita,
            "depinisyon": salita.depinisyon,
            "bigkas": salita.bigkas,
            "etimolohiya": salita.etimolohiya,
            "gamit": salita.gamit
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/salita/all", methods=["GET"])
def get_all_salita():
    """Get all Salita for browsing."""
    try:
        limit = request.args.get("limit", 100, type=int)
        salitas = Salita.query.limit(limit).all()
        if not salitas:
            return jsonify({"success": False, "message": "Walang Salita sa database."}), 404
        salita_list = [{"id": s.id, "salita": s.salita, "depinisyon": s.depinisyon, "bigkas": s.bigkas, "etimolohiya": s.etimolohiya, "gamit": s.gamit} for s in salitas]
        return jsonify({"success": True, "count": len(salita_list), "salitas": salita_list}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ===================================================
# POST ROUTES (COMMUNITY FEED)
# ===================================================

@app.route("/api/posts", methods=["GET"])
def get_posts():
    """Get all posts for the feed."""
    try:
        username = request.args.get("username", "").strip()
        posts = Post.query.order_by(Post.created_at.desc()).all()
        
        # Get user's likes if username provided
        user_likes = set()
        if username:
            likes = PostLike.query.filter_by(username=username).all()
            user_likes = {like.post_id for like in likes}
        
        posts_list = [{
            "id": p.id,
            "username": p.username,
            "profile_image": p.profile_image,
            "title": p.title,
            "content": p.content,
            "image_url": p.image_url,
            "likes_count": p.likes_count,
            "comments_count": p.comments_count,
            "created_at": utc_to_manila(p.created_at).isoformat() if p.created_at else None,
            "is_liked": p.id in user_likes
        } for p in posts]
        return jsonify(posts_list), 200
    except Exception as e:
        print(f"[ERROR] Error fetching posts: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route("/api/posts", methods=["POST"])
def create_post():
    """Create a new post."""
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data:
            print("[ERROR] No JSON data received")
            return jsonify({"error": "No data provided"}), 400
        
        username = data.get("username", "").strip()
        content = data.get("content", "").strip()
        
        if not username:
            print("[ERROR] Username is required")
            return jsonify({"error": "Username is required"}), 400
        
        if not content:
            print("[ERROR] Content is required")
            return jsonify({"error": "Content is required"}), 400
        
        print(f"[INFO] Creating post - Username: {username}, Content length: {len(content)}")
        
        # Create new post WITHOUT user_id
        new_post = Post(
            username=username,
            profile_image=data.get("profile_image"),
            title=data.get("title", "").strip() or None,
            content=content,
            image_url=data.get("image_url"),
            likes_count=0,
            comments_count=0
        )
        
        db.session.add(new_post)
        db.session.commit()
        
        print(f"[SUCCESS] Post created with ID: {new_post.id}")
        
        return jsonify({
            "id": new_post.id,
            "username": new_post.username,
            "profile_image": new_post.profile_image,
            "title": new_post.title,
            "content": new_post.content,
            "image_url": new_post.image_url,
            "likes_count": new_post.likes_count,
            "comments_count": new_post.comments_count,
            "created_at": utc_to_manila(new_post.created_at).isoformat() if new_post.created_at else None
        }), 201
    except Exception as e:
        db.session.rollback()
        print(f"[ERROR] Exception creating post: {str(e)}")
        import traceback
        traceback.print_exc()  # Print full traceback for debugging
        return jsonify({"error": f"Failed to create post: {str(e)}"}), 500
    

@app.route("/api/posts/<int:post_id>", methods=["DELETE"])
def delete_post(post_id):
    """Delete a post by ID.
    
    Note: This endpoint should implement user authentication and authorization
    to ensure users can only delete their own posts. Current implementation
    allows any user to delete any post, which is a security risk in production.
    """
    try:
        post = Post.query.get(post_id)
        if not post:
            return jsonify({"error": "Post not found"}), 404
        
        # TODO: Add authentication check here
        # Example: if post.username != authenticated_user:
        #     return jsonify({"error": "Unauthorized"}), 403
        
        db.session.delete(post)
        db.session.commit()
        
        return jsonify({"success": True, "message": "Post deleted"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# ===================================================
# POST LIKE/COMMENT ROUTES (COMMUNITY FEED)
# ===================================================

@app.route("/api/posts/<int:post_id>/like", methods=["POST"])
def toggle_like(post_id):
    """Toggle like on a post (like/unlike)."""
    try:
        data = request.get_json() or {}
        username = data.get("username", "").strip()
        
        if not username:
            return jsonify({"error": "Username is required"}), 400
        
        post = Post.query.get(post_id)
        if not post:
            return jsonify({"error": "Post not found"}), 404
        
        # Check if user already liked the post
        existing_like = PostLike.query.filter_by(post_id=post_id, username=username).first()
        
        if existing_like:
            # Unlike: Remove the like
            db.session.delete(existing_like)
            post.likes_count = max(0, post.likes_count - 1)
            db.session.commit()
            return jsonify({
                "success": True,
                "liked": False,
                "likes_count": post.likes_count
            }), 200
        else:
            # Like: Add the like
            new_like = PostLike(post_id=post_id, username=username)
            db.session.add(new_like)
            post.likes_count = post.likes_count + 1
            db.session.commit()
            return jsonify({
                "success": True,
                "liked": True,
                "likes_count": post.likes_count
            }), 200
    except Exception as e:
        db.session.rollback()
        print(f"[ERROR] Error toggling like: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route("/api/posts/<int:post_id>/like/status", methods=["GET"])
def get_like_status(post_id):
    """Check if a user has liked a post."""
    try:
        username = request.args.get("username", "").strip()
        
        if not username:
            return jsonify({"error": "Username is required"}), 400
        
        post = Post.query.get(post_id)
        if not post:
            return jsonify({"error": "Post not found"}), 404
        
        existing_like = PostLike.query.filter_by(post_id=post_id, username=username).first()
        
        return jsonify({
            "success": True,
            "liked": existing_like is not None,
            "likes_count": post.likes_count
        }), 200
    except Exception as e:
        print(f"[ERROR] Error getting like status: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route("/api/posts/<int:post_id>/comments", methods=["GET"])
def get_comments(post_id):
    """Get all comments for a post."""
    try:
        post = Post.query.get(post_id)
        if not post:
            return jsonify({"error": "Post not found"}), 404
        
        comments = PostComment.query.filter_by(post_id=post_id).order_by(PostComment.created_at.asc()).all()
        comments_list = [{
            "id": c.id,
            "post_id": c.post_id,
            "username": c.username,
            "content": c.content,
            "created_at": utc_to_manila(c.created_at).isoformat() if c.created_at else None
        } for c in comments]
        
        return jsonify({
            "success": True,
            "comments": comments_list,
            "count": len(comments_list)
        }), 200
    except Exception as e:
        print(f"[ERROR] Error fetching comments: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route("/api/posts/<int:post_id>/comments", methods=["POST"])
def create_comment(post_id):
    """Add a comment to a post."""
    try:
        data = request.get_json() or {}
        username = data.get("username", "").strip()
        content = data.get("content", "").strip()
        
        if not username:
            return jsonify({"error": "Username is required"}), 400
        
        if not content:
            return jsonify({"error": "Comment content is required"}), 400
        
        post = Post.query.get(post_id)
        if not post:
            return jsonify({"error": "Post not found"}), 404
        
        new_comment = PostComment(
            post_id=post_id,
            username=username,
            content=content
        )
        db.session.add(new_comment)
        post.comments_count = post.comments_count + 1
        db.session.commit()
        
        return jsonify({
            "success": True,
            "comment": {
                "id": new_comment.id,
                "post_id": new_comment.post_id,
                "username": new_comment.username,
                "content": new_comment.content,
                "created_at": utc_to_manila(new_comment.created_at).isoformat() if new_comment.created_at else None
            },
            "comments_count": post.comments_count
        }), 201
    except Exception as e:
        db.session.rollback()
        print(f"[ERROR] Error creating comment: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route("/api/posts/<int:post_id>/comments/<int:comment_id>", methods=["DELETE"])
def delete_comment(post_id, comment_id):
    """Delete a comment from a post."""
    try:
        comment = PostComment.query.filter_by(id=comment_id, post_id=post_id).first()
        if not comment:
            return jsonify({"error": "Comment not found"}), 404
        
        post = Post.query.get(post_id)
        if post:
            post.comments_count = max(0, post.comments_count - 1)
        
        db.session.delete(comment)
        db.session.commit()
        
        return jsonify({
            "success": True,
            "message": "Comment deleted",
            "comments_count": post.comments_count if post else 0
        }), 200
    except Exception as e:
        db.session.rollback()
        print(f"[ERROR] Error deleting comment: {str(e)}")
        return jsonify({"error": str(e)}), 500


# ===================================================
# FILE UPLOAD ROUTES (COMMUNITY FEED)
# ===================================================

@app.route("/api/upload", methods=["POST"])
def upload_image():
    """Upload image file for posts and return URL."""
    try:
        # Check if file is in request
        if 'file' not in request.files:
            print("[ERROR] No file provided in request")
            return jsonify({"success": False, "error": "No file provided"}), 400
        
        file = request.files['file']
        
        # Check if file has filename
        if file.filename == '':
            print("[ERROR] No file selected")
            return jsonify({"success": False, "error": "No file selected"}), 400
        
        # Check if file extension is allowed
        if not allowed_file(file.filename):
            print(f"[ERROR] File type not allowed: {file.filename}")
            return jsonify({
                "success": False,
                "error": f"File type not allowed. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
            }), 400
        
        # Check file size
        file.seek(0, os.SEEK_END)
        file_length = file.tell()
        file.seek(0)
        
        if file_length > MAX_FILE_SIZE:
            print(f"[ERROR] File too large: {file_length} bytes (max: {MAX_FILE_SIZE})")
            return jsonify({
                "success": False,
                "error": f"File too large. Maximum size is 16MB"
            }), 400
        
        # Create secure filename
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S_')
        filename = timestamp + filename
        
        # Save file
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Return image URL
        image_url = f"http://192.168.100.168:5000/uploads/{filename}"
        
        print(f"[SUCCESS] Image uploaded: {filename}")
        
        return jsonify({
            "success": True,
            "image_url": image_url,
            "filename": filename
        }), 200
    
    except Exception as e:
        print(f"[ERROR] Exception during file upload: {str(e)}")
        return jsonify({
            "success": False,
            "error": f"File upload failed: {str(e)}"
        }), 500


@app.route("/uploads/<filename>", methods=["GET"])
def serve_upload(filename):
    """Serve uploaded files."""
    try:
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename)
    except Exception as e:
        print(f"[ERROR] Error serving file {filename}: {str(e)}")
        return jsonify({"error": "File not found"}), 404


# ===================================================
# REGISTER BLUEPRINTS (SULATIN)
# ===================================================
from sulatin_routes import sulatin_bp
app.register_blueprint(sulatin_bp)

# ===================================================
# RUN / DB INIT HANDLER
# ===================================================
import argparse
from sqlalchemy import text as sa_text

def create_sulatin_tables_via_sql():
    """
    Create sulatin tables directly via raw SQL (avoids importing sulatin_routes
    during db init and prevents circular import issues).
    """
    # SQL for sulatin_samples and sulatin_attempts (MySQL syntax)
    sulatin_samples_sql = """
    CREATE TABLE IF NOT EXISTS sulatin_samples (
        id INT AUTO_INCREMENT PRIMARY KEY,
        label VARCHAR(100) NOT NULL,
        source VARCHAR(50) DEFAULT 'user',
        stroke_json JSON NULL,
        image_path VARCHAR(255) NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """
    sulatin_attempts_sql = """
    CREATE TABLE IF NOT EXISTS sulatin_attempts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(80),
        expected VARCHAR(100),
        predicted VARCHAR(100),
        confidence VARCHAR(50),
        correct TINYINT(1) DEFAULT 0,
        stroke_json JSON NULL,
        image_path VARCHAR(255) NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """
    conn = db.engine.connect()
    try:
        conn.execute(sa_text(sulatin_samples_sql))
        conn.execute(sa_text(sulatin_attempts_sql))
    finally:
        conn.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--init-db", action="store_true", help="Create DB tables (app models + sulatin tables) and exit")
    # parse only known args here so it doesn't interfere with Flask's own args
    args, _ = parser.parse_known_args()

    if args.init_db or os.environ.get("INIT_DB") == "1":
        # Create tables for models defined in this module (SignUp, Login, etc.)
        with app.app_context():
            print("Creating tables for models defined in app.py...")
            db.create_all()
            print("Creating sulatin tables (if not present)...")
            try:
                create_sulatin_tables_via_sql()
            except Exception as e:
                print("Warning: creating sulatin tables via SQL failed:", e)
            print("DB tables created. Exiting (init-db).")
        # Exit so the process does not continue to run the server
        sys.exit(0)

    # Normal run: start the Flask server
    app.run(host="0.0.0.0", port=5000, debug=True)