import 'package:bringapp_admin_web_portal/authentication/login_screen.dart';
import 'package:bringapp_admin_web_portal/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
//  await Firebase.initializeApp();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Auto-selects correct config
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Администратор',
      theme: ThemeData(
        // Основные цвета
        primaryColor: const Color(0xFF003366), // Темно-синий (Primary)
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF003366), // Темно-синий (AppBar, основные элементы)
          secondary: Color(0xFF0066CC), // Синий (Акцентные кнопки, элементы)
          onPrimary: Colors.white, // Белый (Текст/иконки на primary)
          onSecondary: Colors.white, // Белый (Текст/иконки на secondary)
        ),
        // Настройка AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366), // Темно-синий фон
          foregroundColor: Colors.white, // Белый текст/иконки
          elevation: 4, // Тень
        ),
        // Настройка кнопок
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066CC), // Синий фон кнопок
            foregroundColor: Colors.white, // Белый текст
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Настройка плавающей кнопки (FAB)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0066CC), // Синий
          foregroundColor: Colors.white, // Белый
        ),
        // Настройка текстовых полей (InputDecoration)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF003366)),
        
        ))),
        home: //FirebaseAuth.instance.currentUser == null
            const LoginScreen()
        //    const HomeScreen(),
        );
  }
}
