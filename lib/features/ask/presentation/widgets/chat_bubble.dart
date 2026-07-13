import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';

/// Tek bir sohbet balonu. AI mesajları içinde ayet alıntısı gibi görünen
/// paragrafları (örn. `"..." SURESİ, N. AYET` içerenler) özel bir
/// kart içinde, serif/italik olarak gösterir — React tasarımındaki
/// `renderMessageContent` mantığının Flutter karşılığı.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  bool get _isUser => message.sender == ChatSender.user;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isUser
                ? AppColors.gold
                : (isDarkMode ? AppColors.surfaceDark : AppColors.surface),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(_isUser ? 20 : 4),
              bottomRight: Radius.circular(_isUser ? 4 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isUser ? 'SİZ' : 'MANEVİ REHBER',
                style: AppTextStyles.labelSm(
                  color: (_isUser ? Colors.white : AppColors.goldBright)
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              if (_isUser)
                Text(
                  message.text,
                  style: AppTextStyles.bodyMd(color: Colors.white),
                )
              else
                _AiMessageContent(text: message.text),
            ],
          ),
        ),
      ),
    );
  }
}

/// AI cevabını paragraflara böler, ayet alıntısı gibi görünenleri özel
/// kart içinde gösterir, geri kalanını normal metin olarak basar.
class _AiMessageContent extends StatelessWidget {
  const _AiMessageContent({required this.text});

  final String text;

  static final RegExp _referencePattern = RegExp(
    r'[A-ZÇĞİÖŞÜa-zçğıöşü\s]+ Suresi,?\s*\d+\.?\s*Ayet',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final paragraphs = text.split('\n\n').where((p) => p.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        final trimmed = paragraph.trim();
        final referenceMatch = _referencePattern.firstMatch(trimmed);
        final looksLikeQuote =
            trimmed.startsWith('"') || referenceMatch != null;

        if (looksLikeQuote) {
          final reference = referenceMatch?.group(0);
          final body = reference != null
              ? trimmed.replaceAll(reference, '').replaceAll('"', '').trim()
              : trimmed.replaceAll('"', '').trim();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.backgroundDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.goldBright,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"$body"',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLg(color: AppColors.goldBright)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                  if (reference != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      reference.toUpperCase(),
                      style: AppTextStyles.labelSm(
                        color: (isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            trimmed,
            style: AppTextStyles.bodyMd(
              color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}