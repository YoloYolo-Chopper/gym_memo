import 'package:flutter/material.dart';
import 'package:gym_memo/screens/add_screen.dart';
import 'package:gym_memo/screens/home_screen.dart';
import 'package:gym_memo/screens/training_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFfeb854)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFfeb854),
          selectedItemColor: Color(0xFF113F67),
          unselectedItemColor: Color(0xFF111111),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/add': (context) => const AddScreen(),
        '/training': (context) => const TrainingScreen(),

      },

    );
  }
}
