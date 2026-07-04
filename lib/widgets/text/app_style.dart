import 'package:flutter/material.dart';
import 'package:flutter_with_hive/core/themes.dart';

class AppStyle {
  // Font Styles

  static TextStyle style9w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 9, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }
   static TextStyle style11w500({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 11, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }
   static TextStyle style17w700({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 17, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }
   static TextStyle style22w700({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 22, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }
    static TextStyle style17w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 17, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }
   static TextStyle style20w700({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style9w400({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 9, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style9w500({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 9, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style32w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 32, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }

  static TextStyle style50w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 50, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }

  static TextStyle style24w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 24, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }

  static TextStyle style20w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }

  static TextStyle style16w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }

  static TextStyle style16w400({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style16w700({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style14w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 14, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }

  static TextStyle style14w400({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 14, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style13w400({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 13, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style13w500({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 13, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style12w700({Color? color = AppColors.titleColor, bool isUnderLine = false}) {
    return TextStyle(
      color: color,
      fontSize: 12,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w700,
      decoration: isUnderLine ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static TextStyle style12w600({Color? color = AppColors.titleColor, bool isUnderLine = false, String? fontFamily = "Montserrat"}) {
    return TextStyle(
      color: color,
      fontSize: 12,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      decoration: isUnderLine ? TextDecoration.underline : TextDecoration.none,
      decorationColor: color,
      decorationThickness: 1.5,
    );
  }

  static TextStyle style12w400({Color? color = AppColors.bodyTextDark}) {
    return TextStyle(color: color, fontSize: 12, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style12w500({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 12, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style11w400({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 11, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style11w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 11, fontFamily: 'Montserrat', fontWeight: FontWeight.w600, height: 13.41 / 11);
  }

  static TextStyle style11w700({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 11, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style10w400({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 10, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style10w500({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 10, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style13w600({Color? color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 13, fontFamily: 'Montserrat', fontWeight: FontWeight.w600);
  }

  //////////////////////////////////////////
  /////////////////
  static TextStyle style6w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 6, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style7w500({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 6, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style8w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 8, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  // static TextStyle style10w400({Color color = AppColors.titleColor}) {
  //   return TextStyle(
  //     color: color,
  //     fontSize: 10,
  //     fontFamily: 'Montserrat',
  //     fontWeight: FontWeight.w400,
  //   );
  // }

  static TextStyle style10w600({Color? color = AppColors.titleColor, String? fontFamily = "Montserrat"}) {
    return TextStyle(color: color, fontSize: 10, fontFamily: fontFamily, fontWeight: FontWeight.w600);
  }

  static TextStyle style10w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 10, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  // static TextStyle style11w400({Color color = AppColors.titleColor}) {
  //   return TextStyle(
  //     color: color,
  //     fontSize: 11,
  //     fontFamily: 'Montserrat',
  //     fontWeight: FontWeight.w400,
  //   );
  // }

  // static TextStyle style11w700({Color color = AppColors.titleColor}) {
  //   return TextStyle(
  //     color: color,
  //     fontSize: 11,
  //     fontFamily: 'Montserrat',
  //     fontWeight: FontWeight.w700,
  //   );
  // }

  // static TextStyle style12w600({Color color = AppColors.titleColor}) {
  //   return TextStyle(
  //     color: color,
  //     fontSize: 12,
  //     fontFamily: 'Montserrat',
  //     fontWeight: FontWeight.w600,
  //   );
  // }

  // static TextStyle style13w400({Color color = AppColors.titleColor}) {
  //   return TextStyle(
  //     color: color,
  //     fontSize: 13,
  //     fontFamily: 'Montserrat',
  //     fontWeight: FontWeight.w400,
  //   );
  // }

  // static TextStyle style13w600({Color color = AppColors.titleColor}) {
  //   return TextStyle(
  //     color: color,
  //     fontSize: 13,
  //     fontFamily: 'Montserrat',
  //     fontWeight: FontWeight.w600,
  //   );
  // }

  static TextStyle style14w500({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 14, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style14w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 14, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style15w500({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 15, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style15w400({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 15, fontFamily: 'Montserrat', fontWeight: FontWeight.w400);
  }

  static TextStyle style15w600({Color color = AppColors.titleColor, bool isUnderLine = false}) {
    return TextStyle(
      color: color,
      fontSize: 15,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w600,
      decoration: isUnderLine ? TextDecoration.underline : TextDecoration.none,
      decorationColor: color,
    );
  }

  // static TextStyle style16w600({Color color = AppColors.titleColor}) {
  //   return TextStyle(
  //     color: color,
  //     fontSize: 16,
  //     fontFamily: 'Montserrat',
  //     fontWeight: FontWeight.w600,
  //   );
  // }

  static TextStyle style18w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 18, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style18w500({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 18, fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
  }

  static TextStyle style24w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 24, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style30w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 30, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }

  static TextStyle style32w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 32, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }
   static TextStyle style28w700({Color color = AppColors.titleColor}) {
    return TextStyle(color: color, fontSize: 28, fontFamily: 'Montserrat', fontWeight: FontWeight.w700);
  }
}
