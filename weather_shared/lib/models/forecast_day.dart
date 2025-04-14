class ForecastDay {
  final DateTime date;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final double humidity;
  final double windSpeed;
  final double feelsLike;

  ForecastDay({
    required this.date,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;

    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: main['temp'].toDouble(),
      tempMin: main['temp_min'].toDouble(),
      tempMax: main['temp_max'].toDouble(),
      description: weather['description'],
      iconCode: weather['icon'],
      humidity: main['humidity'].toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      feelsLike: main['feels_like'].toDouble(),
    );
  }
}
