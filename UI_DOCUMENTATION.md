# Canteen App - Flutter Mobile UI

A modern, visually appealing Flutter food ordering app UI for a campus canteen system. This is a complete UI prototype with **no backend, database, or API integration** - all data is static/dummy data.

## 📱 App Features

### Design System
- **Color Palette:**
  - Primary: Teal (`#1ABC9C`)
  - Accent: Dark Teal (`#16A085`)
  - Background: Light Gray-White (`#FAFAFA`)
  - Cards: White (`#FFFFFF`)
  - Text Primary: Dark Blue-Gray (`#2C3E50`)
  - Text Secondary: Gray (`#7F8C8D`)
  
- **Design Elements:**
  - Rounded corners (12-16px)
  - Soft shadows with opacity
  - Clean spacing and padding
  - Modern Material UI 3
  - Smooth animations and transitions

## 🎨 Screens

### 1. **Login Screen** (`LoginScreen`)
- Email and password input fields
- App branding with emoji icon (🍽️)
- Animated elements (fade-in, slide-in transitions)
- Login button navigation to Home Screen
- Clean, minimal design

### 2. **Home Screen** (`HomeScreen`)
- List of canteen tenants/vendors
- Search functionality
- Each tenant card displays:
  - Emoji representation (food icon)
  - Tenant name
  - Star rating with review count
  - Distance and estimated delivery time
  - "Pilih" (Select) button
- Sticky app bar with user profile icon
- Smooth scroll interactions

### 3. **Menu Screen** (`MenuScreen`)
- Grid/list view of food items from selected tenant
- Category filter buttons (All, Nasi, Soup, Noodles, Meat, Vegetables, Drinks)
- Each item card shows:
  - Emoji representation
  - Item name and description
  - Price in Indonesian Rupiah
  - Quantity selector (+/- buttons)
- Cart badge showing item count
- Smooth filtering and cart updates

### 4. **Cart Screen** (`CartScreen`)
- Lists all selected items
- Shows item price and quantity controls
- Calculates total price
- Remove items functionality
- "Lanjut" (Continue) button to proceed to payment
- Empty cart state with emoji

### 5. **Payment Screen** (`PaymentScreen`)
- Total amount display with gradient background
- Payment method selection:
  - Tunai (Cash) 💵
  - Kartu Debit/Kredit (Card) 💳
  - Transfer Bank (Bank Transfer) 🏦
  - E-Wallet 📱
- Animated selection cards
- "Bayar" (Pay) button

### 6. **QR Code Screen** (`QRCodeScreen`)
- Success message with checkmark
- QR code display (with placeholder fallback)
- Order number display
- "Tunjukkan QR ini saat pengambilan" instruction
- "Kembali ke Beranda" (Back to Home) button
- "Bagikan QR Code" (Share QR Code) button
- Pulsing animation on QR code

## 📊 Data Models

### `Tenant`
```dart
class Tenant {
  final int id;
  final String name;
  final String imageUrl;        // Emoji
  final double rating;
  final int reviews;
  final double distance;
  final String estimatedTime;
}
```

### `MenuItem`
```dart
class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;        // Emoji
  final String category;
}
```

### `CartItem`
```dart
class CartItem {
  final MenuItem item;
  int quantity;
  double get totalPrice => item.price * quantity;
}
```

## 🎭 Animations

- **Fade Transitions:** Between screens
- **Slide Transitions:** Menu navigation, Payment screen
- **Scale Animations:** QR code pulsing effect
- **Slide-in Animations:** Form fields on Login screen
- **Color Transitions:** Payment method selection

## 🗂️ File Structure

```
lib/
├── main.dart                 # Main entry point (all code in one file)
│   ├── CanteenApp           # Root app widget
│   ├── Color Constants      # Theme colors
│   ├── Data Models          # Tenant, MenuItem, CartItem
│   ├── Dummy Data           # Static test data
│   ├── LoginScreen          # Login page
│   ├── HomeScreen           # Tenant list
│   ├── MenuScreen           # Food items grid
│   ├── CartScreen           # Shopping cart
│   ├── PaymentScreen        # Payment methods
│   └── QRCodeScreen         # Order confirmation with QR

test/
└── widget_test.dart         # Basic smoke test
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.11.0
- Dart SDK

### Installation & Running

1. **Navigate to project:**
   ```bash
   cd the_caterlink_app
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Run tests:**
   ```bash
   flutter test
   ```

## 💡 Key Implementation Details

### State Management
- Uses `StatefulWidget` with `setState()`
- Simple, local state management
- No external state management libraries needed

### Navigation
- Page transitions using `PageRouteBuilder`
- Custom animation builders
- Push/Pop navigation between screens
- `pushAndRemoveUntil()` for returning home from QR screen

### UI Components Used
- `AppBar` with `SliverAppBar` for scrolling
- `GridView` for menu items
- `ListView` for cart and tenant lists
- `Container` with `BoxDecoration` for custom cards
- `Badge` widget for cart count
- `TextField` with custom styling
- `ElevatedButton` and `OutlinedButton`
- `AnimationController` for complex animations

### Styling
- Custom `BoxShadow` for depth
- `BorderRadius` for rounded corners
- `Opacity` for subtle transparency effects
- Gradient backgrounds
- Custom `InputDecoration` for text fields

## 📝 Dummy Data

The app includes static dummy data:
- **4 Tenants:** Warung Mak Siti, Nasi Kuning Enak, Bakso & Mie Lezat, Kopi & Kue Nikmat
- **8 Menu Items:** Nasi Goreng Spesial, Soto Ayam, Gado-Gado, Sate Ayam, Mie Goreng, Bakso, Es Teh, Kopi Hitam

## 🎯 Indonesian Language Support

The app uses Indonesian language throughout:
- "Pilih" - Select
- "Lanjut" - Continue
- "Bayar" - Pay
- "Keranjang" - Cart
- "Pembayaran" - Payment
- "Tunjukkan QR ini saat pengambilan" - Show this QR code when picking up

## 🔄 Navigation Flow

```
Login Screen
    ↓
Home Screen (Tenant List)
    ↓
Menu Screen (Food Items)
    ↓
Cart Screen
    ↓
Payment Screen
    ↓
QR Code Screen (Order Confirmation)
    ↓
Home Screen (Reset)
```

## 🎨 Similar To

This UI design is inspired by popular food delivery apps like:
- GoFood
- GrabFood
- Tokopedia Food
- Gojek

With simplified features and offline-only functionality for educational purposes.

## 📄 License

This is a sample Flutter project for educational purposes.

## 🙋 Future Enhancements (Not Implemented)

- Backend API integration
- Real database (Firebase/Supabase)
- User authentication
- Order history
- Favorites/Wishlist
- Reviews and ratings
- Location services
- Real QR code generation
- Push notifications
- Payment gateway integration
- Multi-language support
- Dark mode support
- More complex animations
