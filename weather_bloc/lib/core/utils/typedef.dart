import 'package:dartz/dartz.dart';
import 'package:weather_bloc/core/error/failures.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
