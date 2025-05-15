import 'dart:convert';
import 'package:flutter/services.dart';

class CropService {
  Map<String, dynamic> _crops = {};
  bool _isInitialized = false;

  Future<void> loadCrops() async {
    if (_isInitialized) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/crops.json');
      _crops = json.decode(jsonString);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to load crop data: $e');
    }
  }

  Future<String> processQuery(String query) async {
    if (!_isInitialized) await loadCrops();
    
    query = query.toLowerCase();
    
    for (String crop in _crops.keys) {
      if (query.contains(crop)) {
        if (query.contains('loan')) {
          return 'The loan amount for $crop is Rs. ${_crops[crop]['loan']}.';
        } else if (query.contains('fertilizer')) {
          return 'The recommended fertilizer amount for $crop is ${_crops[crop]['fertilizer']}.';
        } else if (query.contains('seed') || query.contains('seeds')) {
          return 'The required seeds for $crop is ${_crops[crop]['seeds']}.';
        } else if (query.contains('water')) {
          return 'The water requirement for $crop is ${_crops[crop]['water']}.';
        } else {
          return 'For $crop:\nLoan: Rs. ${_crops[crop]['loan']}\nFertilizer: ${_crops[crop]['fertilizer']}\nSeeds: ${_crops[crop]['seeds']}\nWater: ${_crops[crop]['water']}';
        }
      }
    }
    
    return "I couldn't find information about that crop. Please try asking about paddy, wheat, maize, cotton, sugarcane, millet, barley, soybean, groundnut, or mustard.";
  }

  List<String> getAvailableCrops() {
    return _crops.keys.toList().cast<String>();
  }
} 