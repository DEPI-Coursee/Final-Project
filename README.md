# Tour Guide - Visit List Page

A beautiful Flutter web application showcasing a Visit List page for a tour guide website.

## 🎯 Project Overview

This is part of a team project for creating a tour guide website. This specific component implements the **Visit List** page where users can view and manage their planned destinations.

## ✨ Features

- **Beautiful UI Design** - Orange/brown theme with modern Material Design 3
- **Responsive Layout** - Works perfectly on mobile and desktop
- **Sample Data** - Pre-loaded with Egyptian tourist destinations
- **Interactive Elements** - Search bar, statistics cards, and action buttons
- **Clean Architecture** - Well-structured code with separate models

## 🎨 Design Highlights

- **Color Scheme**: Orange (#E67E22) and brown gradients
- **Typography**: Clean, readable fonts with proper hierarchy
- **Cards**: Elevated cards with shadows and rounded corners
- **Statistics**: Real-time counters for places, visited, and planned
- **Tags**: Categorized destinations (Historical, Nature, Adventure, etc.)

## 📱 Sample Destinations

1. **Giza Pyramids** - $225 (Historical, Ancient, UNESCO)
2. **Karnak Temple Complex** - $185 (Temple, Historical, Sacred)
3. **Blue Hole, Dahab** - $95 (Diving, Nature, Adventure)
4. **Valley of the Kings** - $165 (Tombs, Pharaohs, Ancient)
5. **White Desert** - $120 (Desert, Camping, Nature)

## 🚀 Running the App

### Prerequisites
- Flutter SDK 3.35.4+
- Chrome browser (for web preview)

### Commands
```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on specific port
flutter run -d chrome --web-port 3000
```

## 📁 Project Structure

```
lib/
├── main.dart           # Main app and Visit List page
└── models/
    └── place.dart      # Place data model

web/                    # Web-specific files
├── index.html
├── manifest.json
└── icons/
```

## 🛠️ Technologies Used

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Material Design 3** - Design system
- **Web Support** - Responsive web application

## 👥 Team Project

This Visit List page is part of a larger tour guide website project developed by a team of 5 developers.

## 📄 License

This project is part of a course assignment.

---

*Developed with ❤️ using Flutter*

