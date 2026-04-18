import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/auth_state.dart';
import '../services/auth_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final authService = ref.watch(authServiceProvider);
    
    return AppShell(
      title: state.userName,
      subtitle: '${state.userEmail} • ${state.files.length} files',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: const Color(0xFFE879F9), child: Text(state.userName.substring(0, 1).toUpperCase())),
                const Spacer(),
                if (state.isAuthenticated)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await authService.signOut();
                      ref.read(appStateProvider.notifier).setUser(
                        userName: 'Guest',
                        userEmail: 'guest@example.com',
                        isAuthenticated: false,
                      );
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  )
                else
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Sign In'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null && result.files.single.path != null) {
                        ref.read(appStateProvider.notifier).addFile(
                              UploadedFileMeta(
                                name: result.files.single.name,
                                path: result.files.single.path!,
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
                            subtitle: Text(file.path, maxLines: 1, overflow: TextOverflow.ellipsis),
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
