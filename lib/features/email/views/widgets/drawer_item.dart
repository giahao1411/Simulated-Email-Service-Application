import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {

  const DrawerItem({
    required this.title, required this.icon, required this.onTap, super.key,
    this.isSelected = false,
    this.count,
  });
  final String title;
  final IconData icon;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 2, bottom: 2),
      child: Container(
        decoration:
            isSelected
                ? BoxDecoration(
                  color: Colors.red[200]!.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                )
                : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(
            icon,
            color: isSelected ? Colors.red[200] : Colors.grey,
            size: 16,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.red[200] : Colors.white,
              fontSize: 14,
            ),
          ),
          trailing:
              count != null
                  ? Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.grey),
                  )
                  : null,
          selected: isSelected,
          onTap: onTap,
        ),
      ),
    );
  }
}
