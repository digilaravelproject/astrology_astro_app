import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/widgets/custom_button.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/core/widgets/loyal_badge.dart';
import '../controllers/orders_controller.dart';
import 'package:astro_astrologer/features/orders/domain/usecases/get_astrologer_orders_usecase.dart';
import 'package:astro_astrologer/features/orders/domain/repositories/i_orders_repository.dart';
import 'package:astro_astrologer/features/orders/data/repositories/orders_repository_impl.dart';
import '../../domain/models/astrologer_order_model.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final OrdersController _ordersController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Only Chat and Call

    if (!Get.isRegistered<OrdersController>()) {
      if (!Get.isRegistered<IOrdersRepository>()) {
         Get.put<IOrdersRepository>(OrdersRepositoryImpl(apiClient: Get.find()));
      }
      if (!Get.isRegistered<GetAstrologerOrdersUseCase>()) {
        Get.put(GetAstrologerOrdersUseCase(Get.find<IOrdersRepository>()));
      }
      Get.put(OrdersController(
        getAstrologerOrdersUseCase: Get.find(),
        apiClient: Get.find(),
      ));
    }
    _ordersController = Get.find<OrdersController>();
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
            onPressed: () {
              if (_tabController.index == 0) {
                _ordersController.fetchChatOrders(isRefresh: true);
              } else {
                _ordersController.fetchCallOrders(isRefresh: true);
              }
            },
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
              isScrollable: false,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, fontFamily: 'Poppins'),
              tabs: const [
                Tab(text: 'Chat'),
                Tab(text: 'Call'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(),
                _buildCallTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Obx(() {
      if (_ordersController.isLoadingChat.value && _ordersController.chatOrders.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
      }

      if (_ordersController.chatError.value.isNotEmpty && _ordersController.chatOrders.isEmpty) {
        return Center(child: Text("Error: ${_ordersController.chatError.value}"));
      }

      if (_ordersController.chatOrders.isEmpty) {
        return Center(
          child: AppText(
            "No chat history available.",
            color: Colors.grey.shade500,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _ordersController.fetchChatOrders(isRefresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          itemCount: _ordersController.chatOrders.length,
          itemBuilder: (context, index) {
            final session = _ordersController.chatOrders[index];
            return _buildOrderCard(session);
          },
        ),
      );
    });
  }

  Widget _buildCallTab() {
    return Obx(() {
      if (_ordersController.isLoadingCall.value && _ordersController.callOrders.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
      }

      if (_ordersController.callError.value.isNotEmpty && _ordersController.callOrders.isEmpty) {
        return Center(child: Text("Error: ${_ordersController.callError.value}"));
      }

      if (_ordersController.callOrders.isEmpty) {
        return Center(
          child: AppText(
            "No call history available.",
            color: Colors.grey.shade500,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _ordersController.fetchCallOrders(isRefresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          itemCount: _ordersController.callOrders.length,
          itemBuilder: (context, index) {
            final session = _ordersController.callOrders[index];
            return _buildOrderCard(session);
          },
        ),
      );
    });
  }

  Widget _buildOrderCard(AstrologerOrderModel session) {
    final isCompleted = session.status == 'completed';
    final isPending = session.status == 'waiting' || session.status == 'pending' || session.status == 'initiated';
    final customerName = session.userName;
    
    DateTime? date;
    try {
      if (session.requestedAt != null) {
        date = DateTime.parse(session.requestedAt!);
      }
    } catch (_) {}
    
    final dateStr = date != null ? DateFormat('dd MMM yy, hh:mm a').format(date.toLocal()) : "N/A";
    final durationMins = (session.durationSeconds / 60).ceil();

    List<Widget> actionButtons = [];

    if (isPending) {
      actionButtons = [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _ordersController.rejectChatOrder(session),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const AppText('Reject', color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _ordersController.acceptChatOrder(session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DB84B),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const AppText('Accept', color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      ];
    } else if (isCompleted) {
      actionButtons = [
        Row(children: [
          Expanded(child: _outlinedAction('Suggest Remedy', Iconsax.health_copy, AppColors.primaryColor)),
          const SizedBox(width: 8),
          Expanded(child: _outlinedAction('Open Kundli', Iconsax.book_1_copy, AppColors.primaryColor)),
        ]),
      ];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? Colors.orange.shade300 : Colors.grey.shade200, width: isPending ? 1.5 : 1.0),
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
              AppText(
                session.requestType.capitalizeFirst ?? 'Chat',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.lightBlue.shade400,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    session.status.capitalizeFirst ?? session.status,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isPending ? Colors.orange : (isCompleted ? Colors.green : Colors.red),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: session.userProfileImage != null ? NetworkImage(session.userProfileImage!) : null,
                backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                child: session.userProfileImage == null 
                  ? AppText(customerName.isNotEmpty ? customerName[0].toUpperCase() : 'U', fontWeight: FontWeight.bold, color: AppColors.primaryColor)
                  : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(customerName, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    const SizedBox(height: 2),
                    AppText('#${session.sessionId}', fontSize: 13, color: Colors.grey.shade500),
                  ],
                ),
              ),
              if (isCompleted)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText('₹ ${session.amount}', fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                    const AppText('Earnings', fontSize: 10, color: Colors.grey),
                  ]
                )
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 16),
          AppText(dateStr, fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
          const SizedBox(height: 12),
          _detailRow('Duration', '$durationMins minutes'),
          _detailRow('Rate', '₹ ${session.ratePerMinute}/min'),
          if (session.queuePosition != null && isPending)
            _detailRow('WaitList #', '${session.queuePosition}'),
          
          if (actionButtons.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            ...actionButtons,
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 80, child: AppText(label, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const AppText(':  ', fontWeight: FontWeight.bold),
        Expanded(child: AppText(value, fontSize: 13, color: Colors.grey.shade700)),
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
}
