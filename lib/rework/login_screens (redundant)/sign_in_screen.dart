// import 'package:ez_health/screens/login_screens/sign_in_widget.dart';
// import 'package:flutter/material.dart';

// class PatientSignInPage extends StatelessWidget {
//   const PatientSignInPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SignInWidget(
//       userType: 'Patient',
//       onUserTypeChange: (newUserType) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const DoctorSignInPage()),
//         );
//       },
//     );
//   }
// }

// class DoctorSignInPage extends StatelessWidget {
//   const DoctorSignInPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SignInWidget(
//       userType: 'Doctor',
//       onUserTypeChange: (newUserType) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const PatientSignInPage()),
//         );
//       },
//     );
//   }
// }
