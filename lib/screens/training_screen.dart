import 'package:flutter/material.dart';
import '../data/db.dart';
import 'package:go_router/go_router.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({
    super.key,
    required this.exercise,
    required this.variation,
  });

  final String exercise;
  final String variation;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final List<_Row> _rows = [];

  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _tomorrowStart => _todayStart.add(const Duration(days: 1));

  @override
  void dispose() {
    //   persist only rows with data, drop empty drafts
    _persistAndPrune();
    super.dispose();
  }

  Future<void> _persistAndPrune() async {
    //   save rows with any data; remove rows without anything
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      final hasData = (r.weight > 0) || (r.reps > 0) || ((r.note ?? '')
          .trim()
          .isNotEmpty);

      if (!hasData) {
        if (r.id != null) {
          await AppDb().deleteEntry(r.id!);
        }
        // TODO ? continue?
        continue;
      }

      // TODO: when does id being created in db?
      if (r.id == null) {
        final id = await AppDb().addEntry(
          date: DateTime.now(),
          exercise: widget.exercise,
          variation: widget.variation,
          weight: r.weight,
          reps: r.reps,
          note: r.note,
        );
        // TODO how does copyWith work?
        _rows[i] = r.copyWith(id: id);
      } else {
        await AppDb().updateEntry(
          // TODO: id! what's this?
          r.id!,
          weight: r.weight,
          reps: r.reps,
          note: r.note,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final rows = await AppDb().listEntriesForDay(
      exercise: widget.exercise,
      variation: widget.variation,
      start: _todayStart,
      end: _tomorrowStart,
    );

    _rows
      ..clear()
      ..addAll(
        rows.map(
              (r) =>
              _Row(
                id: r['id'] as int,
                weight: (r['weight'] as num?)?.toDouble() ?? 0,
                reps: (r['reps'] as num?)?.toInt() ?? 0,
                note: r['note'] as String?,
              ),
        ),
      );
    // Prepend an empty draft row so users see where to type
    // user add to add to the end; insert to add to the beginning
    _rows.add(const _Row(id: null, weight: 0, reps: 0, note: null));
    if (mounted) setState(() {});
  }

  // update partial data to a row
  // TODO: review this code later
  Future<void> _updateRow(int index, {
    String? weight,
    String? reps,
    String? note,
  }) async {
    final row = _rows[index];
    double? newWeight;
    int? newReps;
    String? newNote;

    if (weight != null) newWeight = double.tryParse(weight);
    if (reps != null) newReps = int.tryParse(reps);
    if (note != null) {
      final trimmed = note.trim();
      newNote = trimmed.isEmpty ? null : trimmed;
    }

    final hasAnyData = (newWeight != null && newWeight > 0) ||
        (newReps != null && newReps > 0) ||
        (newNote != null && newNote.isNotEmpty);

    if (row.id == null && !hasAnyData) {
      return;
    }

    // if id is null, add a new row. if id is not null, update the existing row.
    int? id = row.id;
    if (id == null && hasAnyData) {
      id = await AppDb().addEntry(
        date: DateTime.now(),
        exercise: widget.exercise,
        variation: widget.variation,
        weight: newWeight ?? row.weight,
        reps: newReps ?? row.reps,
        note: newNote ?? row.note,
      );
    } else if (id != null) {
      await AppDb().updateEntry(
        id, weight: newWeight, reps: newReps, note: newNote,
      );
    }

    // TODO: why use setState here?
    setState(() {
      _rows[index] = row.copyWith(
        id: id,
        weight: newWeight ?? row.weight,
        reps: newReps ?? row.reps,
        note: note == null ? row.note : newNote,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/day_record'), // go_router's pop
        ),
        title: Text('${widget.exercise} - ${widget.variation}'),
        centerTitle: true,
        backgroundColor: const Color(0xFFfeb854),
        actions: [
          IconButton(
            tooltip: 'Day record',
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              // TODO: why does pop work as going back to day_record rather than one screen down in a stack?
              context.pop();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          // padding: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text('Last Record: 2025/8/21'),
              const TrainingHeaderRow(),
              Expanded(
                child: ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, index) {
                    final r = _rows[index];
                    return Dismissible(
                      // TODO: why put draft_$index here?
                      key: ValueKey(r.id ?? 'draft_$index'),
                      direction: DismissDirection.endToStart,
                      background: const DeleteBackground(),
                      onDismissed: (_) async {
                        if (r.id != null) {
                          await AppDb().deleteEntry(r.id!);
                        }
                        setState(() => _rows.removeAt(index));
                      },
                      child: TrainingSetRow(
                        // TODO: why add a key here?
                        key: ValueKey('row_${r.id ?? 'draft_$index'}'),
                        setNumber: index + 1,
                        weight: r.weight,
                        reps: r.reps,
                        note: r.note,
                        onWeightChanged: (val) =>
                            _updateRow(index, weight: val),
                        onRepsChanged: (val) => _updateRow(index, reps: val),
                        onNoteChanged: (val) => _updateRow(index, note: val),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
            setState(() => _rows.add(_Row(id: null, weight: 0, reps: 0, note: null)));
          },
          child: Icon(Icons.add, color: Colors.white, size: 30, weight: 900),
        ),
      ),
    );
  }
}

class DeleteBackground extends StatelessWidget {
  const DeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(Icons.delete, color: Colors.white),
    );
  }
}

class TrainingHeaderRow extends StatelessWidget {
  const TrainingHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              'Set',
              style: TextStyle(
                color: Colors.black38,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'Weight',
              style: TextStyle(
                color: Colors.black38,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'Reps',
              style: TextStyle(
                color: Colors.black38,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'Assist',
              style: TextStyle(
                color: Colors.black38,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TrainingSetRow extends StatelessWidget {
  const TrainingSetRow({
    super.key,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.note,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onNoteChanged,
  });

  final int setNumber;
  final double weight;
  final int reps;
  final String? note;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final initialWeight = weight == 0 ? '' : weight.toString();
    final initialReps = reps == 0 ? '' : reps.toString();
    final initialNote = note ?? '';
    return Row(
      children: [
        Expanded(flex: 1, child: Center(child: Text(setNumber.toString()))),
        const SizedBox(width: 10),

        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WeightRepsAssistRow(
                initialWeight: initialWeight,
                initialReps: initialReps,
                onWeightChanged: onWeightChanged,
                onRepsChanged: onRepsChanged,
                weightFieldKey: ValueKey('w_${setNumber}'),
                repsFieldKey: ValueKey('r_${setNumber}'),
              ),
              const SizedBox(height: 8),
              // bottom sub-row
              NoteField(
                initialText: initialNote,
                onChanged: onNoteChanged,
                fieldKey: ValueKey('n_${setNumber}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WeightRepsAssistRow extends StatelessWidget {
  const WeightRepsAssistRow({
    super.key,
    required this.initialWeight,
    required this.initialReps,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.weightFieldKey,
    required this.repsFieldKey,
  });

  final String initialWeight;
  final String initialReps;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;
  final Key weightFieldKey;
  final Key repsFieldKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //  top sub-row
        Expanded(
          flex: 2,
          child: NumericTextField(
            key: weightFieldKey,
            hintText: 'Weight',
            initialText: initialWeight,
            onChanged: onWeightChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: NumericTextField(
            key: repsFieldKey,
            hintText: 'Reps',
            initialText: initialReps,
            onChanged: onRepsChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: Center(child: Icon(Icons.check))),
      ],
    );
  }
}

class NumericTextField extends StatelessWidget {
  const NumericTextField({
    super.key,
    required this.hintText,
    this.initialText = '',
    this.onChanged,
  });

  final String hintText;
  final String initialText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialText,
      textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: hintText),
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      onChanged: onChanged,
    );
  }
}

class NoteField extends StatelessWidget {
  const NoteField(
      {super.key, this.initialText = '', this.onChanged, Key? fieldKey})
      : _fieldKey = fieldKey;

  final String initialText;
  final ValueChanged<String>? onChanged;
  final Key? _fieldKey;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      initialValue: initialText,
      onChanged: onChanged,
      decoration: const InputDecoration(hintText: 'Note'),
    );
  }
}

class _Row {
  const _Row({
    required this.id,
    required this.weight,
    required this.reps,
    this.note,
  });

  final int? id;
  final double weight;
  final int reps;
  final String? note;

  _Row copyWith({int? id, double? weight, int? reps, String? note}) =>
      _Row(
        id: id ?? this.id,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        note: note ?? this.note,
      );
}
