import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';
import 'package:nawah_teachers/core/firebase/firebase_service.dart';
import '../../data/model/quiz_model.dart';
import '../cubits/add_quiz/add_quiz_cubit.dart';
import '../cubits/add_quiz/add_quiz_state.dart';
import '../../../auth/presentation/cubits/auth/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth/auth_state.dart';
import '../../data/data_souce/quizzes_remote_data_souce.dart';
import '../../data/repository/quizzes_repository.dart';

class AddQuizScreen extends StatelessWidget {
  const AddQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        try {
          return GetIt.I<AddQuizCubit>();
        } catch (e) {
          final dataSource =
              QuizzesRemoteDataSouceImpl(GetIt.I<IFirebaseService>());
          final repository = QuizzesRepository(dataSource);
          return AddQuizCubit(repository);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Quiz'),
        ),
        body: BlocBuilder<AddQuizCubit, AddQuizState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Quiz Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context.read<AddQuizCubit>().updateTitle(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.questions.length,
                      itemBuilder: (context, index) {
                        final question = state.questions[index];
                        return Card(
                          child: ListTile(
                            title: Text(question.questionText),
                            subtitle: Text(
                              '${question.answers.length} answers',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    context
                                        .read<AddQuizCubit>()
                                        .removeQuestion(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AddQuizCubit>().addQuestion;
                    },
                    child: const Text('Add Question'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
