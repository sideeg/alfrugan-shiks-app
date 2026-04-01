// Path: lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});
  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  AuthException({required this.message});
  @override
  String toString() => message;
}
