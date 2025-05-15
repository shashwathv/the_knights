import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import 'home_screen.dart';
import 'market_prices_screen.dart';
import 'weather_screen.dart';
import 'community_screen.dart';
import 'resources_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('KhetSetu'),
            actions: [
              TextButton(
                onPressed: () {
                  languageProvider.setLanguage(
                    languageProvider.isEnglish ? 'kn' : 'en',
                  );
                },
                child: Text(
                  languageProvider.isEnglish ? 'ಕನ್ನಡ' : 'English',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildFeatureCard(
                context,
                icon: Icons.mic,
                title: languageProvider.isEnglish ? 'Voice Assistant' : 'ಧ್ವನಿ ಸಹಾಯಕ',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.monetization_on,
                title: languageProvider.isEnglish ? 'Market Prices' : 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketPricesScreen()),
                ),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.cloud,
                title: languageProvider.isEnglish ? 'Weather' : 'ಹವಾಮಾನ',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeatherScreen()),
                ),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.people,
                title: languageProvider.isEnglish ? 'Community' : 'ಸಮುದಾಯ',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommunityScreen()),
                ),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.book,
                title: languageProvider.isEnglish ? 'Resources' : 'ಸಂಪನ್ಮೂಲಗಳು',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResourcesScreen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 