from flask import Blueprint, request, jsonify, current_app
from itsdangerous import URLSafeTimedSerializer
import hashlib
from sqlalchemy import text

auth_bp = Blueprint('auth_bp', __name__)

def hash_password(password):
    """Matches the SHA-256 hashing in app.py"""
    return hashlib.sha256(password.encode()).hexdigest()

# --- FORGOT PASSWORD ROUTE ---
@auth_bp.route('/api/forgot-password', methods=['POST'])
def forgot_password():
    from app import mail 
    data = request.get_json()
    email = data.get('email', '').strip()

    if not email:
        return jsonify({"success": False, "message": "Email is required"}), 400

    serializer = URLSafeTimedSerializer(current_app.config['SECRET_KEY'])
    token = serializer.dumps(email, salt='password-reset-salt')

    try:
        from flask_mail import Message
        msg = Message(
            "Dayaw Password Reset",
            sender=current_app.config['MAIL_USERNAME'],
            recipients=[email]
        )
        msg.body = f"Ang iyong reset token ay: {token}\n\nI-copy ito sa app para makapag-set ng bagong password."
        
        mail.send(msg)
        return jsonify({"success": True, "message": "Token sent to your email!"}), 200
    except Exception as e:
        print(f"MAIL ERROR: {e}")
        return jsonify({"success": False, "message": "Failed to send email"}), 500

# --- RESET PASSWORD COMPLETE ---
@auth_bp.route('/api/reset-password-complete', methods=['POST'])
def reset_password_complete():
    data = request.get_json()
    token = data.get('token', '').strip()
    new_password = data.get('password')

    if not token or not new_password:
        return jsonify({"success": False, "message": "Kulang ang data"}), 400

    serializer = URLSafeTimedSerializer(current_app.config['SECRET_KEY'])
    
    try:
        email = serializer.loads(token, salt='password-reset-salt', max_age=1800)
        hashed_pw = hash_password(new_password)
        db = current_app.extensions['sqlalchemy']
        
        query_signup = text("UPDATE sign_up SET password = :pw WHERE email = :email")
        query_login = text("UPDATE login SET password = :pw WHERE email = :email")
        
        db.session.execute(query_signup, {"pw": hashed_pw, "email": email})
        db.session.execute(query_login, {"pw": hashed_pw, "email": email})
        db.session.commit()

        return jsonify({"success": True, "message": "Password updated successfully!"}), 200
    except Exception as e:
        return jsonify({"success": False, "message": "Invalid or expired token"}), 400

@auth_bp.route('/api/google-login', methods=['POST'])
def google_login():
    data = request.get_json()
    email = data.get('email')
    username = data.get('displayName') # Google's name

    if not email:
        return jsonify({"success": False, "message": "Email is required from Google"}), 400

    db = current_app.extensions['sqlalchemy']

    # 1. Check if user exists in the login table
    query = text("SELECT username, email FROM login WHERE email = :email")
    user = db.session.execute(query, {"email": email}).first()

    if user:
        # User exists, log them in immediately
        return jsonify({
            "success": True,
            "message": "Logged in via Google",
            "username": user.username
        }), 200
    else:
        # 2. New User? Create an account for them automatically
        # Since they don't have a password, we can hash a random string or the email itself
        generated_password = hash_password(email + current_app.config['SECRET_KEY'])
        
        try:
            insert_signup = text("INSERT INTO sign_up (username, email, password) VALUES (:u, :e, :p)")
            insert_login = text("INSERT INTO login (username, email, password) VALUES (:u, :e, :p)")
            
            db.session.execute(insert_signup, {"u": username, "e": email, "p": generated_password})
            db.session.execute(insert_login, {"u": username, "e": email, "p": generated_password})
            db.session.commit()
            
            return jsonify({
                "success": True,
                "message": "New account created via Google",
                "username": username
            }), 201
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "message": "Could not create Google account"}), 500