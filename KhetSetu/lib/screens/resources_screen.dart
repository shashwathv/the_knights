import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import '../services/resource_service.dart';
import '../models/resource.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final ResourceService _resourceService = ResourceService();
  List<Resource> _resources = [];
  bool _isLoading = true;
  String _error = '';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      setState(() => _isLoading = true);
      final resources = await _resourceService.getResources(_selectedCategory);
      setState(() {
        _resources = resources;
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load resources: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildResourceCard(Resource resource, bool isEnglish) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading: Icon(
          resource.getTypeIcon(),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          isEnglish ? resource.title : resource.titleKannada,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          isEnglish ? resource.type : resource.typeKannada,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish ? resource.description : resource.descriptionKannada,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (resource.url != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open URL
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: Text(isEnglish ? 'Open Resource' : 'ಸಂಪನ್ಮೂಲ ತೆರೆಯಿರಿ'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isEnglish = languageProvider.isEnglish;
        return Scaffold(
          appBar: AppBar(
            title: Text(isEnglish ? 'Resources' : 'ಸಂಪನ್ಮೂಲಗಳು'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: isEnglish ? 'Category' : 'ವರ್ಗ',
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(isEnglish ? 'All' : 'ಎಲ್ಲಾ'),
                          ),
                          DropdownMenuItem(
                            value: 'guides',
                            child: Text(isEnglish ? 'Guides' : 'ಮಾರ್ಗದರ್ಶಿಗಳು'),
                          ),
                          DropdownMenuItem(
                            value: 'videos',
                            child: Text(isEnglish ? 'Videos' : 'ವೀಡಿಯೊಗಳು'),
                          ),
                          DropdownMenuItem(
                            value: 'documents',
                            child: Text(isEnglish ? 'Documents' : 'ದಾಖಲೆಗಳು'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                            _loadResources();
                          }
                        },
                      ),
                    ),
                  ],
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
                        onRefresh: _loadResources,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _resources.length,
                          itemBuilder: (context, index) {
                            return _buildResourceCard(
                              _resources[index],
                              isEnglish,
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