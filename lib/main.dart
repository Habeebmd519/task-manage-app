import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/core/AuthGateWay/auth_gate_way.dart';

import 'package:task_manager/core/network/connectivity_cubit.dart';

import 'package:task_manager/features/auth/data/auth_service.dart';
import 'package:task_manager/features/auth/presentation/auth_bloc/auth_bloc.dart';

import 'package:task_manager/features/tasks/data/local_cache.dart';
import 'package:task_manager/features/tasks/data/task_repository.dart';
import 'package:task_manager/features/tasks/data/task_service.dart';
import 'package:task_manager/features/tasks/presentation/task_bloc/task_bloc.dart';

import 'package:task_manager/features/theme/theme_cubit.dart';
import 'package:task_manager/features/theme/theme_service.dart';

import 'package:task_manager/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('tasks');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthService())),
        BlocProvider(
          create: (_) =>
              TaskBloc(TaskRepository(TaskService(), TaskLocalCache())),
        ),
        BlocProvider(create: (_) => ThemeCubit(ThemeService())..loadTheme()),
        BlocProvider(create: (_) => ConnectivityCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,

          // 🔥 IMPORTANT: Use AuthGate
          home: const AuthGate(),

          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF5FB3A8),
            scaffoldBackgroundColor: const Color(0xFFF5F7F6),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF5FB3A8),
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF5FB3A8),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF5FB3A8),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF5FB3A8),
            ),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}
