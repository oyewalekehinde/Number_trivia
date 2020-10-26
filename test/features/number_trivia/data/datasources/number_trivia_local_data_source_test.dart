import 'dart:convert';

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numberTrivia/core/error/exceptions.dart';
import 'package:numberTrivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:numberTrivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matcher/matcher.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture("trivia_cached.json")));
    test(
      'should return NumberTrivia from SharedPreferences when there is one on the cache',
      () async {
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture("trivia_cached.json"));
        final result = await dataSource.getLastNumberTrivia();
        verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test('should throw cache Excepton when there is not a cached value',
        () async {
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      final call = dataSource.getLastNumberTrivia;

      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group("cacheNumberTrivia", () {
    final tNumberTriviaModel = NumberTriviaModel(text: "Test trivia", number: 1);
    test(
      "should call SharedPreferences to cache the data",
      () async {

        dataSource.cacheNumberTrivia(tNumberTriviaModel);
        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
        verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA,expectedJsonString ));
      },
    );
  });
}
