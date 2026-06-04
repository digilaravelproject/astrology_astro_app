class DefaultMessageModel {
  int? id;
  int? astrologerId;
  String? title;
  String? content;
  bool? isDefault;
  String? createdAt;
  String? updatedAt;

  DefaultMessageModel({
    this.id,
    this.astrologerId,
    this.title,
    this.content,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory DefaultMessageModel.fromJson(Map<String, dynamic> json) {
    return DefaultMessageModel(
      id: json['id'],
      astrologerId: json['astrologer_id'],
      title: json['title'],
      content: json['content'],
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'astrologer_id': astrologerId,
      'title': title,
      'content': content,
      'is_default': isDefault,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
