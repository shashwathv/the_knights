import '../models/post.dart';

class CommunityService {
  // TODO: Replace with actual API calls
  Future<List<Post>> getPosts(String category) async {
    // Simulated delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    return [
      Post(
        id: '1',
        title: 'Best practices for rice cultivation',
        titleKannada: 'ಭತ್ತದ ಕೃಷಿಗೆ ಉತ್ತಮ ಅಭ್ಯಾಸಗಳು',
        content: 'Here are some tips for better rice cultivation...',
        contentKannada: 'ಉತ್ತಮ ಭತ್ತದ ಕೃಷಿಗೆ ಕೆಲವು ಸಲಹೆಗಳು...',
        author: 'Ramesh Kumar',
        date: '2024-03-20',
        category: 'tips',
        likes: 45,
        comments: 12,
        tags: ['rice', 'cultivation', 'tips'],
      ),
      Post(
        id: '2',
        title: 'Query about pest control',
        titleKannada: 'ಕೀಟ ನಿಯಂತ್ರಣದ ಬಗ್ಗೆ ಪ್ರಶ್ನೆ',
        content: 'I am facing issues with pests in my wheat field...',
        contentKannada: 'ನನ್ನ ಗೋಧಿ ಹೊಲದಲ್ಲಿ ಕೀಟಗಳ ಸಮಸ್ಯೆ ಎದುರಾಗುತ್ತಿದೆ...',
        author: 'Suresh Patil',
        date: '2024-03-19',
        category: 'questions',
        likes: 15,
        comments: 8,
        tags: ['pest-control', 'wheat'],
      ),
      Post(
        id: '3',
        title: 'Success with organic farming',
        titleKannada: 'ಸಾವಯವ ಕೃಷಿಯಲ್ಲಿ ಯಶಸ್ಸು',
        content: 'My experience with transitioning to organic farming...',
        contentKannada: 'ಸಾವಯವ ಕೃಷಿಗೆ ಬದಲಾದ ನನ್ನ ಅನುಭವ...',
        author: 'Lakshmi Devi',
        date: '2024-03-18',
        category: 'success_stories',
        likes: 78,
        comments: 23,
        tags: ['organic', 'success-story'],
      ),
    ].where((post) => category == 'all' || post.category == category).toList();
  }
} 