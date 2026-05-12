# Project Context: Job Notice BD (Job Circular)

This document provides a comprehensive overview of the Job Notice BD (Job Circular) application. It is designed to help both developers and AI models understand the project's architecture, state management, and implementation details.

## 🚀 Overview
**Job Notice BD** is a Flutter-based mobile application designed to provide users with the latest job circulars. It fetches data from a WordPress-powered website and offers features like category-based browsing, search functionality, offline caching, and a favorites system.

## 🏗️ Architecture
The project follows a modular architecture that separates concerns between UI, State Management, Data, and Networking.

### 1. UI Layer (`lib/screens/`, `lib/bottombar.dart`)
- **Material 3**: The app uses the latest Material 3 design system.
- **Main Navigation**: `BottomBar` manages navigation using a `PageView` and `BottomNavigationBar`.
- **Dynamic Theming**: Supports Light and Dark modes, managed via `SettingsProvider`.
- **Screens**:
  - `HomePage`: Displays job categories in a grid.
  - `AllPosts`: Displays posts within a specific category.
  - `SearchPage`: Provides real-time search with debouncing.
  - `FavouritePostPage`: Lists posts saved by the user.
  - `SettingsPage`: App configuration and theme toggling.

### 2. State Management (`lib/providers/`)
The application uses the **Provider** package with `ChangeNotifier` for reactive state management.
- **`PostsProvider`**: Handles fetching posts, pagination, and search logic. It uses a stale-while-revalidate strategy and offloads JSON parsing to background isolates using `compute`.
- **`CategoriesProvider`**: Manages the list of job categories.
- **`FavouritesProvider`**: Handles adding/removing posts from the local favorites storage.
- **`SettingsProvider`**: Manages app-wide settings like `ThemeMode`.

### 3. Networking & Caching (`lib/services/api_service.dart`)
- **Dio**: Used for HTTP requests.
- **Caching**: Implements `dio_cache_interceptor` with `HiveCacheStore` for efficient offline data access and reduced API calls.
- **Stale-While-Revalidate**: The `ApiService` is configured to serve cached data immediately while fetching updates in the background.

### 4. Data Persistence (`lib/models/`, `lib/utis/models.dart`)
- **Hive**: A lightweight and fast NoSQL database used for local storage.
- **Models**: Type-safe models (`SinglePost`, `PostCategory`, `FavouritePost`, `Appsettings`) with Hive adapters for serialization.
- **Global Access**: Common Hive boxes are initialized in `main.dart` and made accessible via `lib/utis/models.dart`.

## 🛠️ Key Technical Implementations

### Networking Optimization
The `ApiService` uses a singleton pattern and initializes a `Dio` instance with custom headers and interceptors. It targets the WordPress REST API (`/wp-json/wp/v2/`).

### Performance
- **Background Parsing**: Heavy JSON decoding is performed using Flutter's `compute` function to prevent UI jank.
- **Image Caching**: Uses `Image.asset` for category icons and likely relies on standard Flutter image caching for network images.
- **Debounced Search**: Search queries are debounced (300ms) to prevent excessive API requests.

### Initialization Workflow (`main.dart`)
1. **Initialize Flutter Bindings**.
2. **Initialize Hive** and register TypeAdapters.
3. **Open Hive Boxes** for categories, posts, favorites, and settings.
4. **Setup MultiProvider** to provide state globally.
5. **Splash Screen**: Shows a splash image while the app prepares data.

## 📂 Directory Structure
- `lib/models/`: Data models and Hive adapters.
- `lib/providers/`: State management logic.
- `lib/screens/`: UI components and page layouts.
- `lib/services/`: API and external service integrations.
- `lib/utis/`: Utility functions, constants, and global variables.
- `img/`: Local assets and category icons.

## 📝 Future AI Understanding
When working on this project, ensure that:
- Any new data models include Hive annotations and generated adapters.
- State changes are handled through the appropriate `Provider`.
- Network calls are routed through the `ApiService` to maintain consistent caching policies.
- UI components remain decoupled from direct data fetching logic.
