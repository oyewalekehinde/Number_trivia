import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numberTrivia/core/error/exceptions.dart';
import 'package:numberTrivia/core/error/failures.dart';
import 'package:numberTrivia/core/network/network_info.dart';
import 'package:numberTrivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:numberTrivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:numberTrivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:numberTrivia/features/number_trivia/data/repositiories/number_trivia_repository_impl.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });
  void runTestsOnline(Function body) {
    group("device is online", () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group("device is offline", () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(text: "test trivia", number: tNumber);
    final tNumberTrivia = tNumberTriviaModel;
    test('check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      repository.getConcreteNumberTrivia(tNumber);
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote datasource is successfull',
        () async {
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repository.getConcreteNumberTrivia(tNumber);
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should cache the data locally when the call to remote datasource is successfull',
        () async {
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          await repository.getConcreteNumberTrivia(tNumber);
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote datasource is unsuccessfull',
        () async {
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());
          final result = await repository.getConcreteNumberTrivia(tNumber);
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });
    runTestsOffline(() {
      test(
        "should return last locally cached data when the cached data is present",
        () async {
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repository.getConcreteNumberTrivia(tNumber);
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        "should return cache failure when there is no cached data present",
        () async {
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          final result = await repository.getConcreteNumberTrivia(tNumber);
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(text: "test trivia", number: 123);
    final tNumberTrivia = tNumberTriviaModel;
    test('check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      repository..getRandomNumberTrivia();
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote datasource is successfull',
        () async {
          when(mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repository.getRandomNumberTrivia();
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should cache the data locally when the call to remote datasource is successfull',
        () async {
          when(mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          await repository.getRandomNumberTrivia();
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote datasource is unsuccessfull',
        () async {
          when(mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          final result = await repository.getRandomNumberTrivia();
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });
    runTestsOffline(() {
      test(
        "should return last locally cached data when the cached data is present",
        () async {
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repository.getRandomNumberTrivia();
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        "should return cache failure when there is no cached data present",
        () async {
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          final result = await repository.getRandomNumberTrivia();
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
