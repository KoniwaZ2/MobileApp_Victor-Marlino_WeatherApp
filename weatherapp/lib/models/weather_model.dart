class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final String mainCondition;
  final DateTime dateTime;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.dateTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
    );
  }
}
