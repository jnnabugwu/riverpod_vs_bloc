import 'package:dartz/dartz.dart';
import 'package:weather_riverpod/core/error/failures.dart';

/// A type alias for a Future that returns either a Failure or a value of type T.
typedef ResultFuture<T> = Future<Either<Failure, T>>;
