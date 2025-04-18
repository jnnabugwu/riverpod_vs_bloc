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
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;

    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMax: main['temp_max'].toDouble(),
      tempMin: main['temp_min'].toDouble(),
      description: weather['description'] as String,
      iconCode: weather['icon'] as String,
    );
  }
}
