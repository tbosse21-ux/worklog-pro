class Company {
  final int? id;

  final String companyName;
  final String contactPerson;
  final String street;
  final String zipCode;
  final String city;
  final String phone;
  final String mobile;
  final String email;
  final String website;
  final String logoPath;

  Company({
    this.id,
    required this.companyName,
    required this.contactPerson,
    required this.street,
    required this.zipCode,
    required this.city,
    required this.phone,
    required this.mobile,
    required this.email,
    required this.website,
    required this.logoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'street': street,
      'zipCode': zipCode,
      'city': city,
      'phone': phone,
      'mobile': mobile,
      'email': email,
      'website': website,
      'logoPath': logoPath,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      companyName: map['companyName'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      street: map['street'] ?? '',
      zipCode: map['zipCode'] ?? '',
      city: map['city'] ?? '',
      phone: map['phone'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      logoPath: map['logoPath'] ?? '',
    );
  }
}
