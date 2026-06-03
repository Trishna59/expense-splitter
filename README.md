# Expense Splitter App

A Flutter-based mobile application designed to simplify expense sharing among friends, roommates, travel groups, and colleagues. The application enables users to create groups, record shared expenses, calculate balances automatically, and generate optimized settlements with minimal transactions.

## Features

* Secure email/password authentication with email verification
* Create and manage expense-sharing groups
* Add, edit, and track shared expenses
* Automatic equal expense splitting with rounding adjustment
* Smart settlement engine that minimizes the number of transactions
* Real-time balance updates for all group members
* Offline support through Firestore local caching
* Firebase Firestore security rules for data protection

## Tech Stack

| Layer            | Technology                                |
| ---------------- | ----------------------------------------- |
| Framework        | Flutter                                   |
| Backend          | Firebase Authentication & Cloud Firestore |
| State Management | Riverpod                                  |
| Architecture     | Feature-First Clean Architecture          |

## Project Structure

```text
lib/
├── core/                # Shared utilities, themes, and constants
├── feature/
│   ├── auth/            # Authentication and user management
│   ├── group/           # Group creation and management
│   └── expense/         # Expense tracking and settlements
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Trishna59/expense-splitter.git
cd expense-splitter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project using Firebase Console.
2. Register an Android application.
3. Download the `google-services.json` file.
4. Place it inside the `android/app/` directory.
5. Generate Firebase configuration files:

```bash
flutterfire configure
```

This command will create the `firebase_options.dart` file required by the application.

### 4. Run the Application

```bash
flutter run
```

## Settlement Algorithm

The application uses a greedy two-pointer settlement algorithm to reduce the total number of transactions required between group members.

### Steps

1. Calculate each member's net balance:

```text
Net Balance = Amount Paid − Amount Owed
```

2. Separate users into:

   * Creditors (positive balance)
   * Debtors (negative balance)

3. Match the largest debtor with the largest creditor.

4. Record the settlement amount and update balances.

5. Continue until all balances become zero.

This approach efficiently minimizes the number of transactions required to settle all debts within a group.

## Future Enhancements

* Custom split percentages
* Unequal expense sharing
* Expense categories and analytics
* Receipt scanning with OCR
* Push notifications and reminders
* Multi-currency support
* Export reports to PDF and Excel

## License

This project is intended for educational and portfolio purposes.
