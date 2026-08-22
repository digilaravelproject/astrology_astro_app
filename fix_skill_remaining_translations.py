import json
import glob
import os

translations = {
    "Finance & Business": {
        "bn_IN": "অর্থ ও ব্যবসা", "hi_IN": "वित्त और व्यवसाय", "ta_IN": "நிதி மற்றும் வணிகம்", "te_IN": "ఫైనాన్స్ & బిజినెస్", "mr_IN": "वित्त आणि व्यवसाय", "gu_IN": "ફાઇનાન્સ અને બિઝનેસ", "kn_IN": "ಹಣಕಾಸು ಮತ್ತು ವ್ಯಾಪಾರ", "ml_IN": "സാമ്പത്തികവും ബിസിനസ്സും", "en_US": "Finance & Business"
    },
    "Relationships": {
        "bn_IN": "সম্পর্ক", "hi_IN": "रिश्ते", "ta_IN": "உறவுகள்", "te_IN": "సంబంధాలు", "mr_IN": "नातेसंबंध", "gu_IN": "સંબંધો", "kn_IN": "ಸಂಬಂಧಗಳು", "ml_IN": "ബന്ധങ്ങൾ", "en_US": "Relationships"
    },
    "Vedic Astrology": {
        "bn_IN": "বৈদিক জ্যোতিষশাস্ত্র", "hi_IN": "वैदिक ज्योतिष", "ta_IN": "வேத ஜோதிடம்", "te_IN": "వేద జ్యోతిషశాస్త్రం", "mr_IN": "वैदिक ज्योतिष", "gu_IN": "વૈદિક જ્યોતિષ", "kn_IN": "ವೈದಿಕ ಜ್ಯೋತಿಷ್ಯ", "ml_IN": "വേദ ജ്യോതിഷം", "en_US": "Vedic Astrology"
    },
    "Tarot Reading": {
        "bn_IN": "ট্যারো রিডিং", "hi_IN": "टैरो रीडिंग", "ta_IN": "டாரோட் வாசிப்பு", "te_IN": "టారో రీడింగ్", "mr_IN": "टॅरो रीडिंग", "gu_IN": "ટેરોટ રીડિંગ", "kn_IN": "ಟ್ಯಾರೋ ಓದುವಿಕೆ", "ml_IN": "ടാരറ്റ് വായന", "en_US": "Tarot Reading"
    },
    "Nadi": {
        "bn_IN": "নাড়ি", "hi_IN": "नाड़ी", "ta_IN": "நாடி", "te_IN": "నాడి", "mr_IN": "नाडी", "gu_IN": "નાડી", "kn_IN": "ನಾಡಿ", "ml_IN": "നാഡി", "en_US": "Nadi"
    },
    "Psychology": {
        "bn_IN": "মনোবিজ্ঞান", "hi_IN": "मनोविज्ञान", "ta_IN": "உளவியல்", "te_IN": "మనస్తత్వశాస్త్రం", "mr_IN": "मानसशास्त्र", "gu_IN": "મનોવિજ્ઞાન", "kn_IN": "ಮನೋವಿಜ್ಞಾನ", "ml_IN": "മനഃശാസ്ത്രം", "en_US": "Psychology"
    },
    "Prashana": {
        "bn_IN": "প্রশ্ন", "hi_IN": "प्रश्न", "ta_IN": "பிரஷ்னா", "te_IN": "ప్రశ్న", "mr_IN": "प्रश्न", "gu_IN": "પ્રશ્ન", "kn_IN": "ಪ್ರಶ್ನೆ", "ml_IN": "പ്രശ്ന", "en_US": "Prashana"
    },
    "Face Reading": {
        "bn_IN": "মুখমণ্ডল পঠন", "hi_IN": "चेहरा पढ़ना", "ta_IN": "முகம் வாசித்தல்", "te_IN": "ముఖ పఠనం", "mr_IN": "चेहरा वाचन", "gu_IN": "ફેસ રીડિંગ", "kn_IN": "ಮುಖ ಓದುವಿಕೆ", "ml_IN": "മുഖം വായന", "en_US": "Face Reading"
    },
    "KP Astrology": {
        "bn_IN": "কেপি জ্যোতিষশাস্ত্র", "hi_IN": "केपी ज्योतिष", "ta_IN": "கே.பி ஜோதிடம்", "te_IN": "కెపి జ్యోతిషశాస్త్రం", "mr_IN": "केपी ज्योतिष", "gu_IN": "કેપી જ્યોતિષ", "kn_IN": "ಕೆಪಿ ಜ್ಯೋತಿಷ್ಯ", "ml_IN": "കെപി ജ്യോതിഷം", "en_US": "KP Astrology"
    },
    "Horary": {
        "bn_IN": "হরারি", "hi_IN": "होरारी", "ta_IN": "ஹோரரி", "te_IN": "హోరరీ", "mr_IN": "होररी", "gu_IN": "હોરારી", "kn_IN": "ಹೊರಾರಿ", "ml_IN": "ഹൊരാരി", "en_US": "Horary"
    },
    "Hindi": {
        "bn_IN": "হিন্দি", "hi_IN": "हिन्दी", "ta_IN": "இந்தி", "te_IN": "హిందీ", "mr_IN": "हिंदी", "gu_IN": "હિન્દી", "kn_IN": "ಹಿಂದಿ", "ml_IN": "ഹിന്ദി", "en_US": "Hindi"
    },
    "English": {
        "bn_IN": "ইংরেজি", "hi_IN": "अंग्रेज़ी", "ta_IN": "ஆங்கிலம்", "te_IN": "ఇంగ్లీష్", "mr_IN": "इंग्रजी", "gu_IN": "અંગ્રેજી", "kn_IN": "ಇಂಗ್ಲೀಷ್", "ml_IN": "ഇംഗ്ലീഷ്", "en_US": "English"
    },
    "Marathi": {
        "bn_IN": "মারাঠি", "hi_IN": "मराठी", "ta_IN": "மராத்தி", "te_IN": "మరాఠీ", "mr_IN": "मराठी", "gu_IN": "મરાઠી", "kn_IN": "ಮರಾಠಿ", "ml_IN": "മറാത്തി", "en_US": "Marathi"
    },
    "Gujarati": {
        "bn_IN": "গুজরাটি", "hi_IN": "गुजराती", "ta_IN": "குஜராத்தி", "te_IN": "గుజరాతీ", "mr_IN": "गुजराती", "gu_IN": "ગુજરાતી", "kn_IN": "ಗುಜರಾತಿ", "ml_IN": "ഗുജറാത്തി", "en_US": "Gujarati"
    },
    "Tamil": {
        "bn_IN": "তামিল", "hi_IN": "तमिल", "ta_IN": "தமிழ்", "te_IN": "తమిళం", "mr_IN": "तमिळ", "gu_IN": "તમિલ", "kn_IN": "ತಮಿಳು", "ml_IN": "തമിഴ്", "en_US": "Tamil"
    },
    "Telugu": {
        "bn_IN": "তেলেগু", "hi_IN": "तेलुगु", "ta_IN": "தெலுங்கு", "te_IN": "తెలుగు", "mr_IN": "तेलुगु", "gu_IN": "તેલુગુ", "kn_IN": "ತೆಲುಗು", "ml_IN": "തെലുങ്ക്", "en_US": "Telugu"
    },
    "Search": {
        "bn_IN": "অনুসন্ধান", "hi_IN": "खोजें", "ta_IN": "தேடுங்கள்", "te_IN": "వెతకండి", "mr_IN": "शोधा", "gu_IN": "શોધો", "kn_IN": "ಹುಡುಕಿ", "ml_IN": "തിരയുക", "en_US": "Search"
    }
}

for file in glob.glob("assets/translations/*.json"):
    lang = os.path.basename(file).split(".")[0]
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    for key, trans_dict in translations.items():
        if lang in trans_dict:
            data[key] = trans_dict[lang]
            
    with open(file, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

print("Remaining translations updated successfully.")
