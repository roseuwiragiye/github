// import 'dart:js';


import 'package:connection_notifier/connection_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:github/Notification/notif_helper.dart';
import 'package:github/firebase_options.dart';
import 'package:github/models/db_connect.dart';
import 'package:github/screens/welcome_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'theme_config.dart';


void main() async {

  var db = DBconnect();

  // db.fetchQuestions();
  // db.addQuestion(
  //   Question(
  //   id: '4', 
  //   title: 'What is 20 + 10', 
  //   options: {'5': false, '90': false, '30': true, '10': false}),
  // );
  
  // Ensure that Firebase is initialized before runApp
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotifHelper.initNotif();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeStateProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    context.read<ThemeStateProvider>().getDarkTheme();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionNotifier(
      child: Consumer<ThemeStateProvider>(builder: (context, theme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: theme.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          home: WelcomeScreen(),
        );
      }),
    );
  }
  
}

final GoogleSignIn googleSignIn = GoogleSignIn();


