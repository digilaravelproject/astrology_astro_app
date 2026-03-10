import os
import re

package_name = 'astro_astrologer'

replacements = {
    r"import 'call_history_screen.dart';": f"import 'package: {package_name}/features/call/call_history_screen.dart';",
    r"import 'chat_history_screen.dart';": f"import 'package: {package_name}/features/chat/chat_history_screen.dart';",
    r"import 'kundli_list_screen.dart';": f"import 'package: {package_name}/features/kundli/kundli_list_screen.dart';",
    r"import 'kundli_screen.dart';": f"import 'package: {package_name}/features/kundli/kundli_screen.dart';",
    r"import 'orders_screen.dart';": f"import 'package: {package_name}/features/orders/orders_screen.dart';",
    r"import 'history_screen.dart';": f"import 'package: {package_name}/features/orders/history_screen.dart';",
    r"import 'waitlist_screen.dart';": f"import 'package: {package_name}/features/waitlist/waitlist_screen.dart';",
    r"import 'assistant_chat_screen.dart';": f"import 'package: {package_name}/features/chat/assistant_chat_screen.dart';",
    r"import 'suggested_remedies_screen.dart';": f"import 'package: {package_name}/features/remedies/suggested_remedies_screen.dart';",
    r"import 'notification_screen.dart';": f"import 'package: {package_name}/features/notification/notification_screen.dart';",
    r"import 'blog_screen.dart';": f"import 'package: {package_name}/features/blog/blog_screen.dart';",
    r"import 'panchang_screen.dart';": f"import 'package: {package_name}/features/panchang/panchang_screen.dart';",
    r"import 'offers_screen.dart';": f"import 'package: {package_name}/features/offers/offers_screen.dart';",
    r"import 'notice_screen.dart';": f"import 'package: {package_name}/features/notification/notice_screen.dart';",
    r"import 'withdrawal_screen.dart';": f"import 'package: {package_name}/features/finance/withdrawal_screen.dart';",
    r"import 'bank_details_screen.dart';": f"import 'package: {package_name}/features/finance/bank_details_screen.dart';",
    r"import 'my_earnings_screen.dart';": f"import 'package: {package_name}/features/profile/screens/my_earnings_screen.dart';",
    r"import 'performance_screen.dart';": f"import 'package: {package_name}/features/profile/screens/performance_screen.dart';",
    r"import 'my_reviews_screen.dart';": f"import 'package: {package_name}/features/profile/screens/my_reviews_screen.dart';",
    r"import 'my_followers_screen.dart';": f"import 'package: {package_name}/features/followers/my_followers_screen.dart';",
    r"import 'training_videos_list_screen.dart';": f"import 'package: {package_name}/features/training/training_videos_list_screen.dart';",
    r"import '../widgets/add_note_bottom_sheet.dart';": f"import 'package: {package_name}/features/home/widgets/add_note_bottom_sheet.dart';",
    r"import '../../widgets/add_note_bottom_sheet.dart';": f"import 'package: {package_name}/features/home/widgets/add_note_bottom_sheet.dart';",
    r"import '../widgets/animated_favorite_button.dart';": f"import 'package: {package_name}/features/home/widgets/animated_favorite_button.dart';",
    r"import '../../widgets/animated_favorite_button.dart';": f"import 'package: {package_name}/features/home/widgets/animated_favorite_button.dart';",
    r"import '../widgets/assistant_chat_sort_bottom_sheet.dart';": f"import 'package: {package_name}/features/chat/assistant_chat_sort_bottom_sheet.dart';",
    r"import '../../widgets/assistant_chat_sort_bottom_sheet.dart';": f"import 'package: {package_name}/features/chat/assistant_chat_sort_bottom_sheet.dart';",
    r"import '../widgets/kundli_chart_widget.dart';": f"import 'package: {package_name}/features/kundli/kundli_chart_widget.dart';",
    r"import '../../widgets/kundli_chart_widget.dart';": f"import 'package: {package_name}/features/kundli/kundli_chart_widget.dart';",
    r"import '../widgets/training_videos_section.dart';": f"import 'package: {package_name}/features/training/training_videos_section.dart';",
    r"import '../widgets/special_offer_banner.dart';": f"import 'package: {package_name}/features/offers/special_offer_banner.dart';",
    r"import 'astromall/astromall_orders_screen.dart';": f"import 'package: {package_name}/features/astromall/astromall_orders_screen.dart';",
    r"import 'kundli_tabs/': 'features/kundli/kundli_tabs/": f"import 'package: {package_name}/features/kundli/kundli_tabs/",
    r"import 'call_details_screen.dart';": f"import 'package: {package_name}/features/call/call_details_screen.dart';",
    r"import 'chat_screen.dart';": f"import 'package: {package_name}/features/chat/chat_screen.dart';",
    r"import 'discounted_session_screen.dart';": f"import 'package: {package_name}/features/offers/discounted_session_screen.dart';",
}

# Add some relative to absolute replacements if needed
more_replacements = {
    r"import '../../home/screens/my_followers_screen.dart';": f"import 'package: {package_name}/features/followers/my_followers_screen.dart';",
    r"import '../../home/screens/training_videos_list_screen.dart';": f"import 'package: {package_name}/features/training/training_videos_list_screen.dart';",
    r"import '../../profile/screens/withdrawal_screen.dart';": f"import 'package: {package_name}/features/finance/withdrawal_screen.dart';",
    r"import '../../profile/screens/bank_details_screen.dart';": f"import 'package: {package_name}/features/finance/bank_details_screen.dart';",
}

replacements.update(more_replacements)

def fix_imports(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    for old, new in replacements.items():
        # Remove space after package: if I accidentally added it
        new = new.replace('package: ', 'package:')
        content = content.replace(old, new)
        
        # Also try replacing with double quotes
        old_dq = old.replace("'", '"')
        new_dq = new.replace("'", '"')
        content = content.replace(old_dq, new_dq)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed imports in {filepath}")

def main():
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                fix_imports(os.path.join(root, file))

if __name__ == "__main__":
    main()
