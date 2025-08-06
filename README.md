# Fit Data App

A Flutter application built with MVVM (Model-View-ViewModel) architecture that implements 8 different fitness app screens with modern UI designs.

## Architecture

This Innovosense follows the MVVM (Model-View-ViewModel) pattern:

### Models (`lib/models/`)
- `screen_model.dart` - Data model for screen information

### Views (`lib/views/`)
- `main_screen.dart` - Main screen that handles navigation between all screens
- `screen_1.dart` - Welcome/Onboarding screen
- `screen_2.dart` - Workout selection screen
- `screen_3.dart` - Progress tracking screen
- `screen_4.dart` - Profile/Settings screen
- `screen_5.dart` - Community/Social screen
- `screen_6.dart` - Recommendations screen
- `screen_7.dart` - Analytics screen
- `screen_8.dart` - Achievements screen

### ViewModels (`lib/viewmodels/`)
- `base_viewmodel.dart` - Base ViewModel class with common functionality
- `screens_viewmodel.dart` - ViewModel that manages screen navigation

### Services (`lib/services/`)
- Directory for business logic and API services (if needed)

### Utils (`lib/utils/`)
- Directory for utility functions and helpers

## Features

- **8 Unique Screens**: Each screen has a distinct UI design for different fitness app features
- **Swipe Navigation**: Tap left/right sides of the screen to navigate
- **Visual Navigation**: Navigation indicators and buttons
- **MVVM Architecture**: Clean separation of concerns
- **Provider State Management**: Uses Provider package for state management
- **Modern UI**: Dark theme with gradients, cards, and modern design elements

## Screen Descriptions

1. **Screen 1** - Welcome screen with app branding and call-to-action
2. **Screen 2** - Workout selection with featured workout and categories
3. **Screen 3** - Progress tracking with stats cards and activity charts
4. **Screen 4** - Profile page with user stats and settings
5. **Screen 5** - Community screen with challenges and friend activities
6. **Screen 6** - Recommendations with personalized workout suggestions
7. **Screen 7** - Analytics with detailed metrics and performance charts
8. **Screen 8** - Achievements with goals, badges, and rewards

## Navigation

- **Tap left side** (30% of screen width) - Go to previous screen
- **Tap right side** (30% of screen width) - Go to next screen
- **Navigation indicators** - Shows current screen position
- **Navigation buttons** - Visual arrows for navigation

## UI Components

- **Gradient Cards**: Beautiful gradient backgrounds for featured content
- **Stats Cards**: Display key metrics with color-coded values
- **Progress Bars**: Visual progress indicators
- **Activity Lists**: Recent activities with icons and timestamps
- **Category Grids**: Organized workout categories
- **Achievement Cards**: Unlocked and locked achievements
- **Navigation Indicators**: Dot indicators showing current position

## Getting Started

1. Ensure you have Flutter installed
2. Navigate to the app directory: `cd app`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

## Dependencies

- `flutter` - Flutter SDK
- `provider` - State management
- `cupertino_icons` - iOS-style icons

## Project Structure

```
lib/
├── models/
│   └── screen_model.dart
├── views/
│   ├── main_screen.dart
│   ├── screen_1.dart
│   ├── screen_2.dart
│   ├── screen_3.dart
│   ├── screen_4.dart
│   ├── screen_5.dart
│   ├── screen_6.dart
│   ├── screen_7.dart
│   └── screen_8.dart
├── viewmodels/
│   ├── base_viewmodel.dart
│   └── screens_viewmodel.dart
├── services/
├── utils/
└── main.dart
```

## Design Features

- **Dark Theme**: Consistent black background with white text
- **Color Accents**: Orange, green, blue, purple, and red accent colors
- **Modern Typography**: Bold headings and readable body text
- **Rounded Corners**: Consistent border radius throughout
- **Gradient Backgrounds**: Eye-catching gradient cards
- **Icon Integration**: Material Design icons for visual appeal
- **Responsive Layout**: Adapts to different screen sizes
