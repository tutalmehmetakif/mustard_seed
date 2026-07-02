/// Miladi (Gregoryen) tarihi Hicri tarihe çeviren, dış paket gerektirmeyen
/// basit bir sınıf.
///
/// "Tabular Islamic Calendar" (Kuveyt algoritması) denen, yaygın olarak
/// kullanılan aritmetik bir yönteme dayanıyor — gerçek hilal gözlemine
/// göre ±1 gün fark olabilir (bu normal, çoğu takvim uygulaması da böyle
/// çalışıyor). Namaz vakti gibi hassasiyet gerektiren bir kullanım için
/// uygun değildir, sadece widget'ta "19 Zilhicce 1446" gibi bir tarih
/// göstermek için yeterlidir.
class HijriDate {
  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
  });

  final int day;
  final int month; // 1-12
  final int year;

  static const List<String> _monthNames = [
    'Muharrem',
    'Safer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  String get monthName => _monthNames[month - 1];

  @override
  String toString() => '$day $monthName $year';

  factory HijriDate.fromGregorian(DateTime date) {
    final julianDay = _gregorianToJulianDay(date);
    return _julianDayToHijri(julianDay);
  }

  static int _gregorianToJulianDay(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final a = (14 - m) ~/ 12;
    final y2 = y + 4800 - a;
    final m2 = m + 12 * a - 3;
    return d +
        ((153 * m2 + 2) ~/ 5) +
        365 * y2 +
        (y2 ~/ 4) -
        (y2 ~/ 100) +
        (y2 ~/ 400) -
        32045;
  }

  static HijriDate _julianDayToHijri(int jd) {
    final l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) ~/ 5316) * ((50 * l2) ~/ 17719) +
        (l2 ~/ 5670) * ((43 * l2) ~/ 15238);
    final l3 = l2 -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l3) ~/ 709;
    final day = l3 - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDate(day: day, month: month, year: year);
  }
}