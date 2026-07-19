import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/onboarding/onboarding_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _page = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final slides = [
      _Slide(
        emoji: '🏃',
        icon: Icons.directions_run_rounded,
        title: L10n.tr('onboarding_run_title', locale),
        body: L10n.tr('onboarding_run_body', locale),
        hint: L10n.tr('onboarding_run_hint', locale),
      ),
      _Slide(
        emoji: '🏆',
        icon: Icons.emoji_events_rounded,
        title: L10n.tr('onboarding_challenges_title', locale),
        body: L10n.tr('onboarding_challenges_body', locale),
        hint: L10n.tr('onboarding_challenges_hint', locale),
      ),
      _Slide(
        emoji: '🛡️',
        icon: Icons.shield_outlined,
        title: L10n.tr('onboarding_safe_title', locale),
        body: L10n.tr('onboarding_safe_body', locale),
        hint: L10n.tr('onboarding_safe_hint', locale),
      ),
      _Slide(
        emoji: '🌍',
        icon: Icons.map_rounded,
        title: L10n.tr('onboarding_explore_title', locale),
        body: L10n.tr('onboarding_explore_body', locale),
        hint: L10n.tr('onboarding_explore_hint', locale),
      ),
    ];

return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.s8),
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(L10n.tr('onboarding_skip', locale)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => slides[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? Theme.of(context).colorScheme.primary : cs.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.s24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              child: FilledButton(
                onPressed: () {
                  if (_index < slides.length - 1) {
                    _page.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finish();
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(_index < slides.length - 1
                    ? L10n.tr('onboarding_next', locale)
                    : L10n.tr('onboarding_get_started', locale)),
              ),
            ),
            const SizedBox(height: AppTheme.s32),
          ],
        ),
      ),
    );
  }

  void _finish() async {
    await completeOnboarding();
    ref.invalidate(onboardingDoneProvider);
    if (mounted) context.go('/');
  }
}

class _Slide extends StatelessWidget {
  final String emoji;
  final IconData icon;
  final String title;
  final String body;
  final String? hint;
  const _Slide({
    required this.emoji,
    required this.icon,
    required this.title,
    required this.body,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  shape: BoxShape.circle,
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 56)),
            ],
          ),
          const SizedBox(height: AppTheme.s16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s6),
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppTheme.rFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AppTheme.brand),
                const SizedBox(width: AppTheme.s6),
                Text('GPS · ${hint ?? 'Learn more'}',
                    style: text.labelSmall!.copyWith(color: AppTheme.brand)),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.s24),
          Text(title, style: text.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.s12),
          Text(body,
              style: text.bodyLarge!
                  .copyWith(color: cs.onSurface.withValues(alpha: 0.72)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
