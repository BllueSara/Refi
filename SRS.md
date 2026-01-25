# Software Requirements Specification (SRS) for Refi Project

## 1. Introduction
**Project Name:** Refi  
**Description:** Refi is a comprehensive Flutter-based mobile application designed for book enthusiasts to manage their personal libraries, track reading progress, and save meaningful quotes. It leverages Supabase for backend services and Google Books API for extensive book accessibility.

## 2. Technical Architecture
The project follows **Clean Architecture** principles to ensure separation of concerns, scalability, and testability.

### Layers:
1.  **Presentation Layer:** Contains UI components (Pages, Widgets) and State Management (BLoC).
2.  **Domain Layer:** Contains core business logic (Entities, Usecases, Repository Interfaces).
3.  **Data Layer:** Handles data retrieval (Repositories Implementations, Data Sources, Models).

### Tech Stack:
*   **Framework:** Flutter (Dart SDK >=3.3.1 <4.0.0)
*   **State Management:** flutter_bloc
*   **Dependency Injection:** get_it
*   **Functional Programming:** dartz
*   **Comparison:** equatable

## 3. APIs and External Services

### 3.1 Backend & Database
**Provider:** [Supabase](https://supabase.com)  
**Database:** PostgreSQL  
**Authentication:** Supabase Auth (Email/Password, Google Sign-In)

**Key Tables:**
*   `books`: Stores user's personal library.
    *   Fields: `id` (UUID), `user_id`, `title`, `author`, `image_url` (or thumbnail), `page_count`, `rating`, `status` (e.g., read, currently reading), `created_at`.
*   `quotes`: Stores user-saved quotes (Inferred).
*   `profiles`: User profile information.

### 3.2 External APIs
**Google Books API:**
*   **Endpoint:** `https://www.googleapis.com/books/v1/volumes`
*   **Usage:** creating/searching for books to add to the library.
*   **Parameters:**
    *   `q`: Search query (Sanitized).
    *   `langRestrict`: `ar` (Arabic).
    *   `orderBy`: `relevance`.
    *   `maxResults`: 20.
*   **Ranking:** Custom smart ranking using Levenshtein distance for better Arabic search relevance.

### 3.3 On-Device Machine Learning
**Google ML Kit:**
*   **Feature:** Text Recognition (`google_mlkit_text_recognition`).
*   **Usage:** Scanning book pages to extract text for quotes.

## 4. Features

### 4.1 Authentication (`/auth`)
*   User Registration and Login.
*   Social Login (Google).

### 4.2 Home (`/home`)
*   Dashboard view.
*   Reading progress summary.
*   Quick access to current reads.

### 4.3 Library Management (`/library`)
*   **View Library:** List of all user books.
*   **Add Book (`/add_book`):**
    *   **Search:** Search via Google Books API.
    *   **Manual Entry:** Add book details manually.
*   **Book Details:** View metadata (Title, Author, Pages, etc.).
*   **Edit/Delete:** Modify book details or remove from library.

### 4.4 Quotes (`/quotes`)
*   **Save Quotes:** Manually type or scan text from physical books.
*   **Quote Card:** Beautifully designed cards for displaying quotes.
*   **Organize:** Link quotes to specific books.

### 4.5 Other Features
*   **Onboarding:** Introduction screens for new users.
*   **Profile:** User settings and stats.
*   **Settings:** App configuration.

## 5. UI/UX Design
*   **Font:** Google Fonts `Tajawal` (Arabic centric).
*   **Icons:** Cupertino Icons & Flutter SVG.
*   **Animations:** Lottie files, Shimmer effects (loading states).
*   **Input:** Smooth page indicators, Video player support.

## 6. Key Libraries & Packages
| Package | Purpose |
| :--- | :--- |
| `flutter_bloc` | State Management |
| `supabase_flutter` | Backend/Auth/DB |
| `http` | REST API Calls |
| `google_mlkit_text_recognition` | OCR (Text Scanning) |
| `shared_preferences` | Local Key-Value Storage |
| `image_picker` | Selecting images from gallery/camera |
| `cached_network_image` | (Implied) Image caching |
| `flutter_dotenv` | Environment secrets management |

## 7. Folder Structure
```
lib/
├── core/           # Core utilities (Error, Network, DI, Secrets)
├── features/       # Feature-based modules
│   ├── add_book/
│   ├── auth/
│   ├── home/
│   ├── library/
│   ├── quotes/
│   ├── scanner/
│   └── ...
├── main.dart       # App Entry point
└── ...
```
