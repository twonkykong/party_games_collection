import 'package:flutter/material.dart';

void showStartBanner(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(text, textAlign: TextAlign.center),
      duration: const Duration(milliseconds: 1600),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    ),
  );
}
