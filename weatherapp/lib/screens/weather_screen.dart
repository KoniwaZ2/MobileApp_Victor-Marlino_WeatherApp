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
  List<ForecastDay> _forecast = [];
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
      duration: const Duration(milliseconds: 700),
    );
    _contentFade =
        CurvedAnimation(parent: _contentAnimCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentAnimCtrl, curve: Curves.easeOut));

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
      final forecast = await _weatherService.getForecast(city);
      setState(() {
        _weather = weather;
        _forecast = forecast;
        _currentCity = city;
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

  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);
  String _formatDay(DateTime dt) => DateFormat('EEE', 'id_ID').format(dt);
  String _formatDate(DateTime dt) => DateFormat('d MMM', 'id_ID').format(dt);

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _contentAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedWeatherBackground(
                particleType: theme.backgroundParticle,
                gradientColors: theme.gradientColors,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: _isLoading
                        ? _buildLoading()
                        : _error != null
                            ? _buildError()
                            : _buildContent(theme),
                  ),
                  // Search bar fixed at bottom
                  _buildBottomSearchBar(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar(WeatherThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.gradientColors.last.withOpacity(0.85),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.22),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari kota...',
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.white38, fontSize: 14),
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
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.close_rounded,
                            color: Colors.white54, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withOpacity(0.25), width: 1.5),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 22),
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
          const SizedBox(
            width: 46,
            height: 46,
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
          const SizedBox(height: 18),
          Text('Memuat data cuaca...',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: Colors.white54, size: 70),
            const SizedBox(height: 20),
            Text(_error ?? 'Terjadi kesalahan',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Periksa koneksi atau nama kota Anda',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _loadWeather(_currentCity),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Coba Lagi',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationHeader(w),
              const SizedBox(height: 22),
              _buildMainWeatherCard(w, theme),
              const SizedBox(height: 14),
              _buildDetailCards(w),
              const SizedBox(height: 18),
              _buildSunriseSunset(w),
              const SizedBox(height: 18),
              _buildForecastSection(theme),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader(WeatherData w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: Colors.white70, size: 15),
            const SizedBox(width: 4),
            Text('${w.cityName}, ${w.country}',
                style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          DateFormat("EEEE, d MMMM yyyy", 'id_ID').format(w.dateTime),
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard(WeatherData w, WeatherThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${w.temperature.round()}°',
                        style: GoogleFonts.poppins(
                            fontSize: 82,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            height: 1)),
                    const SizedBox(height: 4),
                    Text(w.description.toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white60,
                            letterSpacing: 2)),
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08)),
                child: CachedNetworkImage(
                  imageUrl: _weatherService.getIconUrl(w.icon),
                  fit: BoxFit.contain,
                  placeholder: (c, u) =>
                      const Icon(Icons.cloud, color: Colors.white30, size: 56),
                  errorWidget: (c, u, e) => Text(theme.emoji,
                      style: const TextStyle(fontSize: 56),
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat('Terasa', '${w.feelsLike.round()}°C',
                  Icons.thermostat_rounded),
              _miniStat(
                  'Maks', '${w.tempMax.round()}°C', Icons.arrow_upward_rounded,
                  color: Colors.redAccent),
              _miniStat(
                  'Min', '${w.tempMin.round()}°C', Icons.arrow_downward_rounded,
                  color: Colors.lightBlueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white54, size: 15),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildDetailCards(WeatherData w) {
    final details = [
      _DetailItem(Icons.water_drop_rounded, 'Kelembaban', '${w.humidity}%',
          Colors.lightBlueAccent),
      _DetailItem(Icons.air_rounded, 'Angin',
          '${w.windSpeed.toStringAsFixed(1)} m/s', Colors.white70),
      _DetailItem(Icons.compress_rounded, 'Tekanan', '${w.pressure} hPa',
          Colors.orangeAccent),
      _DetailItem(Icons.visibility_rounded, 'Visibilitas',
          '${(w.visibility / 1000).toStringAsFixed(1)} km', Colors.greenAccent),
      _DetailItem(
          Icons.cloud_rounded, 'Awan', '${w.cloudiness}%', Colors.white54),
      _DetailItem(Icons.explore_rounded, 'Arah Angin',
          WeatherTheme.getWindDirection(w.windDeg), Colors.purpleAccent),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: details.map((d) => _buildDetailCard(d)).toList(),
    );
  }

  Widget _buildDetailCard(_DetailItem d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(d.icon, color: d.iconColor, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.value,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(d.label,
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunset(WeatherData w) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Siang & Malam',
              style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.wb_sunny_rounded,
                          color: Colors.orangeAccent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatTime(w.sunrise),
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600)),
                        Text('Terbit',
                            style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                  width: 1, height: 44, color: Colors.white.withOpacity(0.1)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.nights_stay_rounded,
                            color: Colors.indigoAccent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatTime(w.sunset),
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600)),
                          Text('Terbenam',
                              style: GoogleFonts.poppins(
                                  color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection(WeatherThemeData theme) {
    if (_forecast.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prakiraan 5 Hari',
            style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: List.generate(_forecast.length, (i) {
              return _buildForecastRow(_forecast[i], i, _forecast.length);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastRow(ForecastDay day, int index, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: index < total - 1
            ? Border(
                bottom:
                    BorderSide(color: Colors.white.withOpacity(0.06), width: 1))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDay(day.date),
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(_formatDate(day.date),
                    style: GoogleFonts.poppins(
                        color: Colors.white38, fontSize: 9)),
              ],
            ),
          ),
          CachedNetworkImage(
            imageUrl: _weatherService.getIconUrl(day.icon),
            width: 40,
            height: 40,
            placeholder: (c, u) =>
                const Icon(Icons.cloud, color: Colors.white30),
            errorWidget: (c, u, e) => Text(
                WeatherTheme.getTheme(day.mainCondition).emoji,
                style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(WeatherTheme.getConditionIndonesian(day.mainCondition),
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                if (day.pop > 0)
                  Row(
                    children: [
                      const Icon(Icons.water_drop_rounded,
                          color: Colors.lightBlueAccent, size: 10),
                      const SizedBox(width: 2),
                      Text('${(day.pop * 100).round()}%',
                          style: GoogleFonts.poppins(
                              color: Colors.lightBlueAccent, fontSize: 10)),
                    ],
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${day.tempMax.round()}°',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              Text('${day.tempMin.round()}°',
                  style:
                      GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  _DetailItem(this.icon, this.label, this.value, this.iconColor);
}
