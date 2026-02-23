import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeService service;

  ThemeCubit(this.service) : super(ThemeMode.light);

  Future<void> loadTheme() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final theme = await service.getTheme(user.uid);

    emit(theme == "dark" ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    emit(newMode);

    await service.saveTheme(
      user.uid,
      newMode == ThemeMode.dark ? "dark" : "light",
    );
  }
}
