import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VariationScreen extends StatefulWidget {
  const VariationScreen({super.key});


  @override
  State<VariationScreen> createState() => _VariationScreenState();
}

class _VariationScreenState extends State<VariationScreen> {
  final List<String> workout = const [
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
        title: const Text('Select Variation'),
        centerTitle: true,
        backgroundColor: const Color(0xFFfeb854),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias, // <- header corners look right
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFfeb854),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '背中',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView(
                    padding: EdgeInsets.zero, // <- removes default insets
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: workout.map(
                            (i) => ListTile(
                          title: Text(i),
                          onTap: () {
                            // navigate to training
                            context.go('/training/$i');
                          },
                        ),
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
          backgroundColor: const Color(0xFFfeb854),
          elevation: 0,
          onPressed: () {
            // add new item etc.
          },
          child: const Icon(Icons.add, color: Colors.white, size: 30, weight: 700),
        ),
      ),
    );
  }
}