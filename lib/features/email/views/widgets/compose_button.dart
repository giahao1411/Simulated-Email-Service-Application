import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class ComposeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ComposeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 66,
      right: 16,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, color: Colors.red[200], size: 18),
              const SizedBox(width: 8),
              Text(
                AppStrings.composeEmail,
                style: TextStyle(color: Colors.red[200], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
