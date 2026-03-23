class AstrologerSkillsModel {
  final String category;
  final List<String> primarySkills;
  final List<String> allSkills;
  final List<String> languages;
  final int experienceYears;
  final int dailyContributionHours;
  final String heardAbout;

  AstrologerSkillsModel({
    required this.category,
    required this.primarySkills,
    required this.allSkills,
    required this.languages,
    required this.experienceYears,
    required this.dailyContributionHours,
    required this.heardAbout,
  });

  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "primary_skills": primarySkills,
      "all_skills": allSkills,
      "languages": languages,
      "experience_years": experienceYears,
      "daily_contribution_hours": dailyContributionHours,
      "heard_about": heardAbout,
    };
  }

  factory AstrologerSkillsModel.fromJson(Map<String, dynamic> json) {
    return AstrologerSkillsModel(
      category: json['category'],
      primarySkills: List<String>.from(json['primary_skills']),
      allSkills: List<String>.from(json['all_skills']),
      languages: List<String>.from(json['languages']),
      experienceYears: json['experience_years'],
      dailyContributionHours: json['daily_contribution_hours'],
      heardAbout: json['heard_about'],
    );
  }
}