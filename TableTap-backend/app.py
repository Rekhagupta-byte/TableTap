from flask import Flask
from flask_mail import Mail
from flask_cors import CORS
import config
from db import init_db
from auth_routes import auth_bp, set_mail
from customer_routes import customer_bp
from staff_routes import staff_bp, set_mail as set_staff_mail
from order_routes import order_bp
app = Flask(__name__)  # Step 1: Create app

app.config.from_object(config)  # Step 2: Config
CORS(app)

mail = Mail(app)
set_mail(mail)  # Pass mail instance to auth_routes
set_staff_mail(mail)     # for staff_routes

# Step 3: Initialize DB
init_db()

# Step 4: Register blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(customer_bp)
app.register_blueprint(staff_bp)
app.register_blueprint(order_bp)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)  # For physical device testing
