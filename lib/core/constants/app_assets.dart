/// Görsel asset yollarını tek yerden yönetir.
/// pubspec.yaml -> flutter.assets altında `assets/images/` klasörünün
/// tanımlı olması gerekir.
class AppAssets {
  AppAssets._();

  static const String _base = 'assets/images';

  static const String onboardingGuidance = '$_base/onboarding_guidance.jpg';
  static const String onboardingIntention = '$_base/onboarding_intention.jpg';
  static const String hardalTanesiLogo = '$_base/hardal_tanesi_logo.jpg';
}
