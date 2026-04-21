import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<WeatherData> getCurrentWeather(String city) async {
    final url = Uri.parse(
        '$_baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=id');

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
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }

  Future<List<ForecastDay>> getForecast(String city) async {
    final url = Uri.parse(
        '$_baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return _parseForecast(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Kota tidak ditemukan');
    } else {
      throw Exception('Gagal memuat data prakiraan');
    }
  }

  Future<List<ForecastDay>> getForecastByCoords(double lat, double lon) async {
    final url = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return _parseForecast(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat data prakiraan');
    }
  }

  List<ForecastDay> _parseForecast(Map<String, dynamic> data) {
    List<dynamic> list = data['list'];
    Map<String, List<Map<String, dynamic>>> groupedByDay = {};

    for (var item in list) {
      DateTime dt =
          DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      String dateKey =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      if (!groupedByDay.containsKey(dateKey)) {
        groupedByDay[dateKey] = [];
      }
      groupedByDay[dateKey]!.add(Map<String, dynamic>.from(item));
    }

    List<ForecastDay> forecasts = [];
    DateTime today = DateTime.now();
    String todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (var entry in groupedByDay.entries) {
      if (entry.key == todayKey) continue; // Skip today
      if (entry.value.isEmpty) continue;

      DateTime date = DateTime.parse(entry.key);
      forecasts.add(ForecastDay.fromHourlyList(entry.value, date));
    }

    return forecasts.take(5).toList();
  }

  String getIconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}
