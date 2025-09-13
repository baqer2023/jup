import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app32/app/models/weather_models.dart';

class WeatherApiService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherApiService({required this.apiKey});

  Future<WeatherData> getWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final params = {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
        //'units': 'metric', // Uncomment if you want metric units
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load weather data: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }
}
