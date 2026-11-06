import 'package:flutter/material.dart';

/// Design tokens from `design.md` (Opsi A — selaras gambar Stitch).
abstract final class AppColors {
  // Primary
  static const primary = Color(0xFF0F172A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0F172A);

  // Secondary
  static const secondary = Color(0xFF0284C7);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFBAE6FD);
  static const secondaryFixed = Color(0xFFE0F2FE);
  static const onSecondaryFixed = Color(0xFF082F49);

  // Tertiary
  static const tertiary = Color(0xFFF59E0B);
  static const tertiaryFixedDim = Color(0xFFF59E0B);
  static const tertiaryFixed = Color(0xFFFEF3C7);
  static const onTertiaryContainer = Color(0xFFB45309);
  static const tertiaryContainer = Color(0xFF2A1700);

  // Surface
  static const surface = Color(0xFFF8F9FF);
  static const surfaceBright = Color(0xFFFFFFFF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);

  // Text & outline
  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF64748B);
  static const outline = Color(0xFF76777D);
  static const outlineVariant = Color(0xFFC6C6CD);

  // Error
  static const error = Color(0xFFDC2626);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Compatibility aliases for the previous teal palette.
  static const toska = secondary;
  static const toskaDark = onSecondaryFixed;
  static const toskaTint = secondaryFixed;
  static const ink = onSurface;
  static const muted = onSurfaceVariant;
  static const canvas = surface;
  static const border = outlineVariant;
  static const readOnlyFill = surfaceContainerLow;
  static const danger = error;
  static const warning = onTertiaryContainer;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const margin = 16.0;
  static const lg = 20.0;
  static const xl = 32.0;
}

abstract final class AppRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const pill = 999.0;
}

abstract final class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get floating => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get sheet => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.18),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];
}

/// Type scale from `design.md` §2. Family and size are always paired.
abstract final class AppTypography {
  static const headlineXl = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const headlineXlMobile = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 26,
    height: 1.23,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.52,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const headlineLg = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const headlineMd = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    fontVariations: [FontVariation('wght', 600)],
  );

  static const headlineSm = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
  );

  static const bodyLg = TextStyle(
    fontFamily: 'Chivo',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
  );

  static const bodyMd = TextStyle(
    fontFamily: 'Chivo',
    fontSize: 15,
    height: 1.47,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
  );

  static const bodySm = TextStyle(
    fontFamily: 'Chivo',
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.13,
    fontVariations: [FontVariation('wght', 400)],
  );

  static const labelLg = TextStyle(
    fontFamily: 'Chivo',
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.28,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const labelMd = TextStyle(
    fontFamily: 'Chivo',
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.48,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const labelSm = TextStyle(
    fontFamily: 'Chivo',
    fontSize: 11,
    height: 1.27,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.55,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const codeData = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.26,
    fontVariations: [FontVariation('wght', 500)],
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryFixed,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.primary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.tertiaryFixed,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
        );

    final textTheme = TextTheme(
      displayLarge: AppTypography.headlineXl.copyWith(
        color: AppColors.onSurface,
      ),
      displayMedium: AppTypography.headlineLg.copyWith(
        color: AppColors.onSurface,
      ),
      displaySmall: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
      ),
      headlineLarge: AppTypography.headlineXlMobile.copyWith(
        color: AppColors.onSurface,
      ),
      headlineMedium: AppTypography.headlineLg.copyWith(
        color: AppColors.onSurface,
      ),
      headlineSmall: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
      ),
      titleLarge: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
      ),
      titleMedium: AppTypography.headlineSm.copyWith(
        color: AppColors.onSurface,
      ),
      titleSmall: AppTypography.labelLg.copyWith(color: AppColors.onSurface),
      bodyLarge: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
      bodyMedium: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      bodySmall: AppTypography.bodySm.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      labelLarge: AppTypography.labelLg.copyWith(color: AppColors.onSurface),
      labelMedium: AppTypography.labelMd.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      labelSmall: AppTypography.labelSm.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Chivo',
      scaffoldBackgroundColor: AppColors.surface,
      visualDensity: VisualDensity.standard,
      textTheme: textTheme,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        titleTextStyle: AppTypography.headlineMd.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.primary.withValues(alpha: 0.1),
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        helperStyle: AppTypography.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        helperMaxLines: 2,
        errorStyle: AppTypography.bodySm.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.7),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: AppTypography.labelLg,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.4),
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: AppTypography.labelLg,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          backgroundColor: AppColors.surfaceContainerLowest,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: AppTypography.labelLg,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: AppTypography.labelLg,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.secondaryFixed,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.labelSm.copyWith(
            color: selected
                ? AppColors.secondary
                : AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? AppColors.secondary
                : AppColors.onSurfaceVariant,
            size: 22,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceContainerLow,
        labelStyle: AppTypography.labelMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        secondaryLabelStyle: AppTypography.labelMd.copyWith(
          color: AppColors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        side: BorderSide.none,
        showCheckmark: false,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outlineVariant.withValues(alpha: 0.55),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        contentTextStyle: AppTypography.bodySm.copyWith(
          color: AppColors.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(
            AppColors.surfaceContainerLowest,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        titleTextStyle: AppTypography.headlineSm.copyWith(
          color: AppColors.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.secondary,
        selectionColor: AppColors.secondary.withValues(alpha: 0.2),
        selectionHandleColor: AppColors.secondary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.labelSm.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}
