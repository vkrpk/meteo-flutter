class MeteoData {
  final String cityName;
  final double temperature;
  final String weatherDescription;

  MeteoData({
    required this.cityName,
    required this.temperature,
    required this.weatherDescription,
  });

  factory MeteoData.fromJson(Map<String, dynamic> json) {
    return MeteoData(
      cityName: json['name'],
      temperature: json['main']['temp'],
      weatherDescription: json['weather'][0]['description'],
    );
  }
}
