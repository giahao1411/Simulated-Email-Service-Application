import 'dart:async';

import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/controllers/label_controller.dart';
import 'package:email_application/features/email/utils/label_dialogs.dart';
import 'package:email_application/features/email/utils/label_sorter.dart';
import 'package:email_application/features/email/views/settings_screen.dart';
import 'package:email_application/features/email/views/widgets/drawer_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late LabelController _labelController;
  final AuthService _authService = AuthService();
  List<String> labels = [];
  late Future<void> _initializeFuture;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _labelController = LabelController();
    _initializeFuture = _initializeControllerAndLoadLabels();

    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      print('Auth state changed: User ${user?.uid ?? "logged out"}');
      setState(() {
        _initializeFuture = _initializeControllerAndLoadLabels();
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeControllerAndLoadLabels() async {
    final userProfile = await _authService.currentUser;
    print(
      'Initialized LabelController with UID: ${userProfile?.uid ?? "No UID"}, Email: ${userProfile?.email ?? "No email"}',
    );
    final loadedLabels = await _labelController.loadLabels();
    // Sắp xếp danh sách nhãn
    LabelSorter.sortLabels(loadedLabels);
    setState(() {
      labels = loadedLabels;
    });
  }

  Future<void> _loadLabels() async {
    final loadedLabels = await _labelController.loadLabels();
    // Sắp xếp danh sách nhãn
    LabelSorter.sortLabels(loadedLabels);
    setState(() {
      labels = loadedLabels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi khi tải dữ liệu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.2),
                      width: 1.5,
                    ),
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
                    Text(
                      AppStrings.gmail,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
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
                      onTap:
                          () => widget.onCategorySelected(AppStrings.starred),
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

                    if (labels.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.2),
                          height: 1,
                          thickness: 1,
                          indent: 52,
                          endIndent: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'NHÃN',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      ...labels.map(
                        (label) => GestureDetector(
                          onLongPress:
                              () => LabelDialogs.showLabelOptions(
                                context,
                                label: label,
                                onDelete: _labelController.deleteLabel,
                                onRename:
                                    (oldLabel) =>
                                        LabelDialogs.showRenameLabelDialog(
                                          context,
                                          oldLabel: oldLabel,
                                          onRename:
                                              _labelController.updateLabel,
                                          onLoadLabels: _loadLabels,
                                        ),
                                onLoadLabels: _loadLabels,
                              ),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.2),
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
                      onTap:
                          () => LabelDialogs.showCreateLabelDialog(
                            context,
                            onCreate: _labelController.saveLabel,
                            onLoadLabels: _loadLabels,
                          ),
                    ),
                    // Dòng phân cách
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.2),
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
                          MaterialPageRoute<SettingsScreen>(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
