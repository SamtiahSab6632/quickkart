class Account {
  const Account({
    required this.name,
    required this.phone,
    required this.password,
    this.email = '',
    this.isGoogleAccount = false,
    this.photoBase64 = '',
  });

  final String name;
  final String phone;
  final String password;
  final String email;
  final bool isGoogleAccount;
  final String photoBase64;

  Account copyWith({
    String? name,
    String? phone,
    String? password,
    String? email,
    bool? isGoogleAccount,
    String? photoBase64,
  }) {
    return Account(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      email: email ?? this.email,
      isGoogleAccount: isGoogleAccount ?? this.isGoogleAccount,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      if (email.isNotEmpty) 'email': email,
      if (isGoogleAccount) 'isGoogle': true,
      if (photoBase64.isNotEmpty) 'photo': photoBase64,
    };
  }

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      name: (json['name'] as String?)?.trim() ?? '',
      phone: json['phone'] as String? ?? '',
      password: json['password'] as String? ?? '',
      email: (json['email'] as String?)?.trim().toLowerCase() ?? '',
      isGoogleAccount: json['isGoogle'] as bool? ?? false,
      photoBase64: json['photo'] as String? ?? '',
    );
  }
}
