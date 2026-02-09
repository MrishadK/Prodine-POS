# 🍽️ ProDine POS  
### Smart • Fast • Offline-Ready Restaurant POS built with Flutter

**ProDine POS** is a modern, cross-platform **Point of Sale (POS)** system designed for **restaurants, cafés, and food businesses** that need speed, reliability, and simplicity.

Built with **Flutter**, it delivers a **touch-friendly**, **offline-capable**, and **thermal-printer-ready** solution for real-world service environments.

> ⚡ Optimized for high-speed order taking  
> 🧾 Built-in receipt printing  
> 💾 Works even without internet  

---

## ✨ Overview

ProDine POS focuses on **performance + usability** in busy restaurant environments.  
From quick order entry to real-time reports, everything is designed to reduce staff effort and increase service speed.

| Feature | Description |
|--------|-------------|
| 🧾 POS Interface | Fast, grid-based menu selection UI |
| 🍔 Menu Management | Dynamic control of items, categories & pricing |
| 🧮 Order Management | Create, modify & track orders with live summaries |
| 🖨️ Printing Support | Thermal printer integration for receipts |
| 📊 Reports & Sales | View history and generate sales reports |
| 💾 Offline Database | Local storage ensures reliability without internet |
| 🔐 Licensing System | Built-in license verification & admin key system |

---

## 🚀 Key Screens

- `pos_screen.dart` → Main billing interface  
- `add_food_screen.dart` → Food & category management  
- `reports_screen.dart` → Sales reports  
- `history_screen.dart` → Order history  
- `license_service.dart` → License verification logic  
- `printer_service.dart` → Receipt printing  

---

## 🛠️ Tech Stack

| Layer | Technology |
|------|------------|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Database | Drift / SQLite (Local SQL) |
| Architecture | MVVM (Models – Views – Providers) |
| Platforms | Windows |

---

## 📂 Project Structure

# Flutter POS Application Structure

## 📁 **lib/**
Main application directory containing all Dart source code.

### 📂 **database/**
Local database configuration and generated files
- Database connection setup
- Migration files
- Generated ORM/DAO classes
- Local storage configurations

### 📂 **models/**
Data models and entity classes
- `Order.dart` - Order data model
- `MenuItem.dart` - Menu item/product model  
- `Settings.dart` - Application settings model
- Other business entity models

### 📂 **providers/**
State management logic (using Provider/Riverpod/Bloc)
- State notifiers
- Business logic controllers
- Application state management
- Data synchronization handlers

### 📂 **screens/**
UI Screens and page implementations
- `pos_screen.dart` - Point of Sale main interface
- `history_screen.dart` - Order history view
- `reports_screen.dart` - Sales reports and analytics
- `settings_screen.dart` - Application settings page
- Screen-specific view models

### 📂 **services/**
External service integrations
- `printer_service.dart` - Receipt printing functionality
- `license_service.dart` - License validation and management
- API clients and external integrations

### 📂 **widgets/**
Reusable UI components
- `menu_grid_widget.dart` - Product menu display grid
- Other shared UI components (buttons, dialogs, cards)

### 📄 **main.dart**
Application entry point
- App initialization
- Root widget configuration
- Provider/state management setup
- Main application class

---

## 🔗 **Dependencies**
*(Typical Flutter POS dependencies)*
- `sqflite` - Local database (database/)
- `provider` or `riverpod` - State management (providers/)
- `printing` - Receipt printing (services/printer_service.dart)
- `intl` - Internationalization
- `shared_preferences` - Local settings storage

---

## 🏗️ **Architecture Pattern**
This structure follows a layered architecture:
1. **Data Layer** (database/, models/)
2. **Business Logic Layer** (providers/, services/)
3. **Presentation Layer** (screens/, widgets/)
4. **Application Layer** (main.dart)

---

---

## ⚙️ Installation & Setup

### ✅ Prerequisites
- Flutter SDK installed
- VS Code / Android Studio
- Windows device (recommended)

### 1️⃣ Clone Repository
```bash
git clone https://github.com/MrishadK/Prodine-POS.git
cd Prodine-POS
```

### 2️⃣ Install Dependencies
```bash
flutter pub get
```

### 3️⃣ Generate Database Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

4️⃣ Run Application
```bash
flutter run -d windows
```

## 💰 Currency Support

ProDine POS is configured to use **SAR (Saudi Riyal)** as the default currency for all transactions, billing, and reports.

## 🔐 Licensing

ProDine POS includes a secure license verification system to control installations and prevent unauthorized usage.
