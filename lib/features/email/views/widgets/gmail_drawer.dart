import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/views/settings_screen.dart';
import 'package:email_application/features/email/views/widgets/drawer_item.dart';
import 'package:flutter/material.dart';

class GmailDrawer extends StatelessWidget {

  const GmailDrawer({
    required this.currentCategory, required this.onCategorySelected, super.key,
  });
  final String currentCategory;
  final Function(String) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      color: Colors.grey[850],
      child: Column(
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerItem(
                  title: AppStrings.inbox,
                  icon: Icons.inbox,
                  isSelected: currentCategory == AppStrings.inbox,
                  onTap: () => onCategorySelected(AppStrings.inbox),
                ),
                DrawerItem(
                  title: AppStrings.starred,
                  icon: Icons.star_border,
                  isSelected: currentCategory == AppStrings.starred,
                  onTap: () => onCategorySelected(AppStrings.starred),
                ),
                DrawerItem(
                  title: AppStrings.sent,
                  icon: Icons.send,
                  isSelected: currentCategory == AppStrings.sent,
                  onTap: () => onCategorySelected(AppStrings.sent),
                ),
                DrawerItem(
                  title: AppStrings.drafts,
                  icon: Icons.insert_drive_file,
                  count: 10,
                  onTap: () => onCategorySelected(AppStrings.drafts),
                ),
                DrawerItem(
                  title: AppStrings.trash,
                  icon: Icons.delete,
                  onTap: () => onCategorySelected(AppStrings.trash),
                ),
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
                DrawerItem(
                  title: AppStrings.settings,
                  icon: Icons.settings,
                  onTap: () {
                    onCategorySelected(AppStrings.settings);
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
