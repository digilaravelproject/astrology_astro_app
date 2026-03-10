import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class SuggestedRemediesScreen extends StatelessWidget {
  const SuggestedRemediesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBar(
        title: 'Suggested Remedies',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return RemedyCard(
            category: index == 1 ? 'Exclusive Gemstone' : 'Bracelets & Pendants',
            product: index == 0 
                ? 'Citrine Bracelet' 
                : index == 1 
                    ? '5 Ratti Ceylon Yellow Sapphire (Pukhraj) Exclusive' 
                    : 'Moonstone Bracelet',
            name: index == 2 ? 'Tania (ID - AT-QVQK4Q8)' : 'Vivek (ID - AT-27Q9776)',
            performBy: 'Astrotalk',
            date: '20 Aug 25, 01:46 PM',
            price: index == 0 ? 'Rs 699' : index == 1 ? 'Rs 43750' : 'Rs 1200',
            type: 'Paid Remedy',
            status: 'Not booked',
            description: index == 1 ? 'Description: this one' : null,
          );
        },
      ),
    );
  }
}

class RemedyCard extends StatelessWidget {
  final String category;
  final String product;
  final String name;
  final String performBy;
  final String date;
  final String price;
  final String type;
  final String status;
  final String? description;

  const RemedyCard({
    super.key,
    required this.category,
    required this.product,
    required this.name,
    required this.performBy,
    required this.date,
    required this.price,
    required this.type,
    required this.status,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Category name: ', category, isValueGreen: true),
                      const SizedBox(height: 4),
                      _buildDetailRow('Product Name: ', product, isValueGreen: true),
                      const SizedBox(height: 4),
                      _buildDetailRow('Name: ', name),
                      const SizedBox(height: 4),
                      _buildDetailRow('Perform by : ', performBy),
                      const SizedBox(height: 4),
                      AppText(date, fontSize: 13, color: Colors.black87),
                      const SizedBox(height: 4),
                      AppText(price, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                      const SizedBox(height: 4),
                      _buildDetailRow('Type: ', type, isValueRed: true),
                      const SizedBox(height: 4),
                      _buildDetailRow('Status: ', status, isValueRed: true),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        AppText(description!, fontSize: 13, color: Colors.black87),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image, color: Colors.grey, size: 40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Iconsax.note_copy, color: AppColors.primaryColor.withOpacity(0.7), size: 18),
                const Spacer(),
                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  foregroundColor: AppColors.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const AppText('Suggest Next Remedy', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isValueGreen = false, bool isValueRed = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87, fontSize: 13),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isValueGreen ? const Color(0xFF7CB342) : (isValueRed ? Colors.red : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
