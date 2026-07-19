import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';

class LessonPage extends ConsumerStatefulWidget {
  final String slug;
  final int index;
  const LessonPage({super.key, required this.slug, required this.index});

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  @override
  Widget build(BuildContext context) {
    final course = courseForSlug(widget.slug);
    final lesson = course.lessons[widget.index];
    final g = ref.watch(gamificationProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final done = g.isLessonDone(course.slug, widget.index);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('${L10n.tr('lesson', locale)} ${widget.index + 1}'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s8, AppTheme.s24, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(lt(lesson.title, locale), style: text.headlineLarge),
                      const SizedBox(height: AppTheme.s8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
                            decoration: BoxDecoration(
                              color: course.category.accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(AppTheme.rFull),
                            ),
                            child: Text('${lesson.minutes} min',
                                style: text.labelSmall!.copyWith(color: course.category.accent)),
                          ),
                          const SizedBox(width: AppTheme.s8),
                          Text(lt(course.title, locale),
                              style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
                        ],
                      ),
                      const SizedBox(height: AppTheme.s20),
                      ...lesson.paragraphs.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.s16),
                            child: Text(lt(p, locale), style: text.bodyLarge!.copyWith(height: 1.6)),
                          )),
                      const SizedBox(height: AppTheme.s24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, AppTheme.s24),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: done
                    ? null
                    : () {
                        final fresh = ref.read(gamificationProvider.notifier).completeLesson(course.slug, widget.index);
                        if (fresh && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(L10n.tr('lesson_complete_xp', locale)),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
                            ),
                          );
                        }
                      },
                icon: Icon(done ? Icons.check_circle_rounded : Icons.check_rounded),
                label: Text(done ? L10n.tr('completed', locale) : L10n.tr('mark_complete', locale)),
                style: FilledButton.styleFrom(
                  backgroundColor: done ? cs.surfaceContainerHighest : AppTheme.brand,
                  foregroundColor: done ? cs.onSurface.withValues(alpha: 0.6) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}