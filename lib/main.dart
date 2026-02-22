import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/data/auth_service.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/screens/signup_screen.dart';

import 'package:task_manager/features/auth/presentation/screens/welcome_screen.dart';
import 'package:task_manager/features/tasks/data/task_repository.dart';
import 'package:task_manager/features/tasks/data/task_service.dart';
import 'package:task_manager/features/tasks/presentation/screens/dashboard_screen.dart';

import 'package:task_manager/features/tasks/presentation/task_bloc/task_bloc.dart';

import 'package:task_manager/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthService())),
        BlocProvider(create: (_) => TaskBloc(TaskRepository(TaskService()))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
      routes: {
        "/dashboard": (context) => (DashboardScreen()),
        "/AuthScreen": (context) => AuthScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5FB3A8)),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        useMaterial3: true,
      ),
    );
  }
}
