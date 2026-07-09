// Değişiklik: ZikirOzelZikirOlusturuldu event'ine opsiyonel aciklama alanı eklendi.
import 'package:flutter/foundation.dart' show immutable;

/// ================== ZIKIR EVENT (OLAYLAR) ==================
/// BLoC mimarisinde "Event", View (arayüz) katmanının kullanıcı
/// etkileşimlerini ViewModel'e (Bloc) bildirmek için gönderdiği mesajlardır.
/// View HİÇBİR ZAMAN state'i doğrudan değiştirmez, sadece bir Event
/// fırlatır (context.read<ZikirBloc>().add(...)) ve state güncellemesini
/// Bloc yapar. Bu, MVVM'deki "View, ViewModel'i tetikler" prensibinin
/// BLoC'taki karşılığıdır.
@immutable
abstract class ZikirEvent {
  const ZikirEvent();
}

/// Kullanıcı dairesel sayaç alanına dokunduğunda (veya "Devam Et" butonuna
/// bastığında) tetiklenir. React tarafındaki handleIncrement() karşılığıdır.
class ZikirSayacArttirildi extends ZikirEvent {
  const ZikirSayacArttirildi();
}

/// "Oturumu Sıfırla" butonuna basıldığında tetiklenir.
class ZikirSifirlandi extends ZikirEvent {
  const ZikirSifirlandi();
}

/// Kullanıcı, hazır zikir listesinden (ikincil seçenek) bir şablon
/// seçtiğinde tetiklenir.
class ZikirSablonSecildi extends ZikirEvent {
  final int index;
  const ZikirSablonSecildi(this.index);
}

/// ASIL ÖZELLİK: Kullanıcı kendi zikrini kurduğunda (isim + hedef adet
/// + opsiyonel açıklama) tetiklenir. Ürün dokümanı Aşama 3'ün kalbi budur.
class ZikirOzelZikirOlusturuldu extends ZikirEvent {
  final String isim;
  final int hedefAdet;
  final String? aciklama;
  const ZikirOzelZikirOlusturuldu({
    required this.isim,
    required this.hedefAdet,
    this.aciklama,
  });
}

/// Sessiz / Titreşim / Sesli mod arasında geçiş için.
class ZikirSesModuDegistirildi extends ZikirEvent {
  const ZikirSesModuDegistirildi();
}