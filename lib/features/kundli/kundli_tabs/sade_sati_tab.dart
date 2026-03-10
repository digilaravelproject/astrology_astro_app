import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';

class SadeSatiTab extends StatelessWidget {
  const SadeSatiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSadesatiStatusCard(),
          const SizedBox(height: 16),
          _buildSadesatiTimelineTable(),
        ],
      ),
    );
  }

  Widget _buildSadesatiStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor, // header
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Center(
              child: AppText("Sadesati", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA4335), // Red color for Yes
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppText("Yes", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText("Rahul", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      SizedBox(height: 4),
                      AppText(
                        "You are currently running into Peak phase of Sadesati from 29-Mar-2025 to 03-Jun-2027",
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSadesatiTimelineTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryColor, // table header
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Row(
              children: [
                Expanded(child: Center(child: AppText("Start", fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
                Expanded(child: Center(child: AppText("End", fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
                Expanded(child: Center(child: AppText("Sign Name", fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
                Expanded(child: Center(child: AppText("Type", fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
              ],
            ),
          ),
          _buildTimelineRow("5-Mar-1993", "15-Oct-1993", "Aquarius", "Rising", isEven: true),
          _buildTimelineRow("10-Nov-1993", "2-Jun-1995", "Aquarius", "Rising", isEven: false),
          _buildTimelineRow("2-Jun-1995", "9-Aug-1995", "Pisces", "Peak", isEven: true, isHighlight: true),
          _buildTimelineRow("9-Aug-1995", "16-Feb-1996", "Aquarius", "Rising", isEven: false),
          _buildTimelineRow("16-Feb-1996", "17-Apr-1998", "Pisces", "Peak", isEven: true, isHighlight: true),
          _buildTimelineRow("17-Apr-1998", "6-Jun-2000", "Aries", "Setting", isEven: false),
          _buildTimelineRow("29-Apr-2022", "12-Jul-2022", "Aquarius", "Rising", isEven: true),
          _buildTimelineRow("17-Jan-2023", "29-Mar-2025", "Aquarius", "Rising", isEven: false),
          _buildTimelineRow("29-Mar-2025", "3-Jun-2027", "Pisces", "Peak", isEven: true, isHighlight: true),
          _buildTimelineRow("3-Jun-2027", "20-Oct-2027", "Aries", "Setting", isEven: false),
          _buildTimelineRow("20-Oct-2027", "23-Feb-2028", "Pisces", "Peak", isEven: true, isHighlight: true),
          _buildTimelineRow("23-Feb-2028", "8-Aug-2029", "Aries", "Setting", isEven: false),
          _buildTimelineRow("5-Oct-2029", "17-Apr-2030", "Aries", "Setting", isEven: true),
          // Additional rows can go here
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String start, String end, String sign, String type, {required bool isEven, bool isHighlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : const Color(0xFFF6F8F9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Center(child: AppText(start, fontSize: 12, color: isHighlight ? const Color(0xFF3285B8) : Colors.black87))),
          Expanded(child: Center(child: AppText(end, fontSize: 12, color: isHighlight ? const Color(0xFF3285B8) : Colors.black87))),
          Expanded(child: Center(child: AppText(sign, fontSize: 12, color: Colors.black87))),
          Expanded(child: Center(child: AppText(type, fontSize: 12, color: isHighlight ? const Color(0xFFA05F67) : Colors.black87))),
        ],
      ),
    );
  }
}
