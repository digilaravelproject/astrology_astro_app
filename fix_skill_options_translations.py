import json
import glob
import os

translations = {
    "Vedic": {
        "bn_IN": "বৈদিক", "hi_IN": "वैदिक", "ta_IN": "வேத", "te_IN": "వేద", "mr_IN": "वैदिक", "gu_IN": "વૈદિક", "kn_IN": "ವೈದಿಕ", "ml_IN": "വേദ", "en_US": "Vedic"
    },
    "Tarot": {
        "bn_IN": "ট্যারো", "hi_IN": "टैरो", "ta_IN": "டாரோட்", "te_IN": "టారో", "mr_IN": "टॅरो", "gu_IN": "ટેરોટ", "kn_IN": "ಟ್ಯಾರೋ", "ml_IN": "ടാരറ്റ്", "en_US": "Tarot"
    },
    "Numerology": {
        "bn_IN": "সংখ্যাতত্ত্ব", "hi_IN": "अंक ज्योतिष", "ta_IN": "எண் கணிதம்", "te_IN": "సంఖ్యాశాస్త్రం", "mr_IN": "अंकशास्त्र", "gu_IN": "અંકશાસ્ત્ર", "kn_IN": "ಸಂಖ್ಯಾಶಾಸ್ತ್ರ", "ml_IN": "സംഖ്യാശാസ്ത്രം", "en_US": "Numerology"
    },
    "Palmistry": {
        "bn_IN": "হস্তরেখাবিদ্যা", "hi_IN": "हस्तरेखा", "ta_IN": "கைரேகை", "te_IN": "హస్తసాముద్రికం", "mr_IN": "हस्तरेषा", "gu_IN": "હસ્તરેખા", "kn_IN": "ಹಸ್ತಸಾಮುದ್ರಿಕ", "ml_IN": "കൈനോട്ടം", "en_US": "Palmistry"
    },
    "Vastu": {
        "bn_IN": "বাস্তু", "hi_IN": "वास्तु", "ta_IN": "வாஸ்து", "te_IN": "వాస్తు", "mr_IN": "वास्तु", "gu_IN": "વાસ્તુ", "kn_IN": "ವಾಸ್ತು", "ml_IN": "വാസ്തു", "en_US": "Vastu"
    },
    "Prashna": {
        "bn_IN": "প্রশ্ন", "hi_IN": "प्रश्न", "ta_IN": "பிரஷ்னா", "te_IN": "ప్రశ్న", "mr_IN": "प्रश्न", "gu_IN": "પ્રશ્ન", "kn_IN": "ಪ್ರಶ್ನೆ", "ml_IN": "പ്രശ്ന", "en_US": "Prashna"
    },
    "Kundli": {
        "bn_IN": "কুণ্ডলী", "hi_IN": "कुंडली", "ta_IN": "ஜாதகம்", "te_IN": "కుండలి", "mr_IN": "कुंडली", "gu_IN": "કુંડળી", "kn_IN": "ಕುಂಡಲಿ", "ml_IN": "കുണ്ഡലി", "en_US": "Kundli"
    },
    "Match Making": {
        "bn_IN": "ম্যাচ মেকিং", "hi_IN": "मैच मेकिंग", "ta_IN": "பொருத்தம் பார்த்தல்", "te_IN": "మ్యాచ్ మేకింగ్", "mr_IN": "मॅच मेकिंग", "gu_IN": "મેચ મેકિંગ", "kn_IN": "ಪಂದ್ಯ ತಯಾರಿಕೆ", "ml_IN": "പൊരുത്തം നോക്കൽ", "en_US": "Match Making"
    },
    "Horoscope": {
        "bn_IN": "রাশিফল", "hi_IN": "राशिफल", "ta_IN": "ராசிபலன்", "te_IN": "జాతకం", "mr_IN": "राशीभविष्य", "gu_IN": "રાશિફળ", "kn_IN": "ಜಾತಕ", "ml_IN": "ജാതകം", "en_US": "Horoscope"
    },
    "Marriage": {
        "bn_IN": "বিবাহ", "hi_IN": "विवाह", "ta_IN": "திருமணம்", "te_IN": "వివాహం", "mr_IN": "विवाह", "gu_IN": "લગ્ન", "kn_IN": "ಮದುವೆ", "ml_IN": "വിവാഹം", "en_US": "Marriage"
    },
    "Career": {
        "bn_IN": "ক্যারিয়ার", "hi_IN": "करियर", "ta_IN": "தொழில்", "te_IN": "కెరీర్", "mr_IN": "करिअर", "gu_IN": "કારકિર્દી", "kn_IN": "ವೃತ್ತಿ", "ml_IN": "കരിയർ", "en_US": "Career"
    },
    "Love": {
        "bn_IN": "প্রেম", "hi_IN": "प्रेम", "ta_IN": "காதல்", "te_IN": "ప్రేమ", "mr_IN": "प्रेम", "gu_IN": "પ્રેમ", "kn_IN": "ಪ್ರೀತಿ", "ml_IN": "സ്നേഹം", "en_US": "Love"
    },
    "Health": {
        "bn_IN": "স্বাস্থ্য", "hi_IN": "स्वास्थ्य", "ta_IN": "சுகாதாரம்", "te_IN": "ఆరోగ్యం", "mr_IN": "आरोग्य", "gu_IN": "સ્વાસ્થ્ય", "kn_IN": "ಆರೋಗ್ಯ", "ml_IN": "ആരോഗ്യം", "en_US": "Health"
    },
    "Finance": {
        "bn_IN": "অর্থসংস্থান", "hi_IN": "वित्त", "ta_IN": "நிதி", "te_IN": "ఆర్థికం", "mr_IN": "वित्त", "gu_IN": "નાણાં", "kn_IN": "ಹಣಕಾಸು", "ml_IN": "സാമ്പത്തികം", "en_US": "Finance"
    },
    "Education": {
        "bn_IN": "শিক্ষা", "hi_IN": "शिक्षा", "ta_IN": "கல்வி", "te_IN": "విద్య", "mr_IN": "शिक्षण", "gu_IN": "શિક્ષણ", "kn_IN": "ಶಿಕ್ಷಣ", "ml_IN": "വിദ്യാഭ്യാസം", "en_US": "Education"
    },
    "Childbirth": {
        "bn_IN": "সন্তান প্রসব", "hi_IN": "प्रसव", "ta_IN": "பிரசவம்", "te_IN": "ప్రసవం", "mr_IN": "बाळंतपण", "gu_IN": "બાળજન્મ", "kn_IN": "ಹೆರಿಗೆ", "ml_IN": "പ്രസവം", "en_US": "Childbirth"
    },
    "Legal": {
        "bn_IN": "আইনগত", "hi_IN": "कानूनी", "ta_IN": "சட்ட", "te_IN": "చట్టపరమైన", "mr_IN": "कायदेशीर", "gu_IN": "કાનૂની", "kn_IN": "ಕಾನೂನು", "ml_IN": "നിയമപരമായ", "en_US": "Legal"
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

print("Options translations updated successfully.")
