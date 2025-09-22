import 'package:flutter/material.dart';

class MyGoogleSignInButton extends StatelessWidget {
  final void Function()? onTap;
  const MyGoogleSignInButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Center(
          child: Image.asset(
            'assets/google.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
