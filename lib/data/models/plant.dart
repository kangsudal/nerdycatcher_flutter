class Plant {
  final int? id;
  final String name;
  final String varietyCode;
  final String imagePath;
  final DateTime? createdAt;
  final DateTime? deletedAt;
  final DateTime? updatedAt;

  Plant({
    this.id,
    required this.name,
    required this.varietyCode,
    required this.imagePath,
    this.createdAt,
    this.deletedAt,
    this.updatedAt,
  });

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as int?,
      name: map['name'] as String,
      varietyCode: map['variety_code'],
      imagePath: map['image_path'] ?? '', // null 방지
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'variety_code': varietyCode,
      'image_path': imagePath,
    };
  }
}