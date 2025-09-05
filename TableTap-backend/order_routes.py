from flask import Blueprint, request, jsonify
from db import get_db_connection
from datetime import datetime

order_bp = Blueprint("order", __name__)

# ---------------- Create a new order ----------------
@order_bp.route('/order', methods=['POST'])
def create_order():
    data = request.get_json()
    table_number = data.get("table_number")
    items = data.get("items", [])

    if not table_number or not items:
        return jsonify({"success": False, "message": "Table number and items are required"}), 400

    total_price = 0
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        for item in items:
            cursor.execute("SELECT price FROM menu WHERE id = ?", (item["menu_item_id"],))
            menu_item = cursor.fetchone()
            if menu_item:
                total_price += menu_item["price"] * item.get("quantity", 1)
            else:
                return jsonify({"success": False, "message": f"Menu item {item['menu_item_id']} not found"}), 404

        cursor.execute(
            "INSERT INTO orders (table_number, total_price, status, created_at) VALUES (?, ?, 'pending', ?)",
            (table_number, total_price, datetime.now())
        )
        order_id = cursor.lastrowid

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
@order_bp.route('/orders', methods=['GET'])
def get_orders():
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
        cursor.execute(
            "SELECT oi.id, oi.menu_item_id, m.name, oi.quantity, oi.status "
            "FROM order_items oi JOIN menu m ON oi.menu_item_id = m.id "
            "WHERE oi.order_id = ?", (order["id"],)
        )
        items = cursor.fetchall()

        # Convert items into readable strings like "Pizza x2"
        item_names = [f"{row['name']} x{row['quantity']}" for row in items]

        orders_list.append({
            "id": order["id"],
            "table": order["table_number"],
            "items": item_names,
            "total": order["total_price"],
            "status": order["status"],  # expected: pending/in_progress/completed
            "created_at": order["created_at"],
            "isNew": True if order["status"] == "pending" else False
        })

    conn.close()
    return jsonify(orders_list), 200



# ---------------- Update order item status ----------------
@order_bp.route('/order_item/<int:item_id>/status', methods=['PUT'])
def update_order_item_status(item_id):
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
@order_bp.route('/order/<int:order_id>/status', methods=['PUT'])
def update_order_status(order_id):
    data = request.get_json()
    new_status = data.get("status")
    if new_status not in ["pending", "in_progress", "completed"]:
        return jsonify({"success": False, "message": "Invalid status"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE orders SET status = ? WHERE id = ?", (new_status, order_id))
    conn.commit()
    conn.close()
    return jsonify({"success": True, "message": f"Order {order_id} updated to {new_status}"}), 200
