import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceContainerLowest,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FieldInspectionApp());
}
