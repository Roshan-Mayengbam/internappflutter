import 'package:equatable/equatable.dart';

/// A base class for all failure types in the application.
/// By extending Equatable, we can compare different Failure objects.
abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

/// Represents a failure from the server (e.g., 4xx or 5xx status code).
class ServerFailure extends Failure {
  final String message;
  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents a failure to connect to the network.
class NetworkFailure extends Failure {
  final String message = "Network connection failed. Please check your connection.";
}

/// Represents a failure during authentication (e.g., invalid token).
class AuthFailure extends Failure {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}