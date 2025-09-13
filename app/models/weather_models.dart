// class WeatherResponse {
//   final double lat;
//   final double lon;
//   final String timezone;
//   final int timezoneOffset;
//   final CurrentWeather current;
//   final List<MinutelyForecast>? minutely;
//   final List<HourlyForecast> hourly;
//   final List<DailyForecast> daily;
//   final List<WeatherAlert>? alerts;
//
//   WeatherResponse({
//     required this.lat,
//     required this.lon,
//     required this.timezone,
//     required this.timezoneOffset,
//     required this.current,
//     this.minutely,
//     required this.hourly,
//     required this.daily,
//     this.alerts,
//   });
//
//   factory WeatherResponse.fromJson(Map<String, dynamic> json) {
//     return WeatherResponse(
//       lat: json['lat']?.toDouble() ?? 11.0,
//       lon: json['lon']?.toDouble() ?? 11.0,
//       timezone: json['timezone'] ?? '',
//       timezoneOffset: json['timezone_offset'] ?? 1,
//       current: CurrentWeather.fromJson(json['current']),
//       minutely: json['minutely'] != null
//           ? List<MinutelyForecast>.from(
//           json['minutely'].map((x) => MinutelyForecast.fromJson(x)))
//           : null,
//       hourly: List<HourlyForecast>.from(
//           json['hourly'].map((x) => HourlyForecast.fromJson(x))),
//       daily: List<DailyForecast>.from(
//           json['daily'].map((x) => DailyForecast.fromJson(x))),
//       alerts: json['alerts'] != null
//           ? List<WeatherAlert>.from(
//           json['alerts'].map((x) => WeatherAlert.fromJson(x)))
//           : null,
//     );
//   }
// }
//
// class CurrentWeather {
//   final int dt;
//   final int sunrise;
//   final int sunset;
//   final double temp;
//   final double feelsLike;
//   final int pressure;
//   final int humidity;
//   final double dewPoint;
//   final double uvi;
//   final int clouds;
//   final int visibility;
//   final double windSpeed;
//   final int windDeg;
//   final double windGust;
//   final List<WeatherCondition> weather;
//
//   CurrentWeather({
//     required this.dt,
//     required this.sunrise,
//     required this.sunset,
//     required this.temp,
//     required this.feelsLike,
//     required this.pressure,
//     required this.humidity,
//     required this.dewPoint,
//     required this.uvi,
//     required this.clouds,
//     required this.visibility,
//     required this.windSpeed,
//     required this.windDeg,
//     required this.windGust,
//     required this.weather,
//   });
//
//   factory CurrentWeather.fromJson(Map<String, dynamic> json) {
//     return CurrentWeather(
//       dt: json['dt'],
//       sunrise: json['sunrise'],
//       sunset: json['sunset'],
//       temp: json['temp']?.toDouble() ?? 0.0,
//       feelsLike: json['feels_like']?.toDouble() ?? 0.0,
//       pressure: json['pressure'] ?? 0,
//       humidity: json['humidity'] ?? 0,
//       dewPoint: json['dew_point']?.toDouble() ?? 0.0,
//       uvi: json['uvi']?.toDouble() ?? 0.0,
//       clouds: json['clouds'] ?? 0,
//       visibility: json['visibility'] ?? 0,
//       windSpeed: json['wind_speed']?.toDouble() ?? 0.0,
//       windDeg: json['wind_deg'] ?? 0,
//       windGust: json['wind_gust']?.toDouble() ?? 0.0,
//       weather: List<WeatherCondition>.from(
//           json['weather'].map((x) => WeatherCondition.fromJson(x))),
//     );
//   }
// }
//
// class WeatherCondition {
//   final int id;
//   final String main;
//   final String description;
//   final String icon;
//
//   WeatherCondition({
//     required this.id,
//     required this.main,
//     required this.description,
//     required this.icon,
//   });
//
//   factory WeatherCondition.fromJson(Map<String, dynamic> json) {
//     return WeatherCondition(
//       id: json['id'],
//       main: json['main'],
//       description: json['description'],
//       icon: json['icon'],
//     );
//   }
//
//   String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
// }
//
// class MinutelyForecast {
//   final int dt;
//   final double precipitation;
//
//   MinutelyForecast({
//     required this.dt,
//     required this.precipitation,
//   });
//
//   factory MinutelyForecast.fromJson(Map<String, dynamic> json) {
//     return MinutelyForecast(
//       dt: json['dt'],
//       precipitation: json['precipitation']?.toDouble() ?? 0.0,
//     );
//   }
// }
//
// class HourlyForecast {
//   final int dt;
//   final double temp;
//   final double feelsLike;
//   final int pressure;
//   final int humidity;
//   final double dewPoint;
//   final double uvi;
//   final int clouds;
//   final int visibility;
//   final double windSpeed;
//   final int windDeg;
//   final double windGust;
//   final List<WeatherCondition> weather;
//   final double pop;
//
//   HourlyForecast({
//     required this.dt,
//     required this.temp,
//     required this.feelsLike,
//     required this.pressure,
//     required this.humidity,
//     required this.dewPoint,
//     required this.uvi,
//     required this.clouds,
//     required this.visibility,
//     required this.windSpeed,
//     required this.windDeg,
//     required this.windGust,
//     required this.weather,
//     required this.pop,
//   });
//
//   factory HourlyForecast.fromJson(Map<String, dynamic> json) {
//     return HourlyForecast(
//       dt: json['dt'],
//       temp: json['temp']?.toDouble() ?? 0.0,
//       feelsLike: json['feels_like']?.toDouble() ?? 0.0,
//       pressure: json['pressure'] ?? 0,
//       humidity: json['humidity'] ?? 0,
//       dewPoint: json['dew_point']?.toDouble() ?? 0.0,
//       uvi: json['uvi']?.toDouble() ?? 0.0,
//       clouds: json['clouds'] ?? 0,
//       visibility: json['visibility'] ?? 0,
//       windSpeed: json['wind_speed']?.toDouble() ?? 0.0,
//       windDeg: json['wind_deg'] ?? 0,
//       windGust: json['wind_gust']?.toDouble() ?? 0.0,
//       weather: List<WeatherCondition>.from(
//           json['weather'].map((x) => WeatherCondition.fromJson(x))),
//       pop: json['pop']?.toDouble() ?? 0.0,
//     );
//   }
// }
//
// class DailyForecast {
//   final int dt;
//   final int sunrise;
//   final int sunset;
//   final int moonrise;
//   final int moonset;
//   final double moonPhase;
//   final String summary;
//   final DailyTemp temp;
//   final DailyFeelsLike feelsLike;
//   final int pressure;
//   final int humidity;
//   final double dewPoint;
//   final double windSpeed;
//   final int windDeg;
//   final double windGust;
//   final List<WeatherCondition> weather;
//   final int clouds;
//   final double pop;
//   final double? rain;
//   final double uvi;
//
//   DailyForecast({
//     required this.dt,
//     required this.sunrise,
//     required this.sunset,
//     required this.moonrise,
//     required this.moonset,
//     required this.moonPhase,
//     required this.summary,
//     required this.temp,
//     required this.feelsLike,
//     required this.pressure,
//     required this.humidity,
//     required this.dewPoint,
//     required this.windSpeed,
//     required this.windDeg,
//     required this.windGust,
//     required this.weather,
//     required this.clouds,
//     required this.pop,
//     this.rain,
//     required this.uvi,
//   });
//
//   factory DailyForecast.fromJson(Map<String, dynamic> json) {
//     return DailyForecast(
//       dt: json['dt'],
//       sunrise: json['sunrise'],
//       sunset: json['sunset'],
//       moonrise: json['moonrise'],
//       moonset: json['moonset'],
//       moonPhase: json['moon_phase']?.toDouble() ?? 0.0,
//       summary: json['summary']?.toString() ?? '',
//
//       temp: DailyTemp.fromJson(json['temp']),
//       feelsLike: DailyFeelsLike.fromJson(json['feels_like']),
//       pressure: json['pressure'] ?? 0,
//       humidity: json['humidity'] ?? 0,
//       dewPoint: json['dew_point']?.toDouble() ?? 0.0,
//       windSpeed: json['wind_speed']?.toDouble() ?? 0.0,
//       windDeg: json['wind_deg'] ?? 0,
//       windGust: json['wind_gust']?.toDouble() ?? 0.0,
//       weather: List<WeatherCondition>.from(
//           json['weather'].map((x) => WeatherCondition.fromJson(x))),
//       clouds: json['clouds'] ?? 0,
//       pop: json['pop']?.toDouble() ?? 0.0,
//       rain: json['rain']?.toDouble(),
//       uvi: json['uvi']?.toDouble() ?? 0.0,
//     );
//   }
// }
//
// class DailyTemp {
//   final double day;
//   final double min;
//   final double max;
//   final double night;
//   final double eve;
//   final double morn;
//
//   DailyTemp({
//     required this.day,
//     required this.min,
//     required this.max,
//     required this.night,
//     required this.eve,
//     required this.morn,
//   });
//
//   factory DailyTemp.fromJson(Map<String, dynamic> json) {
//     return DailyTemp(
//       day: json['day']?.toDouble() ?? 0.0,
//       min: json['min']?.toDouble() ?? 0.0,
//       max: json['max']?.toDouble() ?? 0.0,
//       night: json['night']?.toDouble() ?? 0.0,
//       eve: json['eve']?.toDouble() ?? 0.0,
//       morn: json['morn']?.toDouble() ?? 0.0,
//     );
//   }
// }
//
// class DailyFeelsLike {
//   final double day;
//   final double night;
//   final double eve;
//   final double morn;
//
//   DailyFeelsLike({
//     required this.day,
//     required this.night,
//     required this.eve,
//     required this.morn,
//   });
//
//   factory DailyFeelsLike.fromJson(Map<String, dynamic> json) {
//     return DailyFeelsLike(
//       day: json['day']?.toDouble() ?? 0.0,
//       night: json['night']?.toDouble() ?? 0.0,
//       eve: json['eve']?.toDouble() ?? 0.0,
//       morn: json['morn']?.toDouble() ?? 0.0,
//     );
//   }
// }
//
// class WeatherAlert {
//   final String senderName;
//   final String event;
//   final int start;
//   final int end;
//   final String description;
//   final List<String> tags;
//
//   WeatherAlert({
//     required this.senderName,
//     required this.event,
//     required this.start,
//     required this.end,
//     required this.description,
//     required this.tags,
//   });
//
//   factory WeatherAlert.fromJson(Map<String, dynamic> json) {
//     return WeatherAlert(
//       senderName: json['sender_name'],
//       event: json['event'],
//       start: json['start'],
//       end: json['end'],
//       description: json['description'],
//       tags: List<String>.from(json['tags'] ?? []),
//     );
//   }
// }


class WeatherData {
  final Coord coord;
  final List<Weather> weather;
  final String base;
  final Main main;
  final int visibility;
  final Wind wind;
  final Rain? rain;
  final Clouds clouds;
  final int dt;
  final Sys sys;
  final int timezone;
  final int id;
  final String name;
  final int cod;

  WeatherData({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    this.rain,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      coord: Coord.fromJson(json['coord']),
      weather: List<Weather>.from(json['weather'].map((x) => Weather.fromJson(x))),
      base: json['base'],
      main: Main.fromJson(json['main']),
      visibility: json['visibility'],
      wind: Wind.fromJson(json['wind']),
      rain: json['rain'] != null ? Rain.fromJson(json['rain']) : null,
      clouds: Clouds.fromJson(json['clouds']),
      dt: json['dt'],
      sys: Sys.fromJson(json['sys']),
      timezone: json['timezone'],
      id: json['id'],
      name: json['name'],
      cod: json['cod'],
    );
  }
}

class Coord {
  final double lon;
  final double lat;

  Coord({
    required this.lon,
    required this.lat,
  });

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
      lon: json['lon']?.toDouble() ?? 0.0,
      lat: json['lat']?.toDouble() ?? 0.0,
    );
  }
}

class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

class Main {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int? seaLevel;
  final int? grndLevel;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    this.seaLevel,
    this.grndLevel,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp']?.toDouble() ?? 0.0,
      feelsLike: json['feels_like']?.toDouble() ?? 0.0,
      tempMin: json['temp_min']?.toDouble() ?? 0.0,
      tempMax: json['temp_max']?.toDouble() ?? 0.0,
      pressure: json['pressure'] ?? 0,
      humidity: json['humidity'] ?? 0,
      seaLevel: json['sea_level'],
      grndLevel: json['grnd_level'],
    );
  }
}

class Wind {
  final double speed;
  final int deg;
  final double? gust;

  Wind({
    required this.speed,
    required this.deg,
    this.gust,
  });

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: json['speed']?.toDouble() ?? 0.0,
      deg: json['deg'] ?? 0,
      gust: json['gust']?.toDouble(),
    );
  }
}

class Rain {
  final double? oneHour;
  final double? threeHours;

  Rain({
    this.oneHour,
    this.threeHours,
  });

  factory Rain.fromJson(Map<String, dynamic> json) {
    return Rain(
      oneHour: json['1h']?.toDouble(),
      threeHours: json['3h']?.toDouble(),
    );
  }
}

class Clouds {
  final int all;

  Clouds({
    required this.all,
  });

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(
      all: json['all'] ?? 0,
    );
  }
}

class Sys {
  final int type;
  final int id;
  final String country;
  final int sunrise;
  final int sunset;

  Sys({
    required this.type,
    required this.id,
    required this.country,
    required this.sunrise,
    required this.sunset,
  });

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      type: json['type'] ?? 0,
      id: json['id'] ?? 0,
      country: json['country'] ?? '',
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }
}