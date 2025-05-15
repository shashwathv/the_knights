import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather.dart';

class WeatherService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> locationParts = [];
        
        // Add each location component with null check and fallback
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          locationParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          locationParts.add(place.locality!);
        }
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          locationParts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          locationParts.add(place.administrativeArea!);
        }
        
        // If no location parts were added, return coordinates
        if (locationParts.isEmpty) {
          return 'Lat: ${lat.toStringAsFixed(2)}, Lon: ${lon.toStringAsFixed(2)}';
        }
        
        return locationParts.join(', ');
      }
      return 'Lat: ${lat.toStringAsFixed(2)}, Lon: ${lon.toStringAsFixed(2)}';
    } catch (e) {
      // Return coordinates as fallback
      return 'Lat: ${lat.toStringAsFixed(2)}, Lon: ${lon.toStringAsFixed(2)}';
    }
  }

  Future<Weather> getCurrentWeather(double lat, double lon) async {
    // Simulated delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    return Weather(
      temperature: 28.5,
      feelsLike: 30.0,
      humidity: 65,
      windSpeed: 12.5,
      description: 'Partly cloudy',
      descriptionKannada: 'ಭಾಗಶಃ ಮೋಡ',
      condition: 'clouds',
      date: '2024-03-20',
    );
  }

  Future<List<Weather>> getForecast(double lat, double lon) async {
    // Simulated delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample 5-day forecast
    return List.generate(
      5,
      (index) => Weather(
        temperature: 28.0 + index,
        feelsLike: 29.5 + index,
        humidity: 65 - index,
        windSpeed: 12.0 + index,
        description: index % 2 == 0 ? 'Sunny' : 'Partly cloudy',
        descriptionKannada: index % 2 == 0 ? 'ಬಿಸಿಲು' : 'ಭಾಗಶಃ ಮೋಡ',
        condition: index % 2 == 0 ? 'clear' : 'clouds',
        date: DateTime.now().add(Duration(days: index + 1)).toString().split(' ')[0],
      ),
    );
  }
} 