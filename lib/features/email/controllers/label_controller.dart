import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';

class LabelController {
  final CollectionReference _labelsRef = FirebaseFirestore.instance.collection('labels');
  final AuthService _authService = AuthService();
  String? uid; // UID của người dùng hiện tại
  String? email; // Email của người dùng hiện tại (vẫn giữ để tham khảo)

  LabelController() {
    // Không gọi _initializeUserData trong constructor nữa
  }

  Future<void> initializeUserData() async {
    final userProfile = await _authService.currentUser;
    uid = userProfile?.uid ?? 'default_uid'; // Fallback nếu không có UID
    email = userProfile?.email ?? 'default@example.com'; // Fallback nếu không có email
    print('Initialized user data for labels: UID=$uid, Email=$email');
  }

  // Tải danh sách nhãn từ Firestore, chỉ lấy nhãn của UID hiện tại
  Future<List<String>> loadLabels() async {
    await initializeUserData(); // Đảm bảo UID được khởi tạo
    if (uid == 'default_uid') {
      print('No user logged in, returning empty labels');
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _labelsRef
          .where('uid', isEqualTo: uid)
          .get();
      final labels = snapshot.docs.map((doc) => doc['name'] as String).toList();
      print('Loaded labels for UID $uid: $labels');
      return labels;
    } catch (e) {
      print('Lỗi khi tải nhãn: $e');
      return [];
    }
  }

  // Kiểm tra xem nhãn đã tồn tại chưa cho UID hiện tại
  Future<bool> doesLabelExist(String labelName) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    final QuerySnapshot snapshot = await _labelsRef
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
      print('Cannot save label: No user logged in');
      return false;
    }
    try {
      if (await doesLabelExist(label)) {
        print('Label already exists: $label');
        return false; // Nhãn đã tồn tại
      }
      await _labelsRef.add({
        'name': label,
        'uid': uid, // Sử dụng UID để phân quyền
        'email': email, // Lưu email để tham khảo (tùy chọn)
      });
      print('Saved label: $label for UID: $uid');
      return true;
    } catch (e) {
      print('Lỗi khi lưu nhãn: $e');
      return false;
    }
  }

  // Cập nhật nhãn trong Firestore
  Future<bool> updateLabel(String oldLabel, String newLabel) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    try {
      if (await doesLabelExist(newLabel)) {
        print('New label already exists: $newLabel');
        return false; // Nhãn mới đã tồn tại
      }
      final QuerySnapshot snapshot = await _labelsRef
          .where('uid', isEqualTo: uid)
          .where('name', isEqualTo: oldLabel)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).update({'name': newLabel});
        print('Updated label from $oldLabel to $newLabel for UID: $uid');
        return true;
      }
      print('Label not found: $oldLabel');
      return false;
    } catch (e) {
      print('Lỗi khi cập nhật nhãn: $e');
      return false;
    }
  }

  // Xóa nhãn khỏi Firestore
  Future<bool> deleteLabel(String label) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    try {
      final QuerySnapshot snapshot = await _labelsRef
          .where('uid', isEqualTo: uid)
          .where('name', isEqualTo: label)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).delete();
        print('Deleted label: $label for UID: $uid');
        return true;
      }
      print('Label not found: $label');
      return false;
    } catch (e) {
      print('Lỗi khi xóa nhãn: $e');
      return false;
    }
  }
}
