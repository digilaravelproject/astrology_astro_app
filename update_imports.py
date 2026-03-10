import os

replacements = {
    # Home to Feature
    'features/home/screens/astromall/': 'features/astromall/',
    'features/home/widgets/astromall_filter_bottom_sheet.dart': 'features/astromall/astromall_filter_bottom_sheet.dart',
    'features/home/screens/blog_detail_screen.dart': 'features/blog/blog_detail_screen.dart',
    'features/home/screens/blog_screen.dart': 'features/blog/blog_screen.dart',
    'features/home/screens/call_details_screen.dart': 'features/call/call_details_screen.dart',
    'features/home/screens/call_history_screen.dart': 'features/call/call_history_screen.dart',
    'features/home/screens/call_screen.dart': 'features/call/call_screen.dart',
    'features/home/screens/chat_history_screen.dart': 'features/chat/chat_history_screen.dart',
    'features/home/screens/chat_screen.dart': 'features/chat/chat_screen.dart',
    'features/home/screens/assistant_chat_screen.dart': 'features/chat/assistant_chat_screen.dart',
    'features/home/screens/create_default_message_screen.dart': 'features/chat/create_default_message_screen.dart',
    'features/home/widgets/assistant_chat_sort_bottom_sheet.dart': 'features/chat/assistant_chat_sort_bottom_sheet.dart',
    'features/home/screens/create_kundli_screen.dart': 'features/kundli/create_kundli_screen.dart',
    'features/home/screens/kundli_list_screen.dart': 'features/kundli/kundli_list_screen.dart',
    'features/home/screens/kundli_screen.dart': 'features/kundli/kundli_screen.dart',
    'features/home/widgets/kundli_chart_widget.dart': 'features/kundli/kundli_chart_widget.dart',
    'features/home/screens/kundli_tabs/': 'features/kundli/kundli_tabs/',
    'features/home/screens/notice_screen.dart': 'features/notification/notice_screen.dart',
    'features/home/screens/notification_detail_screen.dart': 'features/notification/notification_detail_screen.dart',
    'features/home/screens/notification_screen.dart': 'features/notification/notification_screen.dart',
    'features/home/screens/history_screen.dart': 'features/orders/history_screen.dart',
    'features/home/screens/orders_screen.dart': 'features/orders/orders_screen.dart',
    'features/home/screens/discounted_session_screen.dart': 'features/offers/discounted_session_screen.dart',
    'features/home/screens/offers_screen.dart': 'features/offers/offers_screen.dart',
    'features/home/widgets/special_offer_banner.dart': 'features/offers/special_offer_banner.dart',
    'features/home/screens/panchang_screen.dart': 'features/panchang/panchang_screen.dart',
    'features/home/screens/training_videos_list_screen.dart': 'features/training/training_videos_list_screen.dart',
    'features/home/widgets/training_videos_section.dart': 'features/training/training_videos_section.dart',
    'features/home/screens/suggested_remedies_screen.dart': 'features/remedies/suggested_remedies_screen.dart',
    'features/home/screens/my_followers_screen.dart': 'features/followers/my_followers_screen.dart',
    'features/home/screens/waitlist_screen.dart': 'features/waitlist/waitlist_screen.dart',
    'features/home/screens/set_sleep_hours_screen.dart': 'features/schedule/set_sleep_hours_screen.dart',

    # Profile to Feature
    'features/profile/screens/add_bank_screen.dart': 'features/finance/add_bank_screen.dart',
    'features/profile/screens/bank_details_screen.dart': 'features/finance/bank_details_screen.dart',
    'features/profile/screens/withdrawal_screen.dart': 'features/finance/withdrawal_screen.dart',
    'features/profile/screens/my_earnings_screen.dart': 'features/finance/my_earnings_screen.dart',
    'features/profile/screens/astromall_earnings_screen.dart': 'features/finance/astromall_earnings_screen.dart',
    'features/profile/screens/pay_slip_screen.dart': 'features/finance/pay_slip_screen.dart',
    'features/profile/screens/invoice_screen.dart': 'features/finance/invoice_screen.dart',
    'features/profile/screens/download_form_screen.dart': 'features/finance/download_form_screen.dart',
    'features/profile/screens/form_webview_screen.dart': 'features/finance/form_webview_screen.dart',
    'features/profile/widgets/earning_breakup_bottom_sheet.dart': 'features/finance/earning_breakup_bottom_sheet.dart',
    'features/profile/widgets/invoice_card.dart': 'features/finance/invoice_card.dart',
    'features/profile/widgets/invoice_summary_header.dart': 'features/finance/invoice_summary_header.dart',

    'features/profile/screens/faq_screen.dart': 'features/support/faq_screen.dart',
    'features/profile/screens/feedback_screen.dart': 'features/support/feedback_screen.dart',
    'features/profile/screens/help_support_screen.dart': 'features/support/help_support_screen.dart',
    'features/profile/screens/important_numbers_screen.dart': 'features/support/important_numbers_screen.dart',

    'features/profile/screens/availability_screen.dart': 'features/schedule/availability_screen.dart',
    'features/profile/screens/live_schedule_screen.dart': 'features/schedule/live_schedule_screen.dart',

    'features/profile/screens/performance_screen.dart': 'features/performance/performance_screen.dart',
    'features/profile/screens/weekly_ranking_screen.dart': 'features/performance/weekly_ranking_screen.dart',
    'features/profile/screens/my_reviews_screen.dart': 'features/performance/my_reviews_screen.dart',
}

def update_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    for old, new in replacements.items():
        content = content.replace(old, new)
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

def walk_and_update(root_dir):
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                update_file(os.path.join(root, file))

if __name__ == "__main__":
    walk_and_update('lib')
