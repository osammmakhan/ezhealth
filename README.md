# ez_health

A new Flutter project for managing health appointments and payments.

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)

### Installation

1. **Clone the repository:**

    ```sh
    git clone https://github.com/your-repo/ez_health.git
    cd ez_health
    ```

2. **Install dependencies:**

    ```sh
    flutter pub get
    ```

3. **Set up Firebase:**

    Ensure you have a Firebase project set up and update the `google-services.json` and `GoogleService-Info.plist` files in your project.

4. **Run the application:**

    ```sh
    flutter run
    ```

## Project Structure

- **lib/main.dart:** Entry point of the application.
- **lib/onboarding_screen.dart:** Onboarding screen for new users.
- **lib/auth.dart:** Authentication screen for sign in and sign up.
- **lib/patient/appointment/patient_appointment_screen.dart:** Screen for managing patient appointments.
- **lib/patient/appointment/patient_details_screen.dart:** Screen for entering patient details.
- **lib/patient/payment/payment_methods_screen.dart:** Screen for managing payment methods.
- **lib/patient/payment/payment_details_screen.dart:** Screen for entering payment details.
- **lib/patient/patient_home_screen.dart:** Home screen for patients.
- **lib/admin/admin_home_screen.dart:** Home screen for admin users.
- **lib/doctor/doctor_home_screen.dart:** Home screen for doctors.
- **lib/notification_screen.dart:** Screen for displaying notifications.
- **lib/providers/appointment_provider.dart:** Provider for managing appointment state.
- **lib/providers/payment_provider.dart:** Provider for managing payment state.
- **lib/services/firebase_service.dart:** Service for interacting with Firebase.

## Firebase Integration

The project uses Firebase for authentication, Firestore for database, and Firebase Storage for storing files. Ensure you have the Firebase project set up and the necessary configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) in place.

## Running Tests

To run tests, use the following command:

```sh
flutter test
