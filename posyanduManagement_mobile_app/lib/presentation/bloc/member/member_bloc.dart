import 'package:posyandumanagement_mobile_app/data/models/user.dart';
import 'package:posyandumanagement_mobile_app/data/source/user_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'member_event.dart';
part 'member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  MemberBloc() : super(MemberInitial()) {
    on<OnFetchMember>((event, emit) async {
      emit(MemberLoading());
      List<User>? result = await UserSource.getEmlpoyee();
      if (result == null) {
        emit(MemberFailed('Ada Kesalahan'));
      } else {
        emit(MemberLoaded(result));
      }
    });
  }
}
