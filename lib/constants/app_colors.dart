import 'package:flutter/material.dart';

// Helper to avoid deprecated withOpacity
Color setOpacity(Color color, double opacity) {
  return color.withValues(alpha: opacity);
}

// Color Scheme
const Color kPrimaryColor = Color(0xFF1ABC9C); // Teal
const Color kAccentColor = Color(0xFF16A085); // Darker Teal
const Color kBackgroundColor = Color(0xFFFAFAFA); // Light Gray-White
const Color kCardColor = Color(0xFFFFFFFF); // White
const Color kTextPrimary = Color(0xFF2C3E50); // Dark Blue-Gray
const Color kTextSecondary = Color(0xFF7F8C8D); // Gray
const Color kDangerColor = Color(0xFFE74C3C); // Red
const Color kSuccessColor = Color(0xFF27AE60); // Green
