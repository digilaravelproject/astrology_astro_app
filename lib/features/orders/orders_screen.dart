import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import '../../../core/widgets/loyal_badge.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: CustomAppBar(
        title: 'Orders',
        showLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87, size: 18),
            label: const AppText('Refresh', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Poppins'),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('WaitList'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const AppText('2', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const Tab(text: 'Chat'),
                const Tab(text: 'Call'),
                const Tab(text: 'AstroMall'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWaitListTab(),
                _buildChatTab(),
                _buildCallTab(),
                _buildAstroMallTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab content builders ────────────────────────────────────────────────

  Widget _buildWaitListTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      children: [
        _buildSessionCard(
          type: 'Repeat (Indian)',
          status: 'Waiting',
          statusColor: Colors.orange,
          sessionId: '#338579629',
          date: '20 Feb 26, 10:50 AM',
          details: {
            'Name': 'Kishore (AT-ZDXL297)',
            'Type': 'Chat',
            'Token': '1',
          },
          actions: [
            _outlinedAction('Chat Assistant', Icons.chat_bubble_rounded, Colors.green),
            const SizedBox(height: 8),
            _outlinedAction('Start Offline Session', Iconsax.clock_copy, Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
        _buildSessionCard(
          type: 'New (Indian)',
          status: 'Waiting',
          statusColor: Colors.orange,
          sessionId: '#338581777',
          date: '20 Feb 26, 11:11 AM',
          details: {
            'Name': 'Rahul (AT-MKK63GE)',
            'Type': 'Chat',
            'Token': '1',
          },
          actions: [
            _outlinedAction('Chat Assistant', Icons.chat_bubble_rounded, Colors.green),
            const SizedBox(height: 8),
            _outlinedAction('Start Offline Session', Iconsax.clock_copy, Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoBanner(
          'Offline sessions monthly limit: 7/150',
          'System allows maximum 150 offline sessions a month. If your last 7 days average daily busy time is more than 3 hours, unlimited offline sessions are allowed.',
        ),
      ],
    );
  }

  Widget _buildChatTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      children: [
        _buildSessionCard(
          type: 'Repeat (Indian)',
          status: 'Completed',
          statusColor: Colors.green,
          sessionId: '#1771563549910',
          date: '20 Feb 26, 10:29 – 10:41 AM',
          earnings: '₹ 129.0',
          isLoyal: true,
          details: {
            'Name': 'Kishore (AT-ZDXL297)',
            'DOB': '21-Aug-1976, 07:00 AM',
            'Duration': '12 minutes',
            'Rate': '₹ 11.8/min',
            'POB': 'Kolhapur, Maharashtra',
          },
          actions: [
            Row(children: [
              Expanded(child: _outlinedAction('Suggest Remedy', Iconsax.health_copy, AppColors.primaryColor)),
              const SizedBox(width: 8),
              Expanded(child: _outlinedAction('Open Kundli', Iconsax.book_1_copy, AppColors.primaryColor)),
            ]),
          ],
        ),
        const SizedBox(height: 12),
        _buildSessionCard(
          type: 'Repeat (Indian)',
          status: 'Cancelled',
          statusColor: Colors.red,
          sessionId: '#1771561025979',
          date: '20 Feb 26, 09:47 AM',
          earnings: '₹ 0.0',
          details: {
            'Name': 'Kishore (AT-ZDXL297)',
            'DOB': '21-Aug-1976, 07:00 AM',
            'POB': 'Kolhapur, Maharashtra',
          },
        ),
      ],
    );
  }

  Widget _buildCallTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      children: [
        _buildSessionCard(
          type: 'Repeat (Indian)',
          status: 'Completed',
          statusColor: Colors.green,
          sessionId: '#1771487754310752',
          date: '19 Feb 26 (01:26 – 01:41 PM)',
          earnings: '₹ 337.5',
          isLoyal: true,
          details: {
            'Name': 'Pooja (AT-VLQM7E)',
            'Gender': 'Female',
            'DOB': '15-Apr-1992, 10:35 PM',
            'Duration': '15 minutes',
            'Rate': '₹ 22.5/min',
            'Rating': '⭐⭐⭐⭐☆',
            'POB': 'Mumbai, Maharashtra',
          },
          actions: [
            Row(children: [
              Expanded(child: _outlinedAction('Suggest Remedy', Iconsax.health_copy, AppColors.primaryColor)),
              const SizedBox(width: 8),
              Expanded(child: _outlinedAction('Open Kundli', Iconsax.book_1_copy, AppColors.primaryColor)),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildAstroMallTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      children: [
        _buildAstroMallCard(
          orderId: '1752982547415',
          date: '20 Jul 25, 09:05 AM',
          status: 'Closed',
          statusColor: Colors.green,
          customerName: 'Kartikee (AT-GG4V2W8)',
          productName: 'Evil Eye Protection Bracelet',
          quantity: 1,
          earnings: '₹ 116.31',
        ),
      ],
    );
  }

  // ── Reusable card widgets ────────────────────────────────────────────────

  Widget _buildSessionCard({
    required String type,
    required String status,
    required Color statusColor,
    required String sessionId,
    required String date,
    String? earnings,
    bool isLoyal = false,
    required Map<String, String> details,
    List<Widget> actions = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(
                      type,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightBlue.shade400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AppText(
                          status,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status == 'Completed') ...[
                        const SizedBox(width: 4),
                        Icon(Icons.check_circle, color: statusColor, size: 16),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Astrotalk and Earnings row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Astrotalk', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        const SizedBox(height: 2),
                        AppText(
                          sessionId,
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  if (earnings != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(earnings, fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                        const AppText('Earnings', fontSize: 10, color: Colors.grey),
                      ]
                    )
                  else 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Iconsax.document_copy, size: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 16),
              
              // Date
              AppText(date, fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
              const SizedBox(height: 12),
              
              // Details
              ...details.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 80, child: AppText(e.key, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                    const AppText(':  ', fontWeight: FontWeight.bold),
                    Expanded(child: AppText(e.value, fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ),
              )),
              
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),
                ...actions,
              ],
            ],
          ),
        ),
        if (isLoyal) LoyalBadge.positioned(top: 0, left: 0),
      ],
    ),
  );
}

  Widget _buildAstroMallCard({
    required String orderId,
    required String date,
    required String status,
    required Color statusColor,
    required String customerName,
    required String productName,
    required int quantity,
    required String earnings,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(status, fontSize: 13, fontWeight: FontWeight.w700, color: statusColor),
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle, color: statusColor, size: 14),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.receipt_2_copy, size: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Order: $orderId', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                    const SizedBox(height: 2),
                    AppText(date, fontSize: 12, color: Colors.grey.shade500),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(earnings, fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                  const AppText('Your Earnings', fontSize: 10, color: Colors.grey),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _detailRow('Name', customerName),
          _detailRow('Product', productName),
          _detailRow('Quantity', quantity.toString()),
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const AppText('Call with User', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 70, child: AppText(label, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        const AppText(':  ', fontWeight: FontWeight.bold),
        Expanded(child: AppText(value, fontSize: 12, color: Colors.grey.shade700)),
      ]),
    );
  }

  Widget _outlinedAction(String label, IconData icon, Color color) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14, color: color),
      label: AppText(label, fontSize: 12, fontWeight: FontWeight.w600, color: color),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        minimumSize: const Size(0, 38),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildInfoBanner(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softPink),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Iconsax.info_circle_copy, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(child: AppText(title, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
        ]),
        const SizedBox(height: 6),
        AppText(message, fontSize: 11, color: Colors.black54, height: 1.5),
      ]),
    );
  }
}
