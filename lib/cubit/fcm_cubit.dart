// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prime_web/data/repositories/fcm_repositories.dart';

abstract class SetFcmState {}

class SetFcmStateInit extends SetFcmState {}

class SetFcmStateInProgress extends SetFcmState {}

class SetFcmStateInSussess extends SetFcmState {
  final bool useAuthtoken;
  final String setFcm;
  SetFcmStateInSussess({required this.setFcm, required this.useAuthtoken});
}

class SetFcmInError extends SetFcmState {
  String error;
  SetFcmInError({
    required this.error,
  });
}

class SetFcmCubit extends Cubit<SetFcmState> {
  final SetFcm _setfcmkey = SetFcm();

  SetFcmCubit() : super(SetFcmStateInit());

  Future setFcm() async {
    emit(SetFcmStateInProgress());
    try {
      final setFcmKey = await _setfcmkey.SetFcmRepo();
      emit(
        SetFcmStateInSussess(useAuthtoken: false, setFcm: setFcmKey),
      );
    } catch (e) {
      SetFcmInError(error: e.toString());
    }
  }
}
