import 'package:posyandumanagement_mobile_app/data/models/schedule.dart';
import 'package:posyandumanagement_mobile_app/data/source/schedule_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'progress_task_event.dart';
part 'progress_task_state.dart';

class ProgressTaskBloc extends Bloc<ProgressTaskEvent, ProgressTaskState> {
  ProgressTaskBloc() : super(ProgressTaskInitial()) {
    on<OnFetchProgressTasks>((event, emit) async {
      emit(ProgressTaskLoading());
      List<Schedule>? result = await TaskSource.progress(event.userId);
      if (result == null) {
        emit(ProgressTaskFailed("Ada Kesalahan"));
      } else {
        emit(ProgressTaskLoaded(result));
      }
    });
  }
}
