class UserModel {
  final int? id;
  final String username;
  final String password;
  final String? nama;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    this.nama,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        username: map['username'],
        password: map['password'],
        nama: map['nama'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'nama': nama,
      };
}