import 'package:flutter/material.dart';
import '../../data/model/quiz_model.dart';

class AddAnswerDialog extends StatefulWidget {
  const AddAnswerDialog({super.key});

  @override
  State<AddAnswerDialog> createState() => _AddAnswerDialogState();
}

class _AddAnswerDialogState extends State<AddAnswerDialog> {
  final _answerController = TextEditingController();
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Answer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              labelText: 'Answer',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Correct Answer'),
            value: _isCorrect,
            onChanged: (value) {
              setState(() {
                _isCorrect = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an answer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      AnswerModel(
        answerText: _answerController.text,
        isCorrect: _isCorrect,
      ),
    );
  }
}
