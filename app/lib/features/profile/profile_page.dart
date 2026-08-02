import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/gamification/leaderboard_data.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/network/leaderboard_provider.dart';
import 'package:mwendo_app/core/network/session_provider.dart';
import 'package:mwendo_app/core/profile/profile_provider.dart';
import 'package:mwendo_app/core/safety/safety_provider.dart';
import 'package:mwendo_app/data/gpx_export.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';
import 'package:mwendo_app/features/safety/safety_service.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/widgets/celebration_overlay.dart';
import 'package:mwendo_app/widgets/metric_tile.dart';
import 'package:mwendo_app/widgets/trailing_chevron.dart';
import 'package:mwendo_app/widgets/section_title.dart';
import 'package:mwendo_app/core/theme/theme_mode_provider.dart';
import 'package:mwendo_app/core/theme/palette_provider.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';
import 'package:mwendo_app/widgets/level_ring.dart';

class YouPage extends ConsumerStatefulWidget {
  const YouPage({super.key});

  @override
  ConsumerState<YouPage> createState() => _YouPageState();
}

class _YouPageState extends ConsumerState<YouPage> {
  int _prevLevel = 0;
  bool _showLevelUp = false;
  String _levelUpTitle = '';
  _StatRange _range = _StatRange.all;

  void _setRange(_StatRange r) {
    if (r == _range) return;
    Haptics.selection();
    setState(() => _range = r);
  }

  @override
  void initState() {
    super.initState();
    _prevLevel = ref.read(gamificationProvider).level;
  }

  @override
  Widget build(BuildContext context) {
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);
    if (g.level > _prevLevel && _prevLevel > 0) {
      _prevLevel = g.level;
      Haptics.celebrate();
      _levelUpTitle = '${L10n.tr('level', locale)} ${g.level}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showLevelUp = true);
      });
    } else {
      _prevLevel = g.level;
    }
    final mode = ref.watch(themeModeProvider);
    final profile = ref.watch(userProfileProvider);
    final units = ref.watch(unitsProvider);
    final contacts = ref.watch(safetyContactsProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final runs = ref.watch(activitiesProvider).value ?? const <RunRecord>[];
    final allBadges = [
      ...ChallengeEvaluator.allChallenges.map((c) => c.badgeId),
      ...specialBadges.keys,
    ];

    final board = ref.watch(remoteLeaderboardProvider(g.xp)).when(
      data: (b) => b,
      loading: () => leaderboardWithUser(g.xp),
      error: (_, _) => leaderboardWithUser(g.xp),
    ).take(5).toList();
    final rank = board.indexWhere((e) => e.you) + 1;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.s24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                       Row(
                         children: [
                           Semantics(
                             label: L10n.tr('edit', locale),
                             button: true,
                             child: GestureDetector(
                               onTap: () => _EditPhotoSheet.show(context, ref),
                               child: profile.photoPath != null
                                   ? CircleAvatar(
                                       radius: 34,
                                       backgroundImage: FileImage(File(profile.photoPath!)),
                                     )
                                   : const CircleAvatar(
                                       radius: 34,
                                       backgroundColor: AppTheme.brand,
                                       child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
                                     ),
                             ),
                           ),
                           const SizedBox(width: AppTheme.s16),
                           Expanded(
                             child: Semantics(
                               label: L10n.tr('edit', locale),
                               button: true,
                               child: GestureDetector(
                                 onTap: () => _EditNameSheet.show(context, ref, profile.username),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(profile.username, style: text.headlineLarge),
                                     Text('${L10n.tr('level', locale)} ${g.level} · ${g.title}',
                                         style: text.bodyMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                                   ],
                                 ),
                               ),
                             ),
                           ),
                           LevelRing(level: g.level, progress: g.levelProgress, size: 56),
                         ],
                       ),
                       const SizedBox(height: AppTheme.s16),
                       Container(
                         padding: const EdgeInsets.all(AppTheme.s16),
                         decoration: BoxDecoration(
                           color: cs.surface,
                           borderRadius: BorderRadius.circular(AppTheme.r16),
                         ),
                         child: XpBar(
                           xpIntoLevel: g.xpIntoLevel,
                           xpForNextLevel: g.xpForNextLevel,
                           progress: g.levelProgress,
                         ),
                       ),
                       const SizedBox(height: AppTheme.s16),
                       _StatsToggle(range: _range, onChanged: _setRange, locale: locale),
                       const SizedBox(height: AppTheme.s16),
                       _StatRow(g: g, range: _range, runs: runs, units: units, locale: locale),
                       const SizedBox(height: AppTheme.s12),
                       _StatRow(g: g, range: _range, runs: runs, units: units, locale: locale),
                       const SizedBox(height: AppTheme.s28),
                       SectionTitle(L10n.tr('achievements', locale)),
                       const SizedBox(height: AppTheme.s12),
                     ]),
                   ),
                 ),
                 SliverPadding(
                   padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
                   sliver: SliverGrid(
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                       crossAxisCount: 4,
                       mainAxisSpacing: AppTheme.s12,
                       crossAxisSpacing: AppTheme.s12,
                       childAspectRatio: 0.8,
                     ),
                     delegate: SliverChildBuilderDelegate(
                       (context, index) {
                         final id = allBadges[index];
                         return _TrophyTile(
                           id: id,
                           earned: g.earnedBadges.contains(id),
                           index: index,
                         );
                       },
                       childCount: allBadges.length,
                     ),
                   ),
                 ),
                if (g.racedLegends.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s28, AppTheme.s24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(L10n.tr('your_legends', locale)),
                          const SizedBox(height: AppTheme.s12),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: g.racedLegends.length,
                              separatorBuilder: (_, _) => const SizedBox(width: AppTheme.s12),
                              itemBuilder: (_, i) {
                                final ghost = ghostPaceForId(g.racedLegends.elementAt(i));
                                final beaten = g.beatenLegends.contains(ghost.id);
                                return _LegendMiniCard(ghost: ghost, beaten: beaten);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.s24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (g.titles.isNotEmpty) ...[
                         SectionTitle(L10n.tr('titles', locale)),
                        const SizedBox(height: AppTheme.s12),
                        Wrap(
                          spacing: AppTheme.s8,
                          runSpacing: AppTheme.s8,
                          children: g.titles
                              .map((t) => Chip(
                                    label: Text(t,
                                        style: text.labelMedium!.copyWith(color: AppTheme.brand)),
                                    backgroundColor: AppTheme.brand.withValues(alpha: 0.14),
                                    side: BorderSide.none,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: AppTheme.s28),
                      ],
                      SectionTitle('${L10n.tr('leaderboard', locale)} · Rank #$rank'),
                      const SizedBox(height: AppTheme.s12),
                      ...board.map((e) => _LeaderRow(e: e, text: text, cs: cs, locale: locale)),
                      const SizedBox(height: AppTheme.s28),
                      SectionTitle(L10n.tr('account', locale)),
                      const SizedBox(height: AppTheme.s12),
                      _AccountTile(),
                      const SizedBox(height: AppTheme.s28),
                      SectionTitle(L10n.tr('settings', locale)),
                      const SizedBox(height: AppTheme.s12),
                      _LangTile(cs: cs, text: text, ref: ref, locale: locale),
                      _SettingTile(
                        icon: Icons.straighten_rounded,
                        title: L10n.tr('units', locale),
                        subtitle: units == Units.metric
                            ? L10n.tr('metric', locale)
                            : L10n.tr('imperial', locale),
                        onTap: () => ref.read(unitsProvider.notifier).toggle(),
                      ),
                      _SettingTile(
                        icon: Icons.brightness_6_rounded,
                        title: L10n.tr('appearance', locale),
                        subtitle: mode == ThemeMode.dark
                            ? L10n.tr('dark', locale)
                            : (mode == ThemeMode.light
                                ? L10n.tr('light', locale)
                                : L10n.tr('system', locale)),
                        onTap: () => ref.read(themeModeProvider.notifier).cycle(),
                      ),
                      _ThemePickerTile(locale: locale),
                      _SettingTile(
                        icon: Icons.shield_outlined,
                        title: L10n.tr('emergency_contacts', locale),
                        subtitle: contacts.isEmpty
                            ? L10n.tr('not_set', locale)
                            : '${contacts.length} ${L10n.tr('emergency_contacts', locale)}',
                        onTap: () => _EmergencyContactsSheet.show(context, ref),
                      ),
                      _SettingTile(
                        icon: Icons.file_download_outlined,
                        title: L10n.tr('export_data', locale),
                        onTap: () => _exportData(context, ref, locale),
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showLevelUp)
          CelebrationOverlay(
            title: _levelUpTitle,
            subtitle: L10n.tr('level_up_subtitle', locale),
            onDone: () => setState(() => _showLevelUp = false),
          ),
      ],
    );
  }
}

class _TrophyTile extends StatefulWidget {
  final String id;
  final bool earned;
  final int index;
  const _TrophyTile({required this.id, required this.earned, required this.index});

  @override
  State<_TrophyTile> createState() => _TrophyTileState();
}

class _TrophyTileState extends State<_TrophyTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.index * 35), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = badgeMeta(widget.id);
    final cs = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
      child: Container(
        decoration: BoxDecoration(
          color: widget.earned ? cs.surface : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.r16),
          border: widget.earned
              ? Border.all(color: AppTheme.tierGold.withValues(alpha: 0.5))
              : null,
          boxShadow: widget.earned
              ? [BoxShadow(color: AppTheme.tierGold.withValues(alpha: 0.25), blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(meta.emoji, style: TextStyle(fontSize: 28, color: widget.earned ? null : cs.onSurface.withValues(alpha: 0.38))),
                if (!widget.earned)
                  Icon(Icons.lock_rounded, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.45)),
              ],
            ),
            const SizedBox(height: AppTheme.s6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4),
              child: Text(meta.name,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: widget.earned ? null : cs.onSurface.withValues(alpha: 0.4)),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsToggle extends StatelessWidget {
  final _StatRange range;
  final ValueChanged<_StatRange> onChanged;
  final AppLocale locale;
  const _StatsToggle({required this.range, required this.onChanged, required this.locale});

  @override
  Widget build(BuildContext context) => SegmentedButton<_StatRange>(
        selected: {range},
        showSelectedIcon: false,
        onSelectionChanged: (s) => onChanged(s.first),
        segments: [
          ButtonSegment(value: _StatRange.week, label: Text(L10n.tr('stats_week', locale))),
          ButtonSegment(value: _StatRange.month, label: Text(L10n.tr('stats_month', locale))),
          ButtonSegment(value: _StatRange.all, label: Text(L10n.tr('all', locale))),
        ],
      );
}

class _StatRow extends StatelessWidget {
  final GamificationState g;
  final _StatRange range;
  final List<RunRecord> runs;
  final Units units;
  final AppLocale locale;
  const _StatRow({required this.g, required this.range, required this.runs, required this.units, required this.locale});

  @override
  Widget build(BuildContext context) {
    late final List<({String label, String value})> tiles;
    if (range == _StatRange.all) {
      tiles = [
        (label: L10n.tr('distance', locale), value: formatDistanceUnits(g.totalDistanceM, units)),
        (label: L10n.tr('runs', locale), value: g.totalRuns.toString()),
        (label: L10n.tr('time', locale), value: formatDuration(g.totalTimeMs)),
        (label: L10n.tr('streak', locale), value: '${g.streakDays}d'),
      ];
    } else {
      final cutoff = DateTime.now().subtract(Duration(days: range == _StatRange.week ? 7 : 30));
      final filtered = runs.where((r) => r.startedAt.isAfter(cutoff)).toList();
      final dist = filtered.fold(0.0, (s, r) => s + r.distanceM);
      final dur = filtered.fold(0, (s, r) => s + r.durationMs);
      final avgPace = dist > 0 ? (dur / 60000) / (dist / 1000) : 0.0;
      tiles = [
        (label: L10n.tr('distance', locale), value: formatDistanceUnits(dist, units)),
        (label: L10n.tr('runs', locale), value: filtered.length.toString()),
        (label: L10n.tr('time', locale), value: formatDuration(dur)),
        (label: L10n.tr('avg_pace', locale), value: avgPace > 0 ? formatPace(avgPace) : '--'),
      ];
    }
    return Row(
      children: tiles
          .map((t) => Expanded(
                child: MetricTile(
                  variant: MetricVariant.card,
                  label: t.label,
                  value: t.value,
                ),
              ))
          .toList(),
    );
  }
}

class _LegendMiniCard extends ConsumerWidget {
  final GhostPace ghost;
  final bool beaten;
  const _LegendMiniCard({required this.ghost, required this.beaten});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l = ghost.legend;
    final cs = Theme.of(context).colorScheme;
    final accent = legendAccent(l);
    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: beaten ? Border.all(color: accent.withValues(alpha: 0.6)) : null,
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 22, backgroundColor: accent.withValues(alpha: 0.18), child: Text(l.emoji, style: const TextStyle(fontSize: 20))),
          const SizedBox(height: AppTheme.s8),
          Text(l.name, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppTheme.s4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s8, vertical: AppTheme.s2),
            decoration: BoxDecoration(
              color: (beaten ? AppTheme.recording : AppTheme.idle).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppTheme.rFull),
            ),
            child: Text(beaten ? L10n.tr('legend_beaten', locale) : L10n.tr('legend_raced', locale),
                style: Theme.of(context).textTheme.labelSmall!.copyWith(color: beaten ? AppTheme.recording : AppTheme.idle)),
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry e;
  final TextTheme text;
  final ColorScheme cs;
  final AppLocale locale;
  const _LeaderRow({required this.e, required this.text, required this.cs, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.s8),
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: e.you ? AppTheme.brand.withValues(alpha: 0.14) : cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r12),
      ),
      child: Row(
        children: [
          Text(e.flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppTheme.s12),
          Expanded(child: Text(e.you ? L10n.tr('you', locale) : e.name, style: text.titleMedium)),
          Text('${e.xp} XP', style: text.labelMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = ref.watch(localeProvider);
    final session = ref.watch(sessionProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4, vertical: AppTheme.s8),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(AppTheme.r12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppTheme.r12)),
            child: Icon(session.isAnonymous ? Icons.person_outline_rounded : Icons.verified_user_rounded,
                color: AppTheme.brand),
          ),
          const SizedBox(width: AppTheme.s16),
          Expanded(
            child: session.isAnonymous
                ? Text(L10n.tr('continue_anonymous', locale), style: text.titleMedium)
                : Text(session.email ?? L10n.tr('account', locale), style: text.titleMedium),
          ),
          TextButton(
            onPressed: () {
              if (session.isAnonymous) {
                context.push('/auth');
              } else {
                ref.read(sessionProvider.notifier).logout();
              }
            },
            child: Text(session.isAnonymous
                ? L10n.tr('sign_in', locale)
                : L10n.tr('sign_out', locale)),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme text;
  final WidgetRef ref;
  final AppLocale locale;
  const _LangTile({required this.cs, required this.text, required this.ref, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4, vertical: AppTheme.s8),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(AppTheme.r12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppTheme.r12)),
            child: Icon(Icons.language_rounded, color: AppTheme.brand),
          ),
          const SizedBox(width: AppTheme.s16),
          Expanded(child: Text(L10n.tr('language', locale), style: text.titleMedium)),
          SegmentedButton<AppLocale>(
            selected: {locale},
            showSelectedIcon: false,
            onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(s.first),
            segments: const [
              ButtonSegment(value: AppLocale.english, label: Text('EN')),
              ButtonSegment(value: AppLocale.swahili, label: Text('SW')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SettingTile({required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final child = ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppTheme.r12)),
        child: Icon(icon, color: cs.primary),
      ),
      title: Text(title, style: text.titleMedium),
      subtitle: subtitle != null ? Text(subtitle!, style: text.bodySmall) : null,
      trailing: const TrailingChevron(),
    );
    if (onTap == null) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.r12),
      onTap: onTap,
      child: child,
    );
  }
}

class _ThemePickerTile extends ConsumerWidget {
  final AppLocale locale;
  const _ThemePickerTile({required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);

    return _SettingTile(
      icon: Icons.palette_outlined,
      title: L10n.tr('color_theme', locale),
      subtitle: _themeName(palette, locale),
      onTap: () => _showThemePicker(context, ref, locale),
    );
  }

  String _themeName(ColorPalette p, AppLocale locale) {
    final key = ColorPalette.presetsByName.entries.firstWhere((e) => e.value == p).key;
    if (key == 'orange') return L10n.tr('theme_kinetic_orange', locale);
    if (key == 'forest') return L10n.tr('theme_kenyan_green', locale);
    if (key == 'ocean') return L10n.tr('theme_midnight_blue', locale);
    if (key == 'berry') return L10n.tr('theme_berry', locale);
    return '';
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, AppLocale locale) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
      ),
      builder: (ctx) => _ThemePickerSheet(locale: locale, currentPalette: ref.read(paletteProvider)),
    );
  }
}

class _ThemePickerSheet extends ConsumerWidget {
  final AppLocale locale;
  final ColorPalette currentPalette;
  const _ThemePickerSheet({required this.locale, required this.currentPalette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palettes = ColorPalette.presets;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.s24,
        left: AppTheme.s24,
        right: AppTheme.s24,
        top: AppTheme.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.tr('choose_color_theme', locale), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.s8),
          Text(L10n.tr('color_theme_description', locale), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppTheme.s20),
          Wrap(
            spacing: AppTheme.s12,
            runSpacing: AppTheme.s12,
            children: palettes.map((p) {
              final isSelected = p == currentPalette;
              return _ThemeSwatch(
                palette: p,
                selected: isSelected,
                onTap: () {
                  Haptics.selection();
                  ref.read(paletteProvider.notifier).set(p);
                  Navigator.pop(context);
                },
                locale: locale,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final ColorPalette palette;
  final bool selected;
  final VoidCallback onTap;
  final AppLocale locale;
  const _ThemeSwatch({required this.palette, required this.selected, required this.onTap, required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = _themeName(palette, locale);

    return Semantics(
      label: name,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
        duration: AppTheme.dFast,
        curve: AppTheme.curveSnappy,
        width: 130,
        padding: const EdgeInsets.all(AppTheme.s16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppTheme.r16),
          border: Border.all(
            color: selected ? cs.primary : cs.outline.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [BoxShadow(color: palette.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [palette.primary, palette.gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppTheme.r12),
              ),
            ),
            const SizedBox(height: AppTheme.s12),
            Text(name, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      ),
    );
  }

  String _themeName(ColorPalette p, AppLocale locale) {
    final key = ColorPalette.presetsByName.entries.firstWhere((e) => e.value == p).key;
    if (key == 'orange') return L10n.tr('theme_kinetic_orange', locale);
    if (key == 'forest') return L10n.tr('theme_kenyan_green', locale);
    if (key == 'ocean') return L10n.tr('theme_midnight_blue', locale);
    if (key == 'berry') return L10n.tr('theme_berry', locale);
    return '';
  }
}

Future<void> _exportData(
    BuildContext context, WidgetRef ref, AppLocale locale) async {
  final repo = await ref.read(activityRepositoryProvider.future);
  final runs = await repo.list();
  if (runs.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.tr('nothing_recorded', locale))),
      );
    }
    return;
  }
  final json = jsonFromRuns(runs);
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, 'mwendo_activities.json'));
  await file.writeAsString(json);
  if (context.mounted) {
    await SharePlus.instance.share(
      ShareParams(
        text: L10n.tr('exported', locale),
        files: [XFile(file.path)],
      ),
    );
  }
}

class _EditNameSheet {
  static void show(BuildContext context, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: Text(L10n.tr('name', ref.read(localeProvider))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(labelText: L10n.tr('name', ref.read(localeProvider))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text(L10n.tr('cancel', ref.read(localeProvider))),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).setUsername(ctrl.text);
              Navigator.of(dlg).pop();
            },
            child: Text(L10n.tr('save', ref.read(localeProvider))),
          ),
        ],
      ),
    );
  }
}

class _EditPhotoSheet {
  static void show(BuildContext context, WidgetRef ref) {
    final picker = ImagePicker();
    final locale = ref.read(localeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(L10n.tr('camera', locale)),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.camera);
                if (img != null) {
                  await ref.read(userProfileProvider.notifier).setPhoto(img.path);
                }
                if (context.mounted) Navigator.of(sheet).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(L10n.tr('gallery', locale)),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (img != null) {
                  await ref.read(userProfileProvider.notifier).setPhoto(img.path);
                }
                if (context.mounted) Navigator.of(sheet).pop();
              },
            ),
            if (ref.read(userProfileProvider).photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(L10n.tr('remove_photo', locale)),
                onTap: () async {
                  await ref.read(userProfileProvider.notifier).setPhoto(null);
                  if (context.mounted) Navigator.of(sheet).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyContactsSheet {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
      ),
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(
          left: AppTheme.s24,
          right: AppTheme.s24,
          top: AppTheme.s24,
          bottom: AppTheme.s24 + MediaQuery.of(sheet).viewInsets.bottom,
        ),
        child: const _EmergencyContactsBody(),
      ),
    );
  }
}

class _EmergencyContactsBody extends ConsumerWidget {
  const _EmergencyContactsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(safetyContactsProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(L10n.tr('emergency_contacts', locale), style: text.titleLarge),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _editContact(context, ref, null, locale),
              icon: const Icon(Icons.add_rounded),
              label: Text(L10n.tr('add_contact', locale)),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.s12),
        if (contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
            child: Text(L10n.tr('no_contacts_yet', locale),
                style: text.bodyMedium!.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6))),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            itemCount: contacts.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppTheme.s8),
            itemBuilder: (_, i) {
              final c = contacts[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_rounded, color: AppTheme.brand),
                title: Text(c.name),
                subtitle: Text('${c.relationship} · ${c.phone}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: L10n.tr('edit', locale),
                      onPressed: () => _editContact(context, ref, i, locale),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: L10n.tr('delete', locale),
                      onPressed: () =>
                          ref.read(safetyContactsProvider.notifier).removeAt(i),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _editContact(BuildContext context, WidgetRef ref, int? index, AppLocale locale) {
    final editing = index == null ? null : ref.read(safetyContactsProvider)[index];
    final nameCtrl = TextEditingController(text: editing?.name);
    final phoneCtrl = TextEditingController(text: editing?.phone);
    final relCtrl = TextEditingController(text: editing?.relationship);

    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: Text(index == null ? L10n.tr('add_contact', locale) : L10n.tr('edit_contact', locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: L10n.tr('name', locale)),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: L10n.tr('phone', locale)),
            ),
            TextField(
              controller: relCtrl,
              decoration: InputDecoration(labelText: L10n.tr('relationship', locale)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text(L10n.tr('cancel', locale)),
          ),
          TextButton(
            onPressed: () {
              final contact = EmergencyContact(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                relationship: relCtrl.text.trim(),
              );
              final notifier = ref.read(safetyContactsProvider.notifier);
              if (index == null) {
                notifier.add(contact);
              } else {
                notifier.update(index, contact);
              }
              Navigator.of(dlg).pop();
            },
            child: Text(L10n.tr('save', locale)),
          ),
        ],
      ),
    );
  }
}

enum _StatRange { week, month, all }