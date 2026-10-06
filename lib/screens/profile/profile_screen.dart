import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../my_listings/my_listings_screen.dart';
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = ref.watch(themeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                (user?.displayName?.isNotEmpty ?? false)
                    ? user!.displayName![0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              user?.displayName ?? 'Campus User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? '',
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 30),

            _profileTile(
              context,
              Icons.inventory_2_outlined,
              'My Listings',
              'Manage your items',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyListingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Appearance',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_suggest_outlined),
                          label: Text('System'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {theme},
                      onSelectionChanged: (selection) {
                        ref.read(themeProvider.notifier).state =
                            selection.first;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _profileTile(
              context,
              Icons.logout_rounded,
              'Log out',
              'Sign out of your account',
              () async {
                await FirebaseAuth.instance.signOut();
              },
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool destructive = false,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor: destructive
              ? Colors.red.withOpacity(.1)
              : Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(.1),
          child: Icon(
            icon,
            color: destructive
                ? Colors.redAccent
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}



