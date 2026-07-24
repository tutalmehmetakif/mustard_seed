import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/deed_list_item.dart';
import '../bloc/daily_deed_bloc.dart';
import '../event/daily_deed_event.dart';
import '../state/daily_deed_state.dart';
import '../widgets/daily_deed_segmented_nav.dart';
import '../widgets/seed_jar_view.dart';

const _completionMessages = [
  'Bir tohum ektin.',
  'Küçük bir adım, güzel bir iz.',
  'Bu, kaybolmayacak bir şey.',
  'Bu hayır deftere düştü.',
];

class DailyDeedPage extends StatefulWidget {
  const DailyDeedPage({super.key});

  @override
  State<DailyDeedPage> createState() => _DailyDeedPageState();
}

class _DailyDeedPageState extends State<DailyDeedPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<DailyDeedBloc, DailyDeedState>(
      listenWhen: (previous, current) =>
          current.monthlySeedCount > previous.monthlySeedCount,
      listener: (context, state) {
        final message = _completionMessages[
            state.monthlySeedCount % _completionMessages.length];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            content: Row(
              children: [
                const Icon(Icons.eco, color: AppColors.goldBright, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodyMd(
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
      child: BlocBuilder<DailyDeedBloc, DailyDeedState>(
        builder: (context, state) {
          if (state.status == DailyDeedStatus.loading ||
              state.status == DailyDeedStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldBright),
            );
          }

          if (state.status == DailyDeedStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Bir şeyler ters gitti.',
                style: AppTextStyles.bodyMd(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            );
          }

          final now = DateTime.now();
          final targetCount = DateTime(now.year, now.month + 1, 0).day;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.horizontalMargin,
                  24,
                  context.horizontalMargin,
                  24,
                ),
                child: DailyDeedSegmentedNav(
                  selectedIndex: _selectedTab,
                  onChanged: (index) => setState(() => _selectedTab = index),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: _selectedTab == 0
                      ? SingleChildScrollView(
                          key: const ValueKey('amellerim'),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.horizontalMargin,
                          ),
                          child: _DeedListView(deeds: state.deeds),
                        )
                      : Padding(
                          key: const ValueKey('kavanoz'),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.horizontalMargin,
                            vertical: 8,
                          ),
                          child: SeedJarView(
                            seedCount: state.monthlySeedCount,
                            targetCount: targetCount,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeedListView extends StatelessWidget {
  const _DeedListView({required this.deeds});
  final List<DeedListItem> deeds;

  @override
  Widget build(BuildContext context) {
    if (deeds.isEmpty) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Text(
        'Henüz eklenmiş bir amel yok.',
        style: AppTextStyles.bodyMd(
          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: deeds.map((deed) => _DeedRow(deed: deed)).toList(),
    );
  }
}

class _DeedRow extends StatelessWidget {
  const _DeedRow({required this.deed});
  final DeedListItem deed;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                deed.text,
                style: AppTextStyles.bodyMd(
                  color: deed.completedToday
                      ? (isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)
                      : (isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                ).copyWith(
                  decoration:
                      deed.completedToday ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: deed.completedToday
                  ? null
                  : () => context
                      .read<DailyDeedBloc>()
                      .add(DeedCompleted(deed.id)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: deed.completedToday
                      ? AppColors.goldBright
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.goldBright,
                    width: 1.5,
                  ),
                ),
                child: deed.completedToday
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}