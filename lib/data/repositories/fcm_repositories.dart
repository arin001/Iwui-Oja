import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:prime_web/utils/api.dart';

class SetFcm {
  Future<String> getFcmToken() async {
    try {
      return (await FirebaseMessaging.instance.getToken()) ?? "";
    } catch (e) {
      return "";
    }
  }

  Future SetFcmRepo() async {
    try {
      final result = await ApiCall.postapi(
        url: ApiCall.setFcm,
        useAuthtoken: false,
        body: {
          "fcm": await getFcmToken(),
        },
      );
      print("This is the result:-${result}");

      if (result['error'] == false) {
        print('this is Set fcm successfully');
      } else {
        print('Set fcm repo error is true');
      }
    } catch (e, st) {
      print('fcm error is: $e,$st');
    }
  }
}
