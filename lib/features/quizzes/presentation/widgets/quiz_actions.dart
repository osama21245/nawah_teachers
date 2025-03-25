import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/quiz_model.dart';
import '../cubits/add_quiz/add_quiz_cubit.dart';
import '../cubits/add_quiz/add_quiz_state.dart';
import '../../../auth/presentation/cubits/auth/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth/auth_state.dart';
import 'add_question_dialog.dart';

class QuizActions extends StatelessWidget {
  const QuizActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _addQuestion(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Question'),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated &&
                authState.userProfile != null) {
              return BlocBuilder<AddQuizCubit, AddQuizState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.questions.isEmpty || state.isLoading
                        ? null
                        : () => context
                            .read<AddQuizCubit>()
                            .saveQuiz(authState.userProfile!.email ?? ''),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Quiz'),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Future<void> _addQuestion(BuildContext context) async {
    final result = await showDialog<QuestionModel>(
      context: context,
      builder: (context) => const AddQuestionDialog(),
    );
    if (result != null) {
      context.read<AddQuizCubit>().addQuestion(result);
    }
  }
}
