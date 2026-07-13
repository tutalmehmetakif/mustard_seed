// Değişiklik: ZikirPage kaldırıldı (BlocProvider artık app_router.dart'ta).
// _ZikirView → ZikirView olarak public yapıldı. Mod ikonları 3'lü güncellendi.
// Özel zikir formuna açıklama TextField'ı eklendi. Scaffold ile
// resizeToAvoidBottomInset: false sarıldı. Odak Modu butonu eklendi.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/zikir_bloc.dart';
import '../bloc/zikir_event.dart';
import '../bloc/zikir_state.dart';

/// ================== ZIKIR VIEW ==================
/// MVVM'de "View" katmanı SADECE görünümden sorumludur: ekrana bir şeyler
/// çizer ve kullanıcı etkileşimlerini Event olarak Bloc'a iletir.
/// Bu dosyada hiçbir iş kuralı (sayaç mantığı, tamamlanma kontrolü vb.)
/// YOKTUR — hepsi ZikirBloc içindedir.
///
/// NOT: BlocProvider artık app_router.dart'taki ShellRoute seviyesinde
/// oluşturuluyor. Bu widget doğrudan ZikirBloc'a erişir.
class ZikirView extends StatefulWidget {
  const ZikirView({super.key});

  @override
  State<ZikirView> createState() => _ZikirViewState();
}

class _ZikirViewState extends State<ZikirView> {
  // Ripple (dokunma dalgası) efekti SADECE görsel bir animasyondur,
  // iş mantığıyla ilgisi yoktur. Bu yüzden bilinçli olarak Bloc'ta değil,
  // View'in kendi (yerel) State'inde tutuyoruz. "Her local UI durumu
  // Bloc'a taşınmalı" diye bir kural yoktur; sadece iş/veri durumu
  // Bloc'ta olmalıdır.
  bool _rippleGoster = false;

  void _rippleTetikle() {
    setState(() => _rippleGoster = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _rippleGoster = false);
    });
  }

  /// Kullanıcının kendi zikrini kurabilmesi için basit bir alt-panel
  /// (bottom sheet). Ürün dokümanının Aşama 3'teki asıl istediği akış budur.
  void _ozelZikirOlusturDialogGoster(BuildContext context) {
    final isimController = TextEditingController();
    final adetController = TextEditingController(text: '33');
    final aciklamaController = TextEditingController();
    final bloc = context.read<ZikirBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kendi Zikrini Oluştur', style: AppTextStyles.headlineMd()),
              const SizedBox(height: 16),
              TextField(
                controller: isimController,
                decoration: const InputDecoration(labelText: 'Zikir ismi'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hedef adet'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aciklamaController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama / Meal (opsiyonel)',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldBright,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final isim = isimController.text.trim();
                    final hedef = int.tryParse(adetController.text) ?? 33;
                    if (isim.isEmpty) return;

                    // View, Bloc'a sadece Event fırlatır — state'i kendisi
                    // hesaplamaz.
                    bloc.add(ZikirOzelZikirOlusturuldu(
                      isim: isim,
                      hedefAdet: hedef,
                      aciklama: aciklamaController.text.trim().isEmpty
                          ? null
                          : aciklamaController.text.trim(),
                    ));
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Oluştur ve Başla'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Scaffold ile sararak resizeToAvoidBottomInset: false yapıyoruz.
    // Böylece klavye açıldığında arka plandaki sayaç alanı kaymamalı.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      // BlocBuilder: ZikirBloc'un State'i her değiştiğinde bu widget'ı
      // yeniden çizer. Bu, React'teki useState + re-render mekanizmasının
      // BLoC dünyasındaki karşılığıdır.
      body: BlocBuilder<ZikirBloc, ZikirState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  _ustBaslik(state, isDarkMode),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: _dairesiSayac(context, state, isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sablonSecici(context, state, isDarkMode),
                  if (state.tamamlandiMi) ...[
                    const SizedBox(height: 16),
                    _tamamlandiKutusu(state),
                  ],
                  const SizedBox(height: 20),
                  _altButonlar(context, state, isDarkMode),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Üst başlık: hedef, tamamlanan tur sayısı ve mod anahtarı.
  Widget _ustBaslik(ZikirState state, bool isDarkMode) {
    return Column(
      children: [
        Text(
          'GÜNLÜK ZİKİR',
          style: AppTextStyles.labelSm(
            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ).copyWith(letterSpacing: 2, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text('Hedef: ${state.aktifSablon.target}',
            style: AppTextStyles.headlineMd(
              color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            )),
        if (state.tamamlananTurSayisi > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome,
                  size: 14, color: AppColors.goldBright),
              const SizedBox(width: 4),
              Text(
                'Tamamlanan Tur: ${state.tamamlananTurSayisi}',
                style: AppTextStyles.labelSm(color: AppColors.goldBright),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        // Sessiz / Titreşim / Sesli mod anahtarı (3'lü çevrim).
        GestureDetector(
          onTap: () =>
              context.read<ZikirBloc>().add(const ZikirSesModuDegistirildi()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _modIkonu(state.mod),
                size: 16,
                color: isDarkMode ? AppColors.textSecondaryDark : AppColors.outline,
              ),
              const SizedBox(width: 6),
              Text(
                _modMetni(state.mod),
                style: AppTextStyles.labelSm(
                  color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mod enum'una göre ikon döndürür.
  IconData _modIkonu(ZikirModu mod) {
    switch (mod) {
      case ZikirModu.sessiz:
        return Icons.volume_off;
      case ZikirModu.titresim:
        return Icons.vibration;
      case ZikirModu.sesli:
        return Icons.volume_up;
    }
  }

  /// Mod enum'una göre metin döndürür.
  String _modMetni(ZikirModu mod) {
    switch (mod) {
      case ZikirModu.sessiz:
        return 'Sessiz Mod';
      case ZikirModu.titresim:
        return 'Titreşim Modu';
      case ZikirModu.sesli:
        return 'Sesli Mod';
    }
  }

  /// Ana dairesel sayaç alanı. React'teki SVG dairesel progress ring +
  /// ripple efekti + orta metin bloğunun Flutter karşılığıdır.
  Widget _dairesiSayac(
      BuildContext context, ZikirState state, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        _rippleTetikle();
        // View, sayaç mantığını KENDİSİ hesaplamaz; sadece Event gönderir.
        context.read<ZikirBloc>().add(const ZikirSayacArttirildi());
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple efekti (React'teki AnimatePresence + motion.div karşılığı).
          AnimatedScale(
            scale: _rippleGoster ? 1.5 : 0.8,
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              opacity: _rippleGoster ? 0.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldBright.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          // Dış daire zemini
          Container(
            width: 288,
            height: 288,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDarkMode ? AppColors.surfaceDark : AppColors.surface)
                  .withValues(alpha: 0.6),
            ),
          ),
          // Dairesel ilerleme çizgisi (SVG stroke-dashoffset'in Flutter
          // karşılığı: CircularProgressIndicator + strokeCap.round).
          SizedBox(
            width: 288,
            height: 288,
            child: CircularProgressIndicator(
              value: state.ilerlemeOrani,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor:
                  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.tamamlandiMi ? AppColors.goldBright : AppColors.gold,
              ),
            ),
          ),
          // Orta metin bloğu.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.sayac}',
                  style: AppTextStyles.displayHero(
                    color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ).copyWith(fontSize: 60),
                ),
                const SizedBox(height: 8),
                Text(
                  state.aktifSablon.phrase,
                  style: AppTextStyles.bodyLg(color: AppColors.goldBright)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  state.aktifSablon.translation,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm(
                    color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ).copyWith(fontSize: 10),
                ),
                const SizedBox(height: 12),
                Text(
                  state.tamamlandiMi
                      ? 'BAŞA DÖNMEK İÇİN DOKUNUN'
                      : 'DOKUNARAK DEVAM ET',
                  style: AppTextStyles.labelSm(
                    color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ).copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Zikir seçim çubuğu: hazır zikirler (ikincil seçenek) + "kendi
  /// zikrini oluştur" butonu.
  Widget _sablonSecici(
      BuildContext context, ZikirState state, bool isDarkMode) {
    return Column(
      children: [
        Text('ZİKİR SEÇİMİ',
            style: AppTextStyles.labelSm(
              color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ).copyWith(fontSize: 10)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...List.generate(state.sablonlar.length, (index) {
                final secili = state.seciliSablonIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(state.sablonlar[index].phrase),
                    selected: secili,
                    selectedColor: AppColors.gold,
                    labelStyle: AppTextStyles.labelSm(
                      color: secili ? Colors.white : null,
                    ),
                    onSelected: (_) => context
                        .read<ZikirBloc>()
                        .add(ZikirSablonSecildi(index)),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('Kendi Zikrini Oluştur'),
                  onPressed: () => _ozelZikirOlusturDialogGoster(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tamamlandiKutusu(ZikirState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldBright.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBright.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome,
              size: 18, color: AppColors.goldBright),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Tebrikler! ${state.aktifSablon.phrase} zikrinizi tamamladınız.',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _altButonlar(
      BuildContext context, ZikirState state, bool isDarkMode) {
    return Row(
      children: [
        // Odak Modu butonu
        IconButton(
          onPressed: () => context.push(
            '/zikir/focus',
            extra: context.read<ZikirBloc>(),
          ),
          icon: const Icon(Icons.fullscreen),
          tooltip: 'Odak Modu',
          color: AppColors.outline,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.read<ZikirBloc>().add(const ZikirSifirlandi()),
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('Oturumu Sıfırla'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _rippleTetikle();
              context.read<ZikirBloc>().add(const ZikirSayacArttirildi());
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Devam Et'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldBright,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}