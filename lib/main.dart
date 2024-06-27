import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meteo/services/city_service.dart';
import 'package:meteo/services/meteo_service.dart';
import 'models/meteodata.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String cityName = 'Paris';
  MeteoData? meteoData;

  Future<void> fetchWeather() async {
    try {
      final cityCoordinates = await CityService.getCityCoordinates(cityName);
      final latitude = cityCoordinates['latitude'];
      final longitude = cityCoordinates['longitude'];
      final data = await MeteoService.getMeteoData(latitude, longitude);
      setState(() {
        meteoData = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: meteoData == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('City: ${meteoData!.cityName}'),
            Text('Temperature: ${meteoData!.temperature}°C'),
            Text('Description: ${meteoData!.weatherDescription}'),
          ],
        ),
      ),
    );
  }
}
