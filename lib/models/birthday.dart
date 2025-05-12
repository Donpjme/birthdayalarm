class Birthday {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String? notes;
  final String? phoneNumber;

  String get fullName => '$firstName $lastName'.trim();

  Birthday({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.notes,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'notes': notes,
      'phoneNumber': phoneNumber,
    };
  }

  factory Birthday.fromMap(Map<String, dynamic> map) {
    return Birthday(
      id: map['id'] as int?,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      notes: map['notes'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
    );
  }
}