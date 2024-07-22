part of 'list_schedule_bloc.dart';

@immutable
sealed class ListTaskState {}

final class ListTaskInitial extends ListTaskState {}

final class ListTaskLoading extends ListTaskState {}

final class ListTaskFailed extends ListTaskState {
  final String message;

  ListTaskFailed(this.message);
}

final class ListTaskLoaded extends ListTaskState {
  final List<Schedule> tasks;

  ListTaskLoaded(this.tasks);
}
