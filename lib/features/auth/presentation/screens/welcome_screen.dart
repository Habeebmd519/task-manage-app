import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_event.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_state.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("WELCOME SCREEN OPENED");
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.asset(
                "assets/images/banner.png",
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5FB3A8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Find the things that you Love!"),
                    Container(
                      // color: Colors.red,
                      height: 220,
                      width: double.infinity,

                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Image.asset(
                          "assets/images/AuthVector.png",
                          alignment: Alignment(0.0, 0.1),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5FB3A8),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/AuthScreen");
                          context.read<AuthBloc>().add(ToggleAuthMode());
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          side: const BorderSide(color: Color(0xFF5FB3A8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/AuthScreen");
                          context.read<AuthBloc>().add(ToggleAuthMode());
                        },
                        child: const Text("Login"),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
