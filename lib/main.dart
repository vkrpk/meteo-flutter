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
  final TextEditingController _cityController = TextEditingController();
  String cityName = 'Paris';
  MeteoData? meteoData;
  bool isLoading = false;
  bool isError = false;

  Future<void> fetchWeather(String cityName) async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final cityCoordinates = await CityService.getCityCoordinates(cityName);
      final latitude = cityCoordinates['latitude'];
      final longitude = cityCoordinates['longitude'];
      final data = await MeteoService.getMeteoData(latitude, longitude);
      setState(() {
        meteoData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter city name:'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  hintText: 'Enter city name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredCity = _cityController.text.trim();
                if (enteredCity.isNotEmpty) {
                  fetchWeather(enteredCity);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a city name'),
                    ),
                  );
                }
              },
              child: const Text('Get Weather'),
            ),
            if (isError)
              const Text(
                'Failed to load weather data. Please try again.',
                style: TextStyle(color: Colors.red),
              ),
            if (meteoData != null)
              Column(
                children: [
                  Text('City: ${meteoData!.cityName}'),
                  Text('Temperature: ${meteoData!.temperature}°C'),
                  Text('Description: ${meteoData!.weatherDescription}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
