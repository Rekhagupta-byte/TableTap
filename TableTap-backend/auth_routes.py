import sqlite3
from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from flask_mail import Message
import random
from db import get_db_connection

auth_bp = Blueprint('auth', __name__)
mail = None  # Will be set from app.py

def set_mail(mail_instance):
    global mail
    mail = mail_instance

# ------------------ OTP ------------------
@auth_bp.route('/send-otp', methods=['POST'])
def send_otp():
    data = request.get_json()
    email = data.get('email')

    if not email:
        return jsonify({"success": False, "message": "Email is required"}), 400

    otp = str(random.randint(100000, 999999))

    conn = get_db_connection()
    conn.execute("DELETE FROM otps WHERE email = ?", (email,))
    conn.execute("INSERT INTO otps (email, otp) VALUES (?, ?)", (email, otp))
    conn.commit()
    conn.close()

    # Send OTP email
    msg = Message('TableTap OTP Verification', recipients=[email])
    msg.body = f'Your OTP is {otp}'
    mail.send(msg)

    return jsonify({"success": True, "message": "OTP sent successfully"})

@auth_bp.route('/verify-otp', methods=['POST'])
def verify_otp():
    data = request.get_json()
    email = data.get('email')
    otp = data.get('otp')

    if not email or not otp:
        return jsonify({"success": False, "message": "Email and OTP are required"}), 400

    conn = get_db_connection()
    stored_otp = conn.execute("SELECT otp FROM otps WHERE email = ?", (email,)).fetchone()

    if not stored_otp or stored_otp['otp'] != otp:
        conn.close()
        return jsonify({"success": False, "message": "Invalid OTP"}), 400

    # OTP verified, remove it
    conn.execute("DELETE FROM otps WHERE email = ?", (email,))
    conn.commit()
    conn.close()

    return jsonify({"success": True, "message": "OTP Verified"})

# ------------------ Signup ------------------
@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    name = data.get('name', '').strip()
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')
    role = data.get('role', '').strip().lower()
    secret_code = data.get('secret_code', '').strip()

    if not name or not email or not password or not role:
        return jsonify(success=False, message="Missing required fields"), 400
    if len(password) < 6:
        return jsonify(success=False, message="Password must be at least 6 characters"), 400
    if role not in ['owner', 'staff']:
        return jsonify(success=False, message="Invalid role"), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        password_hash = generate_password_hash(password)

        if role == 'owner':
            # Check if owner exists
            cursor.execute("SELECT id FROM owner WHERE email = ?", (email,))
            if cursor.fetchone():
                return jsonify(success=False, message="Email already registered"), 409

            # Verify owner secret code
            cursor.execute(
                "SELECT id, used FROM owner_codes WHERE email = ? AND secret_code = ?",
                (email, secret_code)
            )
            code_row = cursor.fetchone()
            if not code_row:
                return jsonify(success=False, message="Invalid secret code for owner"), 401
            if code_row['used'] == 1:
                return jsonify(success=False, message="Secret code already used"), 401

            cursor.execute("UPDATE owner_codes SET used = 1 WHERE id = ?", (code_row['id'],))
            cursor.execute(
                "INSERT INTO owner (name, email, password_hash) VALUES (?, ?, ?)",
                (name, email, password_hash)
            )

        elif role == 'staff':
            cursor.execute("SELECT id FROM staff WHERE email = ?", (email,))
            if cursor.fetchone():
                return jsonify(success=False, message="Email already registered"), 409

            # Insert staff with is_activated=0
            cursor.execute(
                "INSERT INTO staff (name, email, role, password, is_activated) VALUES (?, ?, ?, ?, 0)",
                (name, email, 'staff', password_hash)
            )

        conn.commit()
        return jsonify(success=True, message="Signup successful"), 201

    except Exception as e:
        print("Signup error:", e)
        return jsonify(success=False, message="Internal server error"), 500

    finally:
        conn.close()

# ------------------ Login ------------------
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get("email", "").strip()
    password = data.get("password", "")

    if not email or not password:
        return jsonify({"success": False, "message": "Email and password are required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    # Owner login
    user = cursor.execute("SELECT * FROM owner WHERE email = ?", (email,)).fetchone()
    if user and check_password_hash(user["password_hash"], password):
        conn.close()
        return jsonify({
            "success": True,
            "message": "Login successful",
            "user": {
                "email": user["email"],
                "role": "owner",
                "name": user["name"]
            }
        }), 200

    # Staff login
    staff = cursor.execute("SELECT * FROM staff WHERE email = ?", (email,)).fetchone()
    if staff and check_password_hash(staff["password"], password):
        conn.close()
        return jsonify({
            "success": True,
            "message": "Login successful",
            "user": {
                "email": staff["email"],
                "role": "staff",
                "name": staff["name"]
            },
            "is_activated": staff["is_activated"]  # <- forced password change flag
        }), 200

    conn.close()
    return jsonify({"success": False, "message": "User not found or invalid password"}), 404



# ------------------ Tables & Menu ------------------
@auth_bp.route("/table/<int:table_number>", methods=["GET"])
def get_table_info(table_number):
    conn = get_db_connection()
    table = conn.execute("SELECT * FROM tables WHERE table_number = ?", (table_number,)).fetchone()
    conn.close()

    if table:
        return jsonify({
            "success": True,
            "table_number": table["table_number"],
            "status": table["status"]
        }), 200
    return jsonify({"success": False, "message": "Table not found"}), 404

@auth_bp.route("/menu")
def menu():
    conn = get_db_connection()
    items = conn.execute("SELECT * FROM menu").fetchall()
    conn.close()
    return jsonify([dict(item) for item in items])

@auth_bp.route('/menu', methods=['POST'])
def add_menu_item():
    data = request.get_json()
    name = data.get('name')
    price = data.get('price')
    category = data.get('category')
    image_url = data.get('image_url', '')

    if not name or price is None or not category:
        return jsonify({"message": "Missing required fields"}), 400

    try:
        conn = get_db_connection()
        conn.execute(
            "INSERT INTO menu (name, price, category, image_url) VALUES (?, ?, ?, ?)",
            (name, price, category, image_url)
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Item added successfully"}), 201
    except Exception as e:
        return jsonify({"message": "Error adding item", "error": str(e)}), 500

@auth_bp.route('/menu/<int:item_id>', methods=['PUT'])
def update_menu_item(item_id):
    data = request.get_json()
    name = data.get('name')
    price = data.get('price')
    category = data.get('category')
    image_url = data.get('image_url', '')

    if not name or price is None or not category:
        return jsonify({"message": "Missing required fields"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE menu SET name=?, price=?, category=?, image_url=? WHERE id=?",
        (name, price, category, image_url, item_id)
    )
    conn.commit()
    updated = cursor.rowcount
    conn.close()

    if updated == 0:
        return jsonify({"message": "Menu item not found"}), 404
    return jsonify({"message": "Menu item updated successfully"}), 200
