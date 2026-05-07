# SEV‑AI - ( An AI -Based Multilingual Symptom  Triage And HealthCare Guidance Platform  With Emergecny Escalation And Conversational Decision Support )

 SEV‑AI (Care Companion) repository — a multilingual, AI‑assisted healthcare platform combining a Flutter mobile app, a web-based conversational frontend, and a Java backend with IoT simulation components.

## Project Summary

- **What it is:** A healthcare application that provides AI‑assisted symptom analysis through a conversational interface. The platform supports role‑based experiences for **Users**, **Doctors** and **Admins** and includes features such as triage, alerts, hospital discovery, medication reminders and teleconsultation.
- **Primary technologies:** Flutter (mobile), TypeScript + Vite (web frontend chatbot), Java + Maven (backend), Docker for containerization and a small IoT simulator for ESP32 device testing.

## Key Features

- Multilingual AI chatbot for symptom triage and guided conversation.
- Role‑based UI and workflows: `User`, `Doctor`, `Admin`.
- Symptom triage and severity scoring with actionable recommendations.
- Teleconsultation support (video/voice integration points exist in app).
- Hospital discovery, alerts and push/notification hooks.
- Medication reminders and appointment scheduling.
- IoT simulator for device data ingestion (ESP32 simulator under `iot/`).

## Repository Structure

- `care-companion-ai/care-companion-ai-main/` — Web frontend Chatbot (Vite + TypeScript). Contains `package.json`, build config, and `src/`.
- `sevai-backend/` — Backend service (Java / Maven). Contains `pom.xml`, `src/main` (application code), Dockerfile and an ESP32 simulator in `iot/sevai_esp32_simulator/`.
- `Symptom_Triage-main/` — Flutter mobile application used as the user-facing mobile client.
- `assets/`, `build/`, `ios/`, `android/`, etc. — Flutter build artifacts and platform folders.

> Note: Each major component is intentionally separated so teams can develop, test and deploy independently.

## Getting Started — Prerequisites

- Node.js (16+) and a package manager: `npm`, `pnpm`, or `yarn` for the web frontend chatbot.
- Java 11+ and Maven wrapper (the repository includes `mvnw` / `mvnw.cmd`).
- Flutter SDK (stable) plus Android SDK / Xcode for mobile development.
- Docker (optional) for containerized backend or local integration testing.

## Setup & Run

1) Web frontend (care‑companion)

	 - Navigate to the frontend folder:

		 cd care-companion-ai/care-companion-ai-main

	 - Install dependencies and run the dev server (examples):

		 npm install
		 npm run dev

	 - Build for production:

		 npm run build

	 - Notes: the project uses Vite + TypeScript. If you prefer `pnpm` or `yarn`, substitute the install command.

2) Backend (sevai-backend)

	 - Navigate to the backend folder:

		 cd sevai-backend

	 - Run with the included Maven wrapper (Linux/macOS):

		 ./mvnw spring-boot:run

		 On Windows PowerShell:

		 .\mvnw.cmd spring-boot:run

	 - Build a jar:

		 ./mvnw package

	 - Run tests:

		 ./mvnw test

	 - Environment & config: check `src/main/resources/application*.properties` or the environment variable support in the backend. For production, set DB credentials, external API keys and JWT secrets in env vars or a secure vault.

	 - Docker: a `Dockerfile` is provided for container builds. Example:

		 docker build -t sevai-backend:latest .

3) Flutter mobile app (Symptom Triage)

	 - Navigate to the Flutter app:

		 cd Symptom_Triage-main

	 - Fetch dependencies and run on a connected device/emulator:

		 flutter pub get
		 flutter run -d <device-id>

	 - Build release artifacts:

		 flutter build apk
		 flutter build ios

	 - Testing: `flutter test`

## Environment Configuration

- The backend likely requires DB and external API keys. Look for `application.properties`/`application.yml` under `sevai-backend/src/main/resources` and set the matching environment variables before starting.
- The frontend may connect to a running backend URL; configure the base API URL in `src/` or in `.env` (frontend uses Vite environment conventions).

## Running Locally (suggested order)

1. Start the backend (`sevai-backend`) and ensure it can connect to any required DB or mock services.
2. Start the web frontend for conversational UI and testing with desktop browsers.
3. Run the Flutter app on a device or emulator to test mobile flows and push notification hooks.
4. Use the ESP32 simulator (`sevai-backend/iot/sevai_esp32_simulator`) to generate device telemetry and validate ingestion.

## Testing

- Backend unit/integration: `./mvnw test`.
- Web frontend: check `vitest` or `npm test` if present in `package.json`.
- Flutter: `flutter test`.

## Deployment Recommendations

- Backend: containerize with Docker and run behind a reverse proxy (Nginx) with TLS. Use environment variables for secrets and a managed database (Postgres/RDS).
- Web frontend: host static assets on a CDN or Vercel/Netlify after `npm run build`.
- Mobile: publish Android APK to Play Store and iOS build to App Store (follow Flutter publishing guides).

## Security & Privacy

- Protect PHI: ensure all personally identifiable or health information is encrypted in transit (TLS) and at rest as required.
- Authentication: use strong JWT secrets, short-lived tokens and role based access control (RBAC) for `User`, `Doctor`, and `Admin` roles.
- Logging: redact sensitive data from logs and use secure log aggregation with ACLs.

## Contributing

- Fork the repository, create feature branches and open pull requests with clear descriptions.
- Add unit tests for backend and frontend behavior where possible.
- Follow existing code style and linting rules in each component (see `eslint.config.js`, TypeScript config, and Flutter analysis options).

## Troubleshooting & Tips

- If the backend fails to start, check Java version and Maven wrapper permissions.
- If the Flutter app fails to connect to the backend, ensure the backend base URL is reachable from the device and that CORS and mobile network settings are correct.
- For frontend build issues, ensure Node and NPM versions are compatible with the `package.json` engines (if present).

## Acknowledgements

This project integrates multiple disciplines: mobile development (Flutter), web frontend (Vite/TypeScript), backend services (Java/Spring Boot) and lightweight IoT simulation. 

---
