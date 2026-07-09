/// Bu dosya, "Hazır Zikir Listesi" için basit bir veri modelidir.
/// Ürün dokümanına göre (Aşama 3) hazır liste İKİNCİL bir seçenektir;
/// asıl deneyim kullanıcının KENDİ zikrini kurmasıdır. Bu yüzden bu model
/// hem hazır şablonları hem de kullanıcının oluşturduğu özel zikirleri
/// aynı yapıda (ZikirTemplate) tutar — ViewModel (BLoC) katmanında ayrım
/// yapmaya gerek kalmaz.
class ZikirTemplate {
  final String phrase; // Zikrin kendisi, örn: "Subhanallah"
  final String translation; // Kısa anlamı / açıklaması
  final int target; // Hedef adet (kullanıcı özel zikirde bunu kendi belirler)

  const ZikirTemplate({
    required this.phrase,
    required this.translation,
    required this.target,
  });

  ZikirTemplate copyWith({String? phrase, String? translation, int? target}) {
    return ZikirTemplate(
      phrase: phrase ?? this.phrase,
      translation: translation ?? this.translation,
      target: target ?? this.target,
    );
  }
}

/// Hazır zikir listesi — React tarafındaki ZIKIR_TEMPLATES verisinin
/// Flutter karşılığı. İleride bu liste bir repository/veritabanından
/// da gelebilir; şimdilik sabit (const) veri olarak tutuyoruz.
const List<ZikirTemplate> defaultZikirTemplates = [
  ZikirTemplate(
    phrase: 'Subhanallah',
    translation: 'Allah her türlü eksiklikten münezzehtir',
    target: 33,
  ),
  ZikirTemplate(
    phrase: 'Elhamdülillah',
    translation: 'Hamd, yalnızca Allah\'a mahsustur',
    target: 33,
  ),
  ZikirTemplate(
    phrase: 'Allahu Ekber',
    translation: 'Allah en büyüktür',
    target: 34,
  ),
  ZikirTemplate(
    phrase: 'La ilahe illallah',
    translation: 'Allah\'tan başka ilah yoktur',
    target: 100,
  ),
];