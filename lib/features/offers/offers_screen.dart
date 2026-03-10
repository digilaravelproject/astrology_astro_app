import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _offers = [
    {'discount': '75%', 'isActive': false},
    {'discount': '20%', 'isActive': true},
    {'discount': '50%', 'isActive': false, 'isHappyHours': true},
  ];

  String _selectedHistoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Offers'),
      body: Column(
        children: [
          _buildInfoBanner(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllOffersTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: AppText(
        'Loyal - Customers who have spoken with you for more than 15 minutes (including both call and chat)',
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.grey.shade200,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Poppins'),
        tabs: const [
          Tab(text: 'ALL OFFERS'),
          Tab(text: 'HISTORY'),
        ],
      ),
    );
  }

  Widget _buildAllOffersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _offers.length,
      itemBuilder: (context, index) {
        return _buildOfferCard(_offers[index], index);
      },
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${offer['discount']} off${offer['isHappyHours'] == true ? ' (Happy Hours)' : ''}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: offer['isActive'] as bool,
                            onChanged: (v) {
                              setState(() {
                                _offers[index]['isActive'] = v;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                        ),
                        AppText(
                          offer['isActive'] == true ? 'Active' : 'Inactive',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildUserTypeSection('New Users', '₹30.0', '₹8.0', '₹3.9', '₹3.9', '₹8.0', Colors.blue.shade50, Colors.blue),
                const SizedBox(height: 16),
                _buildUserTypeSection('Loyal Users', '₹30.0', '₹19.0', '₹9.5', '₹9.5', '₹19.0', Colors.orange.shade50, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSection(
    String title,
    String originalPrice,
    String currentPrice,
    String yourShare,
    String atShare,
    String customerPays,
    Color tagBg,
    Color tagText,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: AppText(title, color: tagText, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                AppText(originalPrice, color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough),
                const SizedBox(width: 8),
                AppText(currentPrice, color: Colors.green.shade600, fontSize: 14, fontWeight: FontWeight.bold),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPriceDetail('Your Share', yourShare),
            const SizedBox(width: 8),
            _buildPriceDetail('At Share', atShare),
            const SizedBox(width: 8),
            _buildPriceDetail('Customer pays', customerPays),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDetail(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            AppText(label, fontSize: 10, color: Colors.grey.shade600, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            AppText(value, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        _buildHistoryFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildHistoryCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryFilters() {
    final List<String> filters = ['All', '50% off', '20% off', '75% off'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedHistoryFilter == filter;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: AppText(
                filter,
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              selected: isSelected,
              onSelected: (v) {
                setState(() {
                  _selectedHistoryFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primaryColor : Colors.grey.shade300),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('50% off', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText('Completed', color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeDetail('Start Time *', '16 Feb 2026 , 11:10 AM'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeDetail('End Time *', '16 Feb 2026 , 02:36 PM'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, fontSize: 10, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          AppText(value, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
        ],
      ),
    );
  }
}
