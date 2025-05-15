class MarketPrice {
  final String cropName;
  final String cropNameKannada;
  final String variety;
  final String varietyKannada;
  final String quality;
  final String qualityKannada;
  final double pricePerQuintal;
  final String market;
  final String date;

  MarketPrice({
    required this.cropName,
    required this.cropNameKannada,
    required this.variety,
    required this.varietyKannada,
    required this.quality,
    required this.qualityKannada,
    required this.pricePerQuintal,
    required this.market,
    required this.date,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      cropName: json['cropName'] as String,
      cropNameKannada: json['cropNameKannada'] as String,
      variety: json['variety'] as String,
      varietyKannada: json['varietyKannada'] as String,
      quality: json['quality'] as String,
      qualityKannada: json['qualityKannada'] as String,
      pricePerQuintal: (json['pricePerQuintal'] as num).toDouble(),
      market: json['market'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'cropNameKannada': cropNameKannada,
      'variety': variety,
      'varietyKannada': varietyKannada,
      'quality': quality,
      'qualityKannada': qualityKannada,
      'pricePerQuintal': pricePerQuintal,
      'market': market,
      'date': date,
    };
  }
} 