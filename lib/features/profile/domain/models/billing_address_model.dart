class BillingAddressModel {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String invoiceName;

  BillingAddressModel({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.invoiceName,
  });

  factory BillingAddressModel.fromJson(Map<String, dynamic> json) {
    return BillingAddressModel(
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? '',
      invoiceName: json['invoice_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'invoice_name': invoiceName,
    };
  }
}
