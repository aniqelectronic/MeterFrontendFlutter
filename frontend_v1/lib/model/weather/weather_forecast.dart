class WeatherForecast {
  final String locationId;
  final String locationName;
  final DateTime date;
  final String morningForecast;
  final String afternoonForecast;
  final String nightForecast;
  final String summaryForecast;
  final String summaryWhen;
  final int minTemp;
  final int maxTemp;

  const WeatherForecast({
    required this.locationId,
    required this.locationName,
    required this.date,
    required this.morningForecast,
    required this.afternoonForecast,
    required this.nightForecast,
    required this.summaryForecast,
    required this.summaryWhen,
    required this.minTemp,
    required this.maxTemp,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : <String, dynamic>{};

    return WeatherForecast(
      locationId: (location['location_id'] ?? '').toString(),
      locationName: (location['location_name'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      morningForecast: (json['morning_forecast'] ?? '-').toString(),
      afternoonForecast: (json['afternoon_forecast'] ?? '-').toString(),
      nightForecast: (json['night_forecast'] ?? '-').toString(),
      summaryForecast: (json['summary_forecast'] ?? '-').toString(),
      summaryWhen: (json['summary_when'] ?? '-').toString(),
      minTemp: _toInt(json['min_temp']),
      maxTemp: _toInt(json['max_temp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': {
        'location_id': locationId,
        'location_name': locationName,
      },
      'date': date.toIso8601String().split('T').first,
      'morning_forecast': morningForecast,
      'afternoon_forecast': afternoonForecast,
      'night_forecast': nightForecast,
      'summary_forecast': summaryForecast,
      'summary_when': summaryWhen,
      'min_temp': minTemp,
      'max_temp': maxTemp,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}