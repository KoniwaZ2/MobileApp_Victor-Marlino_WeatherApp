import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../theme/weather_theme.dart';
import '../widgets/animated_background.dart';

class WeatherScreen extends StatefulWidget {
  final String apiKey;
  const WeatherScreen({super.key, required this.apiKey});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  late WeatherService _weatherService;
  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;
  String _currentCity = 'Jakarta';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late AnimationController _contentAnimCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  WeatherThemeData get _theme =>
      WeatherTheme.getTheme(_weather?.mainCondition ?? 'default');

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService(apiKey: widget.apiKey);
    _contentAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentFade =
        CurvedAnimation(parent: _contentAnimCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentAnimCtrl, curve: Curves.easeOutCubic));

    _loadWeather('Jakarta');
  }

  Future<void> _loadWeather(String city) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _contentAnimCtrl.reset();

    try {
      final weather = await _weatherService.getCurrentWeather(city);
      setState(() {
        _weather = weather;
        _currentCity = weather.cityName;
        _isLoading = false;
      });
      _contentAnimCtrl.forward();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) {
      _searchFocus.unfocus();
      _loadWeather(city);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _contentAnimCtrl.dispose();
    super.dispose();
  }

  Widget _buildGlassCard(
      {required Widget child,
      EdgeInsetsGeometry? padding,
      double borderRadius = 28}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(borderRadius),
            border:
                Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedWeatherBackground(
                particleType: theme.backgroundParticle,
                gradientColors: theme.gradientColors,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: _isLoading
                        ? _buildLoading()
                        : _error != null
                            ? _buildError()
                            : _buildContent(theme),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              child: _buildFloatingSearchBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return _buildGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 30,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Cari kota...',
                hintStyle:
                    GoogleFonts.poppins(color: Colors.white54, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _onSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    Icon(Icons.cancel_rounded, color: Colors.white54, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          const SizedBox(height: 24),
          Text('Mengambil data cuaca...',
              style: GoogleFonts.poppins(
                  color: Colors.white70, fontSize: 15, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _buildGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded,
                  color: Colors.white, size: 60),
              const SizedBox(height: 16),
              Text('Lokasi Tidak Ditemukan',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_error ?? 'Silakan coba cari dengan nama kota yang berbeda.',
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _loadWeather('Jakarta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('Kembali ke Default',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(WeatherThemeData theme) {
    final w = _weather!;
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLocationHeader(w),
                const SizedBox(height: 40),
                _buildMainWeatherCard(w, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader(WeatherData w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(w.cityName,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat("EEEE, d MMMM yyyy", 'en_US').format(w.dateTime),
          style: GoogleFonts.poppins(
              color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard(WeatherData w, WeatherThemeData theme) {
    return _buildGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${w.temperature.round()}°',
                        style: GoogleFonts.poppins(
                            fontSize: 84,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1.1)),
                    Text(w.description.toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 1.5)),
                  ],
                ),
              ),
              CachedNetworkImage(
                imageUrl: _weatherService.getIconUrl(w.icon),
                width: 130,
                height: 130,
                fit: BoxFit.cover,
                placeholder: (c, u) =>
                    const Icon(Icons.cloud, color: Colors.white30, size: 60),
                errorWidget: (c, u, e) =>
                    Text(theme.emoji, style: const TextStyle(fontSize: 70)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat('Feels Like', '${w.feelsLike.round()}°',
                  Icons.thermostat_rounded),
              _miniStat(
                  'Max', '${w.tempMax.round()}°', Icons.arrow_upward_rounded),
              _miniStat(
                  'Min', '${w.tempMin.round()}°', Icons.arrow_downward_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Row(
      children: [
        // Lingkaran background untuk ikon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        // Teks Label di atas, Nilai di bawah
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, // <-- Keterangan diletakkan di atas
                style:
                    GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            Text(value, // <-- Suhu diletakkan di bawah
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
