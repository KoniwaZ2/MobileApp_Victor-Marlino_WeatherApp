import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWeatherBackground extends StatefulWidget {
  final String particleType;
  final List<Color> gradientColors;

  const AnimatedWeatherBackground({
    super.key,
    required this.particleType,
    required this.gradientColors,
  });

  @override
  State<AnimatedWeatherBackground> createState() =>
      _AnimatedWeatherBackgroundState();
}

class _AnimatedWeatherBackgroundState extends State<AnimatedWeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  void _initParticles() {
    _particles = List.generate(
        30,
        (i) => Particle(
              x: _random.nextDouble(),
              y: _random.nextDouble(),
              size: _random.nextDouble() * 8 + 2,
              speed: _random.nextDouble() * 0.3 + 0.1,
              opacity: _random.nextDouble() * 0.6 + 0.2,
              angle: _random.nextDouble() * pi * 2,
            ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WeatherParticlePainter(
                particles: _particles,
                progress: _controller.value,
                particleType: widget.particleType,
                color: widget.gradientColors.last,
              ),
              size: Size.infinite,
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.5, -0.7),
              radius: 1.2,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Particle {
  double x, y, size, speed, opacity, angle;
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });
}

class WeatherParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final String particleType;
  final Color color;

  WeatherParticlePainter({
    required this.particles,
    required this.progress,
    required this.particleType,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      double animY = (p.y + progress * p.speed) % 1.0;
      double animX = p.x + sin(progress * pi * 2 + p.angle) * 0.02;

      final paint = Paint()
        ..color = Colors.white.withOpacity(p.opacity * 0.4)
        ..style = PaintingStyle.fill;

      switch (particleType) {
        case 'rain':
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                animX * size.width,
                animY * size.height,
                1.5,
                p.size * 2.5,
              ),
              const Radius.circular(1),
            ),
            paint,
          );
          break;
        case 'snow':
          canvas.drawCircle(
            Offset(animX * size.width, animY * size.height),
            p.size * 0.6,
            paint,
          );
          break;
        case 'cloud':
          canvas.drawCircle(
            Offset(animX * size.width,
                p.y * size.height + sin(progress * pi * 2) * 10),
            p.size * 3,
            Paint()
              ..color = Colors.white.withOpacity(p.opacity * 0.06)
              ..style = PaintingStyle.fill,
          );
          break;
        case 'sun':
          canvas.drawCircle(
            Offset(animX * size.width,
                p.y * size.height + sin(progress * pi * 2 + p.angle) * 15),
            p.size * 0.4,
            Paint()
              ..color = Colors.yellow.withOpacity(p.opacity * 0.3)
              ..style = PaintingStyle.fill,
          );
          break;
        default:
          canvas.drawCircle(
            Offset(animX * size.width, animY * size.height),
            p.size * 0.5,
            paint,
          );
      }
    }
  }

  @override
  bool shouldRepaint(WeatherParticlePainter oldDelegate) => true;
}
