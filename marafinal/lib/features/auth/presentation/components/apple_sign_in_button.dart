import 'package:flutter/material.dart';

class MyAppleSignInButton extends StatelessWidget {
  final void Function()? onTap;
  const MyAppleSignInButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondary, // Visible on light backgrounds
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Center(
          child: Image.asset(
            'assets/apple.png',
            height: 32,
            color: Theme.of(context).colorScheme.inversePrimary,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
