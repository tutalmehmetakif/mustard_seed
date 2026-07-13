import 'package:flutter_bloc/flutter_bloc.dart';

/// Karanlık/aydınlık mod seçimini tutan basit Cubit. State `true` ise
/// karanlık mod, `false` ise aydınlık mod aktiftir.
///
/// Kök seviyede (main.dart, MaterialApp.router'ın üstünde) sağlanıyor ve
/// MaterialApp.themeMode buna bağlı — yani bu, uygulama genelindeki
/// gerçek tema tercihidir, sadece Profil sayfasına özgü değildir.
///
/// ÖNEMLİ SINIR: MaterialApp.themeMode değişse de, uygulamadaki ekranların
/// çoğu (Ana Sayfa, Zikir, Kur'an'a Sor, HomeShellPage'in AppBar/BottomNav'ı)
/// [AppColors]'u [Theme.of(context)] üzerinden değil, doğrudan sabit
/// olarak kullanıyor — bu yüzden karanlık mod açıldığında henüz sadece bu
/// deseni takip eden ekranlarda (bkz. ProfilePage) görsel değişiklik olur.
class ThemeCubit extends Cubit<bool> {
  /// Başlangıç durumu: aydınlık (light) mod.
  ThemeCubit() : super(false);

  /// Karanlık/aydınlık modu tersine çevirir.
  void toggle() => emit(!state);
}
