import 'package:posyandumanagement_mobile_app/common/enums.dart';
import 'package:posyandumanagement_mobile_app/data/models/schedule.dart';
import 'package:posyandumanagement_mobile_app/data/source/schedule_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'detail_schedule_state.dart';

class DetailTaskCubit extends Cubit<DetailTaskState> {
  DetailTaskCubit() : super(DetailTaskState(null, RequestStatus.init));

  fetchDetailTask(int id) async {
    emit(DetailTaskState(null, RequestStatus.loading));
    Schedule? result = await TaskSource.findById(id);
    if (result == null) {
      emit(DetailTaskState(null, RequestStatus.failed));
    } else {
      emit(DetailTaskState(result, RequestStatus.success));
    }
  }
}
