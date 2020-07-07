import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Login Register Forget Page Text Style
class UserEntranceTextStyle {
  // login
  static final loginFieldInputTextStyle = TextStyle(
      color: Colors.white70, fontFamily: 'Montserrat', fontSize: 42.sp);
  static final loginFieldHintStyle =
      TextStyle(fontSize: 42.sp, color: Colors.amberAccent.withOpacity(0.8));
  static final loginHintTextStyle = TextStyle(
    fontSize: 40.sp,
    color: Colors.blueAccent,
    fontFamily: 'NanumGothic',
  );
  static final loginBtnTextStyle = TextStyle(
      color: Colors.black87,
      fontFamily: 'NanumGothic',
      fontWeight: FontWeight.w500,
      fontSize: 42.sp);
  static final headerLoginLabelTextStyle =
      TextStyle(color: Colors.white70, fontSize: 42.sp);

  // register
  static final subHeaderRegisterLabelTextStyle =
      TextStyle(color: Colors.white70, fontSize: 32.sp);
  static final headerRegisterLabelTextStyle = TextStyle(
    fontSize: 64.sp,
    fontFamily: 'NanumGothic',
    color: Colors.white70,
  );

  // forget
  static final headerForgetLabelTextStyle = TextStyle(color: Colors.redAccent, fontSize: 40.sp);
  static final subHeaderForgetLabelTextStyle = TextStyle(
                color: Colors.white70, fontFamily: 'Times New Romance', fontSize: 36.sp);
  static final forgetBtnTextStyle = TextStyle(
            color: Colors.white,
            fontFamily: 'NanumGothic',
            fontWeight: FontWeight.bold,
            fontSize: 42.sp);
  static final forgetSucessHintTextStyle = TextStyle(
                  color: Colors.red,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w600);
}

class UserEntranceIcons {
  // login
  static const email = Icon(Icons.email, color: Colors.white70);
  static const password = Icon(Icons.lock, color: Colors.white70);

  // register
  static const username = Icon(Icons.person_outline, color: Colors.white70);
  static const phone = Icon(Icons.phone_android, color: Colors.white70);
}

class UserEntranceDecoration {
  static final enableBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32.w),
      borderSide: BorderSide(
        color: Colors.white60,
      ));
  static final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(32.w),
  );

  static final shape = RoundedRectangleBorder(
      borderRadius: new BorderRadius.circular(36.w),
      side: BorderSide(color: Colors.black54, width: 0.5.w));

  static final forgetEnableBorder = OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueGrey,
            ),
          );
}

final entranceStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 15.0);

/// notes relevation
/// font-weight definitions
class FontWeights {
  FontWeights._();

  static const thin = FontWeight.w100;
  static const extraLight = FontWeight.w200;
  static const light = FontWeight.w300;
  static const normal = FontWeight.normal;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.bold;
  static const extraBold = FontWeight.w800;
  static const black = FontWeight.w900;
}

const kBottomBarSize = 56.0;
const kIconTintLight = Color(0xFF5F6368);
const kIconTintCheckedLight = Color(0xFF202124);
const kLabelColorLight = Color(0xFF202124);
const kCheckedLabelBackgroudLight = Color(0x337E39FB);
// const kCheckedLabelBackgroudLight = Color(0x3FFFD23E);
const kHintTextColorLight = Color(0xFF61656A);
const kNoteTitleColorLight = Color(0xFF202124);
const kNoteTextColorLight = Color(0x99000000);
const kNoteDetailTextColorLight = Color(0xC2000000);
const kErrorColorLight = Color(0xFFD43131);
const kWarnColorLight = Color(0xFFFD9726);
const kBorderColorLight = Color(0xFFDADCE0);
const kColorPickerBorderColor = Color(0x21000000);
const kBottomAppBarColorLight = Color(0xF2FFFFFF);

const _kPurplePrimaryValue = 0xFF7E39FB;
const kAccentColorLight = const MaterialColor(
  _kPurplePrimaryValue,
  const <int, Color>{
    900: const Color(0xFF0000c9),
    800: const Color(0xFF3f00df),
    700: const Color(0xFF2500d7),
    600: const Color(0xFF6200ee),
    500: const Color(_kPurplePrimaryValue),
    400: const Color(0xFF5400e8),
    300: const Color(0xFF995dff),
    200: const Color(0xFFe3b8ff),
    100: const Color(0xFFdab2ff),
    50: const Color(0xFFfbd5ff),
  },
);

/// Available note background colors
const Iterable<Color> kNoteColors = [
  Colors.white,
  const Color(0xFFF28C82),
  const Color(0xFFFABD03),
  const Color(0xFFFFF476),
  const Color(0xFFCDFF90),
  const Color(0xFFA7FEEB),
  const Color(0xFFCBF0F8),
  const Color(0xFFAFCBFA),
  const Color(0xFFD7AEFC),
  const Color(0xFFFDCFE9),
  const Color(0xFFE6C9A9),
  const Color(0xFFE9EAEE),
];
final kDefaultNoteColor = kNoteColors.first;

/// [TextStyle] for note title in a preview card
const kCardTitleLight = TextStyle(
  color: kNoteTitleColorLight,
  fontSize: 16,
  height: 19 / 16,
  fontWeight: FontWeights.medium,
);

/// [TextStyle] for note title in a preview card
const kNoteTitleLight = TextStyle(
  color: kNoteTitleColorLight,
  fontSize: 21,
  height: 19 / 16,
  fontWeight: FontWeights.medium,
);

/// [TextStyle] for text notes
const kNoteTextLight = TextStyle(
  color: kNoteTextColorLight,
  fontSize: 16,
  height: 1.3125,
);

/// [TextStyle] for text notes in detail view
const kNoteTextLargeLight = TextStyle(
  color: kNoteDetailTextColorLight,
  fontSize: 18,
  height: 1.3125,
);

/// [TextStyle] for checklist notes
const kChecklistTextLight = TextStyle(
  color: kNoteTextColorLight,
  fontSize: 14,
  height: 16 / 14,
);

/// [TextStyle] for checklist notes in detail view
const kChecklistTextLargeLight = TextStyle(
  color: kNoteDetailTextColorLight,
  fontSize: 18,
  height: 16 / 14,
);
