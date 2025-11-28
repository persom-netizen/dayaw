class User {
  final String username;
  final String email;
  final String pangalan;  // Full name
  final String mongkahe;  // Bio

  User({
    required this.username,
    required this.email,
    this.pangalan = '',
    this.mongkahe = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      pangalan: json['pangalan'] ?? '',
      mongkahe: json['mongkahe'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'pangalan': pangalan,
      'mongkahe': mongkahe,
    };
  }

  User copyWith({
    String? username,
    String? email,
    String? pangalan,
    String? mongkahe,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      pangalan: pangalan ?? this.pangalan,
      mongkahe: mongkahe ?? this.mongkahe,
    );
  }
}
