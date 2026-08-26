class ChatMessage {
  final int id;
  final String text;
  final bool isMe;
  final DateTime time;
  final String status;
  final String? image;
  final String type;
  final String? attachmentUrl;
  final int? replyToId;
  final ChatMessage? replyTo;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.status,
    this.image,
    required this.type,
    this.attachmentUrl,
    this.replyToId,
    this.replyTo,
  });

  ChatMessage copyWith({
    int? id,
    String? text,
    bool? isMe,
    DateTime? time,
    String? status,
    String? image,
    String? type,
    String? attachmentUrl,
    int? replyToId,
    ChatMessage? replyTo,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      status: status ?? this.status,
      image: image ?? this.image,
      type: type ?? this.type,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      replyToId: replyToId ?? this.replyToId,
      replyTo: replyTo ?? this.replyTo,
    );
  }
}
