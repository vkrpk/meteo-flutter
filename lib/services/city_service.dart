import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CityService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> getCityCoordinates(String cityName) async {
    final apiKey = dotenv.env['CITY_API_KEY'];
    final url = 'https://api.api-ninjas.com/v1/city?name=$cityName';

    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'X-Api-Key': apiKey,
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data[0];
    } else {
      throw Exception('Failed to load city coordinates');
    }
  }
}
