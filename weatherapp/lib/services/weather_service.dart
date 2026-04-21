import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<WeatherData> getCurrentWeather(String city) async {
    final url = Uri.parse(
        '$_baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=en');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Kota tidak ditemukan');
    } else if (response.statusCode == 401) {
      throw Exception('API key tidak valid');
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }

  Future<WeatherData> getCurrentWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=en');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }

  String getIconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}
