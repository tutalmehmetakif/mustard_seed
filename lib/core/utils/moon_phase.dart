import 'dart:math' as math;

/// Ayın 8 standart, adlandırılmış evresi.
enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  full,
  waningGibbous,
  thirdQuarter,
  waningCrescent,
}

/// Ayın o günkü durumunu temsil eden veri.
///
/// [illumination]: 0.0 (yeni ay) ... 1.0 (dolunay) arasında sürekli değer.
/// [isWaxing]: Ay büyüyor mu (true) küçülüyor mu (false).
/// [phaseName]: 8 standart evreden hangisine en yakın olduğu — widget'ta
/// doğru NASA fotoğrafını seçmek için kullanılır.
/// [label]: Türkçe görünen ad (UI metni için).
class MoonPhaseData {
  const MoonPhaseData({
    required this.illumination,
    required this.isWaxing,
    required this.phaseName,
    required this.label,
    required this.moonDay, // YENİ
  });

  final double illumination;
  final bool isWaxing;
  final MoonPhaseName phaseName;
  final String label;

  /// Döngünün kaçıncı günü (0 = Yeni Ay, ~15 = Dolunay civarı, 29'a
  /// kadar). NASA'nın 30 günlük gerçek fotoğraf setiyle (MoonDay0...
  /// MoonDay29) birebir eşleşir — bu, evrensel bir astronomik ölçüm
  /// olduğu için hangi takvim yılında/ayında olursak olalım doğru sonucu
  /// verir.
  final int moonDay; // YENİ
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
  final phaseName = _phaseNameFor(phaseFraction);
  final moonDay = (phaseFraction * 29).round().clamp(0, 29); // YENİ

  return MoonPhaseData(
    illumination: illumination,
    isWaxing: isWaxing,
    phaseName: phaseName,
    label: _labelFor(phaseName),
    moonDay: moonDay, // YENİ
  );
}

  /// 0.0-1.0 arası döngü kesrini, 8 eşit dilime (her biri 1/8 = %12.5)
  /// bölerek en yakın standart evreye eşler.
  static MoonPhaseName _phaseNameFor(double phaseFraction) {
    // Her dilimin merkezi 1/16, 3/16, 5/16... noktalarında olacak şekilde
    // 8'e bölüyoruz — böylece örn. "tam Yeni Ay" (0.0) civarındaki
    // günler gerçekten "Yeni Ay" kategorisine düşüyor, sınırda kaymıyor.
    final slice = ((phaseFraction * 8) + 0.5).floor() % 8;
    switch (slice) {
      case 0:
        return MoonPhaseName.newMoon;
      case 1:
        return MoonPhaseName.waxingCrescent;
      case 2:
        return MoonPhaseName.firstQuarter;
      case 3:
        return MoonPhaseName.waxingGibbous;
      case 4:
        return MoonPhaseName.full;
      case 5:
        return MoonPhaseName.waningGibbous;
      case 6:
        return MoonPhaseName.thirdQuarter;
      default:
        return MoonPhaseName.waningCrescent;
    }
  }

  static String _labelFor(MoonPhaseName phaseName) {
    switch (phaseName) {
      case MoonPhaseName.newMoon:
        return 'Yeni Ay';
      case MoonPhaseName.waxingCrescent:
        return 'Büyüyen Hilal';
      case MoonPhaseName.firstQuarter:
        return 'İlk Dördün';
      case MoonPhaseName.waxingGibbous:
        return 'Büyüyen Ay';
      case MoonPhaseName.full:
        return 'Dolunay';
      case MoonPhaseName.waningGibbous:
        return 'Küçülen Ay';
      case MoonPhaseName.thirdQuarter:
        return 'Son Dördün';
      case MoonPhaseName.waningCrescent:
        return 'Küçülen Hilal';
    }
  }
}