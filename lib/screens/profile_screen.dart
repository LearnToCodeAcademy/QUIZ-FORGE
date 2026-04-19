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
      title: 'Profile',
      subtitle: 'Manage your study materials',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: GlowCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFE879F9)]),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF1E293B),
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null ? Text(userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)) : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(userEmail, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1)),
                      onPressed: () async => await authNotifier.signOut(),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Expanded(
                    child: GlowCard(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Text('${state.files.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA))),
                          const SizedBox(height: 4),
                          Text('Files', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlowCard(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          const Text('0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE879F9))),
                          const SizedBox(height: 4),
                          Text('Quizzes', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  const Text('Your Files', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: const Color(0xFFA78BFA).withOpacity(0.2),
                      foregroundColor: const Color(0xFFA78BFA),
                      elevation: 0,
                    ),
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
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Upload'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: GlowCard(
                  child: state.files.isEmpty
                      ? const EmptyState(message: 'No files uploaded yet.\nUpload study materials to save them to your profile.')
                      : ListView.separated(
                          itemCount: state.files.length,
                          separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                          itemBuilder: (_, i) {
                            final file = state.files[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFA78BFA).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.description, color: Color(0xFFA78BFA), size: 20),
                              ),
                              title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text(file.path ?? 'In-memory (Web)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => ref.read(appStateProvider.notifier).deleteFile(file),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
