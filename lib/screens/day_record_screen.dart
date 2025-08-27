import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../data/db.dart';

class DayRecordScreen extends StatefulWidget {
  const DayRecordScreen({super.key});

  @override
  State<DayRecordScreen> createState() => _DayRecordScreenState();
}

class _DayRecordScreenState extends State<DayRecordScreen> {
  late String today;

  late Future<List<Map<String, dynamic>>> _rowsFuture;

  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _tomorrowStart => _todayStart.add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    today = '${now.year}-${now.month}-${now.day}';
    _rowsFuture = _fetchTodayRows();
  }

  Future<List<Map<String, dynamic>>> _fetchTodayRows() async {
    final Database db = await AppDb().database;
    final startIso = _todayStart.toIso8601String();
    final endIso = _tomorrowStart.toIso8601String();
    return db.query(
      'entries',
      where: 'date >= ? AND date < ?',
      whereArgs: [startIso, endIso],
      orderBy: 'exercise ASC, variation ASC, date ASC, id ASC',
    );
  }

  @override
  Widget build(BuildContext context) {
    String _formatTime(String iso) {
      if (iso.isEmpty) return '';
      try {
        final dt = DateTime.parse(iso);
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        return '$hh:$mm';
      } catch (_) {
        return '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(today),
        centerTitle: true,
        backgroundColor: const Color(0xFFfeb854),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rowsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) {
            return const Center(child: Text('No entries for today'));
          }

          final grouped = groupBy<Map<String, dynamic>, String>(
            rows,
            (r) => '${r['exercise'] ?? ''}||${r['variation'] ?? ''}',
          );

          final groupKeys = grouped.keys.toList()..sort();

          return ListView.separated(
            itemCount: groupKeys.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final key = groupKeys[index];
              final parts = key.split('||');
              final exercise = parts.isNotEmpty ? parts[0] : '';
              final variation = parts.length > 1 ? parts[1] : '';
              final items = grouped[key] ?? const [];

              return ExpansionTile(
                initiallyExpanded: true,
                leading: const Icon(Icons.fitness_center),
                title: Text('$exercise - $variation'),
                children: [
                  // TODO ? what is ... for?
                  ...items.map((row) {
                    final time = _formatTime(row['date'] as String? ?? '');
                    final set = row['set'] ?? row['set_no'] ?? '';
                    final weight = row['weight'] ?? 0;
                    final reps = row['reps'] ?? 0;
                    final note = (row['note'] ?? '').toString();
                    return ListTile(
                      // TODO test when dense is false
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Text(time),
                      title: Text('Set $set'),
                      subtitle: Text(
                        'Weight: ${weight.toString()} kg, Reps: ${reps.toString()}',
                      ),
                      trailing: note.isEmpty
                          ? null
                          : const Icon(Icons.sticky_note_2_outlined),
                      onTap: () {
                        // TODO: what Uri.encodeComponent does?
                        context.pushNamed(
                          'training',
                          pathParameters: {'variation': variation},
                        );
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 70,
        child: FloatingActionButton(
          backgroundColor: Color(0xFFfeb854),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          onPressed: () {
            context.go('/variation');
          },
          child: Icon(Icons.add, color: Colors.white, size: 30, weight: 900),
        ),
      ),
    );
  }
}
