import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'zikir_event.dart';
import 'zikir_state.dart';

/// ================== ZIKIR BLOC (VIEWMODEL) ==================
/// MVVM'deki "ViewModel" görevini burada BLoC görür.
/// - View: zikir_page.dart (kullanıcıya çizilen kısım, hiç iş mantığı içermez)
/// - ViewModel: ZikirBloc (bu dosya) — Event alır, iş kurallarını uygular,
///   yeni bir State üretip yayınlar (emit).
/// - Model: ZikirTemplate / ZikirState (saf veri sınıfları).
///
/// View bu sınıfa DOĞRUDAN erişmez; sadece Event gönderir ve State dinler.
/// Böylece arayüz (Flutter widget'ları) ile iş mantığı birbirinden
/// tamamen ayrılmış olur — test edilebilirlik ve bakım kolaylığı sağlar.
class ZikirBloc extends Bloc<ZikirEvent, ZikirState> {
  final FlutterTts _tts;

  ZikirBloc({FlutterTts? tts})
      : _tts = tts ?? FlutterTts(),
        super(ZikirState.baslangic()) {
    // TTS başlangıç ayarları
    _initTts();

    // Her Event tipi için ayrı bir handler (işleyici) fonksiyon bağlanır.
    on<ZikirSayacArttirildi>(_sayaciArttir);
    on<ZikirSifirlandi>(_sifirla);
    on<ZikirSablonSecildi>(_sablonSec);
    on<ZikirOzelZikirOlusturuldu>(_ozelZikirOlustur);
    on<ZikirSesModuDegistirildi>(_sesModunuDegistir);
  }

  /// TTS motorunu Arapça dil, tam ses seviyesi ve uygun ses perdesi ile başlat.
  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ar');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
        );
      }
    } catch (_) {}
  }

  /// Latin harfli varsayılan zikirlerin Arapça TTS motoru tarafından
  /// harf harf kodlanmak yerine doğru Arapça kelimeler olarak telaffuz edilmesi için
  /// Arapça karşılıklarını döndürür.
  String _getArabicSpeechText(String phrase) {
    final cleaned = phrase.trim().toLowerCase();
    switch (cleaned) {
      case 'subhanallah':
        return 'سبحان الله';
      case 'elhamdülillah':
      case 'elhamdulillah':
        return 'الحمد لله';
      case 'allahu ekber':
      case 'allahü ekber':
        return 'الله أكبر';
      case 'la ilahe illallah':
        return 'لا إله إلا الله';
      default:
        return phrase;
    }
  }

  Future<void> _sayaciArttir(
    ZikirSayacArttirildi event,
    Emitter<ZikirState> emit,
  ) async {
    final index = state.seciliSablonIndex;
    final aktifMod = state.mod;
    final aktifPhrase = state.aktifSablon.phrase;

    // Mod'a göre geri bildirim (iş mantığı Bloc'ta kalır — View'den çağrılmaz).
    // Başta veya sonda tetiklenebilir; kullanıcı dokunma hissini anında alsın diye burada çağırıyoruz.
    switch (aktifMod) {
      case ZikirModu.sessiz:
        break;
      case ZikirModu.titresim:
        await HapticFeedback.mediumImpact();
        break;
      case ZikirModu.sesli:
        final speakText = _getArabicSpeechText(aktifPhrase);
        await _tts.speak(speakText);
        break;
    }

    // React koddaki handleIncrement() ile birebir aynı mantık:
    // Eğer tur zaten tamamlandıysa, dokunma yeni bir tur başlatır.
    if (state.tamamlandiMi) {
      final yeniSayacMap = Map<int, int>.from(state.sablonSayaclari);
      final yeniTamamMap = Map<int, bool>.from(state.sablonTamamlandiMi);
      yeniSayacMap[index] = 0;
      yeniTamamMap[index] = false;
      emit(state.copyWith(
        sablonSayaclari: yeniSayacMap,
        sablonTamamlandiMi: yeniTamamMap,
      ));
      return;
    }

    final yeniSayac = state.sayac + 1;
    final hedefeUlasildiMi = yeniSayac >= state.aktifSablon.target;

    final yeniSayacMap = Map<int, int>.from(state.sablonSayaclari);
    final yeniTamamMap = Map<int, bool>.from(state.sablonTamamlandiMi);

    yeniSayacMap[index] =
        hedefeUlasildiMi ? state.aktifSablon.target : yeniSayac;
    yeniTamamMap[index] = hedefeUlasildiMi;

    // Tur tamamlandıysa ilgili şablonun tur sayısını artır.
    Map<int, int>? yeniTurMap;
    if (hedefeUlasildiMi) {
      yeniTurMap = Map<int, int>.from(state.sablonTurSayilari);
      yeniTurMap[index] = (yeniTurMap[index] ?? 0) + 1;
    }

    emit(state.copyWith(
      sablonSayaclari: yeniSayacMap,
      sablonTamamlandiMi: yeniTamamMap,
      sablonTurSayilari: yeniTurMap,
    ));

    // TODO (Kalıcılık / Persistence): "Yarıda bırakıp devam edebilme"
    // gereksinimi için burada bir ZikirRepository çağrısı yapılmalı,
    // örn: await _zikirRepository.ilerlemeyiKaydet(state);
    // Projenizin mevcut veri katmanı (Hive/SharedPreferences/Supabase vb.)
    // hangisiyse, o repository bu Bloc'a constructor injection ile
    // verilmelidir. Mevcut dosyalara dokunmamak için burada sadece
    // eklenmesi gereken noktayı işaretliyorum.
  }

  void _sifirla(ZikirSifirlandi event, Emitter<ZikirState> emit) {
    final index = state.seciliSablonIndex;
    final yeniSayacMap = Map<int, int>.from(state.sablonSayaclari);
    final yeniTamamMap = Map<int, bool>.from(state.sablonTamamlandiMi);
    yeniSayacMap[index] = 0;
    yeniTamamMap[index] = false;
    emit(state.copyWith(
      sablonSayaclari: yeniSayacMap,
      sablonTamamlandiMi: yeniTamamMap,
    ));
  }

  void _sablonSec(ZikirSablonSecildi event, Emitter<ZikirState> emit) {
    // Artık şablon değiştiğinde sayaç/tamamlanma sıfırlanmaz; her şablon
    // kendi Map girdisini korur.
    emit(state.copyWith(seciliSablonIndex: event.index));
  }

  void _ozelZikirOlustur(
    ZikirOzelZikirOlusturuldu event,
    Emitter<ZikirState> emit,
  ) {
    // Ürün dokümanının Aşama 3'teki ASIL istediği özellik: kullanıcı
    // kendi zikrinin ismini ve hedef adedini kendisi belirliyor.
    final yeniSablon = state.aktifSablon.copyWith(
      phrase: event.isim,
      translation: event.aciklama ?? 'Kişisel zikriniz',
      target: event.hedefAdet,
    );

    final yeniListe = [...state.sablonlar, yeniSablon];

    emit(state.copyWith(
      sablonlar: yeniListe,
      seciliSablonIndex: yeniListe.length - 1,
    ));
  }

  void _sesModunuDegistir(
    ZikirSesModuDegistirildi event,
    Emitter<ZikirState> emit,
  ) {
    // 3'lü çevrim: sessiz → titresim → sesli → sessiz
    final ZikirModu yeniMod;
    switch (state.mod) {
      case ZikirModu.sessiz:
        yeniMod = ZikirModu.titresim;
        break;
      case ZikirModu.titresim:
        yeniMod = ZikirModu.sesli;
        break;
      case ZikirModu.sesli:
        yeniMod = ZikirModu.sessiz;
        break;
    }
    emit(state.copyWith(mod: yeniMod));
  }

  @override
  Future<void> close() {
    _tts.stop();
    return super.close();
  }
}