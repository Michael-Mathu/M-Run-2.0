import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';


class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final categories = CourseCategory.values;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.tr('learn', locale)),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s8, AppTheme.s24, AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(L10n.tr('academy', locale), style: text.headlineMedium),
                const SizedBox(height: AppTheme.s4),
                Text(L10n.tr('academy_tag', locale),
                    style: text.bodyMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: AppTheme.s24),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ...categories.map((cat) {
                final catCourses = courses.where((c) => c.category == cat).toList();
                if (catCourses.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.accent, size: 22),
                            const SizedBox(width: AppTheme.s8),
                            Text(lt(cat.label, locale), style: text.titleLarge),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.s12),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
                          itemCount: catCourses.length,
                          separatorBuilder: (_, _) => const SizedBox(width: AppTheme.s12),
                          itemBuilder: (_, i) {
                            final c = catCourses[i];
                            return _CourseCardHorizontal(course: c, locale: locale);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.s8),
                  Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, size: 22, color: AppTheme.tierGold),
                      const SizedBox(width: AppTheme.s8),
                      Text(L10n.tr('legends_title', locale), style: text.titleLarge),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s12),
                  Text(L10n.tr('legends_teaser_sub', locale),
                      style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppTheme.s16),
                  Text(L10n.tr('race_ghost_legend', locale),
                      style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.s4),
                  Text(L10n.tr('race_ghost_sub', locale),
                      style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
                  const SizedBox(height: AppTheme.s20),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/learn/legends'),
                      icon: const Icon(Icons.person_rounded),
                      label: Text(L10n.tr('your_legends', locale)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.brand,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCardHorizontal extends StatelessWidget {
  final Course course;
  final AppLocale locale;
  const _CourseCardHorizontal({required this.course, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width * 0.72;

    return GestureDetector(
      onTap: () => context.push('/learn/course/${course.slug}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppTheme.r16),
          border: Border.all(color: cs.surfaceContainerHighest),
        ),
        padding: const EdgeInsets.all(AppTheme.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(course.category.icon, color: course.category.accent, size: 24),
            const SizedBox(height: AppTheme.s8),
            Text(lt(course.title, locale),
                style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppTheme.s2),
            Text(lt(course.subtitle, locale),
                style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text('${L10n.tr('by', locale)} ${lt(course.author, locale)}',
                style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

/*
class _LegendCardTeaser extends StatelessWidget {
  final Legend legend;
  final AppLocale locale;
  const _LegendCardTeaser({required this.legend, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = legendAccent(legend);

    return GestureDetector(
      onTap: () => context.push('/learn/legends/${legend.slug}'),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.r16),
          border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: accent.withValues(alpha: 0.18),
              child: Text(legend.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: AppTheme.s8),
            Text(legend.name, style: text.titleSmall),
            const SizedBox(height: AppTheme.s2),
            Text(lt(legend.discipline, locale),
                style: text.labelSmall!.copyWith(color: accent, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
*/