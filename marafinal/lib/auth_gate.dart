// lib/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/backend_api.dart';
import 'features/auth/presentation/components/loading.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/cubits/profile_cubit.dart';
import 'features/side_menu/sebscriptions/presentation/cubits/subscription_cubit.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Unauthenticated) {
          return const AuthPage();
        }
        if (state is Authenticated) {
          return const HomePage();
        }
        return const LoadingScreen();
      },
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is Authenticated) {
          final subscriptionCubit = context.read<SubscriptionCubit>();
          subscriptionCubit.checkProStatus();
          // Fire-and-forget sync with backend; errors logged but not blocking UI
          BackendApi.syncWithBackend().catchError(
            (e) => debugPrint('Backend sync failed: $e'),
          );
          // Load profile
          context.read<ProfileCubit>().loadProfile();
          print(
            "Checking subscription status & loading profile after authentication",
          );
        }
      },
    );
  }
}
