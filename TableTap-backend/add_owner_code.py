# add_owner_codes.py
from db import get_db_connection

def add_owner_code(email, code):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('INSERT OR IGNORE INTO owner_codes (email, secret_code) VALUES (?, ?)', (email, code))
    conn.commit()
    conn.close()

# Add owner secret codes here
add_owner_code('kumarirekha6465@gmail.com', 'CODE1234')
add_owner_code('ruchin.org@gmail.com', 'banana')

print("Owner codes added successfully.")
