import 'package:equatable/equatable.dart';

import '../../../domain/entities/timetable_item.dart';

sealed class TimetableState extends Equatable {
  const TimetableState();

  @override
  List<Object?> get props => [];
}

class TimetableInitial extends TimetableState {
  const TimetableInitial();
}

class TimetableLoading extends TimetableState {
  const TimetableLoading();
}

class TimetableLoaded extends TimetableState {
  final List<TimetableItem> items;

  const TimetableLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class TimetableExported extends TimetableState {
  final String filePath;

  const TimetableExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class TimetableError extends TimetableState {
  final String message;

  const TimetableError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful admin CRUD operation.
///
/// Extends [TimetableLoaded] so existing [BlocBuilder] checks continue to work.
class TimetableActionSuccess extends TimetableLoaded {
  final String actionMessage;

  const TimetableActionSuccess(this.actionMessage, List<TimetableItem> items)
    : super(items);

  @override
  List<Object?> get props => [actionMessage, items];
}
