import 'package:flutter/cupertino.dart';

class BreadcrumbText extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isFinished;

  const BreadcrumbText({
    required this.text,
    required this.isActive,
    required this.isFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? CupertinoColors.activeBlue
            : (isFinished
                ? CupertinoColors.systemBlue
                : CupertinoColors.white),
        borderRadius: BorderRadius.circular(20), // Make it pill-shaped
      ),
      child: Center(
        child: isFinished
            ? Icon(
                CupertinoIcons.checkmark_alt,
                size: 18,
                color: CupertinoColors.white,
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? CupertinoColors.white
                      : CupertinoColors.systemBlue,
                ),
              ),
      ),
    );
  }
}