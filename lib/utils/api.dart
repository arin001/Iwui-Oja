import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prime_web/utils/constants.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);
  String errorMessage;

  @override
  String toString() {
    return errorMessage;
  }
}

class ApiCall {
  static Map<String, dynamic> headers() {
    const jwtToken = '20000';

    return {
      'Authorization': 'Bearer $jwtToken',
      'Accept': 'application/json',
    };
  }

// Api Url
  static String getSystemSettings = '${databaseUrl}get-system-settings';
  static String getDrawerItems = '${databaseUrl}get-drawer-items';
  static String getOnbording = '${databaseUrl}get-onboarding-list';
  static String setFcm = '${databaseUrl}add-fcm';

  static Future<Map<String, dynamic>> postapi({
    required String url,
    required Map<String, dynamic> body,
    required bool useAuthtoken,
  }) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap(body, ListFormat.multiCompatible);

      print('API Called POST: $url with $body');
      print('Body Params: $body');

      final response = await dio.post(
        url,
        data: formData,
        options: useAuthtoken ? Options(headers: headers()) : null,
      );

      print('Response: $response');

      return response.data;
    } on DioException catch (e) {
      ApiException(e.toString());
    } on ApiException catch (e) {
      throw ApiException(e.toString());
    } catch (e) {
      throw ApiException(e.toString());
    }
    return {};
  }

  static Future<Map<String, dynamic>> getapi({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final dio = Dio();

      log('calling api $url');

      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      log('$response --------- response');

      final resp = response.data;

      return resp;
    } on DioException catch (e, stack) {
      if (kDebugMode) {
        print('Url is $url');
        log('${e.error}');
        log('$stack');
        print(e.response?.data);
        print(e.response?.statusCode);
        print(e.response?.statusMessage);
      }
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      print(e);
    }
    return {};
  }
}
