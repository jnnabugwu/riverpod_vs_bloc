class ForecastDay {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String description;
  final String iconCode;

  ForecastDay({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.description,
    required this.iconCode,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMax: (json['temp']['max'] as num).toDouble(),
      tempMin: (json['temp']['min'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}
