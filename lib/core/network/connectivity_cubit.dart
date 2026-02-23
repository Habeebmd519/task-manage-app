import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit() : super(true) {
    Connectivity().onConnectivityChanged.listen((result) {
      emit(result != ConnectivityResult.none);
    });
  }
}
