import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/get_videos/get_videos_cubit.dart';
import '../cubits/get_videos/get_videos_state.dart';
import '../../data/model/video_model.dart';
import 'add_video_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetVideosCubit>().getVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Videos'),
      ),
      body: BlocBuilder<GetVideosCubit, GetVideosCubitState>(
        builder: (context, state) {
          if (state.isLoading()) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.isFailure()) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'Failed to load videos',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<GetVideosCubit>().getVideos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state.isSuccess() && (state.videos?.isEmpty ?? true)) {
            return const Center(
              child: Text('No videos found. Add your first video!'),
            );
          } else if (state.isSuccess()) {
            return ListView.builder(
              itemCount: state.videos!.length,
              itemBuilder: (context, index) {
                final video = state.videos![index];
                return VideoCard(video: video);
              },
            );
          }

          return const Center(child: Text('Start by adding a video'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVideoScreen()),
          ).then((_) {
            // Refresh the videos list when returning from add screen
            context.read<GetVideosCubit>().getVideos();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoModel video;

  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (video.thumbnailUrl != null)
            Image.network(
              video.thumbnailUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.video_file, size: 50),
                );
              },
            )
          else
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.video_file, size: 50),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Implement video playback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Playing video: ${video.title}')),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Video'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
