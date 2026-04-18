import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulamanın tek tema fabrikası — Material 3, Nunito font.
///
/// KURAL: Bu dosyada hiçbir yerde `Colors.black` veya `Colors.white` yoktur.
/// Tüm renkler `ColorScheme` üzerinden bağlanır. UI katmanı
/// `Theme.of(context).colorScheme` ile renklere erişir.
///
/// Dark ColorScheme  → True-black OLED (#000000 background)
/// Light ColorScheme → Beyaz/soft beyaz yüzeyler
abstract final class AppTheme {
  AppTheme._();

  // ════════════════════════════════════════════════════════════════════════════
  // DARK
  // ════════════════════════════════════════════════════════════════════════════

  static ThemeData get dark {
    const cs = _darkScheme;
    return _base(cs).copyWith(
      scaffoldBackgroundColor: cs.surface,
      // Dark: kart/buton rengi 0xFF1A1A1A (surface)
      cardTheme: _cardTheme(cs.surface, cs),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LIGHT
  // ════════════════════════════════════════════════════════════════════════════

  static ThemeData get light {
    const cs = _lightScheme;
    return _base(cs).copyWith(
      scaffoldBackgroundColor: cs.surface,
      // Light: kart/buton rengi surfaceContainerHighest (hafif gri)
      cardTheme: _cardTheme(cs.surfaceContainerHighest, cs),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // COLOR SCHEMES
  // ════════════════════════════════════════════════════════════════════════════

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    // Zemin
    surface: Color(0xFF000000), // True OLED black
    surfaceContainerHighest: Color(0xFF1A1A1A), // Kart / bottom sheet
    surfaceContainerHigh: Color(0xFF0D0D0D),
    surfaceContainer: Color(0xFF1A1A1A),
    surfaceContainerLow: Color(0xFF0A0A0A),
    // Birincil — Pastel Lavanta
    primary: Color(0xFFB39DDB),
    onPrimary: Color(0xFF1A1030),
    primaryContainer: Color(0xFF7B6FA8),
    onPrimaryContainer: Color(0xFFEEEEEE),
    // İkincil — Pastel Mint
    secondary: Color(0xFF80CBC4),
    onSecondary: Color(0xFF00201E),
    secondaryContainer: Color(0xFF4E9E97),
    onSecondaryContainer: Color(0xFFEEEEEE),
    // Üçüncül — Pastel Amber
    tertiary: Color(0xFFFFCC80),
    onTertiary: Color(0xFF2A1A00),
    tertiaryContainer: Color(0xFFCC9A4E),
    onTertiaryContainer: Color(0xFFEEEEEE),
    // Hata
    error: Color(0xFFEF9A9A),
    onError: Color(0xFF3B0000),
    errorContainer: Color(0xFF8B2A2A),
    onErrorContainer: Color(0xFFFFDAD6),
    // Metin / ikon
    onSurface: Color(0xFFEEEEEE),
    onSurfaceVariant: Color(0xFF9E9E9E),
    outline: Color(0xFF303030),
    outlineVariant: Color(0xFF212121),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFEEEEEE),
    onInverseSurface: Color(0xFF1A1A1A),
    inversePrimary: Color(0xFF7B6FA8),
  );

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    surface: Color(0xFFFAFAFA),
    surfaceContainerHighest: Color(0xFFE8E8F0), // buton/kart
    surfaceContainerHigh: Color(0xFFEFEFF5),
    surfaceContainer: Color(0xFFE8E8F0),
    surfaceContainerLow: Color(0xFFF4F4F8),
    primary: Color(0xFF7B6FA8),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD9D0F0),
    onPrimaryContainer: Color(0xFF1A1030),
    secondary: Color(0xFF4E9E97),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFC8F0ED),
    onSecondaryContainer: Color(0xFF00201E),
    tertiary: Color(0xFFB8860B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE9B0),
    onTertiaryContainer: Color(0xFF2A1A00),
    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF3B0000),
    onSurface: Color(0xFF1A1A1A),
    onSurfaceVariant: Color(0xFF5A5A6A),
    outline: Color(0xFFB0B0C0),
    outlineVariant: Color(0xFFD8D8E8),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1A1A1A),
    onInverseSurface: Color(0xFFF0F0F0),
    inversePrimary: Color(0xFFB39DDB),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // BASE THEME FACTORY
  // ════════════════════════════════════════════════════════════════════════════

  static ThemeData _base(ColorScheme cs) {
    // Nunito text theme — tüm TextStyle'larda inherit:true
    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
          fontSize: 57, fontWeight: FontWeight.w700, color: cs.onSurface),
      displayMedium: GoogleFonts.nunito(
          fontSize: 45, fontWeight: FontWeight.w600, color: cs.onSurface),
      displaySmall: GoogleFonts.nunito(
          fontSize: 36, fontWeight: FontWeight.w600, color: cs.onSurface),
      headlineLarge: GoogleFonts.nunito(
          fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface),
      headlineMedium: GoogleFonts.nunito(
          fontSize: 28, fontWeight: FontWeight.w600, color: cs.onSurface),
      headlineSmall: GoogleFonts.nunito(
          fontSize: 24, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: cs.onSurface),
      titleMedium: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleSmall: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
      bodyLarge:
          GoogleFonts.nunito(fontSize: 16, height: 1.5, color: cs.onSurface),
      bodyMedium:
          GoogleFonts.nunito(fontSize: 14, height: 1.5, color: cs.onSurface),
      bodySmall: GoogleFonts.nunito(
          fontSize: 12, height: 1.4, color: cs.onSurfaceVariant),
      labelLarge: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface),
      labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant),
      labelSmall: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant),
    );

    final isDark = cs.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: cs.surface,
                systemNavigationBarColor: cs.surface,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: cs.surface,
                systemNavigationBarColor: cs.surface,
              ),
        titleTextStyle: GoogleFonts.nunito(
          color: cs.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // ── BottomNavigationBar ────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w500, fontSize: 12),
      ),

      // ── Input ──────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        hintStyle: GoogleFonts.nunito(color: cs.onSurfaceVariant, fontSize: 14),
        labelStyle:
            GoogleFonts.nunito(color: cs.onSurfaceVariant, fontSize: 14),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primaryContainer,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle:
              GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),

      // ── FilledButton ───────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primaryContainer,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle:
              GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 2,
        shape: const CircleBorder(),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme:
          DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1),

      // ── ListTile ───────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        tileColor: const Color(0x00000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── BottomSheet ────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainer,
        modalBackgroundColor: cs.surfaceContainer,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: cs.outline,
        showDragHandle: true,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.nunito(
            color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.nunito(
            color: cs.onSurfaceVariant, fontSize: 14, height: 1.5),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        selectedColor: cs.primaryContainer.withAlpha(102), // 0.4 * 255
        side: BorderSide(color: cs.outline),
        labelStyle: GoogleFonts.nunito(color: cs.onSurface, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle:
            GoogleFonts.nunito(color: cs.onInverseSurface, fontSize: 13),
        actionTextColor: cs.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      // ── Switch ─────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? cs.primary
                : cs.onSurfaceVariant),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? cs.primaryContainer
                : cs.surfaceContainerHigh),
      ),
    );
  }

  // ── Card helper ────────────────────────────────────────────────────────────

  static CardThemeData _cardTheme(Color cardColor, ColorScheme cs) =>
      CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      );
}
