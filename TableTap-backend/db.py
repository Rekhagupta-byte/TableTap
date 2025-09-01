import sqlite3

def get_db_connection():
    conn = sqlite3.connect('tabletap.db',timeout=10)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("PRAGMA foreign_keys = ON")

    # Create owners table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS owner (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL
    )
''')

    # Create otps table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS otps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            otp TEXT NOT NULL
        )
    ''')

    # Create owner_codes table with 'used' column
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS owner_codes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            secret_code TEXT NOT NULL,
            used INTEGER DEFAULT 0
        )
    ''')

    conn.execute("""
CREATE TABLE IF NOT EXISTS staff (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL,
    phone TEXT,
    password TEXT NOT NULL,
    is_activated INTEGER DEFAULT 0
)
""")


    conn.execute("""
        CREATE TABLE IF NOT EXISTS tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_number INTEGER UNIQUE NOT NULL,
            status TEXT DEFAULT 'Available'
        )
    """)

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS menu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT,
        image_url TEXT)
                   ''')

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER NOT NULL,
        items TEXT NOT NULL,
        total_price REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pending',
        created_at TEXT NOT NULL,
        FOREIGN KEY (table_number) REFERENCES tables(table_number) ON DELETE CASCADE
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER NOT NULL,
        feedback TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (table_number) REFERENCES tables(table_number) ON DELETE CASCADE
    )
    """)

    # Indexes for faster lookups
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_owner_email ON owner(email)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_staff_email ON staff(email)")

    cursor.execute("CREATE INDEX IF NOT EXISTS idx_otps_email ON otps(email)")

    conn.commit()
    conn.close()

def fix_image_urls():
    conn = sqlite3.connect('tabletap.db')
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE menu
        SET image_url = REPLACE(image_url, '192.168.0.244', '192.168.0.245')
        WHERE image_url LIKE '%192.168.0.244%';
    """)

    conn.commit()
    conn.close()
    print("Image URLs updated successfully.")

if __name__ == "__main__":
    init_db()
    fix_image_urls()
    print("Database initialized successfully.")
