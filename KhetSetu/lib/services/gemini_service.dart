import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

class GeminiService {
  static const String apiKey = 'AIzaSyBrcDqOD3LMNhR6mYMHLehu5hBiwrQzdzo'; // Replace with your API key
  late final GenerativeModel _model;
  
  // Rate limiting variables
  static const _maxRequestsPerMinute = 10;
  static const _cooldownPeriod = Duration(minutes: 1);
  static int _requestCount = 0;
  static DateTime? _lastResetTime;
  
  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  Future<void> _checkRateLimit() async {
    final now = DateTime.now();
    if (_lastResetTime == null) {
      _lastResetTime = now;
      _requestCount = 0;
    } else if (now.difference(_lastResetTime!) >= _cooldownPeriod) {
      _lastResetTime = now;
      _requestCount = 0;
    }

    if (_requestCount >= _maxRequestsPerMinute) {
      final waitTime = _cooldownPeriod - now.difference(_lastResetTime!);
      throw Exception('Rate limit exceeded. Please try again in ${waitTime.inSeconds} seconds.');
    }

    _requestCount++;
  }

  Future<String> processQuery(String query, String languageCode) async {
    try {
      await _checkRateLimit();
      
      final prompt = '''
You are KhetSetu, an agricultural assistant. Answer in ${languageCode == 'en' ? 'English' : 'Kannada'}.

For crop-related queries, provide information in the following format:

**Basic Information**
• Crop Name
• Growing Season
• Duration

**Soil Requirements**
• Soil Type
• pH Level
• Drainage Requirements

**Cultivation Guide**
1. Land Preparation
2. Sowing Method
3. Irrigation Schedule
4. Fertilizer Application
5. Weed Management

**Disease Management**
• Common Diseases
• Prevention Methods
• Treatment Options

**Harvesting**
• Optimal Time
• Method
• Expected Yield

Format all sections with proper headings using "**Section Title**" and use "•" for bullet points.
Make headings prominent and maintain clear spacing between sections.

Query: $query
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        return 'I apologize, but I could not generate a response at this time.';
      }

      // Process and format the response
      String formattedResponse = response.text!;
      
      // Ensure proper formatting for sections
      formattedResponse = formattedResponse.replaceAll(RegExp(r'#+ (.+)'), r'**\1**');
      
      // Ensure proper bullet points
      formattedResponse = formattedResponse.replaceAll(RegExp(r'^\* ', multiLine: true), '• ');
      formattedResponse = formattedResponse.replaceAll(RegExp(r'^- ', multiLine: true), '• ');
      
      return formattedResponse;
    } catch (e) {
      return 'I encountered an error while processing your query. Please try again.';
    }
  }

  Future<String> getCommunityContent(String topic, String language) async {
    try {
      await _checkRateLimit();
      
      final prompt = '''
      Act as an agricultural news curator. Find and recommend 5 relevant news articles about farming and agriculture related to: $topic
      Provide the response in $language.

      CRITICAL REQUIREMENTS:
      1. Only include REAL, EXISTING news articles from reputable Indian sources
      2. Articles MUST be from:
         - NDTV Agriculture
         - The Hindu Agriculture
         - Indian Express Agriculture
         - Economic Times Agriculture
         - Times of India Agriculture
         - Krishi Jagran
         - Agriculture Today
      3. Articles must be:
         - Recent (within last 3 months maximum)
         - Focused on Indian agriculture
         - Related to farmers, crops, or agricultural policies
         - From verifiable sources
      4. Each article must have a complete, working URL
      5. DO NOT make up or guess any information
      6. If specific topic has no recent news, use latest general agricultural news

      For each article provide:
      Source: [Exact news source name]
      Title: [Complete article headline as published]
      Date: [Publication date in DD Month YYYY format]
      Summary: [3-4 sentences summarizing key points]
      URL: [Complete article URL]
      Topic: [Specific agricultural topic/category]
      ---

      If the request is in Kannada:
      - Translate titles and summaries to Kannada
      - Keep source names and URLs in English
      - Use Kannada agricultural terms correctly
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response received';
    } catch (e) {
      if (e.toString().contains('quota')) {
        throw Exception('API quota exceeded. Please try again later or contact support.');
      }
      throw Exception('Failed to generate news content: $e');
    }
  }

  Future<List<Map<String, String>>> getRecommendedVideos(String topic, String language) async {
    try {
      await _checkRateLimit();
      
      final prompt = '''
      Act as an agricultural video curator. Search for and recommend 3 REAL, EXISTING YouTube videos about farming and agriculture in $language.
      The videos should be educational and related to: $topic

      CRITICAL REQUIREMENTS:
      1. ONLY include videos that you are 100% certain exist RIGHT NOW on YouTube
      2. Use COMPLETE, EXACT YouTube URLs (https://www.youtube.com/watch?v=... format)
      3. Videos MUST be about farming/agriculture
      4. Prefer videos from:
         - Official agricultural channels
         - Government agricultural departments
         - Agricultural universities
         - Well-known farming experts
      5. For $language content:
         - If available, use videos in $language
         - If not available, suggest English videos with $language subtitles
         - If neither available, use English videos
      6. Videos should be recent (preferably within last 2 years)
      7. DO NOT make up or guess any information - only include REAL videos

      For each video provide:
      1. The EXACT, CURRENT video title as shown on YouTube
      2. A brief description of the actual content
      3. The ACTUAL video duration (e.g. "10:15")
      4. One key learning point from the video
      5. The COMPLETE YouTube URL (must be in https://www.youtube.com/watch?v=... format)

      Topic: $topic
      Format as:
      Title: [exact video title]
      Description: [brief description]
      Duration: [actual duration]
      Learning: [key point]
      URL: [complete YouTube URL]
      ---
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final videoText = response.text ?? '';
      
      final videoSections = videoText.split('---').where((s) => s.trim().isNotEmpty).toList();
      final videos = videoSections.map((section) {
        final lines = section.trim().split('\n');
        final url = _extractValue(lines.firstWhere((l) => l.startsWith('URL:'), orElse: () => ''));
        
        // Only include videos with valid YouTube URLs
        if (!_isValidYouTubeUrl(url)) {
          return null;
        }

        return {
          'title': _extractValue(lines.firstWhere((l) => l.startsWith('Title:'), orElse: () => '')),
          'description': _extractValue(lines.firstWhere((l) => l.startsWith('Description:'), orElse: () => '')),
          'duration': _extractValue(lines.firstWhere((l) => l.startsWith('Duration:'), orElse: () => '')),
          'learning': _extractValue(lines.firstWhere((l) => l.startsWith('Learning:'), orElse: () => '')),
          'url': url,
        };
      }).whereType<Map<String, String>>().toList();

      if (videos.isEmpty) {
        throw Exception('No valid YouTube videos found for the topic');
      }

      return videos;
    } catch (e) {
      if (e.toString().contains('quota')) {
        throw Exception('API quota exceeded. Please try again later or contact support.');
      }
      throw Exception('Failed to get video recommendations: $e');
    }
  }

  bool _isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      
      // Check for valid YouTube domains
      if (!['youtube.com', 'www.youtube.com'].contains(uri.host)) {
        return false;
      }
      
      // Ensure it's a proper watch URL
      if (!url.contains('watch?v=')) {
        return false;
      }
      
      // Validate video ID format (should be 11 characters)
      final videoId = uri.queryParameters['v'];
      if (videoId == null || videoId.length != 11) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  String _extractValue(String line) {
    return line.split(':').skip(1).join(':').trim();
  }

  Future<List<Map<String, String>>> getResourceRecommendations(String topic, String language) async {
    try {
      final prompt = '''
      Act as an agricultural resource curator. Suggest 5 educational resources in $language.
      If the topic is in Kannada, translate it to English first, then process it.
      For each resource, provide:
      1. Title
      2. Type (Article/Guide/Tool)
      3. Brief description
      4. Key benefits
      
      Topic: $topic
      Format the response as:
      Title: [title]
      Type: [type]
      Description: [description]
      Benefits: [benefits]
      ---
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final resourceText = response.text ?? '';
      
      final resourceSections = resourceText.split('---').where((s) => s.trim().isNotEmpty).toList();
      return resourceSections.map((section) {
        final lines = section.trim().split('\n');
        return {
          'title': _extractValue(lines.firstWhere((l) => l.startsWith('Title:'), orElse: () => '')),
          'type': _extractValue(lines.firstWhere((l) => l.startsWith('Type:'), orElse: () => '')),
          'description': _extractValue(lines.firstWhere((l) => l.startsWith('Description:'), orElse: () => '')),
          'benefits': _extractValue(lines.firstWhere((l) => l.startsWith('Benefits:'), orElse: () => '')),
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get resource recommendations: $e');
    }
  }
} 