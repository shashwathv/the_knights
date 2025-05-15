import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _currentWeather;
  List<Weather>? _forecast;
  bool _isLoading = true;
  String? _error;
  String _locationName = '';

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // Get current location
      final position = await _weatherService.getCurrentLocation();
      
      // Get location name
      final locationName = await _weatherService.getLocationName(
        position.latitude,
        position.longitude,
      );
      
      // Get weather data
      final currentWeather = await _weatherService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      final forecast = await _weatherService.getForecast(
        position.latitude,
        position.longitude,
      );
      
      if (!mounted) return;
      
      setState(() {
        _locationName = locationName;
        _currentWeather = currentWeather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _locationName = 'Location unavailable';
        _currentWeather = null;
        _forecast = null;
      });
    }
  }

  Widget _buildCurrentWeather(bool isEnglish) {
    if (_currentWeather == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish ? 'Your Location' : 'ನಿಮ್ಮ ಸ್ಥಳ',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _locationName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadWeatherData,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Weather Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_currentWeather!.temperature}°',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'C',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnglish
                          ? _currentWeather!.description
                          : _currentWeather!.descriptionKannada,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Icon(
                  _currentWeather!.getWeatherIcon(),
                  size: 72,
                  color: Colors.blue,
                ),
              ],
            ),
            const Divider(height: 32),
            // Weather Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  icon: Icons.thermostat,
                  label: isEnglish ? 'Feels Like' : 'ಅನುಭವಿಸುವ',
                  value: '${_currentWeather!.feelsLike}°C',
                ),
                _buildWeatherDetail(
                  icon: Icons.water_drop,
                  label: isEnglish ? 'Humidity' : 'ತೇವಾಂಶ',
                  value: '${_currentWeather!.humidity}%',
                ),
                _buildWeatherDetail(
                  icon: Icons.air,
                  label: isEnglish ? 'Wind' : 'ಗಾಳಿ',
                  value: '${_currentWeather!.windSpeed} km/h',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildForecast(bool isEnglish) {
    if (_forecast == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? '5-Day Forecast' : '5 ದಿನಗಳ ಮುನ್ಸೂಚನೆ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _forecast!.length,
                itemBuilder: (context, index) {
                  final weather = _forecast![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(weather.date),
                        const SizedBox(height: 8),
                        Icon(weather.getWeatherIcon()),
                        Text('${weather.temperature}°C'),
                        Text(
                          isEnglish
                              ? weather.description
                              : weather.descriptionKannada,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Weather' : 'ಹವಾಮಾನ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    isEnglish ? 'Error: $_error' : 'ದೋಷ: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWeatherData,
                  child: ListView(
                    children: [
                      _buildCurrentWeather(isEnglish),
                      _buildForecast(isEnglish),
                    ],
                  ),
                ),
    );
  }
} 