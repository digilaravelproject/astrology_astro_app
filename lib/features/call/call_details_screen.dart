import 'package:flutter/material.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class CallDetailsScreen extends StatelessWidget {
  final String title;
  final String name;
  final String dateOfBirth;
  final String placeOfBirth;
  final String gender;
  final String schedule;
  final String duration;
  final String rating;

  const CallDetailsScreen({
    super.key,
    required this.title,
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.gender,
    required this.schedule,
    required this.duration,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Client Profile',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E1A47),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Name', name),
            const SizedBox(height: 8),
            _buildDetailRow('Date of Birth', dateOfBirth),
            const SizedBox(height: 8),
            _buildDetailRow('Place of Birth', placeOfBirth),
            const SizedBox(height: 8),
            _buildDetailRow('Gender', gender),
            const SizedBox(height: 24),
            const AppText(
              'Appointment Schedule:',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E1A47),
            ),
            const SizedBox(height: 12),
            AppText(
              schedule,
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Duration', duration),
            const SizedBox(height: 8),
            if (rating.isNotEmpty) _buildDetailRow('Rating', rating),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '$label: ',
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
        Expanded(
          child: AppText(
            value,
            fontSize: 14,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
