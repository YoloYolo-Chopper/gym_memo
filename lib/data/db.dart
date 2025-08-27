import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDb {
  AppDb._();

  static final AppDb _i = AppDb._();

  factory AppDb() => _i;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  //  open database
  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'gym_memo.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            exercise TEXT NOT NULL,
            variation TEXT NOT NULL,
            weight REAL NOT NULL,
            reps INTEGER NOT NULL,
            note TEXT
          )
      ''');
      },
    );
  }

  // add entry
  Future<int> addEntry({
    required DateTime date,
    required String exercise,
    required variation,
    required double weight,
    required int reps,
    String? note,
  }) async {
    final db = await database;
    return db.insert('entries', {
      'date': date.toIso8601String(),
      'exercise': exercise,
      'variation': variation,
      'weight': weight,
      'reps': reps,
      'note': note,
    });
  }

  // list all entries
  Future<List<Map<String, dynamic>>> listEntries() async {
    final db = await database;
    return db.query('entries', orderBy: 'date DESC, id DESC');
  }

  // list entries for a given exercise/variation on a specific day
  Future<List<Map<String, dynamic>>> listEntriesForDay({
    required String exercise,
    required String variation,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;
    final startIso = start.toIso8601String();
    final endIso = end.toIso8601String();
    return db.query(
      'entries',
      where: 'exercise = ? AND variation = ? AND date >= ? AND date < ?',
      whereArgs: [exercise, variation, startIso, endIso],
      orderBy: 'date ASC, id ASC',
    );
  }

  // get a single entry by id
  Future<Map<String, dynamic>?> getEntry(int id) async {
    final db = await database;
    final rows = await db.query(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  // update entry
  Future<int> updateEntry(
    int id, {
    double? weight,
    int? reps,
    String? note,
  }) async {
    final db = await database;
    final Map<String, Object?> values = {};
    if (weight != null) values['weight'] = weight;
    if (reps != null) values['reps'] = reps;
    if (note != null) values['note'] = note;
    if (values.isEmpty) return 0;
    return db.update(
      'entries',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // delete entry by id
  Future<int> deleteEntry(int id) async {
    final db = await database;
    return db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}
