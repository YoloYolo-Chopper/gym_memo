import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_memo/data/local_db.dart';

class DayRecordScreen extends StatefulWidget {
  const DayRecordScreen({super.key});

  @override
  State<DayRecordScreen> createState() => _DayRecordScreenState();
}

class _DayRecordScreenState extends State<DayRecordScreen> {
  late String today;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    today = '${now.year}-${now.month}-${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(today),
        backgroundColor: const Color(0xFFfeb854),
        elevation: 0,
      ),
      body: SafeArea(child: Container()),
      floatingActionButton: SizedBox(
        width: 80,
        height: 70,
        child: FloatingActionButton(
          backgroundColor: Color(0xFFfeb854),
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white, size: 30, weight: 900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          onPressed: () {
            context.go('/variation');
          },
        ),
      ),
    );
  }
}
