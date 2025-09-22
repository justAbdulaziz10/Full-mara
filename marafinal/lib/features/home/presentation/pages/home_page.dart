import 'package:flutter/material.dart';
import 'package:marafinal/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/subscription_cubit.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/cubits/subscription_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marafinal/features/side_menu/sebscriptions/presentation/pages/offerings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void handleAddSpecificWater() {
    final subscriptionState = context.read<SubscriptionCubit>().state;

    if (subscriptionState is SubscriptionLoaded && subscriptionState.isSubscribed) {
      //addSpecificWater();
      
    } else {
      showSubscriptionDialog();
    }
  }

  void showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Premium Subscription Required"),
        content: const Text(
          "This feature is available for premium subscribers only. Please subscribe",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfferingsPage(),
                ),
              );
            },
            child: const Text("Subscribe"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
