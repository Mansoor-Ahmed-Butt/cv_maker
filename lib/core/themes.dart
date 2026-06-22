import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand
  static const primaryColor = Color(0xFF003A4D);
  static const secondaryColorOrange = Color(0xFFFC9D74);
  static const appBlue = Color(0xFF6366F1);
  static const appPurple = Color(0xFF8B5CF6);
  static const appPink = Color(0xFFEC4899);
  static const appSkyBlueC = Color(0xFF42A5F5);
  static const appPurpleWshadeC = Color(0xFFAB47BC);

  // Semantic
  static const success = Color(0xFF10B981);
  static const successDark = Color(0xFF059669);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFEAB308);
  static const info = Color(0xFFFBBF24);
  static const danger = Color(0xFFEF4444);

  // Neutrals
  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF000000);
  static const transparent = Colors.transparent;
  static const greyColor = Color(0xFF9E9E9E);
  static const titleColor = Color(0xFF2D2C2C);
  static const subtitleColor = Color(0xFF656565);
  static const bodyText = Color(0xFF747879);
  static const bodyTextDark = Color(0xFF444444);
  static const borderColor = Color(0xFFD9E2E4);
  static const lightBackgroundColor = Color(0xFFF2F5F6);
  static const surfaceLight = Color(0xFFF9FAFB);
  static const surfaceDark = Color(0xFF1E1E3F);
  static const surfaceDarkSecondary = Color(0xFF2A2A4E);
  static const mutedText = Color(0xFF6B7280);
  static const placeHolderColor = Color(0xFFCCCCCC);

  // App backgrounds
  static const homeBackgroundColor1 = Color(0xFF0A0E27);
  static const homeBackgroundColor2 = Color(0xFF1A1F3A);
  static const homeBackgroundColor3 = Color(0xFF2D1B69);
  static const appBackgroundColor = Color(0xFF141516);
  static const textFieldBackgroundColor = Color(0xFF090909);

  // Legacy/support tokens kept for compatibility
  static const red = danger;
  static const appRedC = danger;
  static const appGreyC = greyColor;
  static const appYellowC = info;
  static const appOrangeC = Color(0xFFF97316);
  static const appGreenC = success;
  static const appDarkGreenC = successDark;
  static const appDarkYellowC = warning;
  static const appLightYellowC = warningLight;
  static const textColorLabel = Color(0xFFF34E3A);
  static const buttonColor = Color(0xFFF34E3A);
  static const buttonTextColor = Color(0xFFF34E3A);
  static const buttonBackgroundColor = Color(0xFF140702);
  static const cursorColor = Color(0xFF484848);
  static const hintTextColor = Color(0xFF484848);
  static const loginButtonColor = Color(0xFF008DC9);
  static const selectionColor = Color(0xFF484848);
  static const selectionHandleColor = Color(0xFFF34E3A);
  static const homePageTextColor = Color(0xFFDAD6D6);
  static const homePageDateColor = Color(0xFF545454);
  static const dotColor = Color(0xFFDDDDDD);
  static const currentStatusColor = Color(0xFF080808);
  static const currentStatusTextColor = Color(0xFF727272);
  static const lineChartLabelColor = Color(0xFF545454);
  static const currentStatusLabelColor = Color(0xFF545454);
  static const activityColor = Color(0xFFDAD6D6);
  static const chooseProgramColor = Color(0xFF545454);

  // Navigation
  static const bottomNavColor1 = surfaceDark;
  static const bottomNavColor2 = surfaceDarkSecondary;
  static const bottomNavShadowColor1 = appBlue;
  static const bottomNavShadowColor2 = blackColor;
  static const bottomNavCenterButtonColor1 = appBlue;
  static const bottomNavCenterButtonColor2 = appPurple;
  static const bottonNavCenterButtonColor3 = appPink;
  static const bottomNavCenterButtonShadowColor1 = appBlue;
  static const bottomNavIconColor1 = mutedText;
  static const bottomNavIconColor2 = appBlue;

  // Cards and effects
  static const bgAnimatedCircleColor1 = appBlue;
  static const startCardColor1 = surfaceDark;
  static const startCardColor2 = surfaceDarkSecondary;
  static const resumeCardColor1 = surfaceDark;
  static const resumeCardColor2 = surfaceDarkSecondary;
  static const getStartedButtonColor22 = appOrangeC;
  static const getStartedButtonColor33 = appSkyBlueC;

  static const Gradient homeBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [homeBackgroundColor1, homeBackgroundColor2, homeBackgroundColor3],
  );

  static const Gradient primaryAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [appBlue, appPurple, appPink],
  );

  static const Gradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [appBlue, appPurple, appPink],
  );

  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, appSkyBlueC],
  );

  static const Gradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [appPink, appOrangeC],
  );
}

class AppTheme {
  const AppTheme._();

  static final ColorScheme colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.appBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.appBlue,
        secondary: AppColors.appPurple,
        surface: AppColors.whiteColor,
        error: AppColors.danger,
      );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.whiteColor,
    primaryColor: AppColors.appBlue,
    colorScheme: colorScheme,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.bodyText.withValues(alpha: 0.35),
      cursorColor: AppColors.appBlue,
      selectionHandleColor: AppColors.appBlue,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      contentTextStyle: const TextStyle(color: AppColors.whiteColor),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.bodyText),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.appBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    ),
  );
}
