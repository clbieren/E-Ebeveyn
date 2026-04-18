import 'package:flutter/material.dart';

/// Uygulamanın tüm renk sabitleri.
///
/// Tasarım Kararı:
/// - [background] → Saf siyah (#000000). OLED ekranlarda piksel kapatır, pil tasarrufu sağlar.
/// - [surface] → Çok hafif gri (#0D0D0D). Kartları arka plandan ayırt etmek için minimal fark.
/// - Vurgular → Pastel tonlar. Gece kullanımında göz yorgunluğunu minimuma indirir.
abstract final class AppColors {
  // ── Zemin Renkleri ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF000000); // True Black
  static const Color surface = Color(0xFF0D0D0D); // Near-black surface
  static const Color surfaceContainer =
      Color(0xFF1A1A1A); // Kart / bottom sheet

  // ── Birincil Vurgu: Pastel Lavanta ──────────────────────────────────────────
  /// Uyku takibinde kullanılacak. Sakinleştirici, gece dostu.
  static const Color primary = Color(0xFFB39DDB); // Pastel Lavender
  static const Color primaryDim = Color(0xFF7B6FA8); // Basılı / seçili state
  static const Color onPrimary = Color(0xFF1A1030); // Primary üzeri metin

  // ── İkincil Vurgu: Pastel Mint ──────────────────────────────────────────────
  /// Beslenme takibinde kullanılacak.
  static const Color secondary = Color(0xFF80CBC4); // Pastel Teal/Mint
  static const Color secondaryDim = Color(0xFF4E9E97);
  static const Color onSecondary = Color(0xFF00201E);

  // ── Üçüncül Vurgu: Pastel Amber ─────────────────────────────────────────────
  /// Bez takibinde kullanılacak.
  static const Color tertiary = Color(0xFFFFCC80); // Pastel Amber
  static const Color tertiaryDim = Color(0xFFCC9A4E);
  static const Color onTertiary = Color(0xFF2A1A00);

  // ── Hata ────────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF9A9A); // Pastel Red — sert değil
  static const Color onError = Color(0xFF3B0000);

  // ── Metin ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEEEEEE); // Yüksek kontrast
  static const Color textSecondary = Color(0xFF9E9E9E); // İkincil bilgi
  static const Color textDisabled = Color(0xFF424242);

  // ── Ayırıcı / Sınır ─────────────────────────────────────────────────────────
  static const Color divider = Color(0xFF212121);
  static const Color outline = Color(0xFF303030);
}
