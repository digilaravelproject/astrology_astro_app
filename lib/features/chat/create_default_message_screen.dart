import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';

class CreateDefaultMessageScreen extends StatefulWidget {
  const CreateDefaultMessageScreen({super.key});

  @override
  State<CreateDefaultMessageScreen> createState() => _CreateDefaultMessageScreenState();
}

class _CreateDefaultMessageScreenState extends State<CreateDefaultMessageScreen> {
  final List<Map<String, String>> _defaultMessages = [
    {
      "title": "aap in gernal birth time",
      "body": "aap in gernal birth time 12 PM dalenge to aapki kundali kya hai pata nahi chalegi.. aapko right prediction ke liye apna right birth time dena hoga... ye jyotish ka niyam.. aapke right guidance ke liye"
    },
    {
      "title": "हर शनिवार शाम",
      "body": "हर शनिवार शाम पीपल के पेड़ पर सरसों का तेल + काले तिल मिलाकर चढ़ाएँ और 7 बार परिक्रमा करें। एक बार का सबसे खास उपाय (जरूर करें) किसी शनिवार को लोहे की कटोरी में सरसों का तेल भरकर उसमें अपना चेहरा देखें और पूरी कटोरी किसी गरीब, मजदूर या पहलवान अखाड़े में दान कर दें। (ये उपाय एक बार करने से भी लग्न का शनि बहुत शांत हो जाता है।) मांस, मदिरा, अंडा पूरी तरह छोड़ दें (जीवन भर के लिए बेहतर)। काले रंग के कपड़े बहुत कम पहनें। पिता या बुजुर्गों का अपमान कभी न करें, उनका आशीर्वाद लेते रहें। इन उपायों को शुरू करते ही 40-45 दिन में आपको खुद फर्क महसूस होने लगेगा - मानसिक शांति बढ़ेगी, कर्ज उतरने का रास्ता बनेगा और स्वास्थ्य में सुधार आएगा।"
    },
    {
      "title": "आपके लाख प्रयत्नों के उपरान्त भी",
      "body": "आपके लाख प्रयत्नों के उपरान्त भी आपके सामान की बिक्री निरन्तर घटती जा रही हो, तो बिक्री में वृद्धि हेतु किसी भी मास के शुक्ल पक्ष के गुरुवार के दिन से निम्नलिखित क्रिया प्रारम्भ करनी चाहिए - व्यापार स्थल अथवा दुकान के मुख्य द्वार के एक कोने को गंगाजल से धोकर स्वच्छ कर लें । इसके उपरान्त हल्दी से स्वस्तिक बनाकर उस पर चने की दाल और गुड़ थोड़ी मात्रा में रख दें । इसके बाद आप उस स्वस्तिक को बार-बार नहीं देखें । इस प्रकार प्रत्येक गुरुवार को यह क्रिया सम्पन्न करने से बिक्री में अवश्य ही वृद्धि होती है । इस प्रक्रिया को कम-से-कम 11 गुरुवार तक अवश्य करें"
    },
    {
      "title": "This is gernal prediction and astrology affect person to person.",
      "body": "This is gernal prediction and astrology affect person to person."
    }
  ];

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();

  void _addMessage() {
    if (_titleController.text.trim().isNotEmpty && _messageController.text.trim().isNotEmpty) {
      setState(() {
        _defaultMessages.add({
          "title": _titleController.text.trim(),
          "body": _messageController.text.trim()
        });
        _titleController.clear();
        _messageController.clear();
      });
      Get.back(); // Close bottom sheet
      Get.snackbar(
        "Success",
        "Default message added successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  void _showAddMessageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              "New Default Message",
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E1A47),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2E1A47), fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: "Enter message title...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2E1A47)),
                decoration: InputDecoration(
                  hintText: "Enter your predefined message here...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "Save Message",
              onPressed: _addMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Default Messages',
      ),
      body: _defaultMessages.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _defaultMessages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildMessageCard(index),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: CustomButton(
          text: "+ Add New Message",
          onPressed: _showAddMessageSheet,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.message_copy, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 24),
          const AppText(
            "No Default Messages",
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E1A47),
          ),
          const SizedBox(height: 8),
          AppText(
            "Add quick responses to save time during chat.",
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(int index) {
    final msg = _defaultMessages[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0), // space for icons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  msg["title"] ?? "",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                AppText(
                  msg["body"] ?? "",
                  fontSize: 13,
                  color: Colors.black87.withOpacity(0.8),
                  height: 1.5,
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Edit action
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Icon(Icons.edit, color: Colors.grey.shade500, size: 20),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _defaultMessages.removeAt(index);
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.delete_outline, color: Color(0xFFE57373), size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
