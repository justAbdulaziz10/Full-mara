import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marafinal/features/auth/presentation/components/apple_sign_in_button.dart';
import 'package:marafinal/features/auth/presentation/components/google_sign_in_button.dart';
import 'package:marafinal/features/auth/presentation/components/my_button.dart';
import 'package:marafinal/features/auth/presentation/components/my_textfield.dart';
import 'package:marafinal/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({super.key, this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  late final authCubit = context.read<AuthCubit>();

  void login(){
    final String email = emailController.text;
    final String pw = pwController.text;


    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email,pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill both email & password.")),
      );
    }
  }

  void openForgotPasswordBox(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password?"),
        content: MyTextfield(controller: emailController, hintText: "Enter email", obscureText: false),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {
              String message = await authCubit.forgotPassword(emailController.text);

              if(message == "Password reset email sent! Check your inbox."){
                Navigator.pop(context);
                emailController.clear();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(
                'assets/maraLogo.html',
                height: 100, // You can adjust the size as needed
              ),

              const SizedBox(height: 25),

              Text(
                "Welcome back to Mara!",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 25),

              MyTextfield(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              MyTextfield(
                controller: pwController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => openForgotPasswordBox(),
                    child: Text("Forgot Password?", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              MyButton(
                onTap: login,
                text: "LOGIN",
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.tertiary,
                    )
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text("Or Sign in with",),
                  ),

                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.tertiary,
                    )
                  )
                ],
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyAppleSignInButton(
                    onTap: ()async {
                      await authCubit.signInWithApple();
                    },
                  ),

                  const SizedBox(width: 10),

                  MyGoogleSignInButton(
                    onTap: ()async {
                      await authCubit.signInWithGoogle();
                    },
                  )
                ],
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: widget.togglePages,
                  child: Text(
                    "Register Now",
                    style: TextStyle(fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ]
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
