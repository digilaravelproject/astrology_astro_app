class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class FAQModel {
  final int id;
  final String type;
  final String title;
  final String content;
  final List<FAQItem> items;

  FAQModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.items,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    // The response has "page" object within "data"
    final page = json['page'] ?? json;
    final content = page['content']?.toString() ?? '';
    return FAQModel(
      id: page['id'] is int ? page['id'] : int.tryParse(page['id'].toString()) ?? 0,
      type: page['type']?.toString() ?? '',
      title: page['title']?.toString() ?? '',
      content: content,
      items: _parseContent(content),
    );
  }

  static List<FAQItem> _parseContent(String html) {
    final List<FAQItem> items = [];
    // Regular expressions to find <h3> and <p> tags
    final RegExp exp = RegExp(r"<h3>(.*?)</h3>.*?<p>(.*?)</p>", dotAll: true);
    final Iterable<RegExpMatch> matches = exp.allMatches(html);

    for (final RegExpMatch match in matches) {
      if (match.groupCount >= 2) {
        String question = match.group(1)?.trim() ?? "";
        String answer = match.group(2)?.trim() ?? "";
        
        // Clean up any remaining HTML tags if needed
        question = question.replaceAll(RegExp(r'<[^>]*>'), '');
        answer = answer.replaceAll(RegExp(r'<[^>]*>'), '');
        
        if (question.isNotEmpty && answer.isNotEmpty) {
          items.add(FAQItem(question: question, answer: answer));
        }
      }
    }
    return items;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
    };
  }
}
