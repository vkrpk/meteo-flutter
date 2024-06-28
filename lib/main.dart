import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meteo/services/city_service.dart';
import 'package:meteo/services/meteo_service.dart';
import 'models/meteodata.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
  FlutterNativeSplash.remove();
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
  double _latitude = 51.509364;
  double _longitude = -0.128928;
  List<String> selectedCities = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedCities();
  }

  Future<void> _loadSelectedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCities = prefs.getStringList('selectedCities') ?? [];
    });
  }

  Future<void> _saveSelectedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCities', selectedCities);
  }

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
        _latitude = double.parse(latitude.toString());
        _longitude = double.parse(longitude.toString());
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
              onPressed: () async {
                final enteredCity = _cityController.text.trim();
                if (enteredCity.isNotEmpty) {
                  await fetchWeather(enteredCity);
                  setState(() {
                    selectedCities.add(enteredCity);
                    _saveSelectedCities();
                  });
                  _cityController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a city name'),
                    ),
                  );
                }
              },
              child: const Text('Add City'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: selectedCities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(selectedCities[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          selectedCities.removeAt(index);
                          _saveSelectedCities();
                        });
                      },
                    ),
                  );
                },
              ),
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
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_latitude, _longitude),
                  initialZoom: 9.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


