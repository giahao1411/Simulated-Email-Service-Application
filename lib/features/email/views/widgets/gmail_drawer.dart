import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/views/settings_screen.dart';
import 'package:email_application/features/email/views/widgets/drawer_item.dart';
import 'package:flutter/material.dart';

class GmailDrawer extends StatefulWidget {
  const GmailDrawer({
    required this.currentCategory,
    required this.onCategorySelected,
    super.key,
  });

  final String currentCategory;
  final Function(String) onCategorySelected;

  @override
  _GmailDrawerState createState() => _GmailDrawerState();
}

class _GmailDrawerState extends State<GmailDrawer> {
  // Danh sách nhãn
  List<String> labels = [];

  // Tham chiếu đến collection 'labels' trong Firestore
  final CollectionReference _labelsRef = FirebaseFirestore.instance.collection(
    'labels',
  );

  @override
  void initState() {
    super.initState();
    _loadLabels(); // Tải nhãn khi widget được khởi tạo
  }

  // Tải danh sách nhãn từ Firestore
  Future<void> _loadLabels() async {
    try {
      final QuerySnapshot snapshot = await _labelsRef.get();
      setState(() {
        labels = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Lỗi khi tải nhãn: $e');
    }
  }

  // Lưu nhãn mới vào Firestore
  Future<void> _saveLabel(String label) async {
    try {
      await _labelsRef.add({'name': label});
      await _loadLabels(); // Tải lại danh sách sau khi thêm
    } catch (e) {
      print('Lỗi khi lưu nhãn: $e');
    }
  }

  // Cập nhật nhãn trong Firestore
  Future<void> _updateLabel(String oldLabel, String newLabel) async {
    try {
      final QuerySnapshot snapshot =
          await _labelsRef.where('name', isEqualTo: oldLabel).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).update({'name': newLabel});
        await _loadLabels(); // Tải lại danh sách sau khi cập nhật
      }
    } catch (e) {
      print('Lỗi khi cập nhật nhãn: $e');
    }
  }

  // Xóa nhãn khỏi Firestore
  Future<void> _deleteLabel(String label) async {
    try {
      final QuerySnapshot snapshot =
          await _labelsRef.where('name', isEqualTo: label).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).delete();
        await _loadLabels(); // Tải lại danh sách sau khi xóa
      }
    } catch (e) {
      print('Lỗi khi xóa nhãn: $e');
    }
  }

  // Hiển thị tùy chọn khi nhấn giữ nhãn
  void _showLabelOptions(String label) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        child: AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Tùy chọn nhãn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white70),
                title: const Text(
                  'Đổi tên',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _renameLabel(label);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.white70),
                title: const Text(
                  'Xóa',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteLabel(label);
                },
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Căn phải
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8), // Khoảng cách nhỏ giữa nút và lề
              ],
            ),
          ],
          contentPadding: const EdgeInsets.all(16.0), // Điều chỉnh padding nội dung
          actionsPadding: const EdgeInsets.only(right: 16.0, bottom: 8.0), // Điều chỉnh padding cho actions
        ),
      ),
    );
  }

  // Đổi tên nhãn
  void _renameLabel(String oldLabel) {
    TextEditingController controller = TextEditingController(text: oldLabel);
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        child: AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Đổi tên nhãn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nhập tên mới',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty &&
                        controller.text != oldLabel) {
                      _updateLabel(oldLabel, controller.text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Lưu', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
          contentPadding: const EdgeInsets.all(16.0),
          actionsPadding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
        ),
      ),
    );
  }

  // Tạo nhãn mới
  void _createNewLabel() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        child: AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            'Tạo nhãn mới',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nhập tên nhãn',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _saveLabel(controller.text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Tạo', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
          contentPadding: const EdgeInsets.all(16.0),
          actionsPadding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      color: Colors.grey[850],
      child: Column(
        children: [
          // Header với logo Gmail
          Container(
            padding: const EdgeInsets.only(
              top: 20,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Gmail_icon_%282020%29.svg/1280px-Gmail_icon_%282020%29.svg.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  AppStrings.gmail,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          // Danh sách danh mục và nhãn
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Các danh mục chính
                DrawerItem(
                  title: AppStrings.inbox,
                  icon: Icons.inbox,
                  isSelected: widget.currentCategory == AppStrings.inbox,
                  onTap: () => widget.onCategorySelected(AppStrings.inbox),
                ),
                DrawerItem(
                  title: AppStrings.starred,
                  icon: Icons.star_border,
                  isSelected: widget.currentCategory == AppStrings.starred,
                  onTap: () => widget.onCategorySelected(AppStrings.starred),
                ),
                DrawerItem(
                  title: AppStrings.sent,
                  icon: Icons.send,
                  isSelected: widget.currentCategory == AppStrings.sent,
                  onTap: () => widget.onCategorySelected(AppStrings.sent),
                ),
                DrawerItem(
                  title: AppStrings.drafts,
                  icon: Icons.insert_drive_file,
                  isSelected: widget.currentCategory == AppStrings.drafts,
                  onTap: () => widget.onCategorySelected(AppStrings.drafts),
                ),
                DrawerItem(
                  title: AppStrings.trash,
                  icon: Icons.delete,
                  isSelected: widget.currentCategory == AppStrings.trash,
                  onTap: () => widget.onCategorySelected(AppStrings.trash),
                ),

                // Phần nhãn (Labels) chỉ hiển thị khi có nhãn
                if (labels.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Colors.grey[700],
                      height: 1,
                      thickness: 1,
                      indent: 52,
                      endIndent: 16,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('NHÃN', style: TextStyle(fontSize: 12)),
                  ),
                  
                  // Hiển thị danh sách nhãn
                  ...labels.map(
                    (label) => GestureDetector(
                      onLongPress: () => _showLabelOptions(label),
                      child: DrawerItem(
                        title: label,
                        icon: Icons.label_outline_rounded,
                        isSelected: widget.currentCategory == label,
                        onTap: () => widget.onCategorySelected(label),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    color: Colors.grey[700],
                    height: 1,
                    thickness: 1,
                    indent: 52,
                    endIndent: 16,
                  ),
                ),
                // Tùy chọn "Tạo mới" luôn hiển thị
                DrawerItem(
                  title: 'Tạo mới',
                  icon: Icons.add,
                  onTap: _createNewLabel,
                ),
                // Dòng phân cách
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    color: Colors.grey[700],
                    height: 1,
                    thickness: 1,
                    indent: 52,
                    endIndent: 16,
                  ),
                ),
                // Cài đặt
                DrawerItem(
                  title: AppStrings.settings,
                  icon: Icons.settings,
                  onTap: () {
                    widget.onCategorySelected(AppStrings.settings);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
