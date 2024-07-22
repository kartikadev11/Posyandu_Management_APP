import 'package:posyandumanagement_mobile_app/data/models/schedule.dart';
import 'package:posyandumanagement_mobile_app/data/source/schedule_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'list_schedule_event.dart';
part 'list_schedule_state.dart';

class ListTaskBloc extends Bloc<ListTaskEvent, ListTaskState> {
  ListTaskBloc() : super(ListTaskInitial()) {
    on<OnFetchListTask>((event, emit) async {
      emit(ListTaskLoading());
      List<Schedule>? result = await TaskSource.whereUserAndStatus(
        event.memberId,
        event.status,
      );
      if (result == null) {
        emit(ListTaskFailed('Ada Kesalahan'));
      } else {
        emit(ListTaskLoaded(result));
      }
    });
  }
}
