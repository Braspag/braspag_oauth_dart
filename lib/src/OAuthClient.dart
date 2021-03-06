import 'dart:convert';

import 'package:braspag_oauth_dart/oauth.dart';
import 'package:braspag_oauth_dart/src/OAuthError.dart';
import 'package:dio/dio.dart';

class OAuthClient {
  Dio dio;
  OAuthClient(this.dio);

  Future<BraspagOAuth> getAccessToken(
      {String clientId,
      String clientSecret,
      OAuthEnvironment environment}) async {
    try {
      String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret'));

      Map<String, String> body = {'grant_type': 'client_credentials'};

      dio.options
        ..baseUrl = baseUrl(environment)
        ..headers["content-type"] = "application/x-www-form-urlencoded"
        ..headers["authorization"] = basicAuth;

      var response = await dio.post("oauth2/token", data: body);

      return BraspagOAuth.fromJson(response.data);
    } on DioError catch (e) {
      _getErrorDio(e);
    } catch (e) {
      throw ErrorResponseOAuth(
          code: "Unknown Error", message: "Falha ao tentar obter credenciais");
    }
    return null;
  }
}

String baseUrl(OAuthEnvironment enviroment) {
  return enviroment == OAuthEnvironment.PRODUCTION
      ? "https://auth.braspag.com.br/"
      : "https://authsandbox.braspag.com.br/";
}

_getErrorDio(DioError e) {
  if (e?.response != null) {
    Map<String, dynamic> map = e.response.data;
    OAuthError errorsOAuth = OAuthError.fromJson(map);

    throw ErrorResponseOAuth(
        code: "${e.response.statusCode}",
        message: errorsOAuth.errorDescription);
  } else {
    throw ErrorResponseOAuth(code: e.message, message: "Unknown Error");
  }
}
