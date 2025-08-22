import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfeb854),
      appBar: AppBar(
        title: const Text('Workout Memo'),
        backgroundColor: Color(0xFFfeb854),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFFffffff),
                ),
                margin: EdgeInsets.all(20),
              ),
              SizedBox(height: 5),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  fixedSize: Size(380, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  context.go('/day');
                },
                icon: Icon(Icons.add_circle, size: 40),
                label: Text('本日のトレーニングを追加', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

      ),
    );
  }
}




