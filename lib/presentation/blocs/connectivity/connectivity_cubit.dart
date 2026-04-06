import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const ConnectivityOnline()) {
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final result = await _connectivity.checkConnectivity();
    _onChanged(result);
  }

  void _onChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      emit(const ConnectivityOffline());
    } else {
      emit(const ConnectivityOnline());
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
