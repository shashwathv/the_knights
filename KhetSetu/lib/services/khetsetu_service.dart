import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/crop.dart';
import '../models/expense.dart';

class KhetSetuService {
  Map<String, dynamic> _data = {};
  List<Crop> _crops = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/crops.json');
      _data = json.decode(jsonString);
      _crops = (_data['crops'] as List)
          .map((cropJson) => Crop.fromJson(cropJson))
          .toList();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize KhetSetu service: $e');
    }
  }

  String _formatCropInfo(Crop crop, String languageCode) {
    if (languageCode == 'en') {
      return '''
**${crop.getLocalizedName(languageCode)} Information**

**Cultivation Details**
• Loan Amount: Rs. ${crop.loanAmount}
• Fertilizer Requirements: ${crop.fertilizer}
• Seed Requirements: ${crop.seeds}
• Water Requirements: ${crop.water}

**Cultivation Guide**
${crop.getCultivationGuide(languageCode)}
''';
    } else {
      return '''
**${crop.getLocalizedName(languageCode)} ಮಾಹಿತಿ**

**ಕೃಷಿ ವಿವರಗಳು**
• ಸಾಲದ ಮೊತ್ತ: ರೂ. ${crop.loanAmount}
• ರಸಗೊಬ್ಬರ ಅವಶ್ಯಕತೆಗಳು: ${crop.fertilizer}
• ಬೀಜದ ಅವಶ್ಯಕತೆಗಳು: ${crop.seeds}
• ನೀರಿನ ಅವಶ್ಯಕತೆಗಳು: ${crop.water}

**ಕೃಷಿ ಮಾರ್ಗದರ್ಶಿ**
${crop.getCultivationGuide(languageCode)}
''';
    }
  }

  String _formatSubsidyInfo(List<dynamic> subsidies, String languageCode) {
    final title = languageCode == 'en' ? '**Available Subsidies**\n\n' : '**ಲಭ್ಯವಿರುವ ಸಬ್ಸಿಡಿಗಳು**\n\n';
    final items = subsidies.map((subsidy) {
      return '• ${subsidy['title'][languageCode]}\n  ${subsidy['description'][languageCode]}\n';
    }).join('\n');
    return title + items;
  }

  String _formatLenderInfo(List<dynamic> lenders, String languageCode) {
    final title = languageCode == 'en' ? '**Available Lenders**\n\n' : '**ಲಭ್ಯವಿರುವ ಸಾಲದಾತರು**\n\n';
    final items = lenders.map((lender) {
      if (languageCode == 'en') {
        return '''• ${lender['name']}
  ${lender['description'][languageCode]}
  Interest Rate: ${lender['interestRate']}
  Contact: ${lender['contact']}\n''';
      } else {
        return '''• ${lender['name']}
  ${lender['description'][languageCode]}
  ಬಡ್ಡಿ ದರ: ${lender['interestRate']}
  ಸಂಪರ್ಕ: ${lender['contact']}\n''';
      }
    }).join('\n');
    return title + items;
  }

  Future<String> processQuery(String query, String languageCode) async {
    if (!_isInitialized) await initialize();
    
    query = query.toLowerCase();
    
    // Check for crop information
    for (final crop in _crops) {
      final cropName = crop.getLocalizedName(languageCode).toLowerCase();
      if (query.contains(cropName)) {
        return _formatCropInfo(crop, languageCode);
      }
    }

    // Check for subsidy information
    if (query.contains(languageCode == 'en' ? 'subsidy' : 'ಸಬ್ಸಿಡಿ')) {
      return _formatSubsidyInfo(_data['subsidies'] as List, languageCode);
    }

    // Check for lender information
    if (query.contains(languageCode == 'en' ? 'loan' : 'ಸಾಲ') || 
        query.contains(languageCode == 'en' ? 'lender' : 'ಸಾಲದಾತ')) {
      return _formatLenderInfo(_data['lenders'] as List, languageCode);
    }

    return languageCode == 'en'
        ? '''**How can I help you?**

I can provide information about:
• Specific crops and their cultivation
• Available government subsidies
• Agricultural loans and lenders
• Best farming practices

Please ask about any of these topics!'''
        : '''**ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?**

ನಾನು ಈ ಕೆಳಗಿನ ವಿಷಯಗಳ ಬಗ್ಗೆ ಮಾಹಿತಿ ನೀಡಬಲ್ಲೆ:
• ನಿರ್ದಿಷ್ಟ ಬೆಳೆಗಳು ಮತ್ತು ಅವುಗಳ ಕೃಷಿ
• ಲಭ್ಯವಿರುವ ಸರ್ಕಾರಿ ಸಬ್ಸಿಡಿಗಳು
• ಕೃಷಿ ಸಾಲಗಳು ಮತ್ತು ಸಾಲದಾತರು
• ಉತ್ತಮ ಕೃಷಿ ಪದ್ಧತಿಗಳು

ದಯವಿಟ್ಟು ಈ ವಿಷಯಗಳ ಬಗ್ಗೆ ಕೇಳಿ!''';
  }

  List<String> getAvailableCrops(String languageCode) {
    return _crops.map((crop) => crop.getLocalizedName(languageCode)).toList();
  }

  List<Map<String, String>> getExpenseTypes() {
    return (_data['expenseTypes'] as List)
        .cast<Map<String, dynamic>>()
        .map((type) => {
              'en': type['en'] as String,
              'kn': type['kn'] as String,
            })
        .toList();
  }
} 