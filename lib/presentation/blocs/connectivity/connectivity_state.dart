import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline();
}

class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}
