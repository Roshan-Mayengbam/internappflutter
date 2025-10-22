import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:internappflutter/features/core/errors/failiure.dart';

/// An abstract class for a Use Case.
/// It defines a standard `call` method to execute the use case.
/// [Type] is the success return type.
/// [Params] is the input parameters type.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// A class to be used when a use case does not require any parameters.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}