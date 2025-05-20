import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';

class LabelController {
  // Email của người dùng hiện tại (vẫn giữ để tham khảo)

  LabelController() {
    // Không gọi _initializeUserData trong constructor nữa
  }
  final CollectionReference _labelsRef = FirebaseFirestore.instance.collection(
    'labels',
  );
  final AuthService _authService = AuthService();
  String? uid; // UID của người dùng hiện tại
  String? email;

  Future<void> initializeUserData() async {
    final userProfile = await _authService.currentUser;
    uid = userProfile?.uid ?? 'default_uid'; // Fallback nếu không có UID
    email =
        userProfile?.email ??
        'default@example.com'; // Fallback nếu không có emai
    AppFunctions.debugPrint(
      'Initialized user data for labels: UID=$uid, Email=$email',
    );
  }

  // Tải danh sách nhãn từ Firestore, chỉ lấy nhãn của UID hiện tại
  Future<List<String>> loadLabels() async {
    await initializeUserData(); // Đảm bảo UID được khởi tạo
    if (uid == 'default_uid') {
      AppFunctions.debugPrint('No user logged in, returning empty labels');
      return [];
    }
    try {
      final snapshot = await _labelsRef.where('uid', isEqualTo: uid).get();
      final labels = snapshot.docs.map((doc) => doc['name'] as String).toList();
      AppFunctions.debugPrint('Loaded labels for UID $uid: $labels');
      return labels;
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi tải nhãn: $e');
      return [];
    }
  }

  // Kiểm tra xem nhãn đã tồn tại chưa cho UID hiện tại
  Future<bool> doesLabelExist(String labelName) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    final snapshot =
        await _labelsRef
            .where('uid', isEqualTo: uid)
            .where('name', isEqualTo: labelName)
            .limit(1)
            .get();
    return snapshot.docs.isNotEmpty;
  }

  // Lưu nhãn mới vào Firestore
  Future<bool> saveLabel(String label) async {
    await initializeUserData();
    if (uid == 'default_uid') {
      AppFunctions.debugPrint('Cannot save label: No user logged in');
      return false;
    }
    try {
      if (await doesLabelExist(label)) {
        AppFunctions.debugPrint('Label already exists: $label');
        return false; // Nhãn đã tồn tại
      }
      await _labelsRef.add({
        'name': label,
        'uid': uid, // Sử dụng UID để phân quyền
        'email': email, // Lưu email để tham khảo (tùy chọn)
      });
      AppFunctions.debugPrint('Saved label: $label for UID: $uid');
      return true;
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi lưu nhãn: $e');
      return false;
    }
  }

  // Cập nhật nhãn trong Firestore
  Future<bool> updateLabel(String oldLabel, String newLabel) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    try {
      if (await doesLabelExist(newLabel)) {
        AppFunctions.debugPrint('New label already exists: $newLabel');
        return false; // Nhãn mới đã tồn tại
      }
      final snapshot =
          await _labelsRef
              .where('uid', isEqualTo: uid)
              .where('name', isEqualTo: oldLabel)
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).update({'name': newLabel});
        AppFunctions.debugPrint(
          'Updated label from $oldLabel to $newLabel for UID: $uid',
        );
        return true;
      }
      AppFunctions.debugPrint('Label not found: $oldLabel');
      return false;
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi cập nhật nhãn: $e');
      return false;
    }
  }

  // Xóa nhãn khỏi Firestore
  Future<bool> deleteLabel(String label) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    try {
      final snapshot =
          await _labelsRef
              .where('uid', isEqualTo: uid)
              .where('name', isEqualTo: label)
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).delete();
        AppFunctions.debugPrint('Deleted label: $label for UID: $uid');
        return true;
      }
      AppFunctions.debugPrint('Label not found: $label');
      return false;
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi xóa nhãn: $e');
      return false;
    }
  }
}
