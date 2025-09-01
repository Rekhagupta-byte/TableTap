from flask import Blueprint, request, jsonify
from db import get_db_connection
from datetime import datetime
import json

customer_bp = Blueprint('customer', __name__)

# -----------------------
# Get Menu (Public)
# -----------------------
@customer_bp.route('/menu', methods=['GET'])
def get_menu():
    conn = get_db_connection()
    menu_items = conn.execute("""
        SELECT id, name, price, category, image_url
        FROM menu
    """).fetchall()
    conn.close()

    # Build base URL dynamically (e.g. http://192.168.0.245:5000)
    base_url = request.host_url.rstrip('/')

    menu_list = []
    for row in menu_items:
        image_url = row["image_url"] or ""
        # Ensure full URL
        if image_url and not image_url.startswith("http"):
            image_url = f"{base_url}/{image_url.lstrip('/')}"

        menu_list.append({
            "id": row["id"],
            "name": row["name"],
            "price": float(row["price"]),
            "category": row["category"],
            "image_url": image_url
        })

    return jsonify(menu_list), 200


# -----------------------
# Place Order
# -----------------------
@customer_bp.route('/place-order', methods=['POST'])
def place_order():
    try:
        data = request.json
        table_number = data.get('table_number')
        items = data.get('items')  # List of {id, name, price, quantity, image_url}
        total_price = data.get('total_price')

        if not items or not table_number:
            return jsonify({"error": "Missing table number or items"}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO orders (table_number, items, total_price, status, created_at)
            VALUES (?, ?, ?, ?, ?)
        """, (
            table_number,
            json.dumps(items),
            total_price,
            "Pending",
            datetime.now().isoformat()
        ))

        order_id = cursor.lastrowid
        conn.commit()
        conn.close()

        return jsonify({
            "message": "Order placed successfully",
            "order_id": order_id,
            "status": "Pending"
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -----------------------
# Get Last Order
# -----------------------
@customer_bp.route("/last-order", methods=["GET"])
def last_order():
    table_number = request.args.get("table_number")
    if not table_number:
        return jsonify({"success": False, "message": "table_number required"}), 400

    conn = get_db_connection()
    order = conn.execute(
        "SELECT * FROM orders WHERE table_number = ? ORDER BY created_at DESC LIMIT 1",
        (table_number,)
    ).fetchone()
    conn.close()

    if order:
        return jsonify(dict(order)), 200
    else:
        return jsonify({"success": False, "message": "No orders found"}), 404


@customer_bp.route("/order-status/<int:order_id>", methods=["GET"])
def order_status(order_id):
    conn = get_db_connection()
    order = conn.execute("SELECT * FROM orders WHERE id = ?", (order_id,)).fetchone()
    conn.close()

    if order:
        return jsonify({"status": order["status"]}), 200
    else:
        return jsonify({"success": False, "message": "Order not found"}), 404



# -----------------------
# Submit Feedback
# -----------------------
@customer_bp.route('/feedback', methods=['POST'])
def submit_feedback():
    data = request.json
    table_number = data.get('table_number')
    feedback_text = data.get('feedback')

    if not table_number or not feedback_text:
        return jsonify({"error": "Missing table number or feedback"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO feedback (table_number, feedback, created_at)
        VALUES (?, ?, ?)
    """, (
        table_number,
        feedback_text,
        datetime.now().isoformat()
    ))
    conn.commit()
    conn.close()

    return jsonify({"message": "Feedback submitted successfully"}), 201


# -----------------------
# Cancel Order
# -----------------------
@customer_bp.route('/cancel-order/<int:order_id>', methods=['POST'])
def cancel_order(order_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    # Check if order exists
    order = cursor.execute("SELECT status FROM orders WHERE id = ?", (order_id,)).fetchone()
    if not order:
        conn.close()
        return jsonify({"error": "Order not found"}), 404

    # Only allow cancel if not completed or ready
    if order["status"].lower() in ["completed", "ready"]:
        conn.close()
        return jsonify({"error": "Cannot cancel a completed order"}), 400

    cursor.execute("UPDATE orders SET status = ? WHERE id = ?", ("Cancelled", order_id))
    conn.commit()
    conn.close()

    return jsonify({"message": "Order cancelled successfully"}), 200
