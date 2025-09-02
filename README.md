# 🍴 Cross-Platform Restaurant POS & Ordering System

A complete restaurant management solution with web admin dashboard, mobile customer app, and POS system for kitchen staff.

## 🌟 System Overview

This project consists of three main components:
1. **React Web Dashboard** - Admin panel for restaurant management
2. **Laravel Backend API** - Server-side logic and database management  
3. **Flutter Mobile App** - Customer ordering app and kitchen POS system

---

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   React Web     │    │  Laravel Backend │    │  Flutter Mobile │
│   Dashboard     │◄──►│    (API + DB)    │◄──►│      Apps       │
│                 │    │                  │    │                 │
│ • Admin Panel   │    │ • REST APIs      │    │ • Customer App  │
│ • Menu Mgmt     │    │ • Authentication │    │ • Kitchen POS   │
│ • Order Mgmt    │    │ • Order System   │    │ • QR Scanner    │
│ • Analytics     │    │ • MySQL Database │    │ • Order Status  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

---

## 🎯 Features

### 👨‍💼 Admin Web Dashboard (React)
- 📊 Real-time analytics & sales reports
- 🍽️ Menu item management (CRUD operations)
- 📋 Order management & status tracking
- 👥 Customer management
- 💰 Revenue tracking & insights
- 🔧 System configuration

### 📱 Customer Mobile App (Flutter)
- 📷 QR code scanning for instant menu access
- 🛒 Interactive shopping cart
- 💳 Secure payment processing
- 📍 Order tracking with real-time updates
- ⭐ Rating & review system
- 📱 Push notifications

### 👨‍🍳 Kitchen POS System (Flutter)
- 📋 Incoming order notifications
- ✅ Order status management (Pending → In Progress → Ready → Delivered)
- ⏱️ Preparation time tracking
- 📊 Kitchen performance metrics
- 🔔 Real-time order alerts

### 🔧 Backend API (Laravel)
- 🔐 JWT authentication & authorization
- 📡 RESTful API endpoints
- 🗄️ MySQL database with optimized queries
- 📧 Email notifications
- 🔄 Real-time data synchronization
- 📈 Analytics data processing

---

## 🛠️ Tech Stack

| Component | Technologies |
|-----------|-------------|
| **Frontend Web** | React 18, Tailwind CSS, Axios, React Router |
| **Backend API** | Laravel 10, PHP 8.2, MySQL 8.0, JWT Auth |
| **Mobile Apps** | Flutter 3.x, Dart, Provider/Riverpod |
| **Database** | MySQL 8.0 |
| **Hosting** | AWS EC2, Nginx |
| **Others** | Git, Composer, npm |

---

## 🚀 Quick Start

### 1️⃣ Laravel Backend Setup

```bash
# Clone the backend repository
git clone https://github.com/hariharan-sudhagar/restaurant-pos.git
cd restaurant-pos

# Install dependencies
composer install

# Environment setup
cp .env.example .env
php artisan key:generate

# Database setup
php artisan migrate
php artisan db:seed

# Start development server
php artisan serve
```

**🔗 Live Backend:** [http://13.49.224.75/](http://13.49.224.75/)

### 2️⃣ React Web Dashboard Setup

```bash
# Clone the frontend repository
git clone https://github.com/hariharan-sudhagar/React-restaurant-pos.git
cd React-restaurant-pos

# Install dependencies
npm install

# Start development server
npm start
```

### 3️⃣ Flutter Mobile App Setup

```bash
# Clone the Flutter repository
git clone https://github.com/hariharan-sudhagar/Flutter-app.git
cd Flutter-app

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run
```

---

## 📋 API Endpoints

### Authentication
- `POST /api/login` - User login
- `POST /api/register` - User registration
- `POST /api/logout` - User logout

### Menu Management
- `GET /api/menu` - Get all menu items
- `POST /api/menu` - Create menu item
- `PUT /api/menu/{id}` - Update menu item
- `DELETE /api/menu/{id}` - Delete menu item

### Order Management
- `GET /api/orders` - Get all orders
- `POST /api/orders` - Create new order
- `PUT /api/orders/{id}/status` - Update order status
- `GET /api/orders/{id}` - Get order details

### Analytics
- `GET /api/analytics/daily` - Daily sales data
- `GET /api/analytics/weekly` - Weekly reports
- `GET /api/analytics/monthly` - Monthly insights

---

## 🌊 Order Flow

```
Customer Scans QR Code → Views Menu → Adds to Cart → Places Order
                                                           ↓
Kitchen Receives Order → Updates Status → Prepares Food → Order Ready
                                                           ↓
Customer Notified → Picks Up Order → Order Completed → Rating/Review
```

---

## 🗂️ Project Structure

```
restaurant-pos-system/
├── backend/                    # Laravel API
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── config/
├── frontend/                   # React Dashboard
│   ├── src/
│   ├── public/
│   └── package.json
└── mobile/                     # Flutter Apps
    ├── lib/
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

---

## 🔧 Configuration

### Environment Variables (.env)
```env
# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=restaurant_pos
DB_USERNAME=your_username
DB_PASSWORD=your_password

# JWT Secret
JWT_SECRET=your_jwt_secret_key

# App Settings
APP_NAME="Restaurant POS"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost
```

---

## 📊 Database Schema

### Key Tables
- `users` - System users (admin, staff, customers)
- `menu_items` - Restaurant menu items
- `categories` - Menu categories
- `orders` - Customer orders
- `order_items` - Individual items in orders
- `order_status_logs` - Order status tracking

---

## 🔐 Security Features

- ✅ CORS protection
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ Rate limiting
- ✅ Input validation & sanitization

---

## 📈 Performance Optimizations

- 🚀 Database query optimization
- 💾 Redis caching (optional)
- 📱 Lazy loading in mobile apps
- ⚡ API response compression
- 🔄 Connection pooling
- 📊 Efficient state management

---

## 🧪 Testing

```bash
# Laravel Backend Tests
php artisan test

# React Frontend Tests
npm test

# Flutter App Tests
flutter test
```

---

## 🚀 Deployment

### Backend (AWS EC2)
1. Set up EC2 instance with PHP, MySQL, Nginx
2. Clone repository and configure environment
3. Set up SSL certificate
4. Configure domain and DNS

### Frontend (Netlify/Vercel)
```bash
npm run build
# Deploy build folder to hosting service
```

### Mobile Apps
- **Android:** Build APK/AAB for Google Play Store
- **iOS:** Build IPA for Apple App Store

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Hariharan Sudhagar**
- GitHub: [@hariharan-sudhagar](https://github.com/hariharan-sudhagar)
- Email: hariharansudhagar18.com


---

## 🔮 Future Enhancements

- [ ] Multi-restaurant support
- [ ] Advanced analytics with ML insights
- [ ] Integration with popular payment gateways
- [ ] Inventory management system
- [ ] Customer loyalty program
- [ ] Voice ordering capabilities
- [ ] AI-powered menu recommendations


