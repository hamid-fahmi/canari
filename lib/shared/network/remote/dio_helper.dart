import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class DioHelper {
  static Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response> getData({
    @required String url,
    Map<String, dynamic> query,
  }) async {
    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> postData({
    @required String url,
    @required Map<String, dynamic> data,
  }) async {
    return await dio.post(url, data: data);
  }

  static Future<Response> putData({
    @required String url,
    @required Map<String, dynamic> data,
  }) async {
    return await dio.put(url, data: data);
  }

  static Future<Response> deleteData({
    @required String url,
    @required Map<String, dynamic> data,
  }) async {
    return await dio.delete(url, data: data);
  }
}
