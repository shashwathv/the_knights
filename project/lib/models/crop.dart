class Crop {
  final String name;
  final Map<String, String> localizedNames;
  final double loanAmount;
  final String fertilizer;
  final String seeds;
  final String water;
  final Map<String, String> cultivationGuide;

  Crop({
    required this.name,
    required this.localizedNames,
    required this.loanAmount,
    required this.fertilizer,
    required this.seeds,
    required this.water,
    required this.cultivationGuide,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      name: json['name'] as String,
      localizedNames: Map<String, String>.from(json['localizedNames']),
      loanAmount: (json['loan'] as num).toDouble(),
      fertilizer: json['fertilizer'] as String,
      seeds: json['seeds'] as String,
      water: json['water'] as String,
      cultivationGuide: Map<String, String>.from(json['cultivationGuide']),
    );
  }

  String getLocalizedName(String languageCode) {
    return localizedNames[languageCode] ?? name;
  }

  String getCultivationGuide(String languageCode) {
    return cultivationGuide[languageCode] ?? cultivationGuide['en'] ?? '';
  }
} 