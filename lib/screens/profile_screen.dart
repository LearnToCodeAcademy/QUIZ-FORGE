import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/auth_state.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final user = ref.watch(authStateProvider).value;
    
    final userName = user?.displayName ?? state.userName;
    final userEmail = user?.email ?? state.userEmail;

    return AppShell(
      title: userName,
      subtitle: '$userEmail • ${state.files.length} files',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFE879F9),
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? Text(userName.substring(0, 1).toUpperCase()) : null,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await authNotifier.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'docx', 'txt', 'json', 'csv', 'md'],
                      );
                      if (result != null) {
                        final file = result.files.single;
                        ref.read(appStateProvider.notifier).addFile(
                              UploadedFileMeta(
                                name: file.name,
                                path: kIsWeb ? null : file.path,
                                bytes: file.bytes,
                                createdAt: DateTime.now(),
                              ),
                            );
                      }
                    },
                    child: const Text('+ Upload Files'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GlowCard(
                child: state.files.isEmpty
                    ? const EmptyState(message: 'No files uploaded yet. Upload study materials to save them to your profile.')
                    : ListView.builder(
                        itemCount: state.files.length,
                        itemBuilder: (_, i) {
                          final file = state.files[i];
                          return ListTile(
                            title: Text(file.name),
                            subtitle: Text(file.path ?? 'In-memory (Web)', maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => ref.read(appStateProvider.notifier).deleteFile(file),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
