import 'package:spmb_app/data/database/database_helper.dart';
import 'package:spmb_app/data/models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<UserModel?> login(String username, String password) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }
}