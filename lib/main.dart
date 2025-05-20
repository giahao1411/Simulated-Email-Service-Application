import 'package:email_application/core/config/firebase_options.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/views/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppFunctions.debugPrint('Firebase initialized successfully');
  } on Exception catch (e) {
    AppFunctions.debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManage(),
      child: Consumer<ThemeManage>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Simulated Email App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                primary: Colors.red[700],
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                labelStyle: const TextStyle(color: Colors.black54),
                hintStyle: const TextStyle(color: Colors.black38),
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black87),
                bodyMedium: TextStyle(color: Colors.black87),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                primary: Colors.red[600],
                surface: Colors.grey[900],
                onSurface: Colors.white70,
              ),
              scaffoldBackgroundColor: Colors.grey[900],
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white60),
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white70),
                bodyMedium: TextStyle(color: Colors.white70),
              ),
            ),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
