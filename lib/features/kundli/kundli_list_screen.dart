import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart' as sax;
import 'create_kundli_screen.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';

class KundliListScreen extends StatefulWidget {
  final bool isMatchingMode;
  const KundliListScreen({super.key, this.isMatchingMode = false});

  @override
  State<KundliListScreen> createState() => _KundliListScreenState();
}

class _KundliListScreenState extends State<KundliListScreen> {
  final List<Map<String, String>> kundliList = [
    {
      "id": "1",
      "name": "Utkarsha Rathod",
      "gender": "Female",
      "dob": "05-July-1994",
      "time": "08:13 PM",
      "place": "New Delhi, Delhi, India",
      "initial": "U",
    },
    {
      "id": "2",
      "name": "abc",
      "gender": "Female",
      "dob": "26-November-2000",
      "time": "05:35 AM",
      "place": "Amravati, Maharashtra, India",
      "initial": "a",
    },
  ];

  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = kundliList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredList = kundliList
          .where((item) => (item['name'] ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        if (_selectedIds.length < 2) {
          _selectedIds.add(id);
        } else {
          Get.snackbar(
            "Limit Reached",
            "You can select only 2 Kundlis for Match Making",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5), // Premium Ivory
      appBar: CustomAppBar(
        title: widget.isMatchingMode ? 'Match Making' : 'Kundli',
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildKundliItem(_filteredList[index]);
                    },
                  ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.08)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search by name...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(sax.Iconsax.search_normal_1_copy, size: 18, color: AppColors.primaryColor.withOpacity(0.6)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged("");
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(sax.Iconsax.search_status_copy, size: 64, color: AppColors.primaryColor.withOpacity(0.1)),
          const SizedBox(height: 16),
          AppText(
            "No Kundli Found",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          AppText(
            "Try searching with a different name",
            fontSize: 14,
            color: AppColors.textColorSecondary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildKundliItem(Map<String, String> data) {
    bool isAbc = data['name'] == "abc";
    bool isSelected = _selectedIds.contains(data['id']);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.isMatchingMode) {
          final id = data['id'];
          if (id != null) {
            _toggleSelection(id);
          }
        } else {
          Get.to(() => const KundliScreen());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(isSelected ? 0.12 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with Gradient Ring
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.2),
                    AppColors.softPink.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
              ),
              child: Center(
                child: AppText(
                  data['initial']?.toUpperCase() ?? '',
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(data['name'] ?? '', fontSize: 17, fontWeight: FontWeight.bold),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => CreateKundliScreen(
                                  initialIsMatching: false,
                                  initialKundliData: data,
                                )),
                            child: Icon(Icons.edit_note_rounded, color: AppColors.primaryColor.withOpacity(0.5), size: 24),
                          ),
                          if (widget.isMatchingMode) ...[
                            const SizedBox(width: 12),
                            Icon(
                              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                              size: 22,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Details with micro-icons
                  _buildDetailRow(sax.Iconsax.user_copy, data['gender'] ?? ''),
                  const SizedBox(height: 4),
                  _buildDetailRow(sax.Iconsax.calendar_1_copy, "${data['dob']} | ${data['time']}"),
                  const SizedBox(height: 4),
                  _buildDetailRow(sax.Iconsax.location_copy, data['place'] ?? ''),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.to(() => const KundliScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              "View Kundli",
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textColorSecondary.withOpacity(0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: AppText(
            text,
            fontSize: 12,
            color: AppColors.textColorSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    bool canMatch = _selectedIds.length == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10)),
        ],
      ),
      child: Row(
        children: [
          if (widget.isMatchingMode) ...[
            Expanded(
              child: GestureDetector(
                onTap: canMatch
                    ? () {
                        final selectedItems = kundliList.where((item) => _selectedIds.contains(item['id'])).toList();
                        // Simple logic: first is boy, second is girl or based on gender if available
                        Map<String, String>? boyData;
                        Map<String, String>? girlData;

                        if (selectedItems.length == 2) {
                          if (selectedItems[0]['gender'] == 'Male' || selectedItems[1]['gender'] == 'Female') {
                            boyData = selectedItems[0];
                            girlData = selectedItems[1];
                          } else {
                            boyData = selectedItems[1];
                            girlData = selectedItems[0];
                          }
                        }

                        Get.to(() => CreateKundliScreen(
                              initialIsMatching: true,
                              initialBoyData: boyData,
                              initialGirlData: girlData,
                            ));
                      }
                    : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: canMatch ? 1.0 : 0.5,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.lightPink.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(sax.Iconsax.heart_copy, size: 18, color: canMatch ? AppColors.primaryColor : Colors.grey),
                          const SizedBox(width: 8),
                          AppText(
                            "Match Making",
                            color: canMatch ? AppColors.primaryColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(() => CreateKundliScreen(
                    initialIsMatching: false,
                    hideMatchingTab: !widget.isMatchingMode,
                  )),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: AppText(
                    "Create New",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
