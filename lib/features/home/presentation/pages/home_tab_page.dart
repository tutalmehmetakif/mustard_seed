import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/auth/data/state/auth_state.dart';
import 'package:mustard_seed/features/home/domain/repositories/recommended_activity_repository.dart';
import 'package:mustard_seed/features/home/presentation/widgets/recommended_activities_list_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

import '../../domain/repositories/verse_repository.dart';
import '../bloc/home_bloc.dart';
import '../event/home_event.dart';
import '../state/home_state.dart';
import '../widgets/ask_quran_quick_card.dart';
import '../widgets/quick_zikir_counter_card.dart';
import '../widgets/recommended_card.dart';
import '../widgets/verse_card.dart';

/// Ana Sayfa sekmesinin içeriği (bottom nav'ın "Ana Sayfa" sekmesi).
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
  verseRepository: context.read<VerseRepository>(),
  recommendedActivityRepository:
      context.read<RecommendedActivityRepository>(),
)..add(const HomeStarted()),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalMargin,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Greeting(),
            const SizedBox(height: 24),
            const VerseCard(),
            const SizedBox(height: 24),
            const AskQuranQuickCard(),
            const SizedBox(height: 16),
            const QuickZikirCounterCard(),
            const SizedBox(height: 28),
            BlocBuilder<HomeBloc, HomeState>(
  builder: (context, state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TAVSİYE EDİLENLER',
          style: AppTextStyles.labelSm(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecommendedActivitiesListPage(
                activities: state.recommended,
              ),
            ),
          ),
          child: Text(
            'Tümünü Gör',
            style: AppTextStyles.labelSm(color: AppColors.gold)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  },
),
const SizedBox(height: 12),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return SizedBox(
                  height: 175,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.recommended.length,
                    itemBuilder: (context, index) => RecommendedCard(
                      activity: state.recommended[index],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  String _dynamicGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Hayırlı Sabahlar, $name.';
    if (hour >= 12 && hour < 18) return 'Hayırlı Günler, $name.';
    if (hour >= 18 && hour < 22) return 'Hayırlı Akşamlar, $name.';
    return 'Hayırlı Geceler, $name.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final displayName = state.user?.displayName?.trim();
        final name = (displayName != null && displayName.isNotEmpty)
            ? displayName
            : (state.user?.email?.split('@').first ?? 'Can');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_dynamicGreeting(name), style: AppTextStyles.headlineLg()),
            const SizedBox(height: 4),
            Text(
              'Bugün ruhunu dinlendirmek için neye ihtiyacın var?',
              style: AppTextStyles.bodyMd(),
            ),
          ],
        );
      },
    );
  }
}