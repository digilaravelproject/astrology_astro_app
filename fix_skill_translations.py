import json
import glob
import os

translations = {
    "Source": {
        "bn_IN": "উৎস", "hi_IN": "स्रोत", "ta_IN": "மூலம்", "te_IN": "మూలం", "mr_IN": "स्रोत", "gu_IN": "સ્ત્રોત", "kn_IN": "ಮೂಲ", "ml_IN": "ഉറവിടം", "en_US": "Source"
    },
    "Youtube": {
        "bn_IN": "ইউটিউব", "hi_IN": "यूट्यूब", "ta_IN": "யூடியூப்", "te_IN": "యూట్యూబ్", "mr_IN": "यूट्यूब", "gu_IN": "યુટ્યુબ", "kn_IN": "ಯೂಟ್ಯೂಬ್", "ml_IN": "യൂട്യൂബ്", "en_US": "Youtube"
    },
    "Facebook": {
        "bn_IN": "ফেসবুক", "hi_IN": "फेसबुक", "ta_IN": "பேஸ்புக்", "te_IN": "ఫేస్‌బుక్", "mr_IN": "फेसबुक", "gu_IN": "ફેસબુક", "kn_IN": "ಫೇಸ್‌ಬುಕ್", "ml_IN": "ഫേസ്ബുക്ക്", "en_US": "Facebook"
    },
    "Instagram": {
        "bn_IN": "ইনস্টাগ্রাম", "hi_IN": "इंस्टाग्राम", "ta_IN": "இன்ஸ்டாகிராம்", "te_IN": "ఇన్‌స్టాగ్రామ్", "mr_IN": "इंस्टाग्राम", "gu_IN": "ઇન્સ્ટાગ્રામ", "kn_IN": "ಇನ್‌ಸ್ಟಾಗ್ರಾಮ್", "ml_IN": "ഇൻസ്റ്റാഗ്രാം", "en_US": "Instagram"
    },
    "Friend Referral": {
        "bn_IN": "বন্ধুর রেফারেল", "hi_IN": "मित्र का रेफरल", "ta_IN": "நண்பர் குறிப்பு", "te_IN": "స్నేహితుని రెఫరల్", "mr_IN": "मित्राचा संदर्भ", "gu_IN": "મિત્રનો સંદર્ભ", "kn_IN": "ಸ್ನೇಹಿತರ ಉಲ್ಲೇಖ", "ml_IN": "സുഹൃത്തിന്റെ റഫറൽ", "en_US": "Friend Referral"
    },
    "Google Ad": {
        "bn_IN": "গুগল বিজ্ঞাপন", "hi_IN": "गूगल विज्ञापन", "ta_IN": "கூகுள் விளம்பரம்", "te_IN": "గూగుల్ ప్రకటన", "mr_IN": "गूगल जाहिरात", "gu_IN": "ગૂગલ જાહેરાત", "kn_IN": "ಗೂಗಲ್ ಜಾಹೀರಾತು", "ml_IN": "ഗൂഗിൾ പരസ്യം", "en_US": "Google Ad"
    },
    "Skill Details": {
        "bn_IN": "দক্ষতার বিবরণ", "hi_IN": "कौशल विवरण", "ta_IN": "திறன் விவரங்கள்", "te_IN": "నైపుణ్య వివరాలు", "mr_IN": "कौशल्य तपशील", "gu_IN": "કૌશલ્ય વિગતો", "kn_IN": "ಕೌಶಲ್ಯದ ವಿವರಗಳು", "ml_IN": "നൈപുണ്യ വിശദാംശങ്ങൾ", "en_US": "Skill Details"
    },
    "Professional Skills": {
        "bn_IN": "পেশাদার দক্ষতা", "hi_IN": "व्यावसायिक कौशल", "ta_IN": "தொழில்முறை திறன்கள்", "te_IN": "వృత్తిపరమైన నైపుణ్యాలు", "mr_IN": "व्यावसायिक कौशल्य", "gu_IN": "વ્યાવસાયિક કૌશલ્ય", "kn_IN": "ವೃತ್ತಿಪರ ಕೌಶಲ್ಯಗಳು", "ml_IN": "പ്രൊഫഷണൽ കഴിവുകൾ", "en_US": "Professional Skills"
    },
    "Astrologer category": {
        "bn_IN": "জ্যোতিষী বিভাগ", "hi_IN": "ज्योतिषी श्रेणी", "ta_IN": "ஜோதிடர் வகை", "te_IN": "జ్యోతిష్కుడు వర్గం", "mr_IN": "ज्योतिषी श्रेणी", "gu_IN": "જ્યોતિષી શ્રેણી", "kn_IN": "ಜ್ಯೋತಿಷಿ ವರ್ಗ", "ml_IN": "ജ്യോതിഷ വിഭാഗം", "en_US": "Astrologer category"
    },
    "Category": {
        "bn_IN": "বিভাগ", "hi_IN": "श्रेणी", "ta_IN": "வகை", "te_IN": "వర్గం", "mr_IN": "श्रेणी", "gu_IN": "શ્રેણી", "kn_IN": "ವರ್ಗ", "ml_IN": "വിഭാഗം", "en_US": "Category"
    },
    "Primary Skills": {
        "bn_IN": "প্রাথমিক দক্ষতা", "hi_IN": "प्राथमिक कौशल", "ta_IN": "முதன்மை திறன்கள்", "te_IN": "ప్రాథమిక నైపుణ్యాలు", "mr_IN": "प्राथमिक कौशल्य", "gu_IN": "પ્રાથમિક કૌશલ્યો", "kn_IN": "ಪ್ರಾಥಮಿಕ ಕೌಶಲ್ಯಗಳು", "ml_IN": "പ്രാഥമിക കഴിവുകൾ", "en_US": "Primary Skills"
    },
    "All Skills": {
        "bn_IN": "সমস্ত দক্ষতা", "hi_IN": "सभी कौशल", "ta_IN": "அனைத்து திறன்கள்", "te_IN": "అన్ని నైపుణ్యాలు", "mr_IN": "सर्व कौशल्ये", "gu_IN": "તમામ કૌશલ્યો", "kn_IN": "ಎಲ್ಲಾ ಕೌಶಲ್ಯಗಳು", "ml_IN": "എല്ലാ കഴിവുകളും", "en_US": "All Skills"
    },
    "Skill": {
        "bn_IN": "দক্ষতা", "hi_IN": "कौशल", "ta_IN": "திறன்", "te_IN": "నైపుణ్యం", "mr_IN": "कौशल्य", "gu_IN": "કૌશલ્ય", "kn_IN": "ಕೌಶಲ್ಯ", "ml_IN": "നൈപുണ്യം", "en_US": "Skill"
    },
    "Language": {
        "bn_IN": "ভাষা", "hi_IN": "भाषा", "ta_IN": "மொழி", "te_IN": "భాష", "mr_IN": "भाषा", "gu_IN": "ભાષા", "kn_IN": "ಭಾಷೆ", "ml_IN": "ഭാഷ", "en_US": "Language"
    },
    "Experience In Years": {
        "bn_IN": "বছরের অভিজ্ঞতা", "hi_IN": "वर्षों का अनुभव", "ta_IN": "ஆண்டுகளில் அனுபவம்", "te_IN": "సంవత్సరాల అనుభవం", "mr_IN": "वर्षांचा अनुभव", "gu_IN": "વર્ષોનો અનુભવ", "kn_IN": "ವರ್ಷಗಳ ಅನುಭವ", "ml_IN": "വർഷങ്ങളിലെ പരിചയം", "en_US": "Experience In Years"
    },
    "Experience": {
        "bn_IN": "অভিজ্ঞতা", "hi_IN": "अनुभव", "ta_IN": "அனுபவம்", "te_IN": "అనుభవం", "mr_IN": "अनुभव", "gu_IN": "અનુભવ", "kn_IN": "ಅನುಭವ", "ml_IN": "പരിചയം", "en_US": "Experience"
    },
    "Additional Information": {
        "bn_IN": "অতিরিক্ত তথ্য", "hi_IN": "अतिरिक्त जानकारी", "ta_IN": "கூடுதல் தகவல்", "te_IN": "అదనపు సమాచారం", "mr_IN": "अतिरिक्त माहिती", "gu_IN": "વધારાની માહિતી", "kn_IN": "ಹೆಚ್ಚುವರಿ ಮಾಹಿತಿ", "ml_IN": "കൂടുതൽ വിവരങ്ങൾ", "en_US": "Additional Information"
    },
    "Daily Contribution Hours": {
        "bn_IN": "দৈনিক অবদানের সময়", "hi_IN": "दैनिक योगदान के घंटे", "ta_IN": "தினசரி பங்களிப்பு நேரம்", "te_IN": "రోజువారీ సహకారం గంటలు", "mr_IN": "दैनिक योगदानाचे तास", "gu_IN": "દૈનિક યોગદાન કલાકો", "kn_IN": "ದೈನಂದಿನ ಕೊಡುಗೆ ಗಂಟೆಗಳು", "ml_IN": "പ്രതിദിന സംഭാവന സമയം", "en_US": "Daily Contribution Hours"
    },
    "Contribution Hours": {
        "bn_IN": "অবদানের সময়", "hi_IN": "योगदान के घंटे", "ta_IN": "பங்களிப்பு நேரம்", "te_IN": "సహకార గంటలు", "mr_IN": "योगदानाचे तास", "gu_IN": "યોગદાન કલાકો", "kn_IN": "ಕೊಡುಗೆ ಗಂಟೆಗಳು", "ml_IN": "സംഭാവന സമയം", "en_US": "Contribution Hours"
    },
    "How did you hear about us?": {
        "bn_IN": "আপনি আমাদের সম্পর্কে কীভাবে জানলেন?", "hi_IN": "आपने हमारे बारे में कैसे सुना?", "ta_IN": "எங்களைப் பற்றி எப்படி அறிந்தீர்கள்?", "te_IN": "మీరు మా గురించి ఎలా తెలుసుకున్నారు?", "mr_IN": "तुम्ही आमच्याबद्दल कसे ऐकले?", "gu_IN": "તમે અમારા વિશે કેવી રીતે જાણ્યું?", "kn_IN": "ನೀವು ನಮ್ಮ ಬಗ್ಗೆ ಹೇಗೆ ತಿಳಿದುಕೊಂಡಿರಿ?", "ml_IN": "ഞങ്ങളെക്കുറിച്ച് നിങ്ങൾ എങ്ങനെ അറിഞ്ഞു?", "en_US": "How did you hear about us?"
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

print("Translations updated successfully.")
