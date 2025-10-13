class Profile {
  final String name;
  final String email;
  final String currency;
  final double budget;

  Profile({
    required this.name,
    required this.email,
    required this.currency,
    required this.budget,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'],
      email: json['email'],
      currency: json['currency'],
      budget: json['budget'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'currency': currency,
      'budget': budget,
    };
  }
}