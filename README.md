# vCalendar

**vCalendar** is a professional, open-source task management and calendar application built using **Flutter** framework for desktop (Linux). The application features a modern and elegant design (Glassmorphism) and provides a seamless and efficient user experience for time management and appointment organization.

## ✨ Key Features

*   **Comprehensive Calendar Views**:
    *   **Monthly View**: An overview of the month with clear visual indicators for events.
    *   **Weekly View**: Precise scheduling with hourly time grid.
    *   **Daily View**: Complete details for the day, ideal for busy schedules.

*   **Flexible Event Management**:
    *   Add, edit, and delete events easily.
    *   Support for recurring events (daily, weekly, monthly, yearly).
    *   All-day events or time-specific events.

*   **Categorization and Customization**:
    *   Multiple event categories (work, personal, meetings, etc.).
    *   Color coding for each category for easy visual distinction.
    *   Ability to add and edit categories.

*   **Local Database**:
    *   Works efficiently without internet connection (Offline-first).
    *   Secure and reliable local storage using **Hive** database.

*   **Advanced Search**:
    *   Fast and efficient search for any event in the calendar.

*   **Modern User Interface**:
    *   Glassmorphism design that's easy on the eyes.
    *   Sidebar for quick navigation and easy access to event categories.
    *   Full support for dark mode.

## 🛠️ Technologies Used

The application is built using the latest technologies and best programming practices:

*   **Language and Framework**: [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
*   **Project Architecture**: **Clean Architecture** (complete separation between layers: Domain, Data, Presentation)
*   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
*   **Database**: [Hive](https://pub.dev/packages/hive) (NoSQL database)
*   **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
*   **Date Handling**: [intl](https://pub.dev/packages/intl)

## 🚀 Installation and Running

1.  Ensure Flutter SDK is installed on your machine.
2.  Clone the repository.
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the application on Linux:
    ```bash
    flutter run -d linux
    ```

## 🏗️ Building the Release Version

To build an executable file for Linux:
```bash
flutter build linux
```

