import 'package:weather/features/weather/domain/entities/daily_forecast.dart';
import 'package:weather/features/weather/domain/entities/hourly_forecast.dart';
import 'package:weather/features/weather/domain/entities/weather.dart';

/// Sealed class representing weather UI states.
sealed class WeatherState {
  const WeatherState();
}

/// Initial state before any data is loaded.
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// Loading state while fetching data.
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// Success state with loaded weather data.
class WeatherLoaded extends WeatherState {
  const WeatherLoaded({
    required this.currentWeather,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  final Weather currentWeather;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
}

/// Error state when data fetching fails.
class WeatherError extends WeatherState {
  const WeatherError(this.message);

  final String message;
}
