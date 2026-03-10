#!/bin/bash
mkdir -p lib/features/orders/screens
mkdir -p lib/features/blog/screens
mkdir -p lib/features/panchang/screens
mkdir -p lib/features/notifications/screens
mkdir -p lib/features/wallet/screens

mv lib/features/home/screens/orders_screen.dart lib/features/orders/screens/ 2>/dev/null || true
mv lib/features/home/screens/order_details_screen.dart lib/features/orders/screens/ 2>/dev/null || true
mv lib/features/home/screens/history_screen.dart lib/features/orders/screens/ 2>/dev/null || true
mv lib/features/home/screens/call_history_screen.dart lib/features/orders/screens/ 2>/dev/null || true
mv lib/features/home/screens/chat_history_screen.dart lib/features/orders/screens/ 2>/dev/null || true
mv lib/features/home/screens/service_history_screen.dart lib/features/orders/screens/ 2>/dev/null || true
mv lib/features/home/screens/astromall/astromall_orders_screen.dart lib/features/orders/screens/ 2>/dev/null || true

mv lib/features/home/screens/blog_screen.dart lib/features/blog/screens/ 2>/dev/null || true
mv lib/features/home/screens/blog_detail_screen.dart lib/features/blog/screens/ 2>/dev/null || true

mv lib/features/home/screens/panchang_screen.dart lib/features/panchang/screens/ 2>/dev/null || true

mv lib/features/home/screens/notification_screen.dart lib/features/notifications/screens/ 2>/dev/null || true
mv lib/features/home/screens/notification_detail_screen.dart lib/features/notifications/screens/ 2>/dev/null || true

mv lib/features/home/screens/wallet_screen.dart lib/features/wallet/screens/ 2>/dev/null || true

echo "Restructure script complete"
