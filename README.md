<div align="center">
  <h1>🍼 E-Ebeveyn: Smart Baby Tracker & AI Coach</h1>
  <p><i>Enterprise-grade parenting platform built with Feature-First Clean Architecture</i></p>

  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/Architecture-Clean-success?style=for-the-badge" />
  <img src="https://img.shields.io/badge/State_Management-Riverpod-orange?style=for-the-badge" />
</div>

<br/>

## 🚀 Overview
E-Ebeveyn is not just a baby tracker; it is a fully synchronized, AI-powered parental ecosystem. Designed to reduce parental anxiety, the app offers real-time synchronization between family members, a robust offline-first database, and an AI coaching system, all wrapped in a highly intuitive, premium dark-mode UI.

## 🧠 Architecture Deep Dive (Feature-First Clean Architecture)
To ensure maximum scalability, testability, and separation of concerns, the project strictly adheres to **Clean Architecture**. 

* **Presentation Layer:** Contains completely dumb UI components. State is managed reactively via `Riverpod`, ensuring widget rebuilds are kept to an absolute minimum.
* **Domain Layer:** The heart of the application. Contains enterprise-wide business rules (`Entities`) and application-specific business rules (`UseCases`). Completely independent of any external frameworks.
* **Data Layer:** Handles all external communications. Uses a `Repository Pattern` to abstract data sources (`Supabase` for cloud, `Realm` for local caching).

### 🔄 Data Flow:
`UI (Widget) ➔ Riverpod (Notifier) ➔ UseCase ➔ Repository ➔ Remote/Local DataSource`

## 📸 Premium UI Mocks
<p align="center">
  <img src="https://github.com/user-attachments/assets/2f38c7ce-cb33-415e-a488-0724ddab7fc0" width="250" alt="Home Screen"/>
  <img src="https://github.com/user-attachments/assets/d211e7f0-7560-4b45-ba9d-5bd3af2a9fe3" width="250" alt="AI Coach"/>
  <img src="https://github.com/user-attachments/assets/b1c36ab2-1941-4aa3-a5f0-1739ef3e7f47" width="250" alt="Vaccine Tracker"/>
</p>

## 🔥 Core Engineering Features
* **Realtime Sync (Supabase):** Family mode allows parents and caregivers to see feeding or sleep data update instantly across multiple devices without manual refreshes.
* **Offline-First Capabilities (Realm):** Even in areas with no internet, parents can log critical data. The system automatically syncs with the Supabase backend once the connection is restored.
* **Memory-Optimized Audio Engine:** A custom-built, background-running audio player for the Sleep Library that uses minimal RAM while playing continuous white noise/colic frequencies.
* **AI Behavioral Analysis:** Integration of an AI engine that reads the child's logged data (fever, sleep gaps, feeding) and generates proactive, personalized medical alerts and advice.

## ⚙️ How to Build & Run
1. Clone the repository:
   ```bash
   git clone [https://github.com/KULLANICI_ADIN/e-ebeveyn.git](https://github.com/KULLANICI_ADIN/e-ebeveyn.git)
