# see_menu_items.py
import sqlite3
from config import BASE_URL  # << Add this


def seed_menu_items():
    # Make sure DB name matches your main app
    conn = sqlite3.connect('tabletap.db')  
    cursor = conn.cursor()

    # Create the menu table if it doesn't exist
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS menu (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            category TEXT,
            image_url TEXT
        )
    ''')

    base_image_url = BASE_URL + "/static/images/"


    # Define the menu items
    menu_items = [
        {"name": "Paneer Tikka", "price": 180, "category": "Starters"},
        {"name": "Veg Spring Rolls", "price": 120, "category": "Starters"},
        {"name": "Chicken Lollipop", "price": 200, "category": "Starters"},
        {"name": "Hara Bhara Kabab", "price": 130, "category": "Starters"},
        {"name": "Tandoori Chicken", "price": 250, "category": "Starters"},
        {"name": "Fish Fingers", "price": 220, "category": "Starters"},
        {"name": "Chilli Paneer", "price": 160, "category": "Starters"},
        {"name": "Gobi Manchurian", "price": 140, "category": "Starters"},
        {"name": "Mutton Seekh Kabab", "price": 270, "category": "Starters"},
        {"name": "Crispy Corn", "price": 110, "category": "Starters"},
        {"name": "Samosa", "price": 20, "category": "Starters"},
        {"name": "Onion Pakora", "price": 50, "category": "Starters"},
        {"name": "Chicken Pakora", "price": 160, "category": "Starters"},
        {"name": "Prawn Tempura", "price": 300, "category": "Starters"},
        {"name": "Paneer 65", "price": 140, "category": "Starters"},
        {"name": "Butter Chicken", "price": 220, "category": "Main Course"},
        {"name": "Paneer Butter Masala", "price": 190, "category": "Main Course"},
        {"name": "Chicken Biryani", "price": 180, "category": "Main Course"},
        {"name": "Veg Biryani", "price": 150, "category": "Main Course"},
        {"name": "Dal Makhani", "price": 140, "category": "Main Course"},
        {"name": "Rajma Masala", "price": 130, "category": "Main Course"},
        {"name": "Egg Curry", "price": 120, "category": "Main Course"},
        {"name": "Fish Curry", "price": 230, "category": "Main Course"},
        {"name": "Chole Bhature", "price": 100, "category": "Main Course"},
        {"name": "Pav Bhaji", "price": 90, "category": "Main Course"},
        {"name": "Hyderabadi Dum Biryani", "price": 200, "category": "Main Course"},
        {"name": "Veg Kofta Curry", "price": 160, "category": "Main Course"},
        {"name": "Kadai Chicken", "price": 210, "category": "Main Course"},
        {"name": "Palak Paneer", "price": 170, "category": "Main Course"},
        {"name": "Mutton Rogan Josh", "price": 280, "category": "Main Course"},
        {"name": "Stuffed Paratha", "price": 60, "category": "Main Course"},
        {"name": "Roti (2 pcs)", "price": 30, "category": "Main Course"},
        {"name": "Butter Naan", "price": 40, "category": "Main Course"},
        {"name": "Jeera Rice", "price": 70, "category": "Main Course"},
        {"name": "Steamed Rice", "price": 60, "category": "Main Course"},
        {"name": "Coca Cola", "price": 40, "category": "Drinks"},
        {"name": "Pepsi", "price": 40, "category": "Drinks"},
        {"name": "Sprite", "price": 40, "category": "Drinks"},
        {"name": "Lassi", "price": 50, "category": "Drinks"},
        {"name": "Masala Chai", "price": 20, "category": "Drinks"},
        {"name": "Filter Coffee", "price": 25, "category": "Drinks"},
        {"name": "Fresh Lime Soda", "price": 35, "category": "Drinks"},
        {"name": "Cold Coffee", "price": 60, "category": "Drinks"},
        {"name": "Mango Shake", "price": 70, "category": "Drinks"},
        {"name": "Banana Shake", "price": 60, "category": "Drinks"},
        {"name": "Chocolate Shake", "price": 75, "category": "Drinks"},
        {"name": "Buttermilk", "price": 30, "category": "Drinks"},
        {"name": "Orange Juice", "price": 80, "category": "Drinks"},
        {"name": "Water Bottle", "price": 20, "category": "Drinks"},
        {"name": "Gulab Jamun", "price": 60, "category": "Desserts"},
        {"name": "Rasgulla", "price": 60, "category": "Desserts"},
        {"name": "Rasmalai", "price": 70, "category": "Desserts"},
        {"name": "Ice Cream (Vanilla)", "price": 50, "category": "Desserts"},
        {"name": "Ice Cream (Chocolate)", "price": 55, "category": "Desserts"},
        {"name": "Kulfi", "price": 60, "category": "Desserts"},
        {"name": "Fruit Salad", "price": 70, "category": "Desserts"},
        {"name": "Brownie", "price": 80, "category": "Desserts"},
        {"name": "Jalebi", "price": 40, "category": "Desserts"},
        {"name": "Kheer", "price": 60, "category": "Desserts"},
        {"name": "Gajar Halwa", "price": 70, "category": "Desserts"}
    ]

    # Generate image URLs and insert
    for item in menu_items:
        filename = item['name'].lower().replace(" ", "_") + ".jpg"
        item['image_url'] = base_image_url + filename

        cursor.execute('''
            INSERT INTO menu (name, price, category, image_url)
            VALUES (?, ?, ?, ?)
        ''', (item['name'], item['price'], item['category'], item['image_url'])) 

    conn.commit()
    conn.close()
    print("✅ All menu items inserted successfully (without descriptions).")

# Run
if __name__ == "__main__":
    seed_menu_items()
