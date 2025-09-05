import sqlite3

def get_db_connection():
    conn = sqlite3.connect('tabletap.db', timeout=10)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("PRAGMA foreign_keys = ON")

    # ---------------- Owners ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS owner (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL
    )
    ''')

    # ---------------- OTPs ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS otps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        otp TEXT NOT NULL
    )
    ''')

    # ---------------- Owner Secret Codes ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS owner_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        secret_code TEXT NOT NULL,
        used INTEGER DEFAULT 0
    )
    ''')

    # ---------------- Staff ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS staff (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL,
        phone TEXT,
        password TEXT NOT NULL,
        is_activated INTEGER DEFAULT 0
    )
    ''')

    # ---------------- Tables ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER UNIQUE NOT NULL,
        status TEXT DEFAULT 'Available'
    )
    ''')

    # ---------------- Menu ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS menu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT,
        image_url TEXT
    )
    ''')

    # ---------------- Orders ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER NOT NULL,
        total_price REAL NOT NULL,
        status TEXT DEFAULT 'pending',  -- pending, in_kitchen, served
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (table_number) REFERENCES tables(table_number) ON DELETE CASCADE
    )
    ''')

    # ---------------- Order Items ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        menu_item_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        status TEXT DEFAULT 'pending',  -- pending, preparing, served
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (menu_item_id) REFERENCES menu(id) ON DELETE CASCADE
    )
    ''')

    # ---------------- Feedback ----------------
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER NOT NULL,
        feedback TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (table_number) REFERENCES tables(table_number) ON DELETE CASCADE
    )
    ''')

    # ---------------- Indexes ----------------
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_owner_email ON owner(email)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_staff_email ON staff(email)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_otps_email ON otps(email)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_orders_table ON orders(table_number)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_order_items_menu ON order_items(menu_item_id)")

    conn.commit()
    conn.close()
    print("Database initialized successfully with new orders structure!")


if __name__ == "__main__":
    init_db()

