import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../cubits/add_videos/add_video_cubit.dart';
import '../cubits/add_video_state.dart';
import '../../data/model/video_model.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _videoFile;
  String? _videoUrl;
  int _selectedTeachingLevel = 1; // Default value

  final List<Map<String, dynamic>> _teachingLevels = [
    {'id': 1, 'name': 'Primary'},
    {'id': 2, 'name': 'Secondary'},
    {'id': 3, 'name': 'High School'},
    {'id': 4, 'name': 'University'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Video'),
      ),
      body: BlocListener<AddVideoCubit, AddVideoCubitState>(
        listener: (context, state) {
          if (state.isSuccess()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video added successfully!')),
            );
            Navigator.pop(context);
          } else if (state.isFailure()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to add video'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Video Title'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Video Description'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Teaching Level',
                ),
                value: _selectedTeachingLevel,
                items: _teachingLevels.map((level) {
                  return DropdownMenuItem<int>(
                    value: level['id'] as int,
                    child: Text(level['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTeachingLevel = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a teaching level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_videoFile != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Selected video: ${_videoFile!.path.split('/').last}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _videoFile = null;
                              _videoUrl = null;
                            });
                          },
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_videoUrl != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Video URL: $_videoUrl'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _videoUrl = null;
                            });
                          },
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _pickVideo,
                      child: const Text('Select Video File'),
                    ),
                    const SizedBox(height: 8),
                    const Text('OR'),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Video URL (YouTube, Vimeo, etc.)'),
                      onChanged: (value) {
                        setState(() {
                          _videoUrl = value;
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              BlocBuilder<AddVideoCubit, AddVideoCubitState>(
                builder: (context, state) {
                  if (state.isUploading() && state.uploadProgress != null) {
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: state.uploadProgress,
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Uploading: ${(state.uploadProgress! * 100).toStringAsFixed(1)}%'),
                      ],
                    );
                  }

                  return ElevatedButton(
                    onPressed: state.isLoading() || state.isUploading()
                        ? null
                        : _submitVideo,
                    child: state.isLoading() || state.isUploading()
                        ? const CircularProgressIndicator()
                        : const Text('Submit Video'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
        _videoUrl = null;
      });
    }
  }

  Future<void> _submitVideo() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_videoFile == null && (_videoUrl == null || _videoUrl!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a video file or enter a video URL')),
        );
        return;
      }

      if (_videoFile != null) {
        // Upload the video file
        context.read<AddVideoCubit>().uploadVideoFile(
              videoFile: _videoFile!,
              title: _titleController.text,
              teachingLevelId: _selectedTeachingLevel,
              teacherId: '1', // Get this from your auth system
              description: _descriptionController.text,
            );
      } else if (_videoUrl != null) {
        // Add video with URL
        final video = VideoModel(
          title: _titleController.text,
          description: _descriptionController.text,
          teacherId: '1', // Get this from your auth system
          videoUrl: _videoUrl!,
          teachingLevelId: _selectedTeachingLevel,
        );

        context.read<AddVideoCubit>().addVideo(video);
      }
    }
  }
}
