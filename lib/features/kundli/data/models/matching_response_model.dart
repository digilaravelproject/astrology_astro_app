class MatchingResponseModel {
  final bool success;
  final MatchingData data;
  final BillingInfo billing;
  final MetaInfo meta;

  MatchingResponseModel({
    required this.success,
    required this.data,
    required this.billing,
    required this.meta,
  });

  factory MatchingResponseModel.fromJson(Map<String, dynamic> json) {
    final hasRootData =
        json.containsKey('total') ||
        json.containsKey('conclusion') ||
        json.containsKey('varna');
    return MatchingResponseModel(
      success: json['success'] ?? hasRootData,
      data: MatchingData.fromJson(json['data'] ?? json),
      billing: BillingInfo.fromJson(json['billing'] ?? {}),
      meta: MetaInfo.fromJson(json['meta'] ?? {}),
    );
  }
}

class MatchingData {
  final double compatibilityScore;
  final int maxScore;
  final double percentage;
  final String verdict;
  final String recommendation;
  final GunaMilan gunaMilan;
  final Doshas doshas;
  final PersonAstrologyInfo? maleInfo;
  final PersonAstrologyInfo? femaleInfo;
  final String summary;
  final List<String> strengths;
  final List<String> challenges;

  MatchingData({
    required this.compatibilityScore,
    required this.maxScore,
    required this.percentage,
    required this.verdict,
    required this.recommendation,
    required this.gunaMilan,
    required this.doshas,
    this.maleInfo,
    this.femaleInfo,
    this.summary = '',
    this.strengths = const [],
    this.challenges = const [],
  });

  factory MatchingData.fromJson(Map<String, dynamic> json) {
    final totalPoints =
        (json['total']?['received_points'] ??
                json['total_points'] ??
                json['compatibility_score'] ??
                0)
            .toDouble();
    final maxPts =
        (json['total']?['total_points'] ??
                    json['maximum_points'] ??
                    json['max_score'] ??
                    36)
                is int
            ? (json['total']?['total_points'] ??
                    json['maximum_points'] ??
                    json['max_score'] ??
                    36)
                as int
            : ((json['total']?['total_points'] ??
                        json['maximum_points'] ??
                        json['max_score'] ??
                        36)
                    as num)
                .toInt();
    final pct =
        (json['percentage'] ?? (maxPts > 0 ? (totalPoints / maxPts * 100) : 0))
            .toDouble();
    final ver =
        json['conclusion']?['report'] ??
        json['match_result'] ??
        json['verdict'] ??
        '';
    final rec = json['recommendation'] ?? '';

    final interp = json['interpretation'] as Map<String, dynamic>? ?? {};
    final summaryText = interp['summary'] ?? interp['marriageProspects'] ?? '';
    List<String> strList = [];
    if (interp['strengths'] is List) {
      strList = List<String>.from(interp['strengths'].map((s) => s.toString()));
    }
    List<String> chalList = [];
    if (interp['challenges'] is List) {
      chalList = List<String>.from(
        interp['challenges'].map((c) => c.toString()),
      );
    }

    return MatchingData(
      compatibilityScore: totalPoints,
      maxScore: maxPts,
      percentage: pct,
      verdict: ver,
      recommendation: rec,
      gunaMilan: GunaMilan.fromJson(
        json['gunaDetails'] ?? json['guna_milan'] ?? json,
      ),
      doshas: Doshas.fromJson(json['doshas'] ?? {}, parentJson: json),
      maleInfo:
          json['male_info'] != null
              ? PersonAstrologyInfo.fromJson(json['male_info'])
              : null,
      femaleInfo:
          json['female_info'] != null
              ? PersonAstrologyInfo.fromJson(json['female_info'])
              : null,
      summary: summaryText,
      strengths: strList,
      challenges: chalList,
    );
  }
}

class GunaMilan {
  final GunaDetail varna;
  final GunaDetail vashya;
  final GunaDetail tara;
  final GunaDetail yoni;
  final GunaDetail grahaMaitri;
  final GunaDetail gana;
  final GunaDetail bhakoot;
  final GunaDetail nadi;

  GunaMilan({
    required this.varna,
    required this.vashya,
    required this.tara,
    required this.yoni,
    required this.grahaMaitri,
    required this.gana,
    required this.bhakoot,
    required this.nadi,
  });

  factory GunaMilan.fromJson(Map<String, dynamic> json) {
    return GunaMilan(
      varna: GunaDetail.fromJson(json['varna'] ?? {}, 'varna'),
      vashya: GunaDetail.fromJson(
        json['vasya'] ?? json['vashya'] ?? {},
        'vashya',
      ),
      tara: GunaDetail.fromJson(json['tara'] ?? {}, 'tara'),
      yoni: GunaDetail.fromJson(json['yoni'] ?? {}, 'yoni'),
      grahaMaitri: GunaDetail.fromJson(
        json['grahaMaitri'] ?? json['graha_maitri'] ?? json['maitri'] ?? {},
        'grahamaitri',
      ),
      gana: GunaDetail.fromJson(json['gana'] ?? json['gan'] ?? {}, 'gana'),
      bhakoot: GunaDetail.fromJson(
        json['bhakoot'] ?? json['bhakut'] ?? {},
        'bhakoot',
      ),
      nadi: GunaDetail.fromJson(json['nadi'] ?? {}, 'nadi'),
    );
  }

  Map<String, GunaDetail> toMap() {
    return {
      'varna': varna,
      'vashya': vashya,
      'tara': tara,
      'yoni': yoni,
      'graha_maitri': grahaMaitri,
      'gana': gana,
      'bhakoot': bhakoot,
      'nadi': nadi,
    };
  }
}

class PersonAstrologyInfo {
  final String moonNakshatra;
  final String moonSign;

  PersonAstrologyInfo({required this.moonNakshatra, required this.moonSign});

  factory PersonAstrologyInfo.fromJson(Map<String, dynamic> json) {
    return PersonAstrologyInfo(
      moonNakshatra: json['moon_nakshatra'] ?? json['nakshatra'] ?? '',
      moonSign: json['moon_sign'] ?? json['sign'] ?? '',
    );
  }
}

class GunaDetail {
  final dynamic score; // Can be int or double
  final int max;
  final String description;
  final String significance;
  final List<String> tips;
  final String maleKootAttribute;
  final String femaleKootAttribute;

  GunaDetail({
    required this.score,
    required this.max,
    required this.description,
    this.significance = '',
    this.tips = const [],
    this.maleKootAttribute = '',
    this.femaleKootAttribute = '',
  });

  static String getStaticSignificance(String gunaName) {
    switch (gunaName.toLowerCase()) {
      case 'varna':
        return 'Represents the spiritual compatibility, work inclination, and ego alignment between the couple. It ensures both partners share similar values towards responsibilities and growth.';
      case 'vashya':
      case 'vasya':
        return 'Measures mutual attraction, control, and the power dynamic in the relationship. It determines who will dominate or influence the decision-making process.';
      case 'tara':
        return 'Reflects the compatibility of birth stars (Nakshatras), representing destiny, longevity, health, and mutual luck/prosperity for both partners.';
      case 'yoni':
        return 'Assesses physical compatibility, sexual attraction, and biological affinity. It is essential for nurturing intimacy, passion, and physical satisfaction.';
      case 'grahamaitri':
      case 'maitri':
        return 'Evaluates the friendship between the ruling lords of the Moon signs (Rashis). This indicates mental compatibility, intellectual harmony, and general understanding.';
      case 'gana':
      case 'gan':
        return 'Analyzes the temperament category (Deva/Divine, Manushya/Human, Rakshasa/Demonic) of both partners to predict behavioral patterns and how they handle life situations.';
      case 'bhakoot':
      case 'bhakut':
        return 'Represents emotional compatibility, financial prosperity, and overall success of family life. A strong Bhakoot compatibility ensures happiness and growth.';
      case 'nadi':
        return 'Measures genetic compatibility, nervous system compatibility, and progeny (children) health. Nadi is the most crucial match factor (worth 8 points) in Ashtakoota.';
      default:
        return '';
    }
  }

  static List<String> getStaticTips(String gunaName, double score, int max) {
    final isLow = score < (max / 2.0);
    switch (gunaName.toLowerCase()) {
      case 'varna':
        return isLow
            ? [
              'Develop mutual respect and value each other’s career paths and contributions.',
              'Avoid ego clashes and dividing duties rigidly; practice shared responsibility.',
            ]
            : [
              'Continue to support each other’s personal growth and aspirations.',
              'Keep the channels of mutual appreciation open to maintain ego alignment.',
            ];
      case 'vashya':
      case 'vasya':
        return isLow
            ? [
              'Build equality in decision-making to prevent feelings of being dominated.',
              'Avoid manipulative behaviors and give each other personal space.',
            ]
            : [
              'Nurture the strong natural attraction you share to keep the relationship vibrant.',
              'Ensure mutual respect remains high alongside your close influence.',
            ];
      case 'tara':
        return isLow
            ? [
              'Be supportive during times of low energy or minor health issues.',
              'Consider performing wellness practices or prayers to resolve malefic nakshatra effects.',
            ]
            : [
              'Capitalize on your mutual luck to plan and achieve long-term goals together.',
              'Celebrate milestones together to boost positive energy in the household.',
            ];
      case 'yoni':
        return isLow
            ? [
              'Practice patience and open communication regarding physical needs and preferences.',
              'Build strong emotional intimacy first, as it helps bridge physical compatibility gaps.',
            ]
            : [
              'Maintain your active spark and check in on each other\'s needs regularly.',
              'Ensure deep emotional bonding accompanies your physical connection.',
            ];
      case 'grahamaitri':
      case 'maitri':
        return isLow
            ? [
              'Spend time in activities that require sharing thoughts, such as reading or traveling.',
              'Learn to listen actively without judgment, treating your partner as your best friend.',
            ]
            : [
              'Maintain your great conversational chemistry; talk through conflicts easily.',
              'Engage in shared hobbies and intellectual discussions to keep the bond active.',
            ];
      case 'gana':
      case 'gan':
        return isLow
            ? [
              'Accept differences in behavior without trying to force your partner to change.',
              'Avoid critical remarks during disagreements; take time to cool down before discussing.',
            ]
            : [
              'Enjoy your harmonious temperament and use it to easily resolve daily challenges.',
              'Keep practicing empathy and keep minor habits from escalating.',
            ];
      case 'bhakoot':
      case 'bhakut':
        return isLow
            ? [
              'Formulate a collaborative financial plan and avoid keeping financial secrets.',
              'Support each other’s families and focus on building emotional resilience together.',
            ]
            : [
              'Use your financial compatibility to make smart investments for your future.',
              'Maintain a positive, nurturing home environment for family happiness.',
            ];
      case 'nadi':
        return isLow
            ? [
              'Consult a medical practitioner or doctor for genetic counseling if planning a family.',
              'Focus on stress-reducing activities, healthy nutrition, and a balanced lifestyle.',
            ]
            : [
              'Focus on maintaining a healthy, active lifestyle to support overall wellness.',
              'Enjoy a naturally compatible constitution and genetic harmony.',
            ];
      default:
        return [];
    }
  }

  factory GunaDetail.fromJson(Map<String, dynamic> json, String gunaName) {
    List<String> tipsList = [];
    if (json['tips'] is List) {
      tipsList = List<String>.from(
        (json['tips'] as List).map((t) => t.toString()),
      );
    }

    final scoreValue =
        json['received_points'] ??
        json['obtained_points'] ??
        json['score'] ??
        0;
    final double receivedScore =
        scoreValue is num ? scoreValue.toDouble() : 0.0;
    final int maxPoints =
        json['total_points'] ?? json['maxPoints'] ?? json['max'] ?? 0;

    final sig = json['significance']?.toString() ?? '';
    final finalSig = sig.isNotEmpty ? sig : getStaticSignificance(gunaName);

    final finalTips =
        tipsList.isNotEmpty
            ? tipsList
            : getStaticTips(gunaName, receivedScore, maxPoints);

    return GunaDetail(
      score: scoreValue,
      max: maxPoints,
      description: json['description'] ?? json['interpretation'] ?? '',
      significance: finalSig,
      tips: finalTips,
      maleKootAttribute: json['male_koot_attribute']?.toString() ?? '',
      femaleKootAttribute: json['female_koot_attribute']?.toString() ?? '',
    );
  }
}

class Doshas {
  final ManglikDosha manglik;
  final NadiDosha nadiDosha;

  Doshas({required this.manglik, required this.nadiDosha});

  factory Doshas.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? parentJson,
  }) {
    // Check if Nadi Dosha is indicated in gunaDetails['nadi'] or remedies
    bool isNadiPresent = json['nadi_dosha']?['present'] ?? false;
    if (!isNadiPresent && parentJson != null) {
      final nadiScore = parentJson['gunaDetails']?['nadi']?['score'];
      final remediesList = parentJson['remedies'] as List<dynamic>?;
      if (nadiScore != null && (nadiScore == 0 || nadiScore == 0.0)) {
        isNadiPresent = true;
      } else if (remediesList != null &&
          remediesList.any(
            (r) => r.toString().toLowerCase().contains('nadi'),
          )) {
        isNadiPresent = true;
      }
    }

    return Doshas(
      manglik: ManglikDosha.fromJson(json['manglik'] ?? {}),
      nadiDosha: NadiDosha.fromJson(
        json['nadi_dosha'] ?? {},
        overridePresent: isNadiPresent,
      ),
    );
  }
}

class ManglikDosha {
  final ManglikDetail male;
  final ManglikDetail female;

  ManglikDosha({required this.male, required this.female});

  factory ManglikDosha.fromJson(Map<String, dynamic> json) {
    return ManglikDosha(
      male: ManglikDetail.fromJson(json['male'] ?? {}),
      female: ManglikDetail.fromJson(json['female'] ?? {}),
    );
  }
}

class ManglikDetail {
  final bool present;
  final String? intensity;
  final String? cancelledBy;

  ManglikDetail({required this.present, this.intensity, this.cancelledBy});

  factory ManglikDetail.fromJson(Map<String, dynamic> json) {
    return ManglikDetail(
      present: json['present'] ?? false,
      intensity: json['intensity'],
      cancelledBy: json['cancelled_by'],
    );
  }
}

class NadiDosha {
  final bool present;
  final String severity;
  final List<String> remedies;

  NadiDosha({
    required this.present,
    required this.severity,
    required this.remedies,
  });

  factory NadiDosha.fromJson(
    Map<String, dynamic> json, {
    bool? overridePresent,
  }) {
    return NadiDosha(
      present: overridePresent ?? (json['present'] ?? false),
      severity: json['severity'] ?? '',
      remedies:
          (json['remedies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class BillingInfo {
  final double charged;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String endpoint;
  final String category;

  BillingInfo({
    required this.charged,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.endpoint,
    required this.category,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    return BillingInfo(
      charged: (json['charged'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      endpoint: json['endpoint'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

class MetaInfo {
  final String engine;
  final String version;

  MetaInfo({required this.engine, required this.version});

  factory MetaInfo.fromJson(Map<String, dynamic> json) {
    return MetaInfo(
      engine: json['engine'] ?? '',
      version: json['version'] ?? '',
    );
  }
}
