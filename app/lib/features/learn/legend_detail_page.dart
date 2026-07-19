import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';

/// Parse a time string ("2:01:09", "12:37.35", "1:40.91") into seconds.
double _parseTimeToSeconds(String t) {
  final parts = t.split(':').map((p) => double.tryParse(p) ?? 0).toList();
  if (parts.isEmpty) return 0;
  if (parts.length == 3) return parts[0] * 3600 + parts[1] * 60 + parts[2];
  if (parts.length == 2) return parts[0] * 60 + parts[1];
  return parts[0];
}

/// Distance buckets a user run can match against a legend's personal best.
const Map<String, ({double meters, List<String> legendKeys})> _compareBuckets = {
  '5K': (meters: 5000, legendKeys: ['5000m', '5K']),
  '10K': (meters: 10000, legendKeys: ['10,000m', '10K (road)', '10K']),
  'Half': (meters: 21097.5, legendKeys: ['Half Marathon', 'Half']),
  'Marathon': (meters: 42195, legendKeys: ['Marathon']),
};

class LegendDetailPage extends ConsumerWidget {
  final String slug;
  const LegendDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = legendForSlug(slug);
    final accent = legendAccent(l);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final runsAsync = ref.watch(activitiesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(AppTheme.s24, MediaQuery.of(context).padding.top + AppTheme.s16, AppTheme.s24, AppTheme.s24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.9), accent.withValues(alpha: 0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppBackButton(color: Colors.white),
                      const SizedBox(width: AppTheme.s8),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(l.emoji, style: const TextStyle(fontSize: 36)),
                      ),
                      const SizedBox(width: AppTheme.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.name,
                                style: text.headlineLarge!.copyWith(color: Colors.white)),
                            const SizedBox(height: AppTheme.s4),
                            Row(
                              children: [
                                Text(l.flag, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: AppTheme.s6),
                                Text('${lt(l.country, locale)} · ${lt(l.discipline, locale)}',
                                    style: text.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s16),
                  Text(lt(l.tagline, locale),
                      style: text.titleMedium!.copyWith(color: Colors.white.withValues(alpha: 0.95))),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(L10n.tr('biography', locale), style: text.titleLarge),
                const SizedBox(height: AppTheme.s8),
                Text(lt(l.bio, locale), style: text.bodyLarge!.copyWith(height: 1.6)),
                const SizedBox(height: AppTheme.s24),

                // ---- Personal Bests ----
                if (l.personalBests != null) ...[
                  Text(L10n.tr('personal_bests', locale), style: text.titleLarge),
                  const SizedBox(height: AppTheme.s12),
                  Wrap(
                    spacing: AppTheme.s12,
                    runSpacing: AppTheme.s12,
                    children: l.personalBests!.entries
                        .map((e) => _BestCard(distance: e.key, time: e.value, accent: accent))
                        .toList(),
                  ),
                  const SizedBox(height: AppTheme.s24),
                ],

                // ---- How You Compare (Step 5) ----
                Text(L10n.tr('how_you_compare', locale), style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                runsAsync.when(
                  loading: () => const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (_, _) => _CompareEmpty(onStart: () => context.go('/run'), locale: locale),
                  data: (runs) => _HowYouCompare(legend: l, runs: runs, accent: accent, locale: locale),
                ),
                const SizedBox(height: AppTheme.s24),

                // ---- Career Timeline ----
                Text(L10n.tr('career_timeline', locale), style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                ...l.timeline.map((m) => _TimelineRow(year: m.year, text: lt(m.text, locale), accent: accent)),
                const SizedBox(height: AppTheme.s24),

                // ---- Records ----
                Text(L10n.tr('records', locale), style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                ...l.records.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.s8),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events_rounded, color: AppTheme.tierGold, size: 20),
                          const SizedBox(width: AppTheme.s12),
                          Expanded(child: Text(lt(r, locale), style: text.bodyMedium)),
                        ],
                      ),
                    )),
                const SizedBox(height: AppTheme.s24),

                // ---- Community Results ----
                _CommunitySection(legend: l, accent: accent, locale: locale),
                const SizedBox(height: AppTheme.s24),

                // ---- Training Philosophy ----
                if (l.trainingPhilosophy != null) ...[
                  Text(L10n.tr('training_philosophy', locale), style: text.titleLarge),
                  const SizedBox(height: AppTheme.s12),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.s16),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.r16),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.self_improvement_rounded, color: accent, size: 22),
                            const SizedBox(width: AppTheme.s12),
                            Expanded(
                              child: Text(lt(l.trainingPhilosophy!, locale),
                                  style: text.bodyMedium!.copyWith(height: 1.6)),
                            ),
                          ],
                        ),
                        if (l.relatedCourseSlug != null) ...[
                          const SizedBox(height: AppTheme.s12),
                          _CourseLinkChip(slug: l.relatedCourseSlug!, accent: accent, locale: locale),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.s24),
                ],

                // ---- Rivalries ----
                if (l.rivals.isNotEmpty) ...[
                  Text(L10n.tr('rivalries', locale), style: text.titleLarge),
                  const SizedBox(height: AppTheme.s12),
                  Wrap(
                    spacing: AppTheme.s8,
                    runSpacing: AppTheme.s8,
                    children: l.rivals
                        .map((r) => _RivalChip(rival: r, accent: accent))
                        .toList(),
                  ),
                  const SizedBox(height: AppTheme.s24),
                ],

                // ---- Notable Races ----
                if (l.notableRaces != null) ...[
                  Text(L10n.tr('notable_races', locale), style: text.titleLarge),
                  const SizedBox(height: AppTheme.s12),
                  ...l.notableRaces!.map((race) => Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.s12),
                        padding: const EdgeInsets.all(AppTheme.s16),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(AppTheme.r16),
                          border: Border.all(color: cs.surfaceContainerHighest),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.flag_rounded, color: accent, size: 20),
                            const SizedBox(width: AppTheme.s12),
                            Expanded(
                              child: Text(lt(race, locale), style: text.bodyMedium!.copyWith(height: 1.5)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppTheme.s24),
                ],

                // ---- Quotes (expanded with categories) ----
                Text(L10n.tr('in_their_words', locale), style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                ...l.quotes.map((q) => _QuoteCard(text: lt(q, locale), accent: accent)),
                if (l.quotesExtra != null)
                  ...l.quotesExtra!.map((q) {
                    final meta = LegendQuote.categoryMeta[q.category] ??
                        (Icons.format_quote_rounded, (en: L10n.tr('quote', locale), sw: L10n.tr('quote', locale)));
                    return _QuoteCard(
                      text: lt(q.text, locale),
                      accent: accent,
                      icon: meta.$1,
                      label: lt(meta.$2, locale),
                    );
                  }),
                const SizedBox(height: AppTheme.s12),

                if (l.beatLegendId != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push('/beat/${l.beatLegendId}'),
                      icon: const Icon(Icons.speed_rounded),
                      label: Text(L10n.tr('challenge_me', locale)),
                      style: FilledButton.styleFrom(backgroundColor: accent),
                    ),
                  ),
                const SizedBox(height: AppTheme.s24),

                // ---- Fun Fact ----
                if (l.funFact != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.s16),
                    decoration: BoxDecoration(
                      color: AppTheme.tierGold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.r16),
                      border: Border.all(color: AppTheme.tierGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: AppTheme.tierGold, size: 22),
                        const SizedBox(width: AppTheme.s12),
                        Expanded(
                          child: Text(lt(l.funFact!, locale),
                              style: text.bodyMedium!
                                  .copyWith(fontStyle: FontStyle.italic, height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.s24),
                ],

                // ---- Related Legends carousel ----
                if (l.related.isNotEmpty) ...[
                  Text(L10n.tr('related_legends', locale), style: text.titleLarge),
                  const SizedBox(height: AppTheme.s12),
                  SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: l.related.length,
                      separatorBuilder: (_, _) => const SizedBox(width: AppTheme.s12),
                      itemBuilder: (_, i) {
                        final rel = l.related[i];
                        return _RelatedCard(legend: rel);
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.s24),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BestCard extends StatelessWidget {
  final String distance;
  final String time;
  final Color accent;
  const _BestCard({required this.distance, required this.time, required this.accent});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: 110,
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(distance, style: text.labelSmall!.copyWith(color: accent, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppTheme.s4),
          Text(time, style: text.titleMedium!.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}

class _CourseLinkChip extends StatelessWidget {
  final String slug;
  final Color accent;
  final AppLocale locale;
  const _CourseLinkChip({required this.slug, required this.accent, required this.locale});

  @override
  Widget build(BuildContext context) {
    final course = courseForSlug(slug);
    return GestureDetector(
      onTap: () => context.go('/learn/course/$slug'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s8),
        decoration: BoxDecoration(
          color: course.category.accent.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppTheme.rFull),
          border: Border.all(color: course.category.accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(course.category.icon, color: course.category.accent, size: 16),
            const SizedBox(width: AppTheme.s6),
            Text('${L10n.tr('learn', locale)}: ${lt(course.title, locale)}',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: course.category.accent)),
          ],
        ),
      ),
    );
  }
}

class _RivalChip extends StatelessWidget {
  final Legend rival;
  final Color accent;
  const _RivalChip({required this.rival, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/learn/legends/${rival.slug}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.rFull),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rival.flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: AppTheme.s6),
            Text(rival.name, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String text;
  final Color accent;
  final IconData? icon;
  final String? label;
  const _QuoteCard({required this.text, required this.accent, this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.s12),
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.s8),
              child: Row(
                children: [
                  Icon(icon, color: accent, size: 16),
                  const SizedBox(width: AppTheme.s6),
                  Text(label!.toUpperCase(),
                      style: textTheme.labelSmall!.copyWith(color: accent, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('“', style: textTheme.displayMedium!.copyWith(color: accent, height: 0.6)),
              const SizedBox(width: AppTheme.s8),
              Expanded(
                child: Text(text, style: textTheme.titleMedium!.copyWith(fontStyle: FontStyle.italic)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final Legend legend;
  const _RelatedCard({required this.legend});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accent = legendAccent(legend);
    return GestureDetector(
      onTap: () => context.push('/learn/legends/${legend.slug}'),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(AppTheme.s12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppTheme.r16),
          border: Border.all(color: cs.surfaceContainerHighest),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withValues(alpha: 0.18),
                  child: Text(legend.emoji, style: const TextStyle(fontSize: 18)),
                ),
                const Spacer(),
                Text(legend.flag, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: AppTheme.s10),
            Text(legend.name,
                style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppTheme.s2),
            Text(lt(legend.discipline, Localizations.localeOf(context).languageCode == 'sw' ? AppLocale.swahili : AppLocale.english),
                style: text.labelSmall!.copyWith(color: accent, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _CompareEmpty extends StatelessWidget {
  final VoidCallback onStart;
  final AppLocale locale;
  const _CompareEmpty({required this.onStart, required this.locale});
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.s20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: Border.all(color: cs.surfaceContainerHighest),
      ),
      child: Column(
        children: [
          Icon(Icons.route_rounded, size: 32, color: cs.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: AppTheme.s8),
          Text(L10n.tr('start_running_to_compare', locale),
              style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.s4),
          Text(L10n.tr('log_distance_to_compare', locale),
              style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.s12),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(L10n.tr('go_for_a_run', locale)),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.brand),
          ),
        ],
      ),
    );
  }
}

class _HowYouCompare extends StatelessWidget {
  final Legend legend;
  final List<RunRecord> runs;
  final Color accent;
  final AppLocale locale;
  const _HowYouCompare({required this.legend, required this.runs, required this.accent, required this.locale});

  @override
  Widget build(BuildContext context) {
    // Best run (min duration) per distance bucket.
    final Map<String, int> userPRs = {};
    for (final r in runs) {
      for (final entry in _compareBuckets.entries) {
        if ((r.distanceM - entry.value.meters).abs() <= entry.value.meters * 0.06) {
          final prev = userPRs[entry.key];
          if (prev == null || r.durationMs < prev) userPRs[entry.key] = r.durationMs;
        }
      }
    }

    final rows = <Widget>[];
    for (final entry in _compareBuckets.entries) {
      final legendTime = entry.value.legendKeys
          .map((k) => legend.personalBests?[k])
          .where((v) => v != null)
          .firstOrNull;
      if (legendTime == null) continue; // legend has no PB at this distance
      final legendSeconds = _parseTimeToSeconds(legendTime);
      final userMs = userPRs[entry.key];
      rows.add(_CompareRow(
        label: entry.key == 'Half' ? 'Half Marathon' : entry.key == '5K' ? '5K' : entry.key,
        legendTime: legendTime,
        userMs: userMs,
        legendSeconds: legendSeconds,
        accent: accent,
        locale: locale,
      ));
    }

    if (rows.isEmpty) {
      return _CompareEmpty(onStart: () => context.go('/run'), locale: locale);
    }
    return Column(children: rows);
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String legendTime;
  final int? userMs;
  final double legendSeconds;
  final Color accent;
  final AppLocale locale;
  const _CompareRow({
    required this.label,
    required this.legendTime,
    required this.userMs,
    required this.legendSeconds,
    required this.accent,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (userMs == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.s12),
        child: Row(
          children: [
            SizedBox(width: 92, child: Text(label, style: text.labelMedium!.copyWith(fontWeight: FontWeight.w700))),
            Expanded(
              child: Text(L10n.tr('no_distance_logged', locale).replaceFirst('{label}', label),
                  style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
            ),
            Text(legendTime, style: text.bodySmall!.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      );
    }

    final userSeconds = userMs! / 1000;
    final gapPct = ((userSeconds - legendSeconds) / legendSeconds) * 100;
    final fill = (legendSeconds / userSeconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 92, child: Text(label, style: text.labelMedium!.copyWith(fontWeight: FontWeight.w700))),
              Expanded(
                child: Text(formatDuration(userMs!),
                    style: text.bodyMedium!.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
              ),
              Text('${L10n.tr('vs', locale)} $legendTime',
                  style: text.bodySmall!.copyWith(
                      color: accent, fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(width: AppTheme.s8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s8, vertical: AppTheme.s2),
                decoration: BoxDecoration(
                  color: gapPct <= 0 ? AppTheme.recording.withValues(alpha: 0.16) : accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppTheme.rFull),
                ),
                child: Text('+${gapPct.toStringAsFixed(0)}%',
                    style: text.labelSmall!.copyWith(
                        color: gapPct <= 0 ? AppTheme.recording : accent, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.rFull),
            child: LinearProgressIndicator(
              value: fill,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunitySection extends StatelessWidget {
  final Legend legend;
  final Color accent;
  final AppLocale locale;
  const _CommunitySection({required this.legend, required this.accent, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Simulate community engagement count based on legend fame.
    final athleteCount = legend.records.length * 47 + legend.timeline.length * 23;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.tr('community_results', locale), style: text.titleLarge),
        const SizedBox(height: AppTheme.s12),
        Container(
          padding: const EdgeInsets.all(AppTheme.s16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.r16),
            border: Border.all(color: cs.surfaceContainerHighest),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people_rounded, color: accent, size: 24),
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$athleteCount+', style: text.titleLarge!.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                    const SizedBox(height: AppTheme.s2),
                    Text(L10n.tr('athletes_trained_with_legend', locale).replaceFirst('{name}', legend.name),
                        style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String year;
  final String text;
  final Color accent;
  const _TimelineRow({required this.year, required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(year,
                style: textTheme.labelMedium!.copyWith(color: accent, fontWeight: FontWeight.w700)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 6, right: AppTheme.s12),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(color: cs.surface, width: 2),
            ),
          ),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}