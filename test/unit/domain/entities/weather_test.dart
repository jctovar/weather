import 'package:flutter_test/flutter_test.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';

void main() {
  group('Weather', () {
    group('description (WMO codes)', () {
      test('returns Cielo despejado for code 0', () {
        final weather = Weather(
          temperature: 20,
          apparentTemperature: 18,
          humidity: 50,
          precipitation: 0,
          rain: 0,
          weatherCode: 0,
          windSpeed: 10,
          isDay: true,
          time: DateTime(2024, 1, 1, 12),
        );
        expect(weather.description, 'Cielo despejado');
      });

      test('returns Parcialmente nublado for codes 1, 2, 3', () {
        for (final code in [1, 2, 3]) {
          expect(
            Weather(
              temperature: 20,
              apparentTemperature: 18,
              humidity: 50,
              precipitation: 0,
              rain: 0,
              weatherCode: code,
              windSpeed: 10,
              isDay: true,
              time: DateTime(2024, 1, 1, 12),
            ).description,
            'Parcialmente nublado',
          );
        }
      });

      test('returns Niebla for codes 45, 48', () {
        for (final code in [45, 48]) {
          expect(
            Weather(
              temperature: 10,
              apparentTemperature: 8,
              humidity: 90,
              precipitation: 0,
              rain: 0,
              weatherCode: code,
              windSpeed: 5,
              isDay: true,
              time: DateTime(2024, 1, 1, 12),
            ).description,
            'Niebla',
          );
        }
      });

      test('returns Llovizna for codes 51, 53, 55', () {
        for (final code in [51, 53, 55]) {
          expect(
            Weather(
              temperature: 12,
              apparentTemperature: 10,
              humidity: 85,
              precipitation: 0.5,
              rain: 0.5,
              weatherCode: code,
              windSpeed: 8,
              isDay: true,
              time: DateTime(2024, 1, 1, 12),
            ).description,
            'Llovizna',
          );
        }
      });

      test('returns Lluvia for codes 61, 63, 65', () {
        for (final code in [61, 63, 65]) {
          expect(
            Weather(
              temperature: 15,
              apparentTemperature: 13,
              humidity: 80,
              precipitation: 2.0,
              rain: 2.0,
              weatherCode: code,
              windSpeed: 12,
              isDay: true,
              time: DateTime(2024, 1, 1, 12),
            ).description,
            'Lluvia',
          );
        }
      });

      test('returns Nieve for codes 71, 73, 75', () {
        for (final code in [71, 73, 75]) {
          expect(
            Weather(
              temperature: -2,
              apparentTemperature: -5,
              humidity: 70,
              precipitation: 1.0,
              rain: 0,
              weatherCode: code,
              windSpeed: 15,
              isDay: true,
              time: DateTime(2024, 1, 1, 12),
            ).description,
            'Nieve',
          );
        }
      });

      test('returns Chubascos for codes 80, 81, 82', () {
        for (final code in [80, 81, 82]) {
          expect(
            Weather(
              temperature: 18,
              apparentTemperature: 16,
              humidity: 75,
              precipitation: 5.0,
              rain: 5.0,
              weatherCode: code,
              windSpeed: 20,
              isDay: true,
              time: DateTime(2024, 1, 1, 12),
            ).description,
            'Chubascos',
          );
        }
      });

      test('returns Tormenta for codes 95, 96, 99', () {
        for (final code in [95, 96, 99]) {
          expect(
            Weather(
              temperature: 22,
              apparentTemperature: 20,
              humidity: 90,
              precipitation: 10.0,
              rain: 10.0,
              weatherCode: code,
              windSpeed: 30,
              isDay: false,
              time: DateTime(2024, 1, 1, 22),
            ).description,
            'Tormenta',
          );
        }
      });

      test('returns Desconocido for unknown code', () {
        expect(
          Weather(
            temperature: 20,
            apparentTemperature: 18,
            humidity: 50,
            precipitation: 0,
            rain: 0,
            weatherCode: 999,
            windSpeed: 10,
            isDay: true,
            time: DateTime(2024, 1, 1, 12),
          ).description,
          'Desconocido',
        );
      });
    });
  });
}
