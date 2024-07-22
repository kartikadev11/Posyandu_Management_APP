part of 'list_schedule_bloc.dart';

@immutable
sealed class ListTaskEvent {}

class OnFetchListTask extends ListTaskEvent {
  final String status;
  final int memberId;

  OnFetchListTask(this.status, this.memberId);
}
