import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marafinal/features/auth/data/firebase_auth_repo.dart';
import 'package:marafinal/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:marafinal/features/side_menu/sebscriptions/data/revenuecat_constants.dart';
import 'package:marafinal/features/side_menu/sebscriptions/data/revenuecat_service.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/subscription_cubit.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/offerings_cubit.dart';
import 'package:marafinal/themes/dark_mode.dart';
import 'package:marafinal/themes/light_mode.dart';
import 'package:marafinal/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_screen.dart';
import 'auth_gate.dart';
import 'themes/light_mode.dart';
import 'themes/dark_mode.dart';


import 'firebase_options.dart';

void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await RevenueCatService.configureRevenueCat(appleApiKey);

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
