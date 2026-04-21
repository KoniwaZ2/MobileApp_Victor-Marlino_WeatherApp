import 'package:flutter/material.dart';

class WeatherTheme {
  static WeatherThemeData getTheme(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return WeatherThemeData(
          gradientColors: [
            const Color(0xFF1A6EBD),
            const Color(0xFF2196F3),
            const Color(0xFF64B5F6),
            const Color(0xFFFFD54F),
          ],
          accentColor: const Color(0xFFFFD54F),
          cardColor: const Color(0x33FFFFFF),
          textColor: Colors.white,
          emoji: '☀️',
          backgroundParticle: 'sun',
        );
      case 'clouds':
        return WeatherThemeData(
          gradientColors: [
            const Color(0xFF37474F),
            const Color(0xFF546E7A),
            const Color(0xFF78909C),
            const Color(0xFFB0BEC5),
          ],
          accentColor: const Color(0xFFCFD8DC),
          cardColor: const Color(0x33FFFFFF),
          textColor: Colors.white,
          emoji: '☁️',
          backgroundParticle: 'cloud',
        );
      case 'rain':
      case 'drizzle':
        return WeatherThemeData(
          gradientColors: [
            const Color(0xFF1A237E),
            const Color(0xFF283593),
            const Color(0xFF3949AB),
            const Color(0xFF5C6BC0),
          ],
          accentColor: const Color(0xFF80DEEA),
          cardColor: const Color(0x33FFFFFF),
          textColor: Colors.white,
          emoji: '🌧️',
          backgroundParticle: 'rain',
        );
      case 'thunderstorm':
        return WeatherThemeData(
          gradientColors: [
            const Color(0xFF1B0030),
            const Color(0xFF2D0050),
            const Color(0xFF4A148C),
            const Color(0xFF6A1B9A),
          ],
          accentColor: const Color(0xFFFFFF00),
          cardColor: const Color(0x33FFFFFF),
          textColor: Colors.white,
          emoji: '⛈️',
          backgroundParticle: 'thunder',
        );
      case 'snow':
        return WeatherThemeData(
          gradientColors: [
            const Color(0xFF1E3A5F),
            const Color(0xFF2C5282),
            const Color(0xFF4A90D9),
            const Color(0xFFBFDBFE),
          ],
          accentColor: const Color(0xFFE3F2FD),
          cardColor: const Color(0x33FFFFFF),
          textColor: Colors.white,
          emoji: '❄️',
          backgroundParticle: 'snow',
        );
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fog':
      case 'dust':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return WeatherThemeData(
          gradientColors: [
            const Color(0xFF3E2723),
            const Color(0xFF4E342E),
            const Color(0xFF6D4C41),
            const Color(0xFF8D6E63),
          ],
          accentColor: const Color(0xFFD7CCC8),
          cardColor: const Color(0x33FFFFFF),
          textColor: Colors.white,
          emoji: '🌫️',
          backgroundParticle: 'fog',
        );
      default:
        return WeatherThemeData(
          gradientColors: [
            const Color(0xFF0D47A1),
            const Color(0xFF1565C0),
            const Color(0xFF1976D2),
            const Color(0xFF42A5F5),
          ],
          accentColor: const Color(0xFF90CAF9),
          cardColor: const Color(0x33FFFFFF),
          textColor: Colors.white,
          emoji: '🌤️',
          backgroundParticle: 'default',
        );
    }
  }

  static String getWindDirection(int degrees) {
    const directions = ['U', 'TL', 'T', 'TG', 'S', 'BD', 'B', 'BL'];
    int index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  static String getConditionIndonesian(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Cerah';
      case 'clouds':
        return 'Berawan';
      case 'rain':
        return 'Hujan';
      case 'drizzle':
        return 'Gerimis';
      case 'thunderstorm':
        return 'Badai Petir';
      case 'snow':
        return 'Salju';
      case 'mist':
      case 'fog':
        return 'Berkabut';
      case 'haze':
        return 'Kabut Asap';
      default:
        return condition;
    }
  }
}

class WeatherThemeData {
  final List<Color> gradientColors;
  final Color accentColor;
  final Color cardColor;
  final Color textColor;
  final String emoji;
  final String backgroundParticle;

  WeatherThemeData({
    required this.gradientColors,
    required this.accentColor,
    required this.cardColor,
    required this.textColor,
    required this.emoji,
    required this.backgroundParticle,
  });
}
