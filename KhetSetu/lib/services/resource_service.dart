import '../models/resource.dart';

class ResourceService {
  // TODO: Replace with actual API calls
  Future<List<Resource>> getResources(String category) async {
    // Simulated delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    return [
      Resource(
        id: '1',
        title: 'Modern Farming Techniques',
        titleKannada: 'ಆಧುನಿಕ ಕೃಷಿ ತಂತ್ರಗಳು',
        description: 'Learn about the latest farming techniques and technologies.',
        descriptionKannada: 'ಇತ್ತೀಚಿನ ಕೃಷಿ ತಂತ್ರಗಳು ಮತ್ತು ತಂತ್ರಜ್ಞಾನಗಳ ಬಗ್ಗೆ ತಿಳಿಯಿರಿ.',
        type: 'guide',
        typeKannada: 'ಮಾರ್ಗದರ್ಶಿ',
        url: 'https://example.com/farming-guide',
        tags: ['modern', 'technology', 'guide'],
        date: '2024-03-20',
      ),
      Resource(
        id: '2',
        title: 'Organic Pest Control Methods',
        titleKannada: 'ಸಾವಯವ ಕೀಟ ನಿಯಂತ್ರಣ ವಿಧಾನಗಳು',
        description: 'Video tutorial on natural pest control methods.',
        descriptionKannada: 'ನೈಸರ್ಗಿಕ ಕೀಟ ನಿಯಂತ್ರಣ ವಿಧಾನಗಳ ವೀಡಿಯೊ ಟ್ಯುಟೋರಿಯಲ್.',
        type: 'video',
        typeKannada: 'ವೀಡಿಯೊ',
        url: 'https://example.com/pest-control-video',
        tags: ['organic', 'pest-control', 'video'],
        date: '2024-03-19',
      ),
      Resource(
        id: '3',
        title: 'Government Schemes for Farmers',
        titleKannada: 'ರೈತರಿಗಾಗಿ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
        description: 'Comprehensive guide to available government schemes.',
        descriptionKannada: 'ಲಭ್ಯವಿರುವ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳ ಸಮಗ್ರ ಮಾರ್ಗದರ್ಶಿ.',
        type: 'document',
        typeKannada: 'ದಾಖಲೆ',
        filePath: 'assets/documents/schemes.pdf',
        tags: ['government', 'schemes', 'document'],
        date: '2024-03-18',
      ),
    ].where((resource) => category == 'all' || resource.type == category).toList();
  }
} 