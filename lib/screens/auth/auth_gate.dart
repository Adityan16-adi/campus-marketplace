import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import 'login_screen.dart';
import '../main_shell.dart';
import 'splash_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.when(
      loading: () => const SplashScreen(),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        return const MainShell();
      },
    );
  }
}

