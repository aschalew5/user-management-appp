class Users {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String adresse;
  final String img;
  final String role;

  Users({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.adresse,
    required this.img,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'adresse': adresse,
        'img': img,
        'role': role,
      };

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      uid: json['uid'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      adresse: json['adresse'] ?? '',
      img: json['img'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}
