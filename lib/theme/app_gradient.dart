import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.gradient1, AppColors.gradient2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
