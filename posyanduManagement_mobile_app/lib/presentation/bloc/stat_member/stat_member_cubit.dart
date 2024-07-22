import 'package:posyandumanagement_mobile_app/data/source/schedule_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatMemberCubit extends Cubit<Map> {
  StatMemberCubit() : super(_init);
  static final Map _init = {
    "Queue": 0,
    "Review": 0,
    "Approved": 0,
    "Rejected": 0,
  };

  fetcStatistic(int userId) async {
    final result = await TaskSource.statistic(userId);
    if (result == null) {
      emit(_init);
    } else {
      emit(result);
    }
  }
}
