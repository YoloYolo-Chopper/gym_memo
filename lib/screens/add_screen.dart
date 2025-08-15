import 'package:flutter/material.dart';
import 'package:gym_memo/components/bottom_nav_bar.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  List<String> workout = [
    'ミリタリープレス',
    'ショルダープレス',
    'アーノルドプレス',
    'ニーリングショルダープレス ',
    'シーテッドショルダープレス ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2025/08/15'),
        backgroundColor: Color(0xFFfeb854),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFfeb854),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      '背中',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // backgroundColor: Color(0xFFfeb854),
                      ),
                    ),
                  ),
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: workout.map(
                        (i) => ListTile(title: Text(i), onTap: () {
                          print('$i got tapped!');
                          Navigator.pushNamed(context, '/training');
                        }),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white, size: 30, weight: 700),
          backgroundColor: Color(0xFFfeb854),
          elevation: 0,
          onPressed: () {
            print('test');
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
