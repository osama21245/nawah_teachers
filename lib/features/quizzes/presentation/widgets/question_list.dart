import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/quiz_model.dart';
import '../cubits/add_quiz/add_quiz_cubit.dart';
import '../cubits/add_quiz/add_quiz_state.dart';
import 'add_question_dialog.dart';
import 'question_card.dart';

class QuestionList extends StatelessWidget {
  const QuestionList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddQuizCubit, AddQuizState>(
      builder: (context, state) {
        return Expanded(
          child: ListView.builder(
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final question = state.questions[index];
              return QuestionCard(
                question: question,
                index: index,
                onEdit: () => _editQuestion(context, index),
                onDelete: () =>
                    context.read<AddQuizCubit>().removeQuestion(index),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editQuestion(BuildContext context, int index) async {
    final state = context.read<AddQuizCubit>().state;
    final question = state.questions[index];

    final result = await showDialog<QuestionModel>(
      context: context,
      builder: (context) => AddQuestionDialog(
        initialQuestion: question,
      ),
    );
    if (result != null) {
      context.read<AddQuizCubit>().updateQuestion(index, result);
    }
  }
}
