import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';

class PhotoUtil {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final Map<String, String> _photoUrlCache = {};

  static Future<String> getPhotoUrlByEmail(String email) async {
    if (_photoUrlCache.containsKey(email)) {
      return _photoUrlCache[email]!;
    }

    try {
      final query =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final photoUrl = (data['photoUrl'] ?? '') as String;

        _photoUrlCache[email] = photoUrl;
        return photoUrl;
      }

      _photoUrlCache[email] = '';
      return '';
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lấy photoUrl cho email $email: $e');
      _photoUrlCache[email] = '';
      return '';
    }
  }

  static void clearCache() {
    _photoUrlCache.clear();
    AppFunctions.debugPrint('Đã xóa cache photoUrl');
  }
}
