import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/supabase_ask_quran_repository.dart';
import '../bloc/ask_bloc.dart';
import '../event/ask_event.dart';
import '../state/ask_state.dart';
import '../widgets/chat_bubble.dart';

class AskPage extends StatelessWidget {
  const AskPage({super.key});

  static const List<String> _suggestions = [
    'Zor zamanlarda nasıl sabırlı olabilirim?',
    'Sabır hakkında ayetler',
    'Kaygı ve huzur',
    'Şükretmenin önemi',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AskBloc(
        askQuranRepository: SupabaseAskQuranRepository(),
      ),
      child: const _AskView(),
    );
  }
}

class _AskView extends StatefulWidget {
  const _AskView();

  @override
  State<_AskView> createState() => _AskViewState();
}

class _AskViewState extends State<_AskView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    context.read<AskBloc>().add(AskMessageSent(text));
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      child: BlocConsumer<AskBloc, AskState>(
        listenWhen: (previous, current) =>
            previous.messages.length != current.messages.length,
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.horizontalMargin,
                    vertical: 16,
                  ),
                  children: [
                    if (state.messages.length == 1) const _WelcomeBanner(),
                    for (final message in state.messages) ...[
                      ChatBubble(message: message),
                      const SizedBox(height: 16),
                    ],
                    if (state.isLoading) const _LoadingBubble(),
                    if (state.status == AskStatus.failure)
                      _ErrorBanner(message: state.errorMessage ?? ''),
                    if (state.limitReached) const _LimitReachedBanner(),
                    if (state.messages.length == 1 && !state.isLoading)
                      _SuggestionChips(
                        suggestions: AskPage._suggestions,
                        onTap: _send,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: context.horizontalMargin,
                  right: context.horizontalMargin,
                  bottom: 8,
                ),
                child: Text(
                  'Yapay zeka yanıtları hata içerebilir. Lütfen teyit ediniz.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm(
                    color: (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary)
                        .withValues(alpha: 0.4),
                  ),
                ),
              ),
              _InputBar(
                controller: _textController,
                enabled: !state.isLoading,
                onSubmit: _send,
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.goldBright.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.goldBright,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Kur'an'a Sor",
            style: AppTextStyles.headlineMd(
              color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Zihninizi meşgul eden meseleleri fısıldayın; ayetlerin '
            'sükûnet veren hikmetlerini keşfedin.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(
              color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.goldBright,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ayetlerden şifa aranıyor...',
              style: AppTextStyles.labelSm(
                color: (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary)
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelSm(color: AppColors.error),
            ),
          ),
          TextButton.icon(
            onPressed: () =>
                context.read<AskBloc>().add(const AskRetryRequested()),
            icon: const Icon(Icons.refresh, size: 14, color: AppColors.error),
            label: Text(
              'Tekrar Dene',
              style: AppTextStyles.labelSm(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitReachedBanner extends StatelessWidget {
  const _LimitReachedBanner();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldBright.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_outlined,
              color: AppColors.gold, size: 22),
          const SizedBox(height: 8),
          Text(
            'Günlük ücretsiz soru hakkını kullandın.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(
              color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            // TODO(premium): RevenueCat akışı kurulunca burası gerçek
            // premium ekranını açacak bir butona dönüşecek.
            'Sınırsız soru için Premium\'a geçmen gerekiyor (yakında).',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm(
              color: (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.suggestions, required this.onTap});

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text(
            'ÖNERİLEN KONULAR',
            style: AppTextStyles.labelSm(
              color: (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary)
                  .withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () => onTap(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    s,
                    style: AppTextStyles.labelSm(
                      color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalMargin,
        vertical: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: enabled
                  ? () => onSubmit('Sükunet ve sabır duası')
                  : null,
              icon: Icon(Icons.mic_none_outlined, color: mutedColor),
              tooltip: 'Sabır duası iste',
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: onSubmit,
                style: AppTextStyles.bodyMd(
                  color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Bir soru sor...',
                  hintStyle: AppTextStyles.bodyMd(color: mutedColor.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = enabled && value.text.trim().isNotEmpty;
                return Material(
                  color: canSend ? AppColors.gold : mutedColor.withValues(alpha: 0.15),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: canSend ? () => onSubmit(controller.text) : null,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.send, size: 18, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}