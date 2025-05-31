import 'package:flutter/material.dart';

class AppColors {
  // Modern color palette
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF21D375);
  static const Color accentColor = Color(0xFFFF7B9C);
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D3142);
  static const Color textLight = Color(0xFF9098B1);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
}

class AppTextStyles {
  // Styles de texte
  static TextStyle heading1(BuildContext context) {
    return const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle heading2(BuildContext context) {
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle bodyText(BuildContext context) {
    return const TextStyle(
      fontSize: 22,
      color: AppColors.textDark,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle buttonText(BuildContext context) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.cardColor,
      fontFamily: 'Poppins',
    );
  }
}

class AppDecorations {
  static BoxDecoration neuBox = BoxDecoration(
    color: AppColors.cardColor,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade300,
        offset: const Offset(4, 4),
        blurRadius: 15,
        spreadRadius: 1,
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(-4, -4),
        blurRadius: 15,
        spreadRadius: 1,
      ),
    ],
  );

  static BoxDecoration gradientBox = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primaryColor,
        AppColors.primaryColor.withOpacity(0.8),
      ],
    ),
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryColor.withOpacity(0.3),
        offset: const Offset(0, 4),
        blurRadius: 15,
      ),
    ],
  );

  // Décoration pour les boutons
  static BoxDecoration buttonDecoration(BuildContext context) {
    return BoxDecoration(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Décoration pour les champs de texte
  static InputDecoration textFieldDecoration(BuildContext context, String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyText(context).copyWith(color: Colors.grey),
      filled: true,
      fillColor: AppColors.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
    );
  }
}
