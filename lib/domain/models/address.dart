class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.details,
    required this.area,
    required this.city,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: (json['id'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      details: (json['details'] as String?) ?? '',
      area: (json['area'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
    );
  }

  final String id;
  final String label;
  final String details;
  final String area;
  final String city;

  String get shortAddress => _joinNonEmpty([area, city]);

  String get fullAddress => _joinNonEmpty([details, area, city]);

  SavedAddress copyWith({
    String? label,
    String? details,
    String? area,
    String? city,
  }) {
    return SavedAddress(
      id: id,
      label: label ?? this.label,
      details: details ?? this.details,
      area: area ?? this.area,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'details': details,
    'area': area,
    'city': city,
  };

  @override
  bool operator ==(Object other) =>
      other is SavedAddress &&
      other.id == id &&
      other.label == label &&
      other.details == details &&
      other.area == area &&
      other.city == city;

  @override
  int get hashCode => Object.hash(id, label, details, area, city);

  static String _joinNonEmpty(List<String> parts) {
    return parts
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(', ');
  }
}
