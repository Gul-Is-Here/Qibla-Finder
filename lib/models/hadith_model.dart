/// Model class representing a Hadith
class HadithModel {
  final int id;
  final String arabicText;
  final String englishText;
  final String narrator;
  final String source;
  final String grade; // Sahih, Hasan, etc.
  final String chapter;

  HadithModel({
    required this.id,
    required this.arabicText,
    required this.englishText,
    required this.narrator,
    required this.source,
    this.grade = 'Sahih',
    this.chapter = '',
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] ?? 0,
      arabicText: json['arabic'] ?? '',
      englishText: json['english'] ?? '',
      narrator: json['narrator'] ?? 'Unknown',
      source: json['source'] ?? 'Unknown',
      grade: json['grade'] ?? 'Sahih',
      chapter: json['chapter'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabicText,
      'english': englishText,
      'narrator': narrator,
      'source': source,
      'grade': grade,
      'chapter': chapter,
    };
  }
}
