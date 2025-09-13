// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prime_web/data/model/get_onbording_model.dart';
import 'package:prime_web/data/repositories/get_onbording_repositories.dart';

abstract class GetOnboardingState {}

class GetOnboardingStateInit extends GetOnboardingState {}

class GetOnboardingStateProgress extends GetOnboardingState {}

class GetOnboardingStateSuccess extends GetOnboardingState {
  final List<OnboardingData> onBoardingData;
  GetOnboardingStateSuccess({required this.onBoardingData});
}

class GetOnboardingError extends GetOnboardingState {
  final String error;
  GetOnboardingError({
    required this.error,
  });
}

class GetOnboardingCubit extends Cubit<GetOnboardingState> {
  GetOnboardingCubit() : super(GetOnboardingStateInit());

  Future getOnboardingScreens() async {
    emit(GetOnboardingStateProgress());
    try {
      final result = await GetOnbording.GetOnbordingrepo();
      result.removeWhere((item) => item.status == 0);
      emit(
        GetOnboardingStateSuccess(onBoardingData: result),
      );
    } catch (e) {
      GetOnboardingError(error: e.toString());
    }
  }

  bool onBoardingListIsNotEmpty() {
    List<OnboardingData> data =
        (state as GetOnboardingStateSuccess).onBoardingData;
    bool mode = data.isNotEmpty;
    return mode;
  }
}
