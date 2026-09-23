class UserModel {
  final String uid;
  final String email;
  final String companyName;
  final String mobile;
  final String plan;

  UserModel({
    required this.uid,
    required this.email,
    required this.companyName,
    required this.mobile,
    required this.plan,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'companyName': companyName,
      'mobile': mobile,
      'plan': plan,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      companyName: map['companyName'] ?? '',
      mobile: map['mobile'] ?? '',
      plan: map['plan'] ?? 'Free',
    );
  }
}
