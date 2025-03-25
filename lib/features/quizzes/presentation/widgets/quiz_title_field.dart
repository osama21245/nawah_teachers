import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/add_quiz/add_quiz_cubit.dart';

class QuizTitleField extends StatelessWidget {
  const QuizTitleField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Quiz Title',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => context.read<AddQuizCubit>().updateTitle(value),
    );
  }
}
