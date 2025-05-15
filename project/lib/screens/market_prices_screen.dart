import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import '../services/market_service.dart';
import '../models/market_price.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final MarketService _marketService = MarketService();
  List<MarketPrice> _prices = [];
  bool _isLoading = true;
  String _selectedLocation = 'Bangalore';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    try {
      setState(() => _isLoading = true);
      final prices = await _marketService.getPrices(_selectedLocation);
      setState(() {
        _prices = prices;
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load market prices: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              languageProvider.isEnglish ? 'Market Prices' : 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು',
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: languageProvider.isEnglish ? 'Location' : 'ಸ್ಥಳ',
                    border: const OutlineInputBorder(),
                  ),
                  items: ['Bangalore', 'Mysore', 'Hubli', 'Belgaum']
                      .map((location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLocation = value);
                      _loadPrices();
                    }
                  },
                ),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadPrices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _prices.length,
                          itemBuilder: (context, index) {
                            final price = _prices[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  languageProvider.isEnglish
                                      ? price.cropName
                                      : price.cropNameKannada,
                                ),
                                subtitle: Text(
                                  languageProvider.isEnglish
                                      ? '${price.variety} - ${price.quality}'
                                      : '${price.varietyKannada} - ${price.qualityKannada}',
                                ),
                                trailing: Text(
                                  '₹${price.pricePerQuintal}/q',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
} 