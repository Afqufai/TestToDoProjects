# Workspace Issue & Task Tracker

A comprehensive full-stack application for managing workspace projects and tracking tasks with seamless collaboration across web and mobile platforms. Built with modern technologies including **ASP.NET Core 8.0**, **Next.js 16**, and **Flutter**.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-Production%20Ready-success.svg)

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Local Setup Instructions](#local-setup-instructions)
  - [Backend (.NET)](#backend-net-core-80)
  - [Web Frontend (Next.js)](#web-frontend-nextjs-16)
  - [Mobile Frontend (Flutter)](#mobile-frontend-flutter)
- [Running the Application](#running-the-application)
- [Deployment](#deployment)
- [API Documentation](#api-documentation)
- [Architecture & Design](#architecture--design)
- [Contributing](#contributing)

---

## Features

### Authentication & Security
- ✅ JWT Bearer Token authentication
- ✅ Secure password hashing with ASP.NET Identity
- ✅ User registration and login flows
- ✅ Automatic token refresh handling
- ✅ Protected API endpoints

### Project Management
- ✅ Create, read, update, and delete projects
- ✅ Project search and filtering
- ✅ Detailed project descriptions
- ✅ Project creation timestamps

### Task Management
- ✅ Task lifecycle: To Do → In Progress → Done
- ✅ Task creation, editing, and deletion
- ✅ Task status tracking
- ✅ Task descriptions and details
- ✅ Kanban-style board view
- ✅ Quick task status transitions

### User Experience
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ Real-time error notifications
- ✅ Loading states and skeleton screens
- ✅ Intuitive navigation
- ✅ Clean, modern UI with dark theme

---

## Tech Stack

### Backend
| Technology | Version | Purpose |
|------------|---------|---------|
| **ASP.NET Core** | 8.0 LTS | Web API framework |
| **C#** | 12 | Language |
| **PostgreSQL** | 14+ | Relational database |
| **Entity Framework Core** | 8.0 | ORM for Create/Update/Delete |
| **Dapper** | 2.0+ | Micro-ORM for Read operations |
| **JWT Bearer** | Built-in | Authentication |
| **Serilog** | 3.0+ | Structured logging |

### Web Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| **Next.js** | 16 | React framework with App Router |
| **React** | 19 | UI library |
| **TypeScript** | 5 | Type safety |
| **Tailwind CSS** | 4 | Utility-first CSS |
| **Provider** | 6.0 | State management (React Context API) |
| **Fetch API** | Native | HTTP client |

### Mobile Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.19+ | Cross-platform mobile framework |
| **Dart** | 3.3+ | Programming language |
| **Provider** | 6.0 | State management |
| **Dio** | 5.3+ | HTTP client |
| **Shared Preferences** | 2.2+ | Local storage |

---

## Project Structure

```
WebTestMagang/
├── Program.cs                          # .NET Backend
├── appsettings.json                   # Configuration
├── Controllers/                        # API endpoints
│   ├── AuthController.cs
│   ├── ProjectController.cs
│   └── TaskController.cs
├── Services/                           # Business logic
│   └── TokenService.cs
├── Data/                               # Database
│   ├── AppDbContext.cs
│   └── DbConnectionFactory.cs
├── Models/
│   ├── Entities/
│   │   ├── User.cs
│   │   ├── Project.cs
│   │   └── TaskItem.cs
│   ├── DTOs/
│   │   ├── Auth/
│   │   ├── Project/
│   │   └── Task/
│   └── Enums/
│       └── TaskStatus.cs
├── Repositories/                       # Data access layer
│   ├── Interfaces/
│   └── Implementations/
├── Middleware/
│   └── ExceptionHandlingMiddleware.cs
│
├── frontend/                           # Next.js Web Frontend
│   ├── src/
│   │   ├── app/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx
│   │   │   ├── login/
│   │   │   ├── dashboard/
│   │   │   └── projects/
│   │   ├── components/
│   │   │   ├── Navbar.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── ProjectForm.tsx
│   │   │   └── TaskForm.tsx
│   │   ├── context/
│   │   │   ├── AuthContext.tsx
│   │   │   └── ToastContext.tsx
│   │   └── utils/
│   │       └── api.ts
│   ├── package.json
│   └── tailwind.config.ts
│
└── mobile/                             # Flutter Mobile Frontend
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── project_model.dart
    │   │   ├── task_model.dart
    │   │   └── auth_response_model.dart
    │   ├── services/
    │   │   └── api_service.dart
    │   ├── providers/
    │   │   ├── auth_provider.dart
    │   │   ├── project_provider.dart
    │   │   └── task_provider.dart
    │   └── screens/
    │       ├── login_screen.dart
    │       ├── register_screen.dart
    │       ├── project_list_screen.dart
    │       └── project_detail_screen.dart
    └── pubspec.yaml
```

---

## Prerequisites

### Required Software
- **Git** - Version control
- **.NET SDK** - v8.0 or higher ([Download](https://dotnet.microsoft.com/download))
- **Node.js** - v18 or higher with npm ([Download](https://nodejs.org))
- **PostgreSQL** - v14 or higher ([Download](https://www.postgresql.org/download))
- **Flutter SDK** - v3.19 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Android Studio** or **Xcode** - For Flutter mobile development

### System Requirements
- **RAM**: Minimum 8 GB (16 GB recommended)
- **Disk Space**: 5 GB free
- **OS**: Windows, macOS, or Linux

### Accounts
- GitHub account (optional, for repository)
- IDE/Editor: VS Code, Visual Studio, or Android Studio

---

## Local Setup Instructions

### Backend (.NET Core 8.0)

#### 1. Prerequisites
```bash
# Verify .NET installation
dotnet --version  # Should be 8.0.0 or higher

# Verify PostgreSQL is running
# On Windows, start PostgreSQL service
# On macOS/Linux: brew services start postgresql (if using Homebrew)
```

#### 2. Database Setup
```bash
# Create PostgreSQL database
psql -U postgres -c "CREATE DATABASE WorkspaceTrackerDb;"

# If needed, set password for postgres user
psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```

#### 3. Restore & Build
```bash
cd WebTestMagang

# Restore NuGet packages
dotnet restore

# Apply EF Core migrations
dotnet ef database update

# Build the project
dotnet build
```

#### 4. Configuration
The `appsettings.json` is pre-configured. Update if needed:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=WorkspaceTrackerDb;Username=postgres;Password=postgres"
  },
  "Jwt": {
    "Key": "SuperSecretKeyNeedsToBeAtLeast32BytesLongForHS256Algorithm!",
    "Issuer": "WorkspaceTrackerApi",
    "Audience": "WorkspaceTrackerClients",
    "ExpireMinutes": 60
  }
}
```

#### 5. Run Backend
```bash
# Start development server (with auto-reload)
dotnet watch run

# Or without watch
dotnet run

# Server runs on: http://localhost:5000
# Swagger UI available at: http://localhost:5000/swagger
```

---

### Web Frontend (Next.js 16)

#### 1. Navigate to Frontend Directory
```bash
cd frontend
```

#### 2. Install Dependencies
```bash
npm install
# or
yarn install
```

#### 3. Environment Configuration
```bash
# Copy environment template
cp .env.local.example .env.local

# Edit .env.local (if backend is on different port/host)
# NEXT_PUBLIC_API_URL=http://localhost:5000
```

#### 4. Run Development Server
```bash
npm run dev
# or
yarn dev

# Application runs on: http://localhost:3000
```

#### 5. Build for Production
```bash
npm run build
npm start

# Or using yarn
yarn build
yarn start
```

#### 6. API Integration
The app automatically connects to backend at `http://localhost:5000`. JWT tokens are stored in localStorage and automatically injected into all API requests via the `api.ts` utility.

**Key Files:**
- `src/utils/api.ts` - API wrapper with authentication
- `src/context/AuthContext.tsx` - Authentication state
- `src/context/ToastContext.tsx` - Notifications

---

### Mobile Frontend (Flutter)

#### 1. Verify Flutter Installation
```bash
# Check Flutter version
flutter --version  # v3.19.0 or higher

# Get Flutter dependencies
flutter pub global activate

# Check for issues
flutter doctor
```

#### 2. Navigate to Mobile Directory
```bash
cd mobile
```

#### 3. Get Dependencies
```bash
flutter pub get
```

#### 4. Update API Configuration
Edit `lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'http://localhost:5000';

// For physical device, use your machine's IP address:
// static const String _baseUrl = 'http://192.168.x.x:5000';
```

#### 5. Run on Emulator/Device
```bash
# List available devices
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with verbose logging
flutter run -v
```

#### 6. Build Release APK (Android)
```bash
# Generate signed APK
flutter build apk --release

# APK location: build/app/outputs/flutter-app/release/app-release.apk

# Or build App Bundle (for Google Play)
flutter build appbundle --release
```

#### 7. Build Release IPA (iOS)
```bash
# Generate IPA
flutter build ios --release

# Then follow Xcode prompts for signing and distribution
```

---

## Running the Application

### Start All Services
```bash
# Terminal 1: Start .NET Backend
cd WebTestMagang
dotnet watch run
# → http://localhost:5000

# Terminal 2: Start Next.js Frontend
cd frontend
npm run dev
# → http://localhost:3000

# Terminal 3: Start Flutter Mobile (optional)
cd mobile
flutter run
```

### Access Points
- **API Documentation** (Swagger): http://localhost:5000/swagger
- **Web Application**: http://localhost:3000
- **Mobile Application**: Emulator/Physical Device

### Test Account (After Running)
1. Navigate to web frontend at http://localhost:3000
2. Click "Sign Up"
3. Create test account:
   - **Username**: testuser
   - **Email**: test@example.com
   - **Password**: TestPassword123
4. Create projects and tasks

---

## Deployment

### Backend (.NET Core)
```bash
# Publish for production
dotnet publish -c Release -o ./publish

# Deploy to Azure App Service, AWS, or Docker:
docker build -t workspace-tracker-api .
docker run -p 5000:5000 workspace-tracker-api
```

### Web Frontend (Next.js)
```bash
# Build for production
npm run build

# Deploy to Vercel (recommended)
npm install -g vercel
vercel

# Or build and run standalone
npm start

# Deploy to other platforms (Netlify, Docker, etc.)
```

### Mobile (Flutter)
```bash
# Android Play Store
flutter build appbundle --release
# Submit via Google Play Console

# iOS App Store
flutter build ios --release
# Submit via App Store Connect via Xcode
```

### Docker Compose (All Services)
Create `docker-compose.yml` in root directory:
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: WorkspaceTrackerDb
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - postgres
    environment:
      ConnectionStrings__DefaultConnection: "Host=postgres;Database=WorkspaceTrackerDb;Username=postgres;Password=postgres"

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://backend:5000

volumes:
  postgres_data:
```

Run with: `docker-compose up`

---

## API Documentation

### Base URL
```
http://localhost:5000
```

### Authentication
All protected endpoints require JWT token in header:
```
Authorization: Bearer <token>
```

### Endpoints

#### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login and get JWT token |

#### Projects
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/projects` | Get all projects (Dapper - read) |
| GET | `/api/projects/{id}` | Get project by ID (Dapper - read) |
| POST | `/api/projects` | Create project (EF Core - CUD) |
| PUT | `/api/projects/{id}` | Update project (EF Core - CUD) |
| DELETE | `/api/projects/{id}` | Delete project (EF Core - CUD) |

#### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/projects/{id}/tasks` | Get tasks for project (Dapper - read) |
| GET | `/api/tasks/{id}` | Get task by ID (Dapper - read) |
| POST | `/api/tasks` | Create task (EF Core - CUD) |
| PUT | `/api/tasks/{id}` | Update task (EF Core - CUD) |
| DELETE | `/api/tasks/{id}` | Delete task (EF Core - CUD) |

### Example Requests

#### Register
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Password123"
  }'
```

#### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "Password123"
  }'
```

#### Create Project
```bash
curl -X POST http://localhost:5000/api/projects \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Project",
    "description": "Project description"
  }'
```

---

## Architecture & Design

### Design Patterns
- **Repository Pattern** - Data abstraction layer
- **Provider Pattern** - State management (Frontend)
- **Dependency Injection** - Loose coupling
- **DTO Pattern** - Data transfer objects for API
- **Service Layer** - Business logic separation

### Database Design
```sql
-- Users Table
CREATE TABLE "Users" (
  "Id" UUID PRIMARY KEY,
  "Username" VARCHAR(50) UNIQUE NOT NULL,
  "Email" VARCHAR(100) UNIQUE NOT NULL,
  "PasswordHash" VARCHAR(255) NOT NULL,
  "CreatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Projects Table
CREATE TABLE "Projects" (
  "Id" UUID PRIMARY KEY,
  "Name" VARCHAR(100) NOT NULL,
  "Description" VARCHAR(500),
  "CreatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks Table
CREATE TABLE "Tasks" (
  "Id" UUID PRIMARY KEY,
  "Title" VARCHAR(150) NOT NULL,
  "Description" VARCHAR(1000),
  "Status" VARCHAR(20) NOT NULL, -- 'Todo', 'InProgress', 'Done'
  "ProjectId" UUID NOT NULL,
  "CreatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY ("ProjectId") REFERENCES "Projects"("Id") ON DELETE CASCADE
);
```

### SOLID Principles
- **S**ingle Responsibility - Each class has one purpose
- **O**pen/Closed - Open for extension, closed for modification
- **L**iskov Substitution - Interfaces properly implemented
- **I**nterface Segregation - Specific interfaces for clients
- **D**ependency Inversion - Depend on abstractions, not implementations

---

## Troubleshooting

### Backend Issues
```bash
# Database connection failed
# Solution: Verify PostgreSQL is running
sudo service postgresql status  # Linux
brew services list  # macOS

# EF Core migrations failed
dotnet ef database drop --force
dotnet ef database update

# Port 5000 already in use
dotnet run --urls="http://localhost:5001"
```

### Frontend Issues
```bash
# Dependencies not installing
rm -rf node_modules package-lock.json
npm install

# Port 3000 already in use
npm run dev -- -p 3001

# API connection errors
# Check NEXT_PUBLIC_API_URL in .env.local
# Verify backend is running at http://localhost:5000
```

### Mobile Issues
```bash
# Flutter doctor issues
flutter doctor -v
flutter pub global activate -sgit https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification.git

# Device not detected
flutter devices
adb devices  # For Android

# Build errors
flutter clean
flutter pub get
flutter run
```

---

## Contributing

### Code Style
- Follow language conventions (.NET, TypeScript, Dart)
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/your-feature

# Commit with clear messages
git commit -m "Add: description of changes"

# Push and create Pull Request
git push origin feature/your-feature
```

### Testing
- Write unit tests for services
- Test API endpoints with Postman/cURL
- Test UI on multiple screen sizes
- Verify error handling and edge cases

---

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) file for details.

---

## Support & Contact

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation
- Review API documentation at `/swagger`

---

## Changelog

### Version 1.0.0 (June 2026)
- Initial release
- Full backend API with JWT authentication
- Next.js web frontend with dark theme
- Flutter mobile frontend for iOS/Android
- Complete CRUD operations for Projects and Tasks
- Real-time error handling and notifications
- Production-ready deployment configurations

---

## Acknowledgments

- ASP.NET Core team for the excellent framework
- Next.js and Vercel for modern React tooling
- Flutter team for cross-platform mobile development
- Community libraries and open-source projects

---

**Last Updated**: June 2026  
**Version**: 1.0.0  
**Status**: Production Ready ✅
