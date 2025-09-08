# # from db import get_db_connection

# # def list_owner_codes():
# #     conn = get_db_connection()
# #     cursor = conn.cursor()
# #     rows = cursor.execute("SELECT * FROM owner_codes").fetchall()
# #     conn.close()
# #     if not rows:
# #         print("No owner codes found in the database.")
# #     else:
# #         for r in rows:
# #             print(dict(r))

# # if __name__ == "__main__":
# #     list_owner_codes()

# # import sqlite3tho

# # conn = sqlite3.connect('tabletap.db')
# # cursor = conn.cursor()

# # order_id = 4  # Replace with the order id you want to check

# # cursor.execute("SELECT id, status FROM orders WHERE id = ?", (order_id,))
# # order = cursor.fetchone()

# # if order:
# #     print(f"Order ID: {order[0]}, Status: {order[1]}")
# # else:
# #     print("Order not found")

# # conn.close()

# # from flask import request

# import sqlite3

# conn = sqlite3.connect("tabletap.db")
# cursor = conn.cursor()

# # Update staff id 2 to inactive
# cursor.execute("UPDATE staff SET is_activated = 0 WHERE id = 2")
# conn.commit()

# # Check result
# cursor.execute("SELECT id, name, is_activated FROM staff")
# for row in cursor.fetchall():
#     print(row)

# conn.close()



# import sqlite3

# # Path to your SQLite database
# DB_PATH = "tabletap.db"   # change if needed

# # The old ngrok prefix we want to remove
# OLD_PREFIX = "https://8ea543ecfec7.ngrok-free.app/static/images/"

# def fix_image_urls():
#     conn = sqlite3.connect(DB_PATH)
#     cursor = conn.cursor()

#     # Show before update (optional)
#     print("Before fix:")
#     rows = cursor.execute("SELECT id, name, image_url FROM menu WHERE image_url LIKE ?", (f"{OLD_PREFIX}%",)).fetchall()
#     for r in rows:
#         print(r)

#     # Update rows that still have old prefix
#     cursor.execute("""
#         UPDATE menu
#         SET image_url = REPLACE(image_url, ?, '')
#         WHERE image_url LIKE ?;
#     """, (OLD_PREFIX, f"{OLD_PREFIX}%"))

#     conn.commit()
#     print(f"\n{cursor.rowcount} rows updated.\n")

#     # Show after update (optional)
#     print("After fix:")
#     rows = cursor.execute("SELECT id, name, image_url FROM menu WHERE image_url NOT LIKE ?", (f"{OLD_PREFIX}%",)).fetchall()
#     for r in rows:
#         print(r)

#     conn.close()

import sqlite3

conn = sqlite3.connect("tabletap.db")  # ✅ use the same DB as init_db
cursor = conn.cursor()

# Strip old ngrok URLs, keep only filename
cursor.execute("""
    UPDATE menu
    SET image_url = substr(image_url, instr(image_url, '/static/images/') + length('/static/images/'))
    WHERE image_url LIKE '%/static/images/%';
""")

conn.commit()
conn.close()

print("✅ Image URLs cleaned to filenames only")


# import sqlite3

# # Path to your SQLite database
# db_path = 'tabletap.db'  # Replace with actual path

# # Email of the staff you want to check
# staff_email = 'kumarirekha6465@gmail.com'  # Replace with the staff's email

# # Connect to the database
# conn = sqlite3.connect(db_path)
# cursor = conn.cursor()

# # Query the staff
# cursor.execute("SELECT name, email, role FROM staff WHERE email = ?", (staff_email,))
# staff = cursor.fetchone()

# if staff:
#     name, email, role = staff
#     print(f"Staff Found:\n Name: {name}\n Email: {email}\n Role: {role}")
#     if role.strip().lower() == 'waiter':
#         print("✅ Staff is a waiter.")
#     else:
#         print(f"⚠ Staff role is '{role}', not a waiter.")
# else:
#     print("❌ Staff not found in the database.")

# # Close connection
# conn.close()

