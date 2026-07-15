import 'dart:math' as math;

/// Ayın o günkü durumunu temsil eden veri.
///
/// [illumination]: 0.0 (yeni ay, tamamen karanlık) ile 1.0 (dolunay,
/// tamamen aydınlık) arasında sürekli bir değer.
///
/// [isWaxing]: Ay büyüyor mu (true) yoksa küçülüyor mu (false).
///
/// [label]: Widget'ta gösterilen 4 kategorili metin ("Hilal" vb.).
class MoonPhaseData {
  const MoonPhaseData({
    required this.illumination,
    required this.isWaxing,
    required this.label,
  });

  final double illumination;
  final bool isWaxing;
  final String label;
}

/// Basit bir ay evresi hesaplayıcı.
///
/// Astronomik gözleme dayanmıyor — bilinen bir yeniay referans tarihinden
/// itibaren ~29.53 günlük senodik ay döngüsüne göre yaklaşık hesap yapıyor.
class MoonPhaseCalculator {
  MoonPhaseCalculator._();

  static final DateTime _knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
  static const double _synodicMonthDays = 29.53058867;

  static MoonPhaseData calculate(DateTime date) {
    final daysSinceNewMoon =
        date.toUtc().difference(_knownNewMoon).inHours / 24;
    final phaseFraction =
        (daysSinceNewMoon % _synodicMonthDays) / _synodicMonthDays;

    final illumination = (1 - math.cos(2 * math.pi * phaseFraction)) / 2;
    final isWaxing = phaseFraction < 0.5;

    return MoonPhaseData(
      illumination: illumination,
      isWaxing: isWaxing,
      label: _labelFor(phaseFraction),
    );
  }

  static String _labelFor(double phaseFraction) {
    if (phaseFraction < 0.25) return 'Hilal';
    if (phaseFraction < 0.5) return 'İlk Dördün';
    if (phaseFraction < 0.75) return 'Dolunay';
    return 'Son Dördün';
  }
}