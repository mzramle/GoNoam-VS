class TextPassageModel {
  String id;
  String userId;
  String content;

  TextPassageModel({
    required this.id,
    required this.userId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
    };
  }

  static TextPassageModel fromJson(Map<String, dynamic> json) {
    return TextPassageModel(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
    );
  }
}
