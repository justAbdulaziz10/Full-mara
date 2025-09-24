import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:marafinal/features/auth/data/firebase_auth_repo.dart';
import 'package:marafinal/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:marafinal/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:marafinal/features/side_menu/sebscriptions/data/revenuecat_service.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/offerings_cubit.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/subscription_cubit.dart';
import 'package:marafinal/splash_screen.dart';
import 'package:marafinal/themes/dark_mode.dart';
import 'package:marafinal/themes/light_mode.dart';

import 'auth_gate.dart';
import 'config/runtime_firebase.dart';

// 'firebase_options.dart' kept for tooling but we use runtime_firebase instead.

void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e, st) {
    debugPrint('Env load failed: $e\n$st');
    runApp(
      const _FatalEnvApp(
        message: 'Failed to load .env file. Ensure it exists at project root.',
      ),
    );
    return;
  }

  final missing = missingFirebaseKeys();
  if (missing.isNotEmpty) {
    debugPrint('Missing Firebase env keys: ${missing.join(', ')}');
    runApp(
      _FatalEnvApp(
        message: 'Missing Firebase keys in .env:\n${missing.join('\n')}',
      ),
    );
    return;
  }

  try {
    await Firebase.initializeApp(options: firebaseFromEnv());
  } catch (e, st) {
    debugPrint('Firebase init failed: $e\n$st');
    runApp(
      const _FatalEnvApp(
        message: 'Firebase initialization failed. Check keys.',
      ),
    );
    return;
  }

  final rcKey = dotenv.env['REVENUECAT_APPLE_API_KEY'];
  if (rcKey != null && rcKey.isNotEmpty) {
    await RevenueCatService.configureRevenueCat(rcKey);
  }

  //run app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final firebaseAuthRepo = FireBaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<SubscriptionCubit>(
          create: (context) => SubscriptionCubit(),
        ),
        BlocProvider<OfferingsCubit>(create: (context) => OfferingsCubit()),
        BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: ThemeMode.system,
        // أول ما يفتح التطبيق يوري SplashScreen
        home: const SplashScreen(nextRoute: '/gate'),
        routes: {'/gate': (_) => const AuthGate()},
      ),
    );
  }
}

class _FatalEnvApp extends StatelessWidget {
  final String message;
  const _FatalEnvApp({
    this.message = 'Configuration Error. Check .env values and restart.',
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
