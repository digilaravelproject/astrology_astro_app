class MatchingRequestModel {
  final PersonDetails male;
  final PersonDetails female;

  MatchingRequestModel({
    required this.male,
    required this.female,
  });

  Map<String, dynamic> toJson() {
    return {
      'male': male.toJson(),
      'female': female.toJson(),
    };
  }
}

class PersonDetails {
  final String datetime;
  final double latitude;
  final double longitude;
  final String timezone;

  PersonDetails({
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }
}
