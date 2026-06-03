 Expense Splitter App

A Flutter mobile application for splitting expenses among groups of friends, 
roommates, or colleagues. Built with Firebase and Riverpod.

 Features

- Email/password authentication with email verification
- Create and manage groups (trips, events, shared living)
- Add and track shared expenses
- Equal split calculations with rounding handling
- Smart settlement engine — minimizes number of transactions
- Real-time balance tracking per member
- Offline support via Firestore cache
- Firestore security rules

 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| Backend | Firebase (Auth + Firestore) |
| State Management | Riverpod |
| Architecture | Feature-first Clean Architecture |

Project Structure

\`\`\`
lib/
├── core/               # Shared theme and utilities
├── feature/
│   ├── auth/           # Authentication flow
│   ├── group/          # Group management
│   └── expense/        # Expense tracking & settlements
\`\`\`

Getting Started

1. Clone the repository
\`\`\`bash
git clone https://github.com/Trishna59/expense-splitter.git
\`\`\`

2. Install dependencies
\`\`\`bash
flutter pub get
\`\`\`

3. Set up Firebase
- Create a Firebase project at console.firebase.google.com
- Add an Android app and download \`google-services.json\`
- Place it in \`android/app/\`
- Run \`flutterfire configure\` to generate \`firebase_options.dart\`

4. Run the app
\`\`\`bash
flutter run
\`\`\`


Settlement Algorithm

The app uses a greedy two-pointer algorithm to minimize transactions:

1. Calculate net balance per person (paid − owed)
2. Separate into creditors (+) and debtors (−)
3. Match largest debtor with largest creditor
4. Repeat until all balances reach zero
