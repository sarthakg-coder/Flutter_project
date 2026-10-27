# JobFinder — Full-Stack Job Portal Mobile Application

A clean, modern, and production-ready **Job Portal Mobile Application** built for college project submissions, viva presentations, and portfolio demonstrations.

Built with **Flutter (Frontend)**, **FastAPI (Backend)**, and **PostgreSQL (Database)** following **Clean Architecture principles**.

---

## 📌 Project Overview

**JobFinder** connects job seekers with career opportunities. Candidates can register an account, log in, browse and search vacancies, save jobs to their personal wishlist, submit job applications with custom notes, manage their applications, and update their profile in real time.

All operations communicate with a real Python FastAPI REST API and persist directly to a PostgreSQL database.

---

## 🛠️ Technology Stack

| Layer | Technology | Key Highlights |
| :--- | :--- | :--- |
| **Frontend** | Flutter & Dart | Native Android/iOS performance, Material Design 3 UI |
| **State Management** | `setState()` | Clean, native Flutter state management without external complex state libraries |
| **Networking** | `http` package only | RESTful API client with clean timeout and error handling |
| **Routing** | `go_router` | Declarative routing with auth redirection guards |
| **Secure Storage** | `flutter_secure_storage` | Encrypted JWT token persistence on device |
| **Backend** | Python FastAPI | Asynchronous high-performance REST API with Swagger docs |
| **ORM** | SQLAlchemy | Relational mapping, connection pooling, and migrations |
| **Validation** | Pydantic v2 | Type validation and JSON serialization |
| **Database** | PostgreSQL | ACID-compliant relational database |
| **Authentication** | JWT (JSON Web Tokens) & Bcrypt | Secure salted password hashing and stateless token verification |

---

## 🚀 Key Features

1. **Authentication & Security**
   - Candidate registration with validation (Full name, email, password, phone, location).
   - Secure login issuing a signed JWT Bearer token.
   - Salted Bcrypt password hashing (`bcrypt`).
   - Secure client token storage using platform-native keystore/keychain.
   - Session logout clearing authentication state.

2. **Job Browsing & Discovery**
   - Explore featured opportunities on the Home dashboard.
   - Filter jobs by category (`Full-time`, `Remote`, `Internship`, `All`).
   - Full job details screen with required skill tags, salary, company info, and descriptions.

3. **Debounced Live Search**
   - Real-time search across job titles, company names, locations, and skills.
   - Debounced input to avoid overwhelming the server with requests.

4. **Wishlist / Saved Jobs (CRUD Demonstration)**
   - Save/bookmark jobs to wishlist (`POST /api/v1/saved-jobs`).
   - View all saved jobs (`GET /api/v1/saved-jobs`).
   - Swipe-to-delete or tap bookmark to remove from saved (`DELETE /api/v1/saved-jobs/{job_id}`).

5. **Job Applications (CRUD Demonstration)**
   - Apply for jobs with optional cover letter note (`POST /api/v1/applications`).
   - Enforce business logic: candidates cannot submit duplicate applications for the same job.
   - View submitted applications with status badges (`GET /api/v1/applications`).
   - Withdraw application (`DELETE /api/v1/applications/{application_id}`).

6. **Candidate Profile (HTTP PUT)**
   - View personal candidate profile and join date (`GET /api/v1/users/me`).
   - Update candidate details (`PUT /api/v1/users/me`).

---

## 📱 10+ Complete Application Screens

| # | Screen Name | File Path | Purpose |
| :-: | :--- | :--- | :--- |
| 1 | **Splash Screen** | `lib/screens/splash_screen.dart` | Checks JWT token and routes to Home or Login |
| 2 | **Login Screen** | `lib/screens/login_screen.dart` | Authenticates candidate with email and password |
| 3 | **Register Screen** | `lib/screens/register_screen.dart` | Creates a new account in PostgreSQL |
| 4 | **Home Screen** | `lib/screens/home_screen.dart` | Featured opportunities, quick cards, bottom navigation |
| 5 | **Job List Screen** | `lib/screens/job_list_screen.dart` | All jobs with horizontal filter chips and pull-to-refresh |
| 6 | **Job Details Screen** | `lib/screens/job_details_screen.dart` | Full description, skills list, apply modal bottom sheet |
| 7 | **Search Screen** | `lib/screens/search_screen.dart` | Live search by job title, company, or required skill |
| 8 | **Saved Jobs Screen** | `lib/screens/saved_jobs_screen.dart` | Candidate's bookmarked jobs with swipe-to-remove |
| 9 | **Applications Screen**| `lib/screens/applications_screen.dart` | Track submitted applications with withdraw option |
| 10 | **Profile Screen** | `lib/screens/profile_screen.dart` | View profile details, member since date, and logout |
| 11 | **Edit Profile Screen**| `lib/screens/edit_profile_screen.dart`| Form demonstrating HTTP PUT profile updates |

---

## 🏛️ Architecture & Project Structure

The project follows a **Simple Clean Architecture** separating UI, Business Logic, and Data layers:

```
flutter_project/
├── backend/                        # Python FastAPI Backend
│   ├── app/
│   │   ├── main.py                 # FastAPI app entry point & seed data
│   │   ├── api/
│   │   │   ├── deps.py             # JWT authentication dependencies
│   │   │   └── v1/routes/          # REST API route handlers
│   │   │       ├── auth.py         # Register, Login, Me endpoints
│   │   │       ├── jobs.py         # Job listing and details endpoints
│   │   │       ├── users.py        # Profile GET and PUT endpoints
│   │   │       ├── applications.py # Apply, List, and Withdraw endpoints
│   │   │       └── saved_jobs.py   # Save, List, and Remove endpoints
│   │   ├── core/
│   │   │   ├── config.py           # Environment variables via pydantic-settings
│   │   │   └── security.py         # Bcrypt hashing & JWT token generation
│   │   ├── database/
│   │   │   └── session.py          # SQLAlchemy PostgreSQL connection & session
│   │   ├── models/                 # SQLAlchemy DB models (User, Job, Application, SavedJob)
│   │   └── schemas/                # Pydantic validation schemas
│   ├── requirements.txt            # Python dependencies
│   ├── .env                        # Local database credentials (Git ignored)
│   └── .env.example                # Template for environment configuration
│
├── lib/                            # Flutter Mobile Frontend
│   ├── main.dart                   # Flutter app entry point
│   ├── app/
│   │   └── app_router.dart         # GoRouter configuration & auth guards
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart  # Centralized API URLs and endpoint paths
│   │   ├── services/
│   │   │   └── api_service.dart    # HTTP client (GET, POST, PUT, DELETE) + JWT interceptor
│   │   └── theme/
│   │       └── app_theme.dart      # Colors, typography, and card themes
│   ├── models/                     # Dart models with fromJson & toJson
│   │   ├── user_model.dart
│   │   ├── job_model.dart
│   │   ├── saved_job_model.dart
│   │   └── application_model.dart
│   ├── repositories/               # Repository pattern organizing API operations
│   │   ├── auth_repository.dart
│   │   ├── job_repository.dart
│   │   ├── saved_job_repository.dart
│   │   └── application_repository.dart
│   ├── screens/                    # 11 UI Screens managing state via setState()
│   └── widgets/                    # Reusable UI components (JobCard, CustomButton, etc.)
│
├── pubspec.yaml                    # Flutter dependencies
└── README.md
```

---

## 📡 REST API Endpoint Documentation

All 4 standard HTTP methods are implemented and demonstrated:

| Method | Endpoint | Auth Required | Description |
| :--- | :--- | :---: | :--- |
| `POST` | `/api/v1/auth/register` | No | Register candidate & issue JWT |
| `POST` | `/api/v1/auth/login` | No | Login candidate & issue JWT |
| `GET` | `/api/v1/auth/me` | Yes | Get authenticated candidate info |
| `GET` | `/api/v1/jobs` | Optional | List jobs (supports `?search=` and `?job_type=`) |
| `GET` | `/api/v1/jobs/{id}` | Optional | Get full job details by ID |
| `GET` | `/api/v1/users/me` | Yes | Get candidate profile |
| `PUT` | `/api/v1/users/me` | Yes | Update candidate profile (Name, Phone, Location) |
| `POST` | `/api/v1/saved-jobs` | Yes | Bookmark a job to wishlist |
| `GET` | `/api/v1/saved-jobs` | Yes | Retrieve candidate's saved jobs |
| `DELETE`| `/api/v1/saved-jobs/{job_id}` | Yes | Remove a job from wishlist |
| `POST` | `/api/v1/applications` | Yes | Submit a job application |
| `GET` | `/api/v1/applications` | Yes | List current candidate's applications |
| `DELETE`| `/api/v1/applications/{id}` | Yes | Withdraw a job application |

---

## 💻 Step-by-Step Setup & Running Guide

### 1. Prerequisites
- **Flutter SDK**: 3.19+ (Dart 3.3+)
- **Python**: 3.10+
- **PostgreSQL**: 14+ running on `localhost:5432`

---

### 2. Database Setup (PostgreSQL)
1. Open PostgreSQL command line (`psql`) or pgAdmin:
   ```sql
   CREATE DATABASE jobfinder_db;
   ```
2. Verify credentials in `backend/.env`:
   ```env
   DB_USER=postgres
   DB_PASSWORD=your_postgres_password
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=jobfinder_db
   SECRET_KEY=jobfinder_super_secret_jwt_key_college_project_2026_secured
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=1440
   ```

---

### 3. Backend Setup & Run (FastAPI)
1. Open terminal and navigate to `backend/`:
   ```powershell
   cd backend
   ```
2. Create and activate a virtual environment:
   ```powershell
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   ```
3. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```
4. Start the FastAPI server:
   ```powershell
   uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
   ```
5. Open interactive Swagger API docs in your browser:
   👉 **http://127.0.0.1:8000/docs**

> **Note**: On startup, tables and 6 sample job postings are automatically created in PostgreSQL!

---

### 4. Frontend Setup & Run (Flutter)
1. In the project root, install packages:
   ```powershell
   flutter pub get
   ```
2. Run Flutter static analysis (0 warnings guaranteed):
   ```powershell
   flutter analyze
   ```
3. Run the application:
   - For **Windows Desktop**:
     ```powershell
     flutter run -d windows
     ```
   - For **Chrome Web**:
     ```powershell
     flutter run -d chrome
     ```
   - For **Android Emulator**:
     ```powershell
     flutter run -d emulator-id
     ```

*(The `ApiConstants` automatically detects Android Emulator and connects via `10.0.2.2:8000`, while Desktop/Web connect via `127.0.0.1:8000`)*.

---

## 🎓 Viva & Interview Questions & Answers

**Q1: Why did you use `setState()` instead of Provider or Bloc?**
> *Answer:* `setState()` is Flutter's native, built-in state management mechanism. For a project with clean separation where each screen manages its own local state (like loading indicators, form validation, and filter selections), `setState()` avoids excessive boilerplate while keeping the code easy to trace and maintain.

**Q2: What is the purpose of the Repository layer?**
> *Answer:* The Repository acts as a mediator between the UI (StatefulWidgets) and the Data Source (`ApiService`). The screen never deals with raw HTTP URLs, JSON serialization, or headers. If the API endpoint format changes or offline database caching is added, we only modify the repository without touching the UI.

**Q3: How is authentication handled securely?**
> *Answer:* Passwords are never stored in plain text. The backend hashes them using `bcrypt` with automatic salting. On login, the server issues a signed JWT token containing the user ID and expiration timestamp. The Flutter client stores this token using `flutter_secure_storage` (which encrypts tokens using KeyStore on Android and Keychain on iOS) and attaches it in the `Authorization: Bearer <token>` header for protected endpoints.

**Q4: Which HTTP methods were implemented and for what?**
> *Answer:*
> - **GET**: Retrieve jobs, user profile, saved jobs, and submitted applications.
> - **POST**: User registration, login, bookmarking a job, and applying for a job.
> - **PUT**: Updating candidate profile details (name, phone, location).
> - **DELETE**: Removing a saved job from wishlist, and withdrawing a submitted application.

---

## 📝 Suggested Resume Description

```markdown
JobFinder — Full-Stack Job Portal Application
- Built a full-stack mobile application using Flutter, Dart, Python (FastAPI), and PostgreSQL.
- Implemented Clean Architecture with repository pattern, GoRouter declarative routing, and local setState() management.
- Integrated RESTful APIs supporting complete CRUD operations (GET, POST, PUT, DELETE) using the Dart http package.
- Secured user authentication using Bcrypt salted password hashing and JWT Bearer token authentication stored with flutter_secure_storage.
- Features include live debounced search, job filtering, bookmarked wishlist, application tracking, and profile management.
```

---

## 📷 Screenshots

| Splash & Login | Home Dashboard | Job Details & Apply | My Applications |
| :---: | :---: | :---: | :---: |
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

---

## 📄 License
This project is developed for educational and portfolio demonstration purposes. Feel free to use and customize it for your academic submissions.
