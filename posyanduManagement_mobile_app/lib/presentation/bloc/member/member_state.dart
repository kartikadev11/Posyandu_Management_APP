part of 'member_bloc.dart';

@immutable
sealed class MemberState {}

final class MemberInitial extends MemberState {}

final class MemberLoading extends MemberState {}

final class MemberFailed extends MemberState {
  final String message;

  MemberFailed(this.message);
}

final class MemberLoaded extends MemberState {
  final List<User> members;

  MemberLoaded(this.members);
}
