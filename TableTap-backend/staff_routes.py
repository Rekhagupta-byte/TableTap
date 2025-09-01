import sqlite3
import random
import string
from werkzeug.security import generate_password_hash
from flask import Blueprint, request, jsonify
from flask_mail import Message
from db import get_db_connection

mail = None

def set_mail(mail_instance):
    global mail
    mail = mail_instance

staff_bp = Blueprint('staff', __name__)

# ───── Helpers ─────
def generate_random_password(length=8):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))


# ───── Staff Routes ─────

# ➤ Add a new staff (without email invite)
@staff_bp.route('/staff', methods=['POST'])
def add_staff():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    role = data.get('role')
    phone = data.get('phone', '')

    if not name or not email or not role:
        return jsonify({"error": "Name, email, and role are required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO staff (name, email, role, phone) VALUES (?, ?, ?, ?)",
            (name, email, role, phone)
        )
        conn.commit()
        return jsonify({"message": "Staff added successfully"}), 201
    except sqlite3.IntegrityError:
        return jsonify({"error": "Email already exists"}), 400
    finally:
        conn.close()


# ➤ Get all staff
@staff_bp.route('/staff', methods=['GET'])
def get_staff():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM staff")
    staff_list = cursor.fetchall()
    conn.close()

    staff_data = []
    for row in staff_list:
        staff_data.append({
            "id": row["id"],
            "name": row["name"],
            "email": row["email"],
            "role": row["role"],
            "phone": row["phone"],
            "is_activated": row["is_activated"]
        })

    return jsonify({"staff": staff_data}), 200


# ➤ Update staff
@staff_bp.route('/staff/<int:staff_id>', methods=['PUT'])
def update_staff(staff_id):
    data = request.json
    name = data.get('name')
    role = data.get('role')
    phone = data.get('phone', '')

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE staff SET name = ?, role = ?, phone = ? WHERE id = ?",
        (name, role, phone, staff_id)
    )
    conn.commit()
    conn.close()
    return jsonify({"message": "Staff updated successfully"})


# ➤ Delete staff
@staff_bp.route('/staff/<int:staff_id>', methods=['DELETE'])
def delete_staff(staff_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM staff WHERE id = ?", (staff_id,))
    conn.commit()
    conn.close()
    return jsonify({"message": "Staff deleted successfully"})


# ➤ Invite staff (with default password & email)
@staff_bp.route('/invite', methods=['POST'])
def invite_staff():
    data = request.get_json()
    name = data.get("name")
    email = data.get("email")
    role = data.get("role")
    phone = data.get("phone", "")

    if not all([name, email, role]):
        return jsonify({"success": False, "message": "Missing fields"}), 400

    default_password = generate_random_password(8)
    hashed_password = generate_password_hash(default_password)

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO staff (name, email, role, phone, is_activated, password) VALUES (?, ?, ?, ?, ?, ?)",
            (name, email, role, phone, 1, hashed_password)
        )
        conn.commit()
        conn.close()

        # Send email with login details
        try:
            msg = Message(
                subject="TableTap Staff Invitation",
                recipients=[email],
                body=f"""
Hi {name},

You have been added as {role} in TableTap.

Your login details:
Email: {email}
Password: {default_password}

Please log in and change your password after first login.
"""
            )
            mail.send(msg)
            print(f"Email sent to {email}")
        except Exception as e:
            print("Email send error:", e)
            return jsonify({"success": False, "message": f"Email failed: {str(e)}"}), 500

        return jsonify({"success": True, "message": "Invite sent with default password"}), 200
    except sqlite3.IntegrityError:
        return jsonify({"success": False, "message": "Email already exists"}), 400
    

    # ------------------ Staff Change Password ------------------
@staff_bp.route('/staff/change-password', methods=['POST'])
def staff_change_password():
    data = request.get_json()
    email = data.get('email')
    new_password = data.get('new_password')

    if not email or not new_password:
        return jsonify({"success": False, "message": "Email and new password required"}), 400
    if len(new_password) < 6:
        return jsonify({"success": False, "message": "Password must be at least 6 characters"}), 400

    password_hash = generate_password_hash(new_password)
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE staff SET password=?, is_activated=1 WHERE email=?",
        (password_hash, email)
    )
    conn.commit()
    updated = cursor.rowcount
    conn.close()

    if updated == 0:
        return jsonify({"success": False, "message": "Staff not found"}), 404

    return jsonify({
        "success": True,
        "message": "Password changed successfully",
        "is_activated": 1
    }), 200
