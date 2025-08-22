import 'package:flutter/material.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key, required this.variationName});

  final String variationName;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  List<int> _sets = [1];
  int _nextId = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.variationName),
        backgroundColor: Color(0xFFfeb854),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          // padding: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(child: Text('Last Record: 2025/8/21')),
              TrainingHeaderRow(),
              Expanded(
                child: ListView.builder(
                  itemCount: _sets.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: ValueKey(_sets[index]),
                      direction: DismissDirection.endToStart,
                      background: DeleteBackground(),
                      onDismissed: (_) {
                        setState(() {
                          _sets.removeAt(index);
                        });
                      },
                      child: TrainingSetRow(setNumber: index + 1),
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
          child: Icon(Icons.add, color: Colors.white, size: 30, weight: 900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          onPressed: () {
            setState(() => _sets.add(_nextId++));
          },
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
      alignment: Alignment.centerRight,
      color: Colors.redAccent,
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
  const TrainingSetRow({super.key, required this.setNumber});

  final int setNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: the Set cell
        Expanded(flex: 1, child: Center(child: Text(setNumber.toString()))),
        const SizedBox(width: 10),

        // Right: stack Weight/Reps/Icon above Note
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WeightRepsAssistRow(),
              const SizedBox(height: 8),
              // bottom sub-row
              NoteField(),
            ],
          ),
        ),
      ],
    );
  }
}

class NoteField extends StatelessWidget {
  const NoteField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(decoration: const InputDecoration(hintText: 'Note'));
  }
}

class WeightRepsAssistRow extends StatelessWidget {
  const WeightRepsAssistRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //  top sub-row
        Expanded(flex: 2, child: NumericTextField(hintText: 'Weight')),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: NumericTextField(hintText: 'Reps')),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: Center(child: Icon(Icons.check))),
      ],
    );
  }
}

class NumericTextField extends StatelessWidget {
  const NumericTextField({super.key, required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: hintText),
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
    );
  }
}
