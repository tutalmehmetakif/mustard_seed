import 'package:flutter/material.dart';

/// [ProfileMenuItem] satırını çizmek için gereken saf veriyi tutar.
///
/// [onTap] null ise satır pasif kabul edilir (imleç `not-allowed`, soluk
/// görünüm, dokunma tepkisi yok) — henüz arkasında gerçek bir özellik ya
/// da route olmayan (bildirimler, dil, gizlilik, abonelik gibi) satırlar
/// için kullanılır. Bkz. ProfilePage'teki TODO(profil) notu.
@immutable
class ProfileMenuItemData {
  const ProfileMenuItemData({
    required this.icon,
    required this.title,
    required this.trailingLabel,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String trailingLabel;
  final Color? iconColor;
  final VoidCallback? onTap;

  bool get isEnabled => onTap != null;
}
