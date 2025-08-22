import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_memo/screens/day_record_screen.dart';
import 'package:provider/provider.dart';

import 'package:gym_memo/screens/home_screen.dart';
import 'package:gym_memo/screens/variation_screen.dart';
import 'package:gym_memo/screens/record_screen.dart';
import 'package:gym_memo/screens/shop_screen.dart';
import 'package:gym_memo/screens/training_screen.dart';

import 'package:gym_memo/components/bottom_nav_bar.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return BottomNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => HomeScreen()),
        GoRoute(path: '/day', builder: (context, state) => DayRecordScreen()),
        GoRoute(path: '/record', builder: (context, state) => RecordScreen()),
        GoRoute(path: '/shop', builder: (context, state) => ShopScreen()),
        GoRoute(
          path: '/training/:variationName',
          builder: (context, state) {
            final String variationName = state.pathParameters['variationName']!;
            return TrainingScreen(variationName: variationName);
          },
        ),
        GoRoute(
          path: '/variation',
          builder: (context, state) => VariationScreen(),
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
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
    );
  }
}
