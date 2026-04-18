# E-Ebeveyn: Smart Baby Tracker & AI Coach 🍼✨

E-Ebeveyn is a modern Flutter application built with **Clean Architecture** principles, allowing parents to synchronize and track their baby's development, feeding, and sleep schedules on a single screen.

## 🚀 Project Goal and Architectural Approach
This project is built using a **Feature-First Clean Architecture** to establish a sustainable and scalable software architecture. Data management, UI, and business logic are completely isolated from each other.

### 🛠️ Tech Stack
* **Framework:** Flutter & Dart
* **State Management:** Riverpod (Hooks & Notifiers)
* **Backend & BaaS:** Supabase (PostgreSQL, Auth, Storage)
* **Local Database:** Realm (For offline-first capabilities)
* **Architecture:** Clean Architecture (Domain, Data, Presentation layers)

## 📸 Screenshots
<p align="center">
  <img src="YOUR_SCREENSHOT_LINK_1" width="200"/>
  <img src="YOUR_SCREENSHOT_LINK_2" width="200"/>
  <img src="YOUR_SCREENSHOT_LINK_3" width="200"/>
</p>

## 🔥 Key Features
* **Supabase Realtime:** Instant data synchronization between family members (Mother, Father, Caregiver).
* **Riverpod Caching:** Optimized state management to prevent unnecessary API requests.
* **Custom Audio Player:** Background-running, loop-supported sleep sounds engine.
* **AI Integration:** An AI coach assistant that analyzes baby data and provides personalized insights to parents.

## ⚙️ How to Run
1. Clone the repo: `git clone https://github.com/clbieren/E-Ebeveyn.git`
2. Install dependencies: `flutter pub get`
3. Enter your Supabase credentials in the `lib/config/` directory.
4. Run the project: `flutter run`


## 📁 Folder Structure (Feature-First Clean Architecture)
Our project strictly follows Clean Architecture principles to separate business logic from UI, ensuring high maintainability and scalability.

```text
lib/
├── core/               # Shared utilities, routing, themes, and network services
├── features/           # Feature-based modules (e.g., auth, sleep, vaccine)
│   ├── data/           # DTOs, Data Sources (Supabase, Realm), Repositories Impl
│   ├── domain/         # Entities, Repository Interfaces, UseCases
│   └── presentation/   # UI Screens, Custom Widgets, Riverpod Providers
├── config/             # Environment variables and API keys
└── main.dart           # App entry point