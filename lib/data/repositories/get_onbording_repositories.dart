import 'package:prime_web/data/model/get_onbording_model.dart';
import 'package:prime_web/utils/api.dart';

class GetOnbording {
  static Future<List<OnboardingData>> GetOnbordingrepo() async {
    try {
      final result = await ApiCall.getapi(
        url: ApiCall.getOnbording,
        useAuthToken: false,
      );
      print('$result --------');
      if (result['error'] == false) {
        var data = result['data']['data'];
        return (data as List).map(
          (e) {
            return OnboardingData.fromJson(e);
          },
        ).toList();
      } else {
        print('this is get Onbording error is true');
        throw 'this is get Onbording error is true';
      }
    } catch (e) {
      print('This is error : $e');
      throw '$e';
    }
  }
}
