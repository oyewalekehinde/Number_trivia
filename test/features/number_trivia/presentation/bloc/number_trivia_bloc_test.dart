import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numberTrivia/core/error/failures.dart';
import 'package:numberTrivia/core/usecases/usecase.dart';
import 'package:numberTrivia/core/utils/input_converter.dart';
import 'package:numberTrivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:numberTrivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:numberTrivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:numberTrivia/features/number_trivia/presentation/bloc/bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetrandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetrandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetrandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });
  test("initial state should be empty", () async {
    expect(bloc.initialState, equals(Empty()));
  });

  group("GetTriviaForConcreteNumber", () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    void setUpMockInputConveterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
    }

    test(
      "should call the inputConveter to validate and convert the string to an unsigned integer",
      () async {
        setUpMockInputConveterSuccess();
        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );
    test(
      "should emit [error] when the input is invalid",
      () async {
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        final expected = [
          Empty(),
          Error(message: INVALID_INPUT_FAILURE_MESSAGE)
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      },
    );
    test(
      "should get data from the concrete use case",
      () async {
        setUpMockInputConveterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));

        await untilCalled(mockGetConcreteNumberTrivia(any));
        verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );

    test("should emit [Loading, Loaded] when data is gotten successfully",
        () async {
      setUpMockInputConveterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      final expected = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test("should emit [Loading, Error] when getting data fails", () async {
      setUpMockInputConveterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        "should emit [Loading, Error] with a proper message for the error when getting data fails",
        () async {
      setUpMockInputConveterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group("GetTriviaForRandomNumber", () {
    final tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    

   
    test(
      "should get data from the random use case",
      () async {
       
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        bloc.dispatch(GetTriviaForRandomNumber());

        await untilCalled(mockGetRandomNumberTrivia(any));
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test("should emit [Loading, Loaded] when data is gotten successfully",
        () async {
     
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      final expected = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForRandomNumber());
    });

    test("should emit [Loading, Error] when getting data fails", () async {
     
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForRandomNumber());
    });

    test(
        "should emit [Loading, Error] with a proper message for the error when getting data fails",
        () async {
    
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForRandomNumber());
    });
  });
}
