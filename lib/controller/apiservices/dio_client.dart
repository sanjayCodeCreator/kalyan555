import 'package:dio/dio.dart';

Dio dio = Dio(BaseOptions(
  connectTimeout: const Duration(minutes: 2),
  receiveTimeout: const Duration(minutes: 2),
));
