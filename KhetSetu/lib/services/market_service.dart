import '../models/market_price.dart';

class MarketService {
  // TODO: Replace with actual API calls
  Future<List<MarketPrice>> getPrices(String location) async {
    // Simulated delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    return [
      MarketPrice(
        cropName: 'Rice',
        cropNameKannada: 'ಅಕ್ಕಿ',
        variety: 'Sona Masuri',
        varietyKannada: 'ಸೋನಾ ಮಸೂರಿ',
        quality: 'Grade A',
        qualityKannada: 'ಗ್ರೇಡ್ ಎ',
        pricePerQuintal: 3200,
        market: location,
        date: '2024-03-20',
      ),
      MarketPrice(
        cropName: 'Wheat',
        cropNameKannada: 'ಗೋಧಿ',
        variety: 'Durum',
        varietyKannada: 'ಡುರಮ್',
        quality: 'Premium',
        qualityKannada: 'ಪ್ರೀಮಿಯಂ',
        pricePerQuintal: 2800,
        market: location,
        date: '2024-03-20',
      ),
      MarketPrice(
        cropName: 'Ragi',
        cropNameKannada: 'ರಾಗಿ',
        variety: 'Local',
        varietyKannada: 'ಸ್ಥಳೀಯ',
        quality: 'Standard',
        qualityKannada: 'ಸ್ಟ್ಯಾಂಡರ್ಡ್',
        pricePerQuintal: 2400,
        market: location,
        date: '2024-03-20',
      ),
    ];
  }
} 