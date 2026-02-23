import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_event.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.success) {
              Navigator.pushReplacementNamed(context, "/dashboard");
            }

            if (state.status == AuthStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? "Auth Failed")),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    Container(
                      height: 120,
                      width: 150,

                      child: Image.asset(
                        "assets/images/AuthVector.png",
                        alignment: Alignment(0.0, 0.1),
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      state.isLogin ? "Welcome Back 👋" : "Create Account",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5FB3A8),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      state.isLogin
                          ? "Login to continue"
                          : "Sign up to get started",
                    ),

                    const SizedBox(height: 30),

                    if (!state.isLogin) ...[
                      _buildTextField(
                        controller: nameController,
                        hint: "Full Name",
                        validator: (v) => v!.isEmpty ? "Enter your name" : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildTextField(
                      controller: emailController,
                      hint: "Email",
                      validator: (v) =>
                          v!.contains("@") ? null : "Enter valid email",
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: passwordController,
                      hint: "Password",
                      obscure: true,
                      validator: (v) =>
                          v!.length >= 6 ? null : "Min 6 characters",
                    ),

                    const SizedBox(height: 30),

                    state.status == AuthStatus.loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5FB3A8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    SubmitAuth(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      name: nameController.text.trim(),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                state.isLogin ? "Login" : "Sign Up",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(ToggleAuthMode());
                      },
                      child: Text(
                        state.isLogin
                            ? "Don't have an account? Sign Up"
                            : "Already have an account? Login",
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    bool obscure = false,
  }) {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
