// display user online or offline status
import 'package:flutter/material.dart';

// message page status bar
Map<String, String> statusIndicator = {
  'active': '',
  'inactive': 'No Internet connection available',
  'offline': "Sorry, You're offline"
};

Map<String, Color> statusColor = {
  'active': Colors.white,
  'inactive': Colors.black.withAlpha(160),
  'offline': Colors.red.withAlpha(150)
};

Map<String, Color> statusTextColor = {
  'inactive': Colors.white38,
  'offline': Colors.black
};


// status dot
final List<Icon> iconLists = [
  Icon(
    Icons.check,
    color: Colors.greenAccent,
  ),
  Icon(
    Icons.error_outline,
    color: Colors.greenAccent,
  )
];
final iconIndicator = {"success": 0, "error": 1};


// distinguish network status
Map<String, String> loginErrorHint = {
  "loginError": "Please check your email or password.",
  "netError": "Please check your internet."
};