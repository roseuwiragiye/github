// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:github/Home_Page.dart';
// import 'package:github/screens/welcome_screen.dart';

// class AuthPage extends StatelessWidget {
//   const AuthPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return HomeScreen();
//           } else if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong!'));
//           } else {
//             return const WelcomeScreen();
//           }
//         },
//       ),
//     );
//   }
//   }