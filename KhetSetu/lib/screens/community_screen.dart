import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/language_provider.dart';
import '../services/gemini_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _articles = [];
  bool _isLoading = false;
  bool _hasInitialLoad = false;  // Track if initial load has happened
  final List<String> _categories = [
    'Agriculture Policy',
    'Crop Prices',
    'Weather Impact',
    'New Technologies',
    'Farmer Welfare',
  ];

  @override
  void initState() {
    super.initState();
    // Remove automatic loading on init
    _hasInitialLoad = false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article URL not available')),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open article')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Map<String, String> _parseArticle(String articleText) {
    final lines = articleText.trim().split('\n');
    final article = <String, String>{};
    
    String currentKey = '';
    for (final line in lines) {
      if (line.startsWith('Source:')) article['source'] = line.split('Source:')[1].trim();
      else if (line.startsWith('Title:')) article['title'] = line.split('Title:')[1].trim();
      else if (line.startsWith('Date:')) article['date'] = line.split('Date:')[1].trim();
      else if (line.startsWith('Summary:')) article['summary'] = line.split('Summary:')[1].trim();
      else if (line.startsWith('URL:')) article['url'] = line.split('URL:')[1].trim();
      else if (line.startsWith('Topic:')) article['topic'] = line.split('Topic:')[1].trim();
    }
    return article;
  }

  Future<void> _searchArticles(String query, bool isEnglish) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _geminiService.getCommunityContent(
        query,
        isEnglish ? 'English' : 'Kannada',
      );
      
      final articles = response
          .split('---')
          .where((text) => text.trim().isNotEmpty)
          .map(_parseArticle)
          .where((article) => article.isNotEmpty)
          .toList();

      setState(() {
        _articles = articles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildArticleCard(Map<String, String> article, bool isEnglish) {
    final source = article['source'] ?? '';
    final sourceIcon = _getSourceIcon(source.toLowerCase());

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchURL(article['url'] ?? ''),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic and Source Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      article['topic'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sourceIcon, size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Text(
                          source,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                article['title'] ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  article['date'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Summary
              Text(
                article['summary'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    if (source.contains('ndtv')) return Icons.tv;
    if (source.contains('hindu')) return Icons.newspaper;
    if (source.contains('express')) return Icons.article;
    if (source.contains('times')) return Icons.public;
    if (source.contains('herald')) return Icons.menu_book;
    return Icons.article;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LanguageProvider>(context).isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Agricultural News' : 'ಕೃಷಿ ಸುದ್ದಿ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: isEnglish
                          ? 'Search agricultural news...'
                          : 'ಕೃಷಿ ಸುದ್ದಿಗಳನ್ನು ಹುಡುಕಿ...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _searchArticles(value, isEnglish);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(_categories[index]),
                    onPressed: () => _searchArticles(_categories[index], isEnglish),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty && !_hasInitialLoad
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isEnglish
                                  ? 'Search for agricultural news\nor select a category above'
                                  : 'ಕೃಷಿ ಸುದ್ದಿಗಳನ್ನು ಹುಡುಕಿ\nಅಥವಾ ಮೇಲಿನ ವರ್ಗವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _articles.length,
                        itemBuilder: (context, index) {
                          return _buildArticleCard(_articles[index], isEnglish);
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 