class Users {
  String uid;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String adresse;
  String img;
  String role;

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
