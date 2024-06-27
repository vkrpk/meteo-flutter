import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/meteodata.dart';

class MeteoService {
  static Future<MeteoData> getMeteoData(double lat, double lon) async {
    final apiKey = dotenv.env['METEO_API_KEY'];
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await Dio().get(url);

    if (response.statusCode == 200) {
      return MeteoData.fromJson(response.data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
