import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:number_trivia/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        // arrange
        const str = '123';
        // act
        final result = inputConverter.stringToUnsignedInt(str);
        // assert
        expect(result, equals(const Right(123)));
      },
    );

    test(
      'should return a Failure when the string is not an integer',
      () async {
        // arrange
        const str = 'abc';
        // act
        final result = inputConverter.stringToUnsignedInt(str);
        // assert
        expect(result, equals(Left(InvalidInputFailure())));
      },
    );

    test(
      'should return a Failure when the string is a negative integer',
      () async {
        // arrange
        const str = '-123';
        // act
        final result = inputConverter.stringToUnsignedInt(str);
        // assert
        expect(result, equals(Left(InvalidInputFailure())));
      },
    );
  });
}
