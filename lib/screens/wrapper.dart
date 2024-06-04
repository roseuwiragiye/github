// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:github/Home_Page.dart';
// import 'package:github/screens/login_screen.dart';
// import 'package:github/screens/welcome_screen.dart';

// class Wrapper extends StatefulWidget {
//   const Wrapper({super.key});

//   @override
//   State<Wrapper> createState() => __WrapperState();
// }

// class __WrapperState extends State<Wrapper> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Something went wrong'),
//             );
//           } else if (snapshot.hasData) {
//             return HomeScreen();
//           } else {
//             return LoginScreen();
//           }
//         },
//       ),
//     );
//   }
// }