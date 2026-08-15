# Namma Maavu (Easy-Flour)

Namma Maavu (Easy-Flour) is a comprehensive flour mill and stock management application designed to streamline daily operations, track inventory, and manage sales effectively.

## Features

- **Authentication**: Secure Login and Signup functionality.
- **Dashboard**: Overview of key metrics and recent activities.
- **Inventory Management**:
  - **Rice Stock**: Track incoming and outgoing rice stock.
  - **Plant Stock**: Manage inventory at the processing plant level.
- **Production Management**: Log and monitor daily production details.
- **Sales Tracking**:
  - **Shop Sales**: Record sales directly from the shop.
  - **Other Sales**: Track additional miscellaneous sales.
- **Expense Management**: Log daily operational expenses.

## Tech Stack

### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **Routing**: GoRouter
- **Platform**: Android, iOS, Web, Desktop (Cross-platform)

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB (Mongoose)
- **Authentication**: JWT (JSON Web Tokens)

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Node.js](https://nodejs.org/)
- MongoDB (Local or Atlas)

### Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up your environment variables by creating a `.env` file based on `.env.example` (or configure your MongoDB URI and JWT Secret).
4. Start the server:
   ```bash
   npm run dev
   ```

### Frontend Setup
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Folder Structure
- `/frontend` - Contains the Flutter application code.
- `/backend` - Contains the Node.js/Express API and database models.

## License
This project is proprietary and confidential.