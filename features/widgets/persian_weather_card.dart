import 'package:flutter/cupertino.dart' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, TextDirection;
import 'package:my_app32/app/models/weather_models.dart';
import 'dart:ui' show TextDirection;
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';

class PersianWeatherCard extends StatelessWidget {
  final WeatherData weather;

  const PersianWeatherCard({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert temperature from Kelvin to Celsius
    final temp = AppUtilsMixin.toPersianNumber(
      (weather.main.temp - 273.15).toStringAsFixed(1),
    );
    final humidity = AppUtilsMixin.toPersianNumber(weather.main.humidity);
    final windSpeed = AppUtilsMixin.toPersianNumber(
      weather.wind.speed.toStringAsFixed(0),
    );
    final precipitation = AppUtilsMixin.toPersianNumber(
      weather.rain?.oneHour?.toStringAsFixed(0) ?? '۰',
    );

    late String dayName;
    late String date;

    final now = DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000);
    final jalali = Jalali.fromDateTime(now);
    dayName = jalali.formatter.wN; // Persian week day name
    date =
        '${AppUtilsMixin.toPersianNumber(jalali.formatter.d)} ${jalali.formatter.mN} ${AppUtilsMixin.toPersianNumber(jalali.formatter.y)}';

    // Get Persian day name and date
    //final now = DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000);
    //final dayName = DateFormat('EEEE', 'fa').format(now);
    //final date = DateFormat('d MMMM', 'fa').format(now);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with weather condition and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weather.weather.first.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IranSans',
                  ),
                ),
                Text(
                  "$dayName، $date",
                  style: const TextStyle(fontSize: 16, fontFamily: 'IranSans'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // City name
            Text(
              weather.name,
              style: const TextStyle(fontSize: 16, fontFamily: 'IranSans'),
            ),

            const Divider(height: 24, thickness: 1),

            // Weather metrics in a grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildWeatherMetric("$humidity %", "رطوبت هوا"),
                _buildWeatherMetric("$precipitation %", "شدت بارش"),
                _buildWeatherMetric("$windSpeed km/h", "سرعت باد"),
                _buildWeatherMetric("$temp °C", "دمای هوا"),
              ],
            ),

            const SizedBox(height: 16),

            // Weather icon and additional info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(
                  weather.weather.first.iconUrl,
                  width: 60,
                  height: 60,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildAdditionalInfo(
                      "فشار هوا",
                      AppUtilsMixin.toPersianNumber(
                        "${weather.main.pressure} hPa",
                      ),
                    ),
                    _buildAdditionalInfo(
                      "دید",
                      AppUtilsMixin.toPersianNumber(
                        "${(weather.visibility / 1000).toStringAsFixed(1)} km",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'IranSans',
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontFamily: 'IranSans'),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontFamily: 'IranSans'),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'IranSans',
            ),
          ),
        ],
      ),
    );
  }
}
