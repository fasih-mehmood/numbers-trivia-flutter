import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required this.getConcreteNumberTrivia,
      required this.getRandomNumberTrivia,
      required this.inputConverter})
      : super(Empty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      final inputEither =
          inputConverter.stringToUnsignedInt(event.numberString);

      await inputEither.fold((failure) async {
        emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
      }, (integer) async {
        emit(Loading());

        final failureOrTrivia =
            await getConcreteNumberTrivia(Params(number: integer))
                .whenComplete(() => null);

        emit(_eitherLoadedOrErrorState(failureOrTrivia));
      });
    });
    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(Loading());

      final failureOrTrivia = await getRandomNumberTrivia(NoParams());

      emit(_eitherLoadedOrErrorState(failureOrTrivia));
    });
  }

  NumberTriviaState _eitherLoadedOrErrorState(
      Either<Failure, NumberTrivia> failureOrTrivia) {
    return failureOrTrivia.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (trivia) => Loaded(trivia: trivia));
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => SERVER_FAILURE_MESSAGE,
      CacheFailure() => CACHE_FAILURE_MESSAGE,
      Failure() => 'Unexpected error',
    };
  }
}
