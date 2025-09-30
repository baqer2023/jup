import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app32/app/models/weather_models.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';

class WeatherDisplay extends StatelessWidget {
  final Future<WeatherData> weatherFuture;

  const WeatherDisplay({super.key, required this.weatherFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const WeatherLoadingShimmer();
        } else if (snapshot.hasError) {
          return WeatherErrorWidget(error: snapshot.error.toString());
        } else if (snapshot.hasData) {
          return WeatherCard(weather: snapshot.data!);
        } else {
          return const WeatherEmptyState();
        }
      },
    );
  }
}

class WeatherCard extends StatefulWidget {
  final WeatherData weather;

  const WeatherCard({super.key, required this.weather});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late String _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat.Hm().format(now); // ساعت:دقیقه
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temp = AppUtilsMixin.toPersianNumber(
      (widget.weather.main.temp - 273.15).round(),
    );

    final now = DateTime.fromMillisecondsSinceEpoch(widget.weather.dt * 1000);
    final jalali = Jalali.fromDateTime(now);
    final dayName = jalali.formatter.wN; // نام روز

    final condition = _translateWeatherCondition(
      widget.weather.weather.first.description,
    );
    final weatherIcon =
        _getWeatherIcon(widget.weather.weather.first.description);

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$temp°',
            style: TextStyle(
              fontFamily: 'IranYekan',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                condition,
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$dayName، تهران',
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ساعت $_currentTime',
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.blueGrey[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          weatherIcon,
        ],
      ),
    );
  }

  String _translateWeatherCondition(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear')) return 'آفتابی';
    if (desc.contains('cloud')) return 'ابری';
    if (desc.contains('rain')) return 'بارانی';
    if (desc.contains('snow')) return 'برفی';
    if (desc.contains('thunderstorm')) return 'طوفانی';
    return 'نامشخص';
  }

  Widget _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear')) {
      return SvgPicture.asset(
        'assets/svg/sunny.svg',
        width: 48,
        height: 48,
      );
    } else if (desc.contains('cloud')) {
      return SvgPicture.asset(
        'assets/svg/partly_cloudy.svg',
        width: 48,
        height: 48,
      );
    } else if (desc.contains('rain')) {
      return SvgPicture.asset(
        'assets/svg/rainy.svg',
        width: 48,
        height: 48,
      );
    } else if (desc.contains('snow')) {
      return SvgPicture.asset(
        'assets/svg/snowy.svg',
        width: 48,
        height: 48,
      );
    } else if (desc.contains('thunderstorm')) {
      return SvgPicture.asset(
        'assets/svg/thunderstorm.svg',
        width: 48,
        height: 48,
      );
    }
    return const Icon(Icons.help_outline, size: 48, color: Colors.grey);
  }
}

class WeatherLoadingShimmer extends StatelessWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.8),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
    );
  }
}

class WeatherErrorWidget extends StatelessWidget {
  final String error;

  const WeatherErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 6.4),
          const Text(
            'خطا در دریافت اطلاعات آب و هوا',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.8),
          ),
          const SizedBox(height: 3.2),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 11.2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WeatherEmptyState extends StatelessWidget {
  const WeatherEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 32, color: Colors.grey),
          SizedBox(height: 6.4),
          Text(
            'داده‌ای برای نمایش وجود ندارد',
            style: TextStyle(fontSize: 11.2),
          ),
        ],
      ),
    );
  }
}
