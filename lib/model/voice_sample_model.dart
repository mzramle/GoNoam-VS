class VoiceSampleModel {
  String id;
  String name;
  String language;
  String textPassage;
  String audioUrl;
  String fileType;
  DateTime creationDate;

  VoiceSampleModel({
    required this.id,
    required this.name,
    required this.language,
    required this.textPassage,
    required this.audioUrl,
    required this.fileType,
    required this.creationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'textPassage': textPassage,
      'audioUrl': audioUrl,
      'fileType': fileType,
      'creationDate': creationDate.toIso8601String(),
    };
  }

  static VoiceSampleModel fromJson(Map<String, dynamic> json) {
    return VoiceSampleModel(
      id: json['id'],
      name: json['name'],
      language: json['language'],
      textPassage: json['textPassage'],
      audioUrl: json['audioUrl'],
      fileType: json['fileType'],
      creationDate: DateTime.parse(json['creationDate']),
    );
  }
}
