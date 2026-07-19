import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale { english, swahili }

const _localePrefKey = 'mwendo.locale';

class LocaleNotifier extends Notifier<AppLocale> {
  @override
  AppLocale build() {
    // Restore persisted locale (plan §7). First frame may briefly show the
    // default; the async load corrects it before the user perceives a change.
    _restore();
    return AppLocale.english;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefKey);
    if (code == 'sw') state = AppLocale.swahili;
  }

  void set(AppLocale l) {
    state = l;
    SharedPreferences.getInstance()
        .then((p) => p.setString(_localePrefKey, l == AppLocale.swahili ? 'sw' : 'en'));
  }

  void toggle() => set(state == AppLocale.english ? AppLocale.swahili : AppLocale.english);
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLocale>(LocaleNotifier.new);

/// Lightweight i18n scaffold for the Phase 2 UI. English and Swahili are
/// provided for every key; missing keys fall back to English.
class L10n {
  static const Map<String, Map<String, String>> _strings = {
    'learn': {'en': 'Learn', 'sw': 'Jifunze'},
    'challenges': {'en': 'Challenges', 'sw': 'Changamoto'},
    'profile': {'en': 'Profile', 'sw': 'Wasifu'},
    'home': {'en': 'Home', 'sw': 'Mwanzo'},
    'run': {'en': 'Run', 'sw': 'Kimbia'},
    'academy': {'en': 'The Mwendo Academy', 'sw': 'Chuo cha Mwendo'},
    'academy_tag': {
      'en': 'Learn the science, the technique, and the heritage.',
      'sw': 'Jifunze sayansi, mbinu, na urithi.'
    },
    'running_science': {'en': 'Running Science', 'sw': 'Sayansi ya Kukimbia'},
    'technique_health': {'en': 'Technique & Health', 'sw': 'Mbinu na Afya'},
    'heritage': {'en': 'Heritage & Culture', 'sw': 'Urithi na Utamaduni'},
    'legends': {'en': 'East African Legends', 'sw': 'Mashujaa wa Afrika Mashariki'},
    'beat_the_legends': {'en': 'Beat the Legends', 'sw': 'Shindana na Mashujaa'},
    'continue_learning': {'en': 'Continue learning', 'sw': 'Endelea kujifunza'},
    'active_challenges': {'en': 'Active Challenges', 'sw': 'Changamoto Zilizo Hai'},
    'see_all': {'en': 'See all', 'sw': 'Tazama zote'},
    'recent_activity': {'en': 'Recent Activity', 'sw': 'Shughuli za Hivi Karibuni'},
    'your_streak': {'en': 'Your streak', 'sw': 'Msururu wako'},
    'level': {'en': 'Level', 'sw': 'Kiwango'},
    'leaderboard': {'en': 'Leaderboard', 'sw': 'Chati ya Wachezaji'},
    'achievements': {'en': 'Achievements', 'sw': 'Mafanikio'},
    'titles': {'en': 'Titles', 'sw': 'Majina'},
    'lessons': {'en': 'lessons', 'sw': 'masomo'},
    'mark_complete': {'en': 'Mark complete', 'sw': 'Weka alama ya kukamilika'},
    'completed': {'en': 'Completed', 'sw': 'Imekamilika'},
    'start_run': {'en': 'Go for a run', 'sw': 'Nenda ukimbi'},
    'challenge_me': {'en': 'Challenge me', 'sw': 'Nishindanishe'},
    'race_this_ghost': {'en': 'Race this ghost', 'sw': 'Shindana na mzuka'},
    'knowledge_streak': {'en': 'Knowledge streak', 'sw': 'Msururu wa Elimu'},
    'language': {'en': 'Language', 'sw': 'Lugha'},
    'english': {'en': 'English', 'sw': 'Kiingereza'},
    'swahili': {'en': 'Swahili', 'sw': 'Kiswahili'},
    'no_badges': {
      'en': 'Complete challenges and lessons to earn badges.',
      'sw': 'Kamilisha changamoto na masomo kupata beji.'
    },
    'edit': {'en': 'Edit', 'sw': 'Hariri'},
    'rank': {'en': 'Rank', 'sw': 'Nafasi'},
    'activity': {'en': 'Activity', 'sw': 'Shughuli'},
    'all': {'en': 'All', 'sw': 'Zote'},
    'cat_starter': {'en': 'Starter', 'sw': 'Mwanzo'},
    'cat_milestone': {'en': 'Milestones', 'sw': 'Hatua'},
    'cat_performance': {'en': 'Performance', 'sw': 'Utendaji'},
    'cat_fun': {'en': 'Fun', 'sw': 'Mchezo'},
    'cat_school': {'en': 'School', 'sw': 'Shule'},
    'cat_knowledge': {'en': 'Learn', 'sw': 'Jifunze'},
    'go_for_a_run': {'en': 'Go for a run', 'sw': 'Nenda ukimbi'},
    'open_academy': {'en': 'Open the Academy', 'sw': 'Fungua Chuo'},
    'reward': {'en': 'Reward', 'sw': 'Tuzo'},
    'badge': {'en': 'Badge', 'sw': 'Beji'},
    'goal': {'en': 'Goal', 'sw': 'Lengo'},
    'challenge_complete': {'en': 'Challenge complete!', 'sw': 'Changamoto imekamilika!'},
    'pace_per_segment': {'en': 'Pace per segment', 'sw': 'Kasi kwa sehemu'},
    'seconds_per_km': {'en': 'Seconds per ~1 km · lower is faster', 'sw': 'Sekunde kwa ~1 km · chini ni haraka'},
    'during_a_run': {'en': 'During a run, hold the ghost\'s average pace to stay ahead. Their target: ', 'sw': 'Wakati wa kukimbia, shikilia kasi ya wastani ya mzuka. Lengo lao: '},
    'delete_activity': {'en': 'Delete activity?', 'sw': 'Futa shughuli?'},
    'delete_activity_body': {'en': 'This run will be removed from your history.', 'sw': 'Mbio hii itaondolewa kwenye historia yako.'},
    'delete': {'en': 'Delete', 'sw': 'Futa'},
    'cancel': {'en': 'Cancel', 'sw': 'Ghairi'},
    'nothing_recorded': {'en': 'Nothing recorded yet', 'sw': 'Hakuna kilichorekodiwa bado'},
    'first_run_prompt': {'en': 'Head out for your first run.', 'sw': 'Tokea kwa mbio yako ya kwanza.'},
    'runner': {'en': 'Runner', 'sw': 'Mkimbiaji'},
    'distance': {'en': 'Distance', 'sw': 'Umbali'},
    'runs': {'en': 'Runs', 'sw': 'Mbio'},
    'time': {'en': 'Time', 'sw': 'Muda'},
    'streak': {'en': 'Streak', 'sw': 'Msururu'},
    'units': {'en': 'Units', 'sw': 'Vipimo'},
    'appearance': {'en': 'Appearance', 'sw': 'Mwonekano'},
    'dark': {'en': 'Dark', 'sw': 'Giza'},
    'light': {'en': 'Light', 'sw': 'Mwangaza'},
    'system': {'en': 'System', 'sw': 'Mfumo'},
    'emergency_contacts': {'en': 'Emergency contacts', 'sw': 'Anwani za dharura'},
    'not_set': {'en': 'Not set', 'sw': 'Haijaseti'},
    'export_data': {'en': 'Export data', 'sw': 'Hamisha data'},
    'no_runs_yet': {'en': 'No runs yet', 'sw': 'Hakuna mbio bado'},
    'routes_will_show': {'en': 'Your routes will show up here.', 'sw': 'Njia zako zitaonekana hapa.'},
    'all_caught_up': {'en': 'All caught up!', 'sw': 'Umekwisha yote!'},
    'browse_more': {'en': 'Browse more challenges to keep the momentum.', 'sw': 'Tazama changamoto zaidi kuendelea.'},
    'this_week': {'en': 'This week', 'sw': 'Wiki hii'},
    'best': {'en': 'Best', 'sw': 'Bora'},
    'no_badges_yet': {'en': 'Complete challenges and lessons to earn badges.', 'sw': 'Kamilisha changamoto na masomo kupata beji.'},
    'metric': {'en': 'Metric (km)', 'sw': 'Metriki (km)'},
    'imperial': {'en': 'Imperial (mi)', 'sw': 'Imperial (mi)'},
    'filter': {'en': 'Filter', 'sw': 'Chuja'},
    'sort': {'en': 'Sort', 'sw': 'Panga'},
    'sort_date': {'en': 'Newest', 'sw': 'Mpya'},
    'sort_distance': {'en': 'Distance', 'sw': 'Umbali'},
    'sort_duration': {'en': 'Duration', 'sw': 'Muda'},
    'export_gpx': {'en': 'Export GPX', 'sw': 'Hamisha GPX'},
    'export_json': {'en': 'Export JSON', 'sw': 'Hamisha JSON'},
    'exported': {'en': 'Exported', 'sw': 'Imehamishwa'},
    'get_started': {'en': 'Start your first run', 'sw': 'Anza mbio yako ya kwanza'},
    'first_run_hint': {'en': 'Your weekly stats are empty. Tap below to record your first run and start your streak!', 'sw': 'Takwimu zako za wiki ni tupu. Gusa hapa chini kurekodi mbio yako ya kwanza na kuanisha msururu wako!'},
    'weekly_distance': {'en': 'Weekly distance', 'sw': 'Umbali wa wiki'},
    'weekly_runs': {'en': 'Weekly runs', 'sw': 'Mbio za wiki'},
    'weekly_best': {'en': 'Weekly best pace', 'sw': 'Kasi bora ya wiki'},
    'elevation': {'en': 'Elevation', 'sw': 'Mwinuko'},
    'calories': {'en': 'Calories', 'sw': 'Kalori'},
    'elev_gain': {'en': 'Elev. Gain', 'sw': 'Mwinuko'},
    'avg_hr': {'en': 'Avg HR', 'sw': 'HR ya Wastani'},
    'add_contact': {'en': 'Add contact', 'sw': 'Ongeza anwani'},
    'edit_contact': {'en': 'Edit contact', 'sw': 'Hariri anwani'},
    'name': {'en': 'Name', 'sw': 'Jina'},
    'phone': {'en': 'Phone', 'sw': 'Simu'},
    'relationship': {'en': 'Relationship', 'sw': 'Uhusiano'},
    'save': {'en': 'Save', 'sw': 'Hifadhi'},
    'no_contacts_yet': {'en': 'No contacts yet. Tap Add to include someone.', 'sw': 'Hakuna anwani bado. Gusa Ongeza kuongeza mtu.'},
    'create_account': {'en': 'Create account', 'sw': 'Fungua akaunti'},
    'sign_in': {'en': 'Sign in', 'sw': 'Ingia'},
    'email': {'en': 'Email', 'sw': 'Barua pepe'},
    'password': {'en': 'Password', 'sw': 'Nenosiri'},
    'have_account': {'en': 'Already have an account? Sign in', 'sw': 'Tayari una akaunti? Ingia'},
    'need_account': {'en': 'Need an account? Register', 'sw': 'Unahitaji akaunti? Jisajili'},
    'continue_anonymous': {'en': 'Continue anonymously', 'sw': 'Endelea bila jina'},
    'account': {'en': 'Account', 'sw': 'Akaunti'},
    'sign_out': {'en': 'Sign out', 'sw': 'Toka'},
    'submitted': {'en': 'Run synced to leaderboard', 'sw': 'Mbio imesawazishwa kwenye ubao'},

    // ---- Polish pass ----
    'level_up_subtitle': {'en': 'Level up! Keep the streak alive.', 'sw': 'Umekwea kiwango! Endelea msururu.'},
    'walk_run_now': {'en': 'Take a walk-run now', 'sw': 'Fanya walk-run sasa'},
    'learn_to_run': {'en': 'How to Start Running', 'sw': 'Jinsi ya Kuanza Kukimbia'},
    'learn_to_run_hint': {
      'en': 'New here? Learn the walk-run method and reach your first 5K.',
      'sw': 'Mpya? Jifunze mbinu ya walk-run ufikie 5K yako ya kwanza.'
    },
    'import_gpx_action': {'en': 'Import a GPX', 'sw': 'Ingiza GPX'},
    'try_search': {'en': "Try 'Kipchoge' or 'Ethiopia'", 'sw': "Jaribu 'Kipchoge' au 'Ethiopia'"},
    'popular_legends': {'en': 'Popular', 'sw': 'Maarufu'},
    'stats_week': {'en': 'Week', 'sw': 'Wiki'},
    'stats_month': {'en': 'Month', 'sw': 'Mwezi'},
    'your_legends': {'en': 'Your Legends', 'sw': 'Mashujaa Wako'},
    'legend_raced': {'en': 'Raced', 'sw': 'Umeshindana'},
    'legend_beaten': {'en': 'Beaten', 'sw': 'Umeshinda'},
    'locked': {'en': 'Locked', 'sw': 'Imefuliwa'},
    'gps_required_title': {'en': 'Location is required', 'sw': 'Eneo linahitajika'},
    'gps_required_body': {
      'en': 'Mwendo uses your location to map your route and measure distance. Without it, runs cannot be tracked.',
      'sw': 'Mwendo hutumia eneo lako kuchora njia na kupima umbali. Bila hilo, mbio haziwezi kufuatiliwa.'
    },
    'progress_reset': {
      'en': 'Your saved progress was corrupted and has been reset.',
      'sw': 'Maendeleo yako yaliharibika na yamerudishwa.'
    },
    'sos_button': {'en': 'Emergency SOS', 'sw': 'SOS ya Dharura'},
    'stop_run': {'en': 'Stop run', 'sw': 'Sita mbio'},
    'pause_run': {'en': 'Pause run', 'sw': 'Sitisha mbio'},
    'resume_run': {'en': 'Resume run', 'sw': 'Endelea mbio'},
    'start_run_control': {'en': 'Start run', 'sw': 'Anza mbio'},
    'open_settings': {'en': 'Open Settings', 'sw': 'Fungua Mipangilio'},
    'skeleton_loading': {'en': 'Loading…', 'sw': 'Inapakia…'},
    'legends_title': {'en': 'Legends', 'sw': 'Mashujaa'},
    'search_legends': {'en': 'Search legends, countries…', 'sw': 'Tafuta mashujaa, nchi…'},
    'no_legends_match': {'en': 'No legends match your filters.', 'sw': 'Hakuna mashujaa wanaolingana.'},
    'pace': {'en': 'Pace', 'sw': 'Kasi'},
    'heart_rate': {'en': 'Heart Rate', 'sw': 'Mapigo ya Moyo'},
    'cadence': {'en': 'Cadence', 'sw': 'Kadensi'},
    'distance_label': {'en': 'Distance', 'sw': 'Umbali'},
    'elev_label': {'en': 'Elev. Gain', 'sw': 'Mwinuko'},
    'calories_label': {'en': 'Calories', 'sw': 'Kalori'},
    'time_label': {'en': 'Time', 'sw': 'Muda'},
    'gps_permission_required': {'en': 'Location permission is required to track runs.', 'sw': 'Ruhusa ya eneo inahitajika kufuatilia mbio.'},
    'grant_background_location': {'en': 'Grant "Allow all the time" so tracking continues with the screen off.', 'sw': 'Toa "Ruhusu kila wakati" ili ufuatiliaji uendelee hata skrini ikiwa imezimwa.'},
    'enable_notifications': {'en': 'Enable notifications so tracking can keep running in the background.', 'sw': 'Wezesha arifa ili ufuatiliaji uendelee chinichini.'},
    'no_route_recorded': {'en': 'No route recorded', 'sw': 'Hakuna njia iliorekodiwa'},
    'no_legends_match_title': {'en': 'No legends match your filters.', 'sw': 'Hakuna mashujaa wanaolingana.'},
    'settings': {'en': 'Settings', 'sw': 'Mipangilio'},
    'avg_pace': {'en': 'Avg Pace', 'sw': 'Kasi ya Wastani'},
    'start_running_to_compare': {'en': 'Start running to compare!', 'sw': 'Anza kukimbia kulinganisha!'},
    'log_distance_to_compare': {'en': 'Log a 5K, 10K, half or marathon and see how you stack up.', 'sw': 'Rekodi 5K, 10K, nusu au marathon uone jinsi unavyojilinganisha.'},
    'country': {'en': 'Country', 'sw': 'Nchi'},
    'discipline': {'en': 'Discipline', 'sw': 'Nidhamu'},
    'era': {'en': 'Era', 'sw': 'Zama'},
    'ghost_label': {'en': 'Ghost', 'sw': 'Mzuka'},
    'ready': {'en': 'Ready', 'sw': 'Tayari'},
    'recording': {'en': 'Recording', 'sw': 'Inarekodi'},
    'paused': {'en': 'Paused', 'sw': 'Imesitishwa'},
    'gps_searching': {'en': 'Searching for GPS…', 'sw': 'Inatafuta GPS…'},
    'no_emergency_contacts': {'en': 'No emergency contacts', 'sw': 'Hakuna anwani za dharura'},
    'sos_prompt': {'en': 'Set up emergency contacts in Settings to use SOS.', 'sw': 'Weka anwani za dharura kwenye Mipangilio kutumia SOS.'},
    'sending_sos': {'en': 'Sending SOS', 'sw': 'Inatuma SOS'},
    'alerting_contacts': {'en': 'Alerting contacts in ', 'sw': 'Inatahadharisha anwani katika '},
'ok': {'en': 'OK', 'sw': 'Sawa'},
    'ghost_held_off': {'en': '{name} held you off — you: {userPace} /km, ghost: {ghostPace} /km', 'sw': '{name} amekuzuia — wewe: {userPace} /km, mzuka: {ghostPace} /km'},
    'you_beat_ghost': {'en': 'You beat {name}! 🏆 ({userPace} vs {ghostPace} /km)', 'sw': 'Umemshinda {name}! 🏆 ({userPace} dhidi ya {ghostPace} /km)'},

    // ---- Onboarding (Phase 2 audit) ----
    'onboarding_skip': {'en': 'Skip', 'sw': 'Ruka'},
    'onboarding_next': {'en': 'Next', 'sw': 'Mbele'},
    'onboarding_get_started': {'en': 'Get started', 'sw': 'Anza'},
    'onboarding_run_title': {'en': 'Run with Mwendo', 'sw': 'Kimbia na Mwendo'},
    'onboarding_run_body': {'en': 'Track every step with a live map, pace and heart rate — all in one screen.', 'sw': 'Fuatilia hatua zako kwa ramani ya moja kwa moja, kasi na mapigo ya moyo — yote kwenye skrini moja.'},
    'onboarding_challenges_title': {'en': 'Challenges that stick', 'sw': 'Changamoto zinazoshikia'},
    'onboarding_challenges_body': {'en': 'Hit your first 5K, build a streak, and watch your XP grow with every run.', 'sw': 'Fikia 5K yako ya kwanza, jenge msururu, na uone XP yako ikiongezeka kila mbio.'},
    'onboarding_safe_title': {'en': 'Run safe', 'sw': 'Kimbia salama'},
    'onboarding_safe_body': {'en': 'One tap to alert your emergency contacts with your live location. Always.', 'sw': 'Gusa mara moja kuwaonya anwani zako za dharura kwa eneo lako la moja kwa moja. Siku zote.'},

    // ---- Learn (Phase 2 audit) ----
    'learn_hero_body': {'en': 'Learn the science, the technique, and the heritage of East African running.', 'sw': 'Jifunze sayansi, mbinu, na urithi wa kukimbia kwa Afrika Mashariki.'},
    'start': {'en': 'Start', 'sw': 'Anza'},
    'legendary_runners': {'en': 'legendary runners', 'sw': 'wakimbiaji wa hadithi'},
    'legends_teaser_sub': {'en': 'Keino to Kipyegon — their stories, records and quotes.', 'sw': 'Keino hadi Kipyegon — hadithi, rekodi na quote zao.'},
    'race_ghost_legend': {'en': 'Race a ghost legend', 'sw': 'Shindana na mzuka wa hadithi'},
    'race_ghost_sub': {'en': 'Pit your pace against Kipchoge, Kipyegon and more.', 'sw': 'Pima kasi yako dhidi ya Kipchoge, Kipyegon na wengine.'},

    // ---- Theme picker (Phase 2 audit) ----
    'color_theme': {'en': 'Color Theme', 'sw': 'Mwonekano wa Rangi'},
    'theme_kinetic_orange': {'en': 'Kinetic Orange', 'sw': 'Orenji ya Kinetiki'},
    'theme_kenyan_green': {'en': 'Kenyan Green', 'sw': 'Kijani cha Kenya'},
    'theme_midnight_blue': {'en': 'Midnight Blue', 'sw': 'Buluu ya Usiku'},
    'theme_berry': {'en': 'Berry', 'sw': 'Berry'},
    'choose_color_theme': {'en': 'Choose a color theme', 'sw': 'Chagua mwonekano wa rangi'},
    'color_theme_description': {'en': 'Customize the look and feel of your app.', 'sw': 'Rekebisha mwonekano na hisia ya programu yako.'},

    // ---- Explore (Phase 2 audit) ----
    'explore_routes': {'en': 'Routes', 'sw': 'Njia'},
    'explore_segments': {'en': 'Segments', 'sw': 'Sehemu'},
    'explore_leaderboards': {'en': 'Leaderboards', 'sw': 'Chati ya Wachezaji'},
    'explore_empty_title': {'en': 'Nothing here yet', 'sw': 'Hakuna hapa bado'},
    'explore_empty_body': {'en': 'Select a segment to see content.', 'sw': 'Chagua sehemu kuona maudhui.'},
    'explore_no_routes': {'en': 'No routes available', 'sw': 'Hakuna njia zinazopatikana'},
    'explore_no_segments': {'en': 'No segments available', 'sw': 'Hakuna sehemu zinazopatikana'},
    'explore_no_leaderboards': {'en': 'No leaderboards yet', 'sw': 'Hakuna chati ya wachezaji bado'},

    // ---- Legend of the day card ----
    'legend_of_week': {'en': 'LEGEND OF THE WEEK', 'sw': 'SHUJAA WA WIKI'},
    'did_you_know': {'en': 'DID YOU KNOW?', 'sw': 'JE, WAJUA?'},
    // Course detail
    'by': {'en': 'By', 'sw': 'Na'},
    'of': {'en': 'of', 'sw': 'kati ya'},
    'lessons_complete': {'en': 'lessons complete', 'sw': 'masomo yamekamilika'},
    // Challenge library header
    'total_xp': {'en': 'total XP', 'sw': 'jumla ya XP'},
    'challenges_done': {'en': 'challenges done', 'sw': 'changamoto zimekamilika'},
    // Leaderboard
    'you': {'en': 'You', 'sw': 'Wewe'},
    // Profile photo sheet
    'camera': {'en': 'Camera', 'sw': 'Kamera'},
    'gallery': {'en': 'Gallery', 'sw': 'Ghala'},
    'remove_photo': {'en': 'Remove photo', 'sw': 'Ondoa picha'},

    // ---- P0: missing keys (Category 1 — localization audit) ----
    // Onboarding (4th slide + hints)
    'onboarding_run_hint': {'en': 'Track every stride', 'sw': 'Fuatilia kila hatua'},
    'onboarding_challenges_hint': {'en': 'Build your streak', 'sw': 'Jenge msururu wako'},
    'onboarding_safe_hint': {'en': 'One tap to stay safe', 'sw': 'Gusa mara moja kuwa salama'},
    'onboarding_explore_title': {'en': 'Explore routes near you', 'sw': 'Gundua njia karibu nawe'},
    'onboarding_explore_body': {
      'en': 'Discover curated routes, segments and local leaderboards built by the community.',
      'sw': 'Gundua njia, sehemu na chati za wachezaji zilizotengenezwa na jamii.'
    },
    'onboarding_explore_hint': {'en': 'Find your next run', 'sw': 'Pata mbio yako inayofuata'},

    // Live HUD / widgets
    'km': {'en': 'km', 'sw': 'km'},
    'per_km': {'en': 'per km', 'sw': 'kwa km'},
    'lv': {'en': 'Lv', 'sw': 'Kiw'},

    // Learn / Legends / Explore
    'all_courses': {'en': 'All Courses', 'sw': 'Kozi Zote'},
    'biography': {'en': 'Biography', 'sw': 'Wasifu'},
    'personal_bests': {'en': 'Personal Bests', 'sw': 'Bora Zake'},
    'how_you_compare': {'en': 'How You Compare', 'sw': 'Jinsi Unavyojilinganisha'},
    'career_timeline': {'en': 'Career Timeline', 'sw': 'Ratiba ya Kazi'},
    'records': {'en': 'Records', 'sw': 'Rekodi'},
    'training_philosophy': {'en': 'Training Philosophy', 'sw': 'Falsafa ya Mazoezi'},
    'rivalries': {'en': 'Rivalries', 'sw': 'Ushindani'},
    'notable_races': {'en': 'Notable Races', 'sw': 'Mbio Muhimu'},
    'in_their_words': {'en': 'In Their Words', 'sw': 'Kwa Maneno Yao'},
    'quote': {'en': 'Quote', 'sw': 'Nukuu'},
    'related_legends': {'en': 'Related Legends', 'sw': 'Mashujaa Wanaohusiana'},
    'community_results': {'en': 'Community Results', 'sw': 'Matokeo ya Jamii'},
    'vs': {'en': 'vs', 'sw': 'dhidi'},
    'no_distance_logged': {'en': 'No {label} logged yet', 'sw': 'Hakuna {label} imerekodiwa bado'},
    'athletes_trained_with_legend': {'en': 'athletes trained with {name}', 'sw': 'wakimbiaji waliofanya mazoezi na {name}'},
    'lesson': {'en': 'Lesson', 'sw': 'Somo'},
    'lesson_complete_xp': {'en': 'Lesson complete! +XP earned', 'sw': 'Somo limekamilika! +XP imepata'},
    'read_more': {'en': 'Read more', 'sw': 'Soma zaidi'},
    'leaderboard_badge_goat': {'en': 'G.O.A.T.', 'sw': 'Bora Zaidi'},

    // Beat-the-Legends flow
    'your_pb': {'en': 'Your PB', 'sw': 'PB Yako'},
    'tier_recommendation': {'en': 'Recommended tier', 'sw': 'Kiwango kinachoshauriwa'},
    'based_on_your_pb': {'en': 'based on your PB', 'sw': 'kulingana na PB yako'},
    'all_distances': {'en': 'All distances', 'sw': 'Umbali wote'},
    'target': {'en': 'Target', 'sw': 'Lengo'},
    'avg': {'en': 'Avg', 'sw': 'Wastani'},
    'slower_than_ghost': {'en': 'slower than ghost', 'sw': 'polepole kuliko mzuka'},
    'faster_than_ghost': {'en': 'faster than ghost', 'sw': 'haraka kuliko mzuka'},
    'no_pb_yet': {'en': 'No PB yet', 'sw': 'Hakuna PB bado'},
    'ahead': {'en': 'Ahead', 'sw': 'Mbele'},
    'behind': {'en': 'Behind', 'sw': 'Nyuma'},
    'proj': {'en': 'Proj.', 'sw': 'Proj.'},
    'projected_finish': {'en': 'Projected finish', 'sw': 'Umalizio uliotarajiwa'},
    'ghost_finish': {'en': 'Ghost finish', 'sw': 'Umalizio wa mzuka'},
    'split_label': {'en': 'Split', 'sw': 'Sehemu'},
    'overall': {'en': 'Overall', 'sw': 'Jumla'},
    'change_tier': {'en': 'Change tier', 'sw': 'Badilisha kiwango'},
    'target_split': {'en': 'Target split', 'sw': 'Sehemu ya lengo'},
    'pace_per_km': {'en': 'Pace / km', 'sw': 'Kasi / km'},
    'you_beat': {'en': 'You beat the ghost!', 'sw': 'Umemshinda mzuka!'},
    'your_time': {'en': 'Your time', 'sw': 'Muda wako'},
    'ghost_time': {'en': 'Ghost time', 'sw': 'Muda wa mzuka'},
    'close': {'en': 'Close', 'sw': 'Funga'},
    'rematch': {'en': 'Rematch', 'sw': 'Shindana tena'},
    'try_harder_tier': {'en': 'Try a harder tier', 'sw': 'Jaribu kiwango kigumu zaidi'},
    'share_result': {'en': 'Share result', 'sw': 'Shiriki matokeo'},
    'split_comparison': {'en': 'Split Comparison', 'sw': 'Ulinganisho wa Sehemu'},
    'delta': {'en': 'Delta', 'sw': 'Tofauti'},
    'status': {'en': 'Status', 'sw': 'Hali'},
    'race_summary': {'en': 'Race Summary', 'sw': 'Muhtasari wa Mbio'},
    'unknown': {'en': 'Unknown', 'sw': 'Haijulikani'},
    'ready_to_race': {'en': 'Ready to race', 'sw': 'Tayari kushindana'},
    'gps_error_start': {'en': 'GPS failed to start. Please try again.', 'sw': 'GPS imeshindwa kuanza. Tafadhali jaribu tena.'},
    'continue_without_background_location': {'en': 'Continue without background location', 'sw': 'Endelea bila eneo la nyuma'},
    'm_behind': {'en': 'm behind', 'sw': 'm nyuma'},
    'm_ahead': {'en': 'm ahead', 'sw': 'm mbele'},
    'meters': {'en': 'm', 'sw': 'm'},
    'kilocalories': {'en': 'kcal', 'sw': 'kilokalori'},
    'recenter_map': {'en': 'Re-center map', 'sw': 'Rudisha ramani katik'},
    'zoom_label': {'en': 'Zoom', 'sw': 'Zoom'},
  };

  static String tr(String key, AppLocale locale) {
    final lang = locale == AppLocale.swahili ? 'sw' : 'en';
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }
}

extension L10nRef on WidgetRef {
  String tr(String key) => L10n.tr(key, read(localeProvider));
}

/// Localized content string: holds both English and Swahili variants of
/// long-form content (legend bios, course/lesson prose, etc.) that lives in
/// data files rather than the short UI key catalog. Resolves by [AppLocale].
typedef LocalizedText = ({String en, String sw});

String lt(LocalizedText t, AppLocale locale) =>
    locale == AppLocale.swahili ? t.sw : t.en;

/// Convenience for content that is only ever authored in English (proper
/// nouns, times, etc.) so callers can uniformly pass a [LocalizedText].
LocalizedText l10nEn(String en) => (en: en, sw: en);
