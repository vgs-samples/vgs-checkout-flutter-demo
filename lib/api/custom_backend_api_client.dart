import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

abstract class Failure {}

class FetchAccessTokenAPIError extends Failure {}

class FetchAccessTokenNotFoundError extends Failure {}

class CustomBackendApiClient {
  Future<Either<Failure, String>> getAccessToken() async {
    final url = Uri.parse(
        AppConstants.paymentOrchestrationServicePath + 'get-auth-token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        return Left(FetchAccessTokenAPIError());
      } else {
        Map<String, dynamic> payload = jsonDecode(response.body);
        final token = payload['access_token'];
        if (token != null) {
          return Right(token);
        } else {
          return Left(FetchAccessTokenNotFoundError());
        }
      }
    } catch (e) {
      return Left(FetchAccessTokenNotFoundError());
    }
  }
}
