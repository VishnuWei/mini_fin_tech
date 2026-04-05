# Smart Spend & Auto-Save

## Overview
Smart Spend & Auto-Save is a mobile-first fintech application that helps users:
- Track daily expenses
- Analyze spending patterns
- Set savings goals
- Receive intelligent weekly auto-save recommendations

The system is designed with a focus on real-world reliability, including offline support, duplicate prevention, and meaningful financial insights.

## Features
- Expense tracking with categories and metadata
- Savings goal management
- Weekly auto-save recommendation engine
- Dashboard with spending analytics
- Insights and alerts
- Offline-first support with sync
- Duplicate submission prevention (idempotency)

## Tech Stack
### Frontend
- Flutter

### Backend
- Node.js (Express)

### Database
- PostgreSQL / MongoDB

## Setup Instructions

### 1. Clone the repository
git clone <your-repo-url>
cd smart-spend-auto-save

### 2. Backend Setup
cd backend
npm install

Create a `.env` file:
PORT=3000
DB_URI=<your_database_connection>

Run backend:
npm start

### 3. Flutter App Setup
cd mobile_app
flutter pub get

Run app:
flutter run

## Run Instructions
- Ensure backend is running
- Update API base URL if needed
- Launch app
- Add income and goal
- Add expenses
- View dashboard

## Assumptions
- Manual expense entry
- Fixed monthly income
- Predefined categories
- Offline support required
- Rule-based recommendation logic

## Trade-offs
- Focus on backend over UI polish
- Rule-based instead of ML
- Limited insights due to time
