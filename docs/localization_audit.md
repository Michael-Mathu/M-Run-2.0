# Mwendo — System-Wide Localization Audit

> **Date:** 2026-07-12 (updated 2026-07-12 Evening)
> **Scope:** `app/` Flutter client (~90 Dart files)
> **Supported locales:** English (`en`) + Swahili (`sw`)
> **System:** custom `L10n.tr(key, locale)` / `ref.tr('key')` catalog in `app/lib/core/l10n/app_strings.dart` (~180 keys)
> **Content localization:** `LocalizedText` record helper + `lt()` resolver for prose (legends, courses)
> **Related plan section:** [§2.6 Swahili Localisation](./implementation_plan.md)

## Executive summary

The app is **not** at 100% coverage — realistically **~50–60% localized by UI surface, far lower by content volume**. Three structural problems dominate:

1. **No fallback safety net.** `L10n.tr` returns the *raw key string* when a key is missing (`app_strings.dart:281`). A missing key is therefore a **visible bug** that shows `per_km`, `lv`, `all_courses`, etc. to users in *both* languages. **~62 such calls existed** — **RESOLVED (P0):** all ~62 missing keys were added to `app_strings.dart` with `en`+`sw` translations on 2026-07-12.
2. **No Flutter framework localization.** `MaterialApp.router` in `app.dart` declares **no `localizationsDelegates` and no `supportedLocales`**, and `pubspec.yaml` does not depend on `flutter_localizations`. All Material/Cupertino system UI (date/time pickers, text-selection menus, back-button tooltips, semantics defaults) is permanently English regardless of the in-app toggle.
3. **Long-form content is architecturally unlocalizable.** The current system only supports short UI keys. All challenge catalogs, rank titles, ghost descriptions, and milestone stories are hardcoded English in data files. **PROGRESS (P1):** legends and courses now use `LocalizedText` with `en`/`sw` pairs and a code-side `lt()` resolver, removing the largest content gap.

**Rough counts:** ~0 broken (missing-key) references (Category 1 resolved) · ~40 hardcoded UI literals · ~150+ content strings across 8 data files · 5 framework/consistency defects.

---

## Category 1 — CRITICAL: `tr()` calls to missing keys (render raw key text to users) — ✅ RESOLVED (P0)

These displayed literal snake_case keys to users in both languages. **All ~62 keys were added to `app_strings.dart` with English + Swahili translations on 2026-07-12**, covering the onboarding 4th-slide/hints, live HUD (`km`/`per_km`/`lv`), Learn/Legends/Explore, and the full Beat-the-Legends cluster (`beat_legends_page`, `ghost_drawer`, `ghost_split_status`, `pre_race_sheet`, `ghost_result_screen`) plus `live_dashboard` (`unknown`, `ready_to_race`). Placeholders (`{label}`, `{name}`) were preserved to match runtime `.replaceFirst(...)` usage. `flutter analyze` passes with no issues.

### Onboarding — `features/onboarding/onboarding_page.dart`
| Line | Missing key | Shows / context |
|---|---|---|
| 29 | `onboarding_run_hint` | slide 1 hint chip |
| 36 | `onboarding_challenges_hint` | slide 2 hint chip |
| 43 | `onboarding_safe_hint` | slide 3 hint chip |
| 48–50 | `onboarding_explore_title`, `onboarding_explore_body`, `onboarding_explore_hint` | entire 4th slide added but keys never defined |

### Live HUD / widgets
| File:line | Missing key | Shows |
|---|---|---|
| `design_system/app_map_hud.dart:38` | `km` | distance unit (renders "km" — accidentally OK, but key undefined) |
| `design_system/app_map_hud.dart:46` | `per_km` | **pace unit renders literal "per_km"** |
| `widgets/level_ring.dart:51` | `lv` | **level label renders literal "lv"** |

### Learn / Legends / Explore
| File:line | Missing key |
|---|---|
| `features/learn/learn_page.dart:110` | `all_courses` |
| `features/learn/legend_detail_page.dart` | `biography`(100), `personal_bests`(107), `how_you_compare`(120), `career_timeline`(133), `records`(139), `training_philosophy`(159), `rivalries`(194), `notable_races`(208), `in_their_words`(233), `quote`(239), `related_legends`(288), `community_results`(685), `vs`(636), `no_distance_logged`(611), `athletes_trained_with_legend`(712) |
| `features/learn/lesson_page.dart` | `lesson`(32), `lesson_complete_xp`(91) |
| `features/learn/data/legend_of_day.dart:94` | `read_more` |
| `features/explore/explore_page.dart:240` | `leaderboard_badge_goat` (dynamic `leaderboard_badge_${badge}`) |

### Beat-the-Legends flow (largest cluster — 33 keys)
| File | Missing keys |
|---|---|
| `features/beat/beat_legends_page.dart` | `your_pb`(117), `tier_recommendation`(294), `based_on_your_pb`(294), `all_distances`(324), `target`(444), `avg`(447), `slower_than_ghost`(477), `faster_than_ghost`(478), `no_pb_yet`(479) |
| `features/beat/ghost_drawer.dart` | `ahead`(126), `behind`(126), `target`(205), `proj`(210), `projected_finish`(276), `ghost_finish`(290) |
| `features/beat/ghost_split_status.dart` | `split_label`(74), `overall`(75), `proj`(90), `projected_finish`(206), `ghost_finish`(211), `target`(291), `proj`(299) |
| `features/beat/pre_race_sheet.dart` | `target`(77), `avg`(82), `change_tier`(149), `target_split`(199), `pace_per_km`(200) |
| `features/beat/ghost_result_screen.dart` | `you_beat`(80), `your_time`(101), `ghost_time`(108), `close`(122), `rematch`(171), `try_harder_tier`(186), `share_result`(204), `split_comparison`(308), `delta`(322), `status`(323), `race_summary`(396) |
| `features/tracking/live_dashboard.dart` | `unknown`(703), `ready_to_race`(799) |

---

## Category 2 — Hardcoded English literals (bypass `tr()` entirely)

### Fully unlocalized page
- **`features/explore/route_detail_page.dart`** — no l10n import at all. Lines 13, 20 use **escaped `\$slug`**, so users literally see `Route Detail: $slug` and `Route Detail Page for: $slug`; line 24 `'Close'`. Placeholder page shipped as-is.

### Existing keys defined but bypassed (quick wins — key already exists, just not wired)
| File:line | Hardcoded | Existing key to use |
|---|---|---|
| `features/tracking/live_dashboard.dart:632` | `'Stop run'` (Semantics) | `stop_run` |
| `features/tracking/live_dashboard.dart:653` | `'Pause run'`/`'Resume run'` | `pause_run`/`resume_run` |
| `features/tracking/live_dashboard.dart:391` | background-location body | `gps_required_body` |
| `design_system/app_fab.dart:21` | `'Stop run'`/`'Start run'` | `stop_run`/`start_run_control` |
| `features/beat/ghost_result_screen.dart:80` | uses `you_beat` | `you_beat_ghost` (exists) |
| `core/gamification/leaderboard_data.dart:31,33` · `core/network/leaderboard_provider.dart:59` | `'You'` | `you` |
| `core/network/leaderboard_provider.dart:31` · `core/profile/profile_provider.dart:10,35` · `core/utils/milestone_story.dart:6` | `'Runner'` fallback | `runner` |

### Other hardcoded UI literals (new keys needed)
| File:line | String | Context |
|---|---|---|
| `features/home/dashboard_page.dart:466` · `profile_page.dart:503` · `challenges/challenge_library_page.dart:250` · `widgets/level_ring.dart:98` | `'XP'` | XP labels (add shared `xp`) |
| `features/home/dashboard_page.dart:792` | `'Runner illustration'` | empty-state semantics |
| `features/profile/profile_page.dart:238` | `' · Rank #'` | leaderboard section title |
| `features/tracking/live_dashboard.dart:323` | `'Challenge complete · +N XP'` | celebration subtitle |
| `features/tracking/live_dashboard.dart:402` | `'Continue without background location'` | permission sheet button |
| `features/tracking/live_dashboard.dart:251,273` | `'m'`, `'kcal'` | metric units |
| `features/onboarding/onboarding_page.dart:182` | `'Learn more'` | slide chip fallback |
| `design_system/app_streak_ring.dart:39` | `'day streak'` | streak ring label |
| `widgets/mwendo_map.dart:423,471` | `'Re-center map'`, `'Zoom'` | map control semantics |
| `features/learn/learn_page.dart:17–22` | `Basics`, `Form & Drills`, `Training Plans`, `Recovery`, `Running Science`, `Heritage` | category headers |
| `features/learn/legends_page.dart:79,89–98,108` | discipline/era filter values (`Half Marathon`, `Cross Country`, `1960s–70s`, …) | filter chips |
| `features/challenges/challenge_detail_page.dart:120–123` | `Bronze`/`Silver`/`Gold`/`Platinum` | tier badge |

### Safety-critical & abbreviations
- **`features/safety/safety_service.dart:7`** — outbound **SOS SMS body**: `'Mwendo SOS: I need help. Location: $locationUrl'`. Sent to emergency contacts; must be localized (parameterize URL). **High severity.**
- **`core/network/session_provider.dart:60,118,119`** — auth errors `'No token returned'`, `'Invalid email or password'`, `'Account already exists'` shown in UI.
- Borderline abbreviations rendered as literals: `bpm` (`app_map_hud.dart:62`), `min` (`course_detail_page.dart`, `lesson_page.dart`), `m ↑`/`km` (explore). Decide: whitelist or localize.

### Share message
- **`features/activity/activity_detail_page.dart:59`** — `'I just completed a {type} — {distance} in {duration} via Mwendo!'` hardcoded English share text.

---

## Category 3 — Content localization gaps (architectural — current system can't hold prose)

English-only data files rendered verbatim. This is the **bulk of untranslated text** and needs a different mechanism (per-locale content maps, JSON/ARB resources, or `Map<AppLocale,String>` model fields).

| Source file | Content | Est. volume |
|---|---|---|
| `features/learn/data/legends.dart` | ~30 legends: `bio`, `trainingPhilosophy`, `timeline[]`, `records[]`, `quotes[]`, `notableRaces[]`, `funFact`, quote category labels (`Training/Racing/Life/Legacy`), era labels | **RESOLVED — LocalizedText applied** |
| `features/learn/data/courses.dart` | course `title`/`subtitle`/`author`, lesson `title`/`summary`/`paragraphs[]`, category labels | **RESOLVED — LocalizedText applied** |
| `features/learn/data/beat_legends.dart` | ghost `name`/`description`, tier labels (`Bronze/Silver/Gold/G.O.A.T.`) | Medium |
| `core/gamification/challenge_evaluator.dart` (+`features/challenges/challenge_evaluator.dart`) | 19 challenges × (title + description + badge name) + goal words (`days/runs/lessons/legends`) | ~38 strings |
| `core/gamification/gamification_state.dart:159–166` | 8 rank titles (`Mwendo Rookie` → `Living Legend`) | 8 |
| `core/utils/milestone_story.dart:9–22` | 4 story openers + 3 body segments + toast (interpolated) | 8 |
| `features/explore/explore_provider.dart:102–159` | sample route/segment names + descriptions | Medium |
| `data/sample_activities.dart:76` | activity types `Morning/Evening/Long Run` | 3 |
| Run `type` values (`Run`, `Walk run`, etc.) across models | displayed raw in dashboard/activity list/detail | data-driven |
| `core/gamification/challenge_evaluator.dart` (+`features/challenges/challenge_evaluator.dart`) | 19 challenges × (title + description + badge name) + goal words (`days/runs/lessons/legends`) | ~38 strings |
| `core/gamification/gamification_state.dart:159–166` | 8 rank titles (`Mwendo Rookie` → `Living Legend`) | 8 |
| `core/utils/milestone_story.dart:9–22` | 4 story openers + 3 body segments + toast (interpolated) | 8 |
| `features/explore/explore_provider.dart:102–159` | sample route/segment names + descriptions | Medium |
| `data/sample_activities.dart:76` | activity types `Morning/Evening/Long Run` | 3 |
| Run `type` values (`Run`, `Walk run`, etc.) across models | displayed raw in dashboard/activity list/detail | data-driven |

---

## Category 4 — Framework & consistency issues

1. **`app.dart:31` — `MaterialApp.router` has no `localizationsDelegates`/`supportedLocales`.** System dialogs, pickers, and default tooltips stay English. Add `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate` and `supportedLocales: [en, sw]`, and drive `locale:` from `localeProvider`. Requires adding `flutter_localizations` to `pubspec.yaml` (currently absent).
2. **Router mislabel — `core/router/app_router.dart:335`.** The **Explore** tab (branch 2) is labeled with `L10n.tr('run')`, so two bottom-nav tabs read "Run". No `explore` key exists. Add `explore` and fix the label.
3. **Theme key mismatches — `features/profile/profile_page.dart:640–642, 681, 683`.** Code calls `theme_kinetic_orange`/`theme_kenyan_green`/`theme_midnight_blue`/`choose_color_theme`/`color_theme_description`, but the catalog defines `theme_orange`/`theme_forest`/`theme_ocean`/`color_theme`. Only `theme_berry` resolves. Also missing `edit`, `share`, `learning_insight`, `activity_not_found`(+body).
4. **No pluralization/gender support.** Keys like `lessons`, `runs`, `days`, `day streak` can't inflect (Swahili noun classes differ). A count-aware helper is needed for correct grammar.
5. **Persistence race (minor)** — `LocaleNotifier.build()` returns English then async-corrects; first frame may flash English.

---

## Remediation roadmap (priority order)

1. ~~**P0 — Stop showing raw keys:** add the ~62 missing keys (Category 1).~~ **DONE (2026-07-12):** all ~62 keys added to `app_strings.dart` with `en`+`sw` — Category 1 fully resolved.
2. ~~**P1 — Content layer (prose):**~~ **PROGRESS (2026-07-12):** Introduced `LocalizedText` record + `lt()` resolver in `app_strings.dart`. Applied to `legends.dart` (all prose fields) and `courses.dart` (titles, subtitles, lessons, categories). Renderers updated (`learn_page.dart`, `legend_detail_page.dart`, `legends_page.dart`, `course_detail_page.dart`, `lesson_page.dart`, `dashboard_page.dart`, `activity_detail_page.dart`). Remaining content gaps are `beat_legends.dart`, challenge evaluator, rank titles, and milestone stories.
3. **P0 — Safety:** localize the SOS SMS body and auth error messages.
4. **P1 — Wire existing keys** already defined but bypassed (`you`, `runner`, `stop_run`, `pause_run`/`resume_run`, `gps_required_body`, `you_beat_ghost`); fix theme-key mismatches; fix Explore nav label.
5. **P1 — Hardcoded literals:** wrap Category 2 strings; localize `route_detail_page.dart` (and fix its broken `\$slug`).
6. **P2 — Framework:** add `flutter_localizations` + delegates + `supportedLocales` + `locale:` binding.
7. **P3 — Polish:** pluralization helper, unit-token strategy (`km`/`mi`/`min`/`bpm`/`XP` whitelist vs. translate), decide on brand/language-code literals (`Mwendo`, `EN`/`SW`).
