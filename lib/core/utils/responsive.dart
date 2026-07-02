import 'package:flutter/material.dart';

/// Ekran boyutuna göre oransal değerler için yardımcı extension.
///
/// Şu an için hedef sadece telefon çözünürlükleri (Android + iOS).
/// Sabit piksel yerine `wp`/`hp` gibi oransal yardımcılar ve `Flexible` /
/// `Expanded` / `FractionallySizedBox` gibi esnek widget'lar kullanılarak
/// farklı ekran boyutlarına otomatik uyum sağlanır.
///
/// Tablet desteği ileride gerekirse, bu extension'a `isTablet` gibi
/// breakpoint kontrolleri eklenerek genişletilebilir — mimari buna göre
/// (sabit px kullanılmadığı için) hazır.
extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);

  /// Doküman standardı: 24px yatay margin. Çok küçük ekranlarda (<360)
  /// biraz daraltılır ki içerik sıkışmasın.
  double get horizontalMargin => screenWidth < 360 ? 16 : 24;

  /// Ekran genişliğine oranlı değer üretir. Örn: context.wp(0.5) -> genişliğin yarısı.
  double wp(double fraction) => screenWidth * fraction;

  /// Ekran yüksekliğine oranlı değer üretir.
  double hp(double fraction) => screenHeight * fraction;
}
