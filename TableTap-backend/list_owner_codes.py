from db import get_db_connection

def list_owner_codes():
    conn = get_db_connection()
    cursor = conn.cursor()
    rows = cursor.execute("SELECT * FROM owner_codes").fetchall()
    conn.close()
    if not rows:
        print("No owner codes found in the database.")
    else:
        for r in rows:
            print(dict(r))

if __name__ == "__main__":
    list_owner_codes()

# import sqlite3tho

# conn = sqlite3.connect('tabletap.db')
# cursor = conn.cursor()

# order_id = 4  # Replace with the order id you want to check

# cursor.execute("SELECT id, status FROM orders WHERE id = ?", (order_id,))
# order = cursor.fetchone()

# if order:
#     print(f"Order ID: {order[0]}, Status: {order[1]}")
# else:
#     print("Order not found")

# conn.close()

# from flask import request


