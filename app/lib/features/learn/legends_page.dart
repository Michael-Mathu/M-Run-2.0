import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';

class LegendsPage extends ConsumerStatefulWidget {
  const LegendsPage({super.key});

  @override
  ConsumerState<LegendsPage> createState() => _LegendsPageState();
}

class _LegendsPageState extends ConsumerState<LegendsPage> {
  final _q = TextEditingController();
  String _query = '';
  String _country = 'All';
  String _discipline = 'All';
  String _era = 'All';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<Legend> get _filtered {
    final q = _query.toLowerCase();
    final locale = AppLocale.english;
    return legends.where((l) {
      if (q.isNotEmpty &&
          !(l.name.toLowerCase().contains(q) ||
              lt(l.country, locale).toLowerCase().contains(q) ||
              lt(l.discipline, locale).toLowerCase().contains(q))) {
        return false;
      }
      if (_country != 'All' && !lt(l.country, locale).startsWith(_country)) return false;
      if (_discipline != 'All' &&
          !lt(l.discipline, locale).toLowerCase().contains(_discipline.toLowerCase())) {
        return false;
      }
      if (_era != 'All' && lt(l.eraLabel, locale) != _era) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final appLocale = locale == AppLocale.swahili ? AppLocale.swahili : AppLocale.english;

    return Scaffold(
      appBar: AppBar(title: Text(L10n.tr('legends_title', locale)), centerTitle: false),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppTheme.r12),
                  ),
                  child: TextField(
                    controller: _q,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: L10n.tr('search_legends', locale),
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppTheme.s12),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.s12),
                _ChipRow(
                  label: L10n.tr('country', locale),
                  options: const ['All', 'Kenya', 'Ethiopia', 'Uganda'],
                  selected: _country,
                  onSelected: (v) {
                    Haptics.light();
                    setState(() => _country = v);
                  },
                ),
                const SizedBox(height: AppTheme.s8),
                _ChipRow(
                  label: L10n.tr('discipline', locale),
                  options: const [
                    'All',
                    'Marathon',
                    '5000m',
                    '10,000m',
                    '1500m',
                    '800m',
                    'Half Marathon',
                    'Cross Country',
                  ],
                  selected: _discipline,
                  onSelected: (v) {
                    Haptics.light();
                    setState(() => _discipline = v);
                  },
                ),
                const SizedBox(height: AppTheme.s8),
                _ChipRow(
                  label: L10n.tr('era', locale),
                  options: const ['All', '1960s–70s', '1980s–90s', '2000s–10s', '2020s+'],
                  selected: _era,
                  onSelected: (v) {
                    Haptics.light();
                    setState(() => _era = v);
                  },
                ),
                const SizedBox(height: AppTheme.s12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, 0, AppTheme.s24, AppTheme.s24),
            sliver: _filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: _SearchEmpty(
                      onSuggestion: (q) => setState(() => _query = q),
                    ),
                  )
                : SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppTheme.s12,
                    crossAxisSpacing: AppTheme.s12,
                    childAspectRatio: 0.92,
                    children: _filtered.map((l) => _LegendCard(legend: l, locale: appLocale)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  final ValueChanged<String> onSuggestion;
  const _SearchEmpty({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode == 'sw'
        ? AppLocale.swahili
        : AppLocale.english;
    const popular = ['Kipchoge', 'Ethiopia', 'Kipyegon', 'Cheptegei', 'Haile'];
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.s24),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 44, color: cs.onSurface.withValues(alpha: 0.38)),
          const SizedBox(height: AppTheme.s12),
          Text(L10n.tr('no_legends_match', locale), style: text.titleMedium),
          const SizedBox(height: AppTheme.s4),
          Text(L10n.tr('try_search', locale),
              style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
              textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.s16),
          Text(L10n.tr('popular_legends', locale),
              style: text.labelMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: AppTheme.s8),
          Wrap(
            spacing: AppTheme.s8,
            runSpacing: AppTheme.s8,
            alignment: WrapAlignment.center,
            children: popular
                .map((p) => ActionChip(
                      label: Text(p),
                      onPressed: () => onSuggestion(p),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  const _ChipRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.s8),
        itemBuilder: (_, i) {
           final opt = options[i];
           final active = opt == selected;
           final accent = opt == 'Kenya'
               ? AppTheme.brand
               : opt == 'Ethiopia'
                   ? const Color(0xFFFFD15C)
                   : opt == 'Uganda'
                       ? const Color(0xFF2BB673)
                       : AppTheme.brand;
           final countryFlag = switch (opt) {
             'Kenya' => '🇰🇪 ',
             'Ethiopia' => '🇪🇹 ',
             'Uganda' => '🇺🇬 ',
             _ => '',
           };
           return FilterChip(
             label: Text('$countryFlag$opt'),
             selected: active,
             onSelected: (_) => onSelected(opt),
             backgroundColor: cs.surface,
             selectedColor: accent.withValues(alpha: 0.18),
             checkmarkColor: accent,
             labelStyle: text.labelMedium!.copyWith(
               color: active ? accent : cs.onSurface.withValues(alpha: 0.7),
               fontWeight: active ? FontWeight.w700 : FontWeight.w600,
             ),
             side: active ? BorderSide(color: accent) : null,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.rFull)),
             padding: const EdgeInsets.symmetric(horizontal: AppTheme.s8),
           );
        },
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  final Legend legend;
  final AppLocale locale;
  const _LegendCard({required this.legend, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accent = legendAccent(legend);
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () {
          Haptics.light();
          context.push('/learn/legends/${legend.slug}');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accent.withValues(alpha: 0.18),
                    child: Text(legend.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const Spacer(),
                  Text(legend.flag, style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: AppTheme.s12),
              Text(legend.name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppTheme.s2),
              Text(lt(legend.discipline, locale),
                  style: text.labelSmall!.copyWith(color: accent, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(lt(legend.country, locale),
                  style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}