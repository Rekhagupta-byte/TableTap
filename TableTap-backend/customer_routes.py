# customer_routes.py
from flask import Blueprint, request, jsonify
from db import get_db_connection
from datetime import datetime

customer_bp = Blueprint("customer", __name__)

# ---------------- Create a new order ----------------
@customer_bp.route("/order", methods=["POST"])
def create_order():
    """
    Expected JSON body:
    {
        "table_number": 5,
        "items": [
            {"menu_item_id": 1, "quantity": 2},
            {"menu_item_id": 3, "quantity": 1}
        ]
    }
    """
    data = request.get_json()
    table_number = data.get("table_number")
    items = data.get("items", [])

    if not table_number or not items:
        return jsonify({"success": False, "message": "Table number and items are required"}), 400

    total_price = 0
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Calculate total price
        for item in items:
            cursor.execute("SELECT price FROM menu WHERE id = ?", (item["menu_item_id"],))
            menu_item = cursor.fetchone()
            if menu_item:
                total_price += menu_item["price"] * item.get("quantity", 1)
            else:
                return jsonify({"success": False, "message": f"Menu item {item['menu_item_id']} not found"}), 404

        # Insert into orders
        cursor.execute(
            "INSERT INTO orders (table_number, total_price, status, created_at) VALUES (?, ?, 'pending', ?)",
            (table_number, total_price, datetime.now())
        )
        order_id = cursor.lastrowid

        # Insert into order_items
        for item in items:
            cursor.execute(
                "INSERT INTO order_items (order_id, menu_item_id, quantity, status) VALUES (?, ?, ?, 'pending')",
                (order_id, item["menu_item_id"], item.get("quantity", 1))
            )

        conn.commit()
        return jsonify({"success": True, "order_id": order_id, "total_price": total_price}), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        conn.close()

# ---------------- Get all orders ----------------
@customer_bp.route("/orders", methods=["GET"])
def get_orders():
    """
    Optionally filter by ?status=pending/in_kitchen/served
    """
    status = request.args.get("status")
    conn = get_db_connection()
    cursor = conn.cursor()

    if status:
        cursor.execute("SELECT * FROM orders WHERE status = ?", (status,))
    else:
        cursor.execute("SELECT * FROM orders")

    orders = cursor.fetchall()
    orders_list = []

    for order in orders:
        cursor.execute("""
            SELECT oi.id, oi.menu_item_id, m.name, oi.quantity, oi.status
            FROM order_items oi
            JOIN menu m ON oi.menu_item_id = m.id
            WHERE oi.order_id = ?
        """, (order["id"],))
        items = [dict(row) for row in cursor.fetchall()]
        orders_list.append({
            "id": order["id"],
            "table_number": order["table_number"],
            "total_price": order["total_price"],
            "status": order["status"],
            "created_at": order["created_at"],
            "items": items
        })

    conn.close()
    return jsonify({"orders": orders_list}), 200

# ---------------- Update order item status (for kitchen staff) ----------------
@customer_bp.route("/order_item/<int:item_id>/status", methods=["PUT"])
def update_order_item_status(item_id):
    """
    JSON body: {"status": "pending"/"preparing"/"served"}
    """
    data = request.get_json()
    new_status = data.get("status")
    if new_status not in ["pending", "preparing", "served"]:
        return jsonify({"success": False, "message": "Invalid status"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE order_items SET status = ? WHERE id = ?", (new_status, item_id))
    conn.commit()
    conn.close()
    return jsonify({"success": True, "message": f"Order item {item_id} updated to {new_status}"}), 200

# ---------------- Update entire order status ----------------
@customer_bp.route("/order/<int:order_id>/status", methods=["PUT"])
def update_order_status(order_id):
    """
    JSON body: {"status": "pending"/"in_kitchen"/"served"}
    """
    data = request.get_json()
    new_status = data.get("status")
    if new_status not in ["pending", "in_kitchen", "served"]:
        return jsonify({"success": False, "message": "Invalid status"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE orders SET status = ? WHERE id = ?", (new_status, order_id))
    conn.commit()
    conn.close()
    return jsonify({"success": True, "message": f"Order {order_id} updated to {new_status}"}), 200

# ---------------- Submit feedback ----------------
@customer_bp.route("/feedback", methods=["POST"])
def submit_feedback():
    """
    JSON body:
    {
        "table_number": 5,
        "feedback": "Great service!"
    }
    """
    data = request.get_json()
    table_number = data.get("table_number")
    feedback_text = data.get("feedback")

    if not table_number or not feedback_text:
        return jsonify({"success": False, "message": "Table number and feedback are required"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO feedback (table_number, feedback, created_at) VALUES (?, ?, ?)",
        (table_number, feedback_text, datetime.now())
    )
    conn.commit()
    conn.close()

    return jsonify({"success": True, "message": "Feedback submitted successfully"}), 201
