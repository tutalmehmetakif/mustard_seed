/// Widget'ta gösterilecek 4 temel ay evresi.
/// Doküman: "Hilal, İlk Dördün, Dolunay, Son Dördün"
enum MoonPhase { hilal, ilkDordun, dolunay, sonDordun }

extension MoonPhaseLabel on MoonPhase {
  String get label {
    switch (this) {
      case MoonPhase.hilal:
        return 'Hilal';
      case MoonPhase.ilkDordun:
        return 'İlk Dördün';
      case MoonPhase.dolunay:
        return 'Dolunay';
      case MoonPhase.sonDordun:
        return 'Son Dördün';
    }
  }
}

/// Basit bir ay evresi hesaplayıcı.
///
/// Astronomik gözleme dayanmıyor — bilinen bir yeniay referans tarihinden
/// itibaren ~29.53 günlük senodik ay döngüsüne göre yaklaşık hesap yapıyor.
/// Widget'ta "Hilal mi, Dolunay mı" göstermek için yeterli hassasiyette;
/// gerçek dini/namaz vakti hesaplamaları için kullanılmamalı (o ayrı,
/// çok daha hassas bir konu).
class MoonPhaseCalculator {
  MoonPhaseCalculator._();

  // Bilinen bir yeniay referans anı: 6 Ocak 2000, 18:14 UTC.
  static final DateTime _knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
  static const double _synodicMonthDays = 29.53058867;

  static MoonPhase calculate(DateTime date) {
    final daysSinceNewMoon =
        date.toUtc().difference(_knownNewMoon).inHours / 24;
    final phaseFraction =
        (daysSinceNewMoon % _synodicMonthDays) / _synodicMonthDays;

    if (phaseFraction < 0.25) return MoonPhase.hilal;
    if (phaseFraction < 0.5) return MoonPhase.ilkDordun;
    if (phaseFraction < 0.75) return MoonPhase.dolunay;
    return MoonPhase.sonDordun;
  }
}