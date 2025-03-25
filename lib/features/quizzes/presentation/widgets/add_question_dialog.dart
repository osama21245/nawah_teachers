import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/model/quiz_model.dart';
import '../../../../core/firebase/firebase_service.dart';
import 'add_answer_dialog.dart';

class AddQuestionDialog extends StatefulWidget {
  final QuestionModel? initialQuestion;

  const AddQuestionDialog({super.key, this.initialQuestion});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _questionController = TextEditingController();
  final List<AnswerModel> _answers = [];
  Uint8List? _imageBytes;
  String? _imageFileName;
  bool _isWrittenQuestion = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestion != null) {
      _questionController.text = widget.initialQuestion!.questionText;
      _answers.addAll(widget.initialQuestion!.answers);
      _isWrittenQuestion = widget.initialQuestion!.isWrittenQuestion;
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (result != null) {
        final bytes = await result.readAsBytes();
        if (bytes.length > 2 * 1024 * 1024) {
          // 2MB limit
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be less than 2MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          _imageBytes = bytes;
          _imageFileName = result.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.initialQuestion == null ? 'Add Question' : 'Edit Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Written Question'),
                      subtitle: const Text('Students will write their answers'),
                      value: _isWrittenQuestion,
                      onChanged: (value) {
                        setState(() {
                          _isWrittenQuestion = value;
                          if (value) {
                            _answers.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (!_isWrittenQuestion) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Multiple Choice Answers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._answers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final answer = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(answer.answerText),
                            leading: Checkbox(
                              value: answer.isCorrect,
                              onChanged: (value) =>
                                  _updateAnswer(index, isCorrect: value!),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeAnswer(index),
                            ),
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _addAnswer,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Answer'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_imageBytes != null) ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selected: $_imageFileName',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.image),
                      label: Text(
                          _imageBytes == null ? 'Add Image' : 'Change Image'),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Max size: 2MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _submit,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  void _addAnswer() async {
    final result = await showDialog<AnswerModel>(
      context: context,
      builder: (context) => const AddAnswerDialog(),
    );
    if (result != null) {
      setState(() {
        _answers.add(result);
      });
    }
  }

  void _updateAnswer(int index, {required bool isCorrect}) {
    setState(() {
      _answers[index] = AnswerModel(
        answerText: _answers[index].answerText,
        isCorrect: isCorrect,
      );
    });
  }

  void _removeAnswer(int index) {
    setState(() {
      _answers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a question'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isWrittenQuestion && _answers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 answers'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isWrittenQuestion && !_answers.any((answer) => answer.isCorrect)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark at least one correct answer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? imageUrl;
    if (_imageBytes != null && _imageFileName != null) {
      setState(() => _isUploading = true);
      try {
        if (kIsWeb) {
          // For web, use the bytes directly
          final result = await GetIt.I<IFirebaseService>().uploadFile(
            path:
                'quiz_images/${DateTime.now().millisecondsSinceEpoch}_$_imageFileName',
            file: _imageBytes!,
          );

          result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload image: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            },
            (url) => imageUrl = url,
          );
        } else {
          // For mobile platforms, create a temporary file
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$_imageFileName');
          await tempFile.writeAsBytes(_imageBytes!);

          final result = await GetIt.I<IFirebaseService>().uploadFile(
            path:
                'quiz_images/${DateTime.now().millisecondsSinceEpoch}_$_imageFileName',
            file: tempFile,
          );

          result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload image: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            },
            (url) => imageUrl = url,
          );

          // Clean up the temporary file
          await tempFile.delete();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }

    if (_imageBytes != null && imageUrl == null) {
      return; // Don't proceed if image upload failed
    }

    Navigator.pop(
      context,
      QuestionModel(
        questionText: _questionController.text,
        answers: _answers,
        imageUrl: imageUrl,
        isWrittenQuestion: _isWrittenQuestion,
      ),
    );
  }
}
