class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String icon;
  final String mainCondition;
  final int pressure;
  final int visibility;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final int cloudiness;
  final DateTime dateTime;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.cloudiness,
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
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDeg: json['wind']['deg'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? '',
      pressure: json['main']['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      uvIndex: 0.0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunrise'] as int) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunset'] as int) * 1000),
      cloudiness: json['clouds']['all'] ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double tempMorning;
  final double tempAfternoon;
  final double tempEvening;
  final String description;
  final String icon;
  final String mainCondition;
  final int humidity;
  final double windSpeed;
  final double pop; // Probability of precipitation

  ForecastDay({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.tempMorning,
    required this.tempAfternoon,
    required this.tempEvening,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
  });

  factory ForecastDay.fromHourlyList(
      List<Map<String, dynamic>> hourlyData, DateTime date) {
    double tempMin = double.infinity;
    double tempMax = double.negativeInfinity;
    double tempMorning = 0, tempAfternoon = 0, tempEvening = 0;
    int morningCount = 0, afternoonCount = 0, eveningCount = 0;
    Map<String, int> conditionCount = {};
    double totalHumidity = 0;
    double totalWind = 0;
    double maxPop = 0;

    for (var h in hourlyData) {
      double temp = (h['main']['temp'] as num).toDouble();
      if (temp < tempMin) tempMin = temp;
      if (temp > tempMax) tempMax = temp;

      DateTime dt =
          DateTime.fromMillisecondsSinceEpoch((h['dt'] as int) * 1000);
      if (dt.hour >= 6 && dt.hour < 12) {
        tempMorning += temp;
        morningCount++;
      } else if (dt.hour >= 12 && dt.hour < 18) {
        tempAfternoon += temp;
        afternoonCount++;
      } else if (dt.hour >= 18 && dt.hour < 22) {
        tempEvening += temp;
        eveningCount++;
      }

      String cond = h['weather'][0]['main'];
      conditionCount[cond] = (conditionCount[cond] ?? 0) + 1;
      totalHumidity += h['main']['humidity'];
      totalWind += (h['wind']['speed'] as num).toDouble();
      double pop = (h['pop'] as num? ?? 0).toDouble();
      if (pop > maxPop) maxPop = pop;
    }

    String dominantCondition =
        conditionCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Find icon for dominant condition
    String icon = '01d';
    for (var h in hourlyData) {
      if (h['weather'][0]['main'] == dominantCondition) {
        icon = h['weather'][0]['icon'].replaceAll('n', 'd');
        break;
      }
    }

    String description = '';
    for (var h in hourlyData) {
      if (h['weather'][0]['main'] == dominantCondition) {
        description = h['weather'][0]['description'];
        break;
      }
    }

    return ForecastDay(
      date: date,
      tempMin: tempMin == double.infinity ? 0 : tempMin,
      tempMax: tempMax == double.negativeInfinity ? 0 : tempMax,
      tempMorning: morningCount > 0
          ? tempMorning / morningCount
          : (tempMin + tempMax) / 2,
      tempAfternoon: afternoonCount > 0
          ? tempAfternoon / afternoonCount
          : (tempMin + tempMax) / 2,
      tempEvening: eveningCount > 0
          ? tempEvening / eveningCount
          : (tempMin + tempMax) / 2,
      description: description,
      icon: icon,
      mainCondition: dominantCondition,
      humidity: (totalHumidity / hourlyData.length).round(),
      windSpeed: totalWind / hourlyData.length,
      pop: maxPop,
    );
  }
}
