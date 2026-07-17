class HouseCuspsModel {
  final bool success;
  final List<HouseCuspData>? data;

  HouseCuspsModel({required this.success, this.data});

  factory HouseCuspsModel.fromJson(Map<String, dynamic> json) {
    return HouseCuspsModel(
      success: json['success'] ?? false,
      data: json['data'] != null 
          ? (json['data'] as List).map((i) => HouseCuspData.fromJson(i)).toList() 
          : null,
    );
  }
}

class HouseCuspData {
  final int? number;
  final String? sign;
  final int? signNumber;
  final num? cusp;
  final num? degree;

  HouseCuspData({
    this.number, 
    this.sign, 
    this.signNumber, 
    this.cusp, 
    this.degree
  });

  factory HouseCuspData.fromJson(Map<String, dynamic> json) {
    return HouseCuspData(
      number: json['number'],
      sign: json['sign'],
      signNumber: json['signNumber'],
      cusp: json['cusp'],
      degree: json['degree'],
    );
  }
}
