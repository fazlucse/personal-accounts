class Profile {
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String photoUrl;
  final String currency;
  final double budget;

  Profile({
    required this.name,
    required this.email,
    this.phone = '',
    this.designation = '',
    this.photoUrl = '',
    required this.currency,
    required this.budget,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      currency: json['currency'] ?? 'BDT',
      budget: (json['budget'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'photoUrl': photoUrl,
      'currency': currency,
      'budget': budget,
    };
  }
}