class Ayah {
  const Ayah({
    required this.numberInSurah,
    required this.text,
    required this.audioUrl,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      audioUrl: json['audio'] as String,
    );
  }

  final int numberInSurah;
  final String text;
  final String audioUrl;
}
