/// Interactive profiles of East African running legends (Pillar 3).
/// Avatars use emoji so the experience works fully offline.
/// Content fields use [LocalizedText] (en/sw) so the UI can render in either
/// language; proper nouns (name) stay as authored.
library;

import 'package:flutter/material.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';

const _kKenya = 'orange';
const _kEthiopia = 'gold';
const _kUganda = 'green';
const _kNetherlands = 'gold';

/// A categorized quote for a legend.
class LegendQuote {
  final String category; // 'training' | 'racing' | 'life' | 'legacy'
  final LocalizedText text;
  const LegendQuote(this.category, this.text);

  static const Map<String, (IconData, LocalizedText)> categoryMeta = {
    'training': (Icons.directions_run_rounded, (en: 'Training', sw: 'Mazoezi')),
    'racing': (Icons.emoji_events_rounded, (en: 'Racing', sw: 'Mashindano')),
    'life': (Icons.psychology_rounded, (en: 'Life', sw: 'Maisha')),
    'legacy': (Icons.auto_stories_rounded, (en: 'Legacy', sw: 'Urithi')),
  };
}

class LegendMilestone {
  final String year;
  final LocalizedText text;
  const LegendMilestone(this.year, this.text);
}

class Legend {
  final String slug;
  final String name; // proper noun — not localized
  final LocalizedText country;
  final String flag;
  final LocalizedText discipline;
  final LocalizedText tagline;
  final LocalizedText bio;
  final List<LegendMilestone> timeline;
  final List<LocalizedText> records;
  final List<LocalizedText> quotes;
  final String emoji;
  final String accent; // hex-like color name resolved below
  final String? beatLegendId;

  // ---- New fields (Pillar 3 expansion) ----
  final Map<String, String>? personalBests;
  final LocalizedText? trainingPhilosophy;
  final List<String>? rivalries; // rival legend slugs
  final List<LocalizedText>? notableRaces;
  final LocalizedText? funFact;
  final List<String>? relatedLegends; // related legend slugs
  final List<LegendQuote>? quotesExtra;
  final String? relatedCourseSlug;
  final int? eraStartYear;

  const Legend({
    required this.slug,
    required this.name,
    required this.country,
    required this.flag,
    required this.discipline,
    required this.tagline,
    required this.bio,
    required this.timeline,
    required this.records,
    required this.quotes,
    required this.emoji,
    required this.accent,
    this.beatLegendId,
    this.personalBests,
    this.trainingPhilosophy,
    this.rivalries,
    this.notableRaces,
    this.funFact,
    this.relatedLegends,
    this.quotesExtra,
    this.relatedCourseSlug,
    this.eraStartYear,
  });

  /// Era bucket label derived from the first career year (kept as a small
  /// [LocalizedText] so the UI can localize it).
  LocalizedText get eraLabel {
    final year = eraStartYear ??
        int.tryParse(timeline.isNotEmpty ? timeline.first.year : '') ?? 2000;
    if (year <= 1979) return (en: '1960s–70s', sw: 'Miaka 1960–70');
    if (year <= 1999) return (en: '1980s–90s', sw: 'Miaka 1980–90');
    if (year <= 2019) return (en: '2000s–10s', sw: 'Miaka 2000–10');
    return (en: '2020s+', sw: 'Miaka 2020+');
  }

  List<Legend> get rivals =>
      (rivalries ?? []).map(legendForSlug).toList();

  List<Legend> get related =>
      (relatedLegends ?? []).map(legendForSlug).toList();
}

/// Translate a PB distance key (English) into the current locale.
String distanceLabel(String en, AppLocale locale) {
  const map = {
    'Marathon': (en: 'Marathon', sw: 'Mbio ya Marathon'),
    'Half Marathon': (en: 'Half Marathon', sw: 'Nusu Marathon'),
    '10,000m': (en: '10,000m', sw: '10,000m'),
    '5000m': (en: '5000m', sw: '5000m'),
    '1500m': (en: '1500m', sw: '1500m'),
    '3000m': (en: '3000m', sw: '3000m'),
    '3000m SC': (en: '3000m SC', sw: '3000m SC'),
    '800m': (en: '800m', sw: '800m'),
    'Mile': (en: 'Mile', sw: 'Mmaili'),
    '2 Mile': (en: '2 Mile', sw: 'Maili 2'),
    '600m': (en: '600m', sw: '600m'),
    '400m': (en: '400m', sw: '400m'),
    '15K': (en: '15K', sw: '15K'),
    '10K (road)': (en: '10K (road)', sw: '10K (barabara)'),
  };
  final lt = map[en];
  return lt == null ? en : (locale == AppLocale.swahili ? lt.sw : lt.en);
}

const List<Legend> legends = [
  Legend(
    slug: 'eliud-kipchoge',
    name: 'Eliud Kipchoge',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'The philosopher of the marathon.', sw: 'Mwanafalsafa wa mbio za marathon.'),
    bio: (en: 'Widely considered the greatest marathoner of all time, Kipchoge broke the 2-hour barrier in an exhibition and set the official world record of 2:01:09 in Berlin 2022. His calm, methodical approach turned racing into a craft.',
        sw: 'Anayehusudiwa kuwa mkimbiaji mkuu wa marathon wa wakati wote, Kipchoge alivunja kizuizi cha saa 2 katika onyesho na kuweka rekodi rasmi ya dunia ya 2:01:09 huko Berlin 2022. Mbinu yake ya utulivu na mpango ilifanya mashindano yawe ni sanaa.'),
    timeline: [
      LegendMilestone('2003', (en: 'World 5000m bronze in Paris', sw: 'Shaba ya dunia ya 5000m huko Paris')),
      LegendMilestone('2013', (en: 'Transitions to the marathon', sw: 'Angeuka kuelekea mbio ya marathon')),
      LegendMilestone('2016', (en: 'Olympic marathon gold, Rio', sw: 'Dhahabu ya Olympic ya marathon, Rio')),
      LegendMilestone('2018', (en: 'World record 2:01:39, Berlin', sw: 'Rekodi ya dunia 2:01:39, Berlin')),
      LegendMilestone('2019', (en: 'Runs 1:59:40 in Vienna (exhibition)', sw: 'Anakimbia 1:59:40 huko Vienna (onyesho)')),
      LegendMilestone('2022', (en: 'World record 2:01:09, Berlin', sw: 'Rekodi ya dunia 2:01:09, Berlin')),
    ],
    records: [(en: 'Marathon WR 2:01:09 (Berlin 2022)', sw: 'Rekodi ya dunia ya Marathon 2:01:09 (Berlin 2022)'), (en: 'First sub-2 hour marathon (exhibition)', sw: 'Marathon ya kwanza chini ya saa 2 (onyesho)')],
    quotes: [(en: 'No human is limited.', sw: 'Hakuna binadamu aliye na mwisho.'), (en: 'The will is what matters most.', sw: 'Nia ndiyo muhimu zaidi.')],
    emoji: '🏃',
    accent: _kKenya,
    beatLegendId: 'kipchoge-marathon',
    eraStartYear: 2003,
    personalBests: {
      'Marathon': '2:01:09',
      'Half Marathon': '59:25',
      '10,000m': '27:36.55',
      '5000m': '12:46.53',
    },
    trainingPhilosophy:
        (en: 'Kipchoge trains at the high-altitude Kaptagat camp, where the week is built around a Tuesday tempo and the legendary Thursday fartlek. He preaches patience: easy days are genuinely easy, and every rep is run by feel, not by the watch. "Train your mind, and the body will follow," he says — discipline and joy, in equal measure, are the engine of his consistency.',
        sw: 'Kipchoge anafanya mazoezi kambini la Kaptagat lenye kimo cha juu, ambapo juma hujengwa kuzunguka kasi ya Jumanne na fartlek ya Alhamisi iliyo ya hadithi. Anahubiri subira: siku za urahisi ni rahisi kweli, na kila marudio hukimbia kwa hisia, sio kwa saa. "Fanya mazoezi ya akili yako, na mwili utafuata," anasema — nidhamu na furaha, kwa kiasi sawa, ndizo injini ya utulivu wake.'),
    rivalries: ['kelvin-kiptum'],
    notableRaces: [
      (en: 'Berlin 2022 — World record 2:01:09, a masterclass in controlled pacing.', sw: 'Berlin 2022 — Rekodi ya dunia 2:01:09, funzo bora la kudhibiti kasi.'),
      (en: 'Vienna 2019 — 1:59:40, the first marathon ever run under two hours (exhibition).', sw: 'Vienna 2019 — 1:59:40, marathon ya kwanza kuendeshwa chini ya saa mbili (onyesho).'),
      (en: 'Rio 2016 — Olympic gold in his first marathon major.', sw: 'Rio 2016 — Dhahabu ya Olympic katika marathon yake ya kwanza kuu.'),
    ],
    funFact: (en: 'Kipchoge\'s favourite pre-race breakfast is tea and chapati.', sw: 'Kifungua kinywa chake cha kupendeza kabla ya mbio ni chai na chapati.'),
    relatedLegends: ['kelvin-kiptum', 'paul-tergat', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('training', (en: 'Only the disciplined ones are free in life.', sw: 'Ni wenye nidhamu pekee wanao huru maishani.')),
      LegendQuote('racing', (en: 'I expect more from myself than anyone else could ever expect.', sw: 'Natarajia zaidi kutoka kwa nafsi yangu kuliko mwingine yeyote.')),
      LegendQuote('life', (en: 'I don\'t know where the limit is, but I would like to go there.', sw: 'Sijui mpaka uko wapi, lakini ningependa kufika huko.')),
      LegendQuote('legacy', (en: 'I want to inspire the next generation of athletes.', sw: 'Nataka kuhamasisha kizazi kijacho cha wanariadha.')),
    ],
    relatedCourseSlug: 'the-thursday-fartlek',
  ),
  Legend(
    slug: 'kelvin-kiptum',
    name: 'Kelvin Kiptum',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'The prodigy who rewrote the limits.', sw: 'Mtoto wa ajabu aliyeandika mpya mipaka.'),
    bio: (en: 'Kiptum stormed onto the scene with a world record 2:00:35 at the 2023 Chicago Marathon, running an aggressive negative split that stunned the sport. His rise hinted at a new era of marathon speed.',
        sw: 'Kiptum aliingia kwa kishindo na rekodi ya dunia ya 2:00:35 kwenye Marathon ya Chicago ya 2023, akikimbia mgawanyo mkali hasi ulioshangaza mchezo. Kupanda kwake kulidokeza enzi mpya ya kasi ya marathon.'),
    timeline: [
      LegendMilestone('2022', (en: 'Marathon debut, Valencia 2:01:53', sw: 'Mbio ya kwanza ya marathon, Valencia 2:01:53')),
      LegendMilestone('2023', (en: 'London 2:01:25 — course record', sw: 'London 2:01:25 — rekodi ya kozi')),
      LegendMilestone('2023', (en: 'World record 2:00:35, Chicago', sw: 'Rekodi ya dunia 2:00:35, Chicago')),
    ],
    records: [(en: 'Marathon WR 2:00:35 (Chicago 2023)', sw: 'Rekodi ya dunia ya Marathon 2:00:35 (Chicago 2023)')],
    quotes: [(en: 'I just run my race.', sw: 'Nakimbia tu mbio yangu.')],
    emoji: '⚡',
    accent: _kKenya,
    beatLegendId: 'kiptum-marathon',
    eraStartYear: 2022,
    personalBests: {
      'Marathon': '2:00:35',
      'Half Marathon': '58:42',
    },
    trainingPhilosophy:
        (en: 'Kiptum built his marathon strength on long, hilly runs around Chepsamo in the Rift Valley, complemented by fast track sessions. Coached by the late Gervais Hakizimana, he was known for high weekly volume and fearless negative-split racing — going harder in the second half than the first.',
        sw: 'Kiptum alijenga nguvu zake za marathon kwa kukimbia kwa muda mrefu milimani karibu na Chepsamo katika Bonde la Rift, akisaidiwa na vipindi vya kasi kwenye nyanya. Akiwa na mchezeshaji Gervais Hakizimana marehemu, alijulikana kwa kiasi kikubwa cha kila wiki na mashindano ya ujasiri ya mgawanyo hasi — kukimbia kwa nguvu zaidi katika sehemu ya pili kuliko ya kwanza.'),
    rivalries: ['eliud-kipchoge'],
    notableRaces: [
      (en: 'Chicago 2023 — World record 2:00:35, the fastest marathon in history.', sw: 'Chicago 2023 — Rekodi ya dunia 2:00:35, marathon ya haraka zaidi katika historia.'),
      (en: 'London 2023 — 2:01:25, a course record on debut at the event.', sw: 'London 2023 — 2:01:25, rekodi ya kozi katika kwanza yake kwenye tukio.'),
      (en: 'Valencia 2022 — 2:01:53, the fastest-ever marathon debut.', sw: 'Valencia 2022 — 2:01:53, mbio ya kwanza ya marathon ya haraka zaidi.'),
    ],
    funFact: (en: 'As a teenager he would pace elite runners for free just to be part of the training.', sw: 'Akiwa kijana alikuwa akawapimia wanariadha hodari bila malipo ili tu kuwa sehemu ya mazoezi.'),
    relatedLegends: ['eliud-kipchoge', 'paul-tergat'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I knew I could run a fast time if I pushed in the second half.', sw: 'Nilijua ningeweza kukimbia kwa wakati wa haraka nikisukuma katika sehemu ya pili.')),
      LegendQuote('training', (en: 'The hills make you strong; the track makes you fast.', sw: 'Milima hukufanya uwe na nguvu; nyanya hukufanya uwe wa haraka.')),
      LegendQuote('legacy', (en: 'I want to show the young ones that anything is possible.', sw: 'Nataka kuwaonyesha vijana kwamba chochote ni rahisi.')),
    ],
  ),
  Legend(
    slug: 'sabastian-sawe',
    name: 'Sabastian Sawe',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'A new name at the front of the pack.', sw: 'Jina jipya mbele ya kundi.'),
    bio: (en: 'Sawe announced himself with a blistering run in London, joining the tiny group of men under 1:59:30. A reminder that the Kenyan pipeline never runs dry.',
        sw: 'Sawe alijitangaza kwa mbio ya kuharisha huko London, akaingia kwenye kundi dogo la wanaume chini ya 1:59:30. Ukumbusho kwamba mfumo wa Kenya haukaushi kamwe.'),
    timeline: [
      LegendMilestone('2024', (en: 'Half marathon breakthrough', sw: 'Mafanikio makubwa ya nusu marathon')),
      LegendMilestone('2026', (en: 'London — 1:59:30 (verify ratification)', sw: 'London — 1:59:30 (thibitisha uidhinishaji)')),
    ],
    records: [(en: 'London 1:59:30 (2026, pending ratification)', sw: 'London 1:59:30 (2026, inasubiri uidhinishaji)')],
    quotes: [(en: 'One step, then the next.', sw: 'Hatua moja, kisha inayofuata.')],
    emoji: '🌟',
    accent: _kKenya,
    eraStartYear: 2024,
    personalBests: {
      'Marathon': '2:03:37',
      'Half Marathon': '59:05',
    },
    trainingPhilosophy:
        (en: 'Sawe rose through the half-marathon ranks before stepping up to the full distance, leaning on high-volume aerobic work and a strong finishing kick. His progress reflects the modern Kenyan pipeline of moving from road 21.1K to marathon with remarkable speed.',
        sw: 'Sawe alipanda viwango vya nusu marathon kabla ya kuingia umbali kamili, akiiegemea kazi kubwa ya aerobiki na teke ya nguvu ya kumalizia. Maendeleo yake yanaonyesha mfumo wa kisasa wa Kenya wa kusonga kutoka barabara ya 21.1K hadi marathon kwa kasi ya ajabu.'),
    rivalries: ['kelvin-kiptum'],
    notableRaces: [
      (en: 'London 2026 — 1:59:30, a stunning run pending ratification.', sw: 'London 2026 — 1:59:30, mbio ya kushangaza inayosubiri uidhinishaji.'),
      (en: 'Valencia Half — a breakthrough that flagged him as one to watch.', sw: 'Nusu Valencia — mafanikio makubwa yaliyomweka alama kama anayefaa kutazamwa.'),
    ],
    funFact: (en: 'He began as a cross-country runner before discovering he was even faster on the road.', sw: 'Alianza kama mkimbiaji wa msituni kabla ya kugundua alikuwa wa haraka zaidi barabarani.'),
    relatedLegends: ['kelvin-kiptum', 'eliud-kipchoge'],
    quotesExtra: [
      LegendQuote('racing', (en: 'When the pack slows, that is when I accelerate.', sw: 'Wakati kundi linapopunguza, ndipo ninaposonga mbele.')),
      LegendQuote('training', (en: 'Consistency on the easy days builds the fast days.', sw: 'Utimizaji siku za urahisi hujenga siku za haraka.')),
    ],
  ),
  Legend(
    slug: 'haile-gebrselassie',
    name: 'Haile Gebrselassie',
    country: (en: 'Ethiopia', sw: 'Uhabeshi'),
    flag: '🇪🇹',
    discipline: (en: 'Marathon / 10,000m', sw: 'Marathon / 10,000m'),
    tagline: (en: 'The emperor of distance.', sw: 'Mfalme wa umbali.'),
    bio: (en: 'A two-time Olympic 10,000m champion who later took the marathon world record to 2:03:59 in Berlin 2008. Haile combined elegance and fierce competitiveness across two decades.',
        sw: 'Mshindi mara mbili wa Olympic ya 10,000m ambaye baadaye alichukua rekodi ya dunia ya marathon hadi 2:03:59 huko Berlin 2008. Haile aliunganisha uzuri na ushindani mkali kwa miongo miwili.'),
    timeline: [
      LegendMilestone('1996', (en: 'Olympic 10,000m gold, Atlanta', sw: 'Dhahabu ya Olympic ya 10,000m, Atlanta')),
      LegendMilestone('2000', (en: 'Olympic 10,000m gold, Sydney', sw: 'Dhahabu ya Olympic ya 10,000m, Sydney')),
      LegendMilestone('2008', (en: 'Marathon WR 2:03:59, Berlin', sw: 'Rekodi ya dunia ya Marathon 2:03:59, Berlin')),
    ],
    records: [(en: 'Marathon WR 2:03:59 (Berlin 2008)', sw: 'Rekodi ya dunia ya Marathon 2:03:59 (Berlin 2008)'), (en: 'Multiple 10,000m Olympic golds', sw: 'Medali nyingi za dhahabu za Olympic za 10,000m')],
    quotes: [(en: 'I run with my heart, not my legs.', sw: 'Nakimbia kwa moyo wangu, sio miguu yangu.')],
    emoji: '👑',
    accent: _kEthiopia,
    eraStartYear: 1993,
    personalBests: {
      'Marathon': '2:03:59',
      '10,000m': '26:22.75',
      '5000m': '12:39.36',
      '3000m': '7:25.09',
    },
    trainingPhilosophy:
        (en: 'Haile\'s signature was "running with the heart" — relaxed, rhythmic, and economical. He favoured high-altitude training in Ethiopia and long, smooth intervals, never wasting a movement. His famous arm-cylon (from childhood carrying books) became part of a near-perfect stride that carried him across two decades at the top.',
        sw: 'Alama ya Haile ilikuwa "kukimbia kwa moyo" — aliye raha, wa mdundo, na wa kuokoa nishati. Aliipendelea mazoezi ya kimo cha juu nchini Uhabeshi na vipindi virefu, laini, bila kupoteza mwendo. Kikosi chake cha mkono (kutoka utotoni kubeba vitabu) kikawa sehemu ya hatua karibu kamili iliyombeba kwa miongo miwili juu.'),
    rivalries: ['paul-tergat', 'kenenisa-bekele'],
    notableRaces: [
      (en: 'Berlin 2008 — Marathon world record 2:03:59 at age 35.', sw: 'Berlin 2008 — Rekodi ya dunia ya marathon 2:03:59 akiwa na miaka 35.'),
      (en: 'Sydney 2000 — Olympic 10,000m gold in a classic duel.', sw: 'Sydney 2000 — Dhahabu ya Olympic ya 10,000m katika pambano la kawaida.'),
      (en: 'Multiple world records from 5000m to the hour run.', sw: 'Rekodi nyingi za dunia kutoka 5000m hadi mbio ya saa.'),
    ],
    funFact: (en: 'He ran with his left arm slightly bent from carrying schoolbooks as a child — and never changed it.', sw: 'Aliokimbia mkono wake wa kushoto ukiwa umepindwa kidogo kutoka kubeba vitabu shuleni utotoni — na hakuwahi kubadilisha.'),
    relatedLegends: ['paul-tergat', 'kenenisa-bekele', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('training', (en: 'If you don\'t have a plan, you will never reach your goal.', sw: 'Ukikose mpango, hutafika kamwe lengo lako.')),
      LegendQuote('racing', (en: 'I love the pressure. Pressure is a privilege.', sw: 'Napenda shinikizo. Shinikizo ni fursa.')),
      LegendQuote('life', (en: 'Running is my medicine, my peace.', sw: 'Kukimbia ni dawa yangu, amani yangu.')),
      LegendQuote('legacy', (en: 'I want to be remembered as one who inspired.', sw: 'Nataka kukumbukwa kama mmoja aliyehamasisha.')),
    ],
    relatedCourseSlug: 'history-of-east-african-running',
  ),
  Legend(
    slug: 'paul-tergat',
    name: 'Paul Tergat',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '10,000m / Marathon', sw: '10,000m / Marathon'),
    tagline: (en: 'The gentleman who broke 2:05 first.', sw: 'Mwanaume sharifu aliyevunja 2:05 kwanza.'),
    bio: (en: 'Five-time world cross-country champion and the first man under 2:05 in the marathon (2:04:55, Berlin 2003). His rivalry with Haile defined an era.',
        sw: 'Bingwa mara tano wa dunia wa msituni na mtu wa kwanza chini ya 2:05 kwenye marathon (2:04:55, Berlin 2003). Ushindani wake na Haile ulifafanua enzi.'),
    timeline: [
      LegendMilestone('1995', (en: 'First of five XC world titles', sw: 'Kwanza ya mataji matano ya dunia ya XC')),
      LegendMilestone('1997', (en: 'World 10,000m champion', sw: 'Bingwa wa dunia wa 10,000m')),
      LegendMilestone('2003', (en: 'First marathon under 2:05, Berlin', sw: 'Marathon ya kwanza chini ya 2:05, Berlin')),
    ],
    records: [(en: 'Marathon 2:04:55 (Berlin 2003)', sw: 'Marathon 2:04:55 (Berlin 2003)'), (en: '10,000m 26:27.85', sw: '10,000m 26:27.85'), (en: 'Half marathon 59:17', sw: 'Nusu marathon 59:17')],
    quotes: [(en: 'Pain is temporary, pride is forever.', sw: 'Maumivu ni ya muda, fahari ni ya milele.')],
    emoji: '🕊️',
    accent: _kKenya,
    beatLegendId: 'tergat-10k',
    eraStartYear: 1995,
    personalBests: {
      'Marathon': '2:04:55',
      '10,000m': '26:27.85',
      '5000m': '12:49.87',
      'Half Marathon': '59:17',
    },
    trainingPhilosophy:
        (en: 'Tergat built his engine on world-cross-country dominance, then translated that strength to the roads. He emphasized year-round aerobic base, disciplined long runs, and a calm, almost serene race temperament — "pain is temporary, pride is forever" was his creed.',
        sw: 'Tergat alijenga injini yake kwa nguvu za dunia za msituni, kisha akageuza nguvu hizo barabarani. Alisisitiza msingi wa aerobiki mwaka mzima, kukimbia kwa nidhamu kwa muda mrefu, na tabia ya mbio ya utulivu — "maumivu ni ya muda, fahari ni ya milele" ilikuwa imani yake.'),
    rivalries: ['haile-gebrselassie'],
    notableRaces: [
      (en: 'Berlin 2003 — First marathon under 2:05 (2:04:55).', sw: 'Berlin 2003 — Marathon ya kwanza chini ya 2:05 (2:04:55).'),
      (en: 'Athens 1997 — World 10,000m champion.', sw: 'Athens 1997 — Bingwa wa dunia wa 10,000m.'),
      (en: 'Five World Cross-Country titles across the 1990s.', sw: 'Mataji matano ya Dunia ya Msituni katika miaka ya 1990.'),
    ],
    funFact: (en: 'He was a policeman before running full-time, and famously humble about his success.', sw: 'Alikuwa polisi kabla ya kukimbia kwa wakati wote, na alijulikana kwa unyenyekevu kuhusu mafanikio yake.'),
    relatedLegends: ['haile-gebrselassie', 'kenenisa-bekele'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I never feared the pain; I feared quitting.', sw: 'Sikuwahi kuogopa maumivu; niliogopa kukata tamaa.')),
      LegendQuote('training', (en: 'The cross-country mud built the marathon lungs.', sw: 'Tope la msituni lilijenga mapafu ya marathon.')),
      LegendQuote('legacy', (en: 'To be first under 2:05 was for all of Kenya.', sw: 'Kuwa wa kwanza chini ya 2:05 ilikuwa kwa ajili ya Kenya yote.')),
    ],
    relatedCourseSlug: 'history-of-east-african-running',
  ),
  Legend(
    slug: 'kipchoge-keino',
    name: 'Kipchoge Keino',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '1500m / 5000m', sw: '1500m / 5000m'),
    tagline: (en: 'The father of Kenyan dominance.', sw: 'Baba wa uongozi wa Kenya.'),
    bio: (en: 'His 1968 Olympic gold ignited East Africa\'s distance-running era. Keino raced through illness and adversity with courage that became legend.',
        sw: 'Dhahabu yake ya Olympic ya 1968 iliwasha enzi ya mbio za umbali za Afrika Mashariki. Keino alishindana kupitia ugonjwa na shida kwa ujasiri uliokuwa hadithi.'),
    timeline: [
      LegendMilestone('1968', (en: 'Olympic 1500m gold, Mexico City', sw: 'Dhahabu ya Olympic ya 1500m, Mexico City')),
      LegendMilestone('1972', (en: 'Olympic 3000m steeplechase gold', sw: 'Dhahabu ya Olympic ya 3000m steeplechase')),
    ],
    records: [(en: 'Olympic 1500m champion 1968', sw: 'Bingwa wa Olympic ya 1500m 1968')],
    quotes: [(en: 'Courage is not the absence of fear.', sw: 'Ushujaa sio kutokuwa na woga.')],
    emoji: '🦁',
    accent: _kKenya,
    beatLegendId: 'keino-1500',
    eraStartYear: 1968,
    personalBests: {
      '1500m': '3:34.91',
      '3000m': '7:39.6',
      '5000m': '13:24.2',
      '3000m SC': '8:23.6',
    },
    trainingPhilosophy:
        (en: 'Keino trained on the high farms around Eldoret, running long and hard at altitude long before altitude science was popular. He raced with a fearless front-running style and a stoic toughness — famously winning the 1968 1500m while battling a gall bladder infection.',
        sw: 'Keino alifanya mazoezi kwenye shamba za juu karibu na Eldoret, akikimbia kwa muda mrefu na kwa nguvu katika kimo kabla ya sayansi ya kimo kuwa maarufu. Alishindana kwa mtindo wa ujasiri wa kupiga mbele na uthabiti — maarufu kwa kushinda 1500m ya 1968 akiwa na ugonjwa wa kibofu cha nyongo.'),
    rivalries: [],
    notableRaces: [
      (en: 'Mexico City 1968 — Olympic 1500m gold that launched an era.', sw: 'Mexico City 1968 — Dhahabu ya Olympic ya 1500m iliyoanza enzi.'),
      (en: 'Munich 1972 — Olympic 3000m steeplechase gold.', sw: 'Munich 1972 — Dhahabu ya Olympic ya 3000m steeplechase.'),
    ],
    funFact: (en: 'After retiring he founded an orphanage and farm that has sheltered hundreds of children.', sw: 'Baada ya kustaafu alianzisha nyumba ya watoto yatima na shamba ambalo limewatunza mamia ya watoto.'),
    relatedLegends: ['eliud-kipchoge', 'paul-tergat', 'haile-gebrselassie'],
    quotesExtra: [
      LegendQuote('life', (en: 'Sport can change the world, one child at a time.', sw: 'Michezo inaweza kubadilisha dunia, mtoto mmoja baada ya mwingine.')),
      LegendQuote('legacy', (en: 'We showed the world that Africans could rule the track.', sw: 'Tulionyesha ulimwengu kwamba Waafrika wangeweza kutawala nyanja.')),
      LegendQuote('racing', (en: 'When the gun fires, fear must disappear.', sw: 'Wakati bunduki inapolia, woga lazima utoweke.')),
    ],
    relatedCourseSlug: 'history-of-east-african-running',
  ),
  Legend(
    slug: 'kenenisa-bekele',
    name: 'Kenenisa Bekele',
    country: (en: 'Ethiopia', sw: 'Uhabeshi'),
    flag: '🇪🇹',
    discipline: (en: '10,000m / Marathon', sw: '10,000m / Marathon'),
    tagline: (en: 'The record-breaking maestro.', sw: 'Bwana wa kuvunja rekodi.'),
    bio: (en: 'Arguably the greatest 10,000m runner in history with multiple Olympic golds and world records, later a serious marathon threat in Berlin.',
        sw: 'Labda mkimbiaji mkuu wa 10,000m katika historia mwenye medali nyingi za dhahabu za Olympic na rekodi za dunia, baadaye tishio kubwa la marathon huko Berlin.'),
    timeline: [
      LegendMilestone('2004', (en: 'Olympic 10,000m gold, Athens', sw: 'Dhahabu ya Olympic ya 10,000m, Athens')),
      LegendMilestone('2008', (en: 'Olympic 10,000m gold, Beijing', sw: 'Dhahabu ya Olympic ya 10,000m, Beijing')),
      LegendMilestone('2019', (en: 'Berlin Marathon 2:01:41', sw: 'Marathon ya Berlin 2:01:41')),
    ],
    records: [(en: '10,000m WR 26:17.53', sw: 'Rekodi ya dunia ya 10,000m 26:17.53'), (en: '5000m WR 12:37.35', sw: 'Rekodi ya dunia ya 5000m 12:37.35')],
    quotes: [(en: 'I run to express myself.', sw: 'Nakimbia kujieleza.')],
    emoji: '🎼',
    accent: _kEthiopia,
    eraStartYear: 2003,
    personalBests: {
      '10,000m': '26:17.53',
      '5000m': '12:37.35',
      'Marathon': '2:01:41',
      '3000m': '7:28.94',
    },
    trainingPhilosophy:
        (en: 'Bekele honed his devastating kick on the track before conquering the roads. He combined enormous aerobic capacity from high-altitude Ethiopian camps with precise, controlled tempo work — a metronomic 10,000m world-record holder who later came within two seconds of the marathon record.',
        sw: 'Bekele alisagia teke yake ya kuharibu kwenye nyanya kabla ya kushinda barabarani. Aliunganisha uwezo mkubwa wa aerobiki kutoka kambi za Uhabeshi za kimo cha juu na kazi ya mdundo sahihi, iliyodhibitiwa — mshikaji rekodi ya dunia ya 10,000m aliyekaribia rekodi ya marathon kwa sekunde mbili.'),
    rivalries: ['haile-gebrselassie', 'paul-tergat'],
    notableRaces: [
      (en: 'Beijing 2008 — Olympic 10,000m gold in WR-equalling style.', sw: 'Beijing 2008 — Dhahabu ya Olympic ya 10,000m kwa mtindo sawa na rekodi ya dunia.'),
      (en: 'Berlin 2019 — 2:01:41, the second-fastest marathon ever at the time.', sw: 'Berlin 2019 — 2:01:41, marathon ya pili ya haraka zaidi wakati huo.'),
      (en: 'Multiple World Cross-Country and 10,000m world titles.', sw: 'Mataji mengi ya Dunia ya Msituni na ya 10,000m.'),
    ],
    funFact: (en: 'He is the only man to hold the 5000m and 10,000m world records simultaneously.', sw: 'Yeye ndiye mtu pekee kushikilia rekodi za dunia za 5000m na 10,000m kwa wakati mmoja.'),
    relatedLegends: ['haile-gebrselassie', 'eliud-kipchoge'],
    quotesExtra: [
      LegendQuote('training', (en: 'The track teaches patience; the road rewards it.', sw: 'Nyanja inafundisha subira; barabara inaitoa thawabu.')),
      LegendQuote('racing', (en: 'I let the kick decide, not the watch.', sw: 'Naruhusu teke liamue, sio saa.')),
      LegendQuote('life', (en: 'Running is how I speak to the world.', sw: 'Kukimbia ndio jinsi ninavyozungumza na ulimwengu.')),
      LegendQuote('legacy', (en: 'Records are borrowed from those who come next.', sw: 'Rekodi hukopwa kutoka kwa wale watakaokuja baadaye.')),
    ],
  ),
  Legend(
    slug: 'joshua-cheptegei',
    name: 'Joshua Cheptegei',
    country: (en: 'Uganda', sw: 'Uganda'),
    flag: '🇺🇬',
    discipline: (en: '5000m / 10,000m', sw: '5000m / 10,000m'),
    tagline: (en: 'The Ugandan record machine.', sw: 'Mashine ya rekodi ya Uganda.'),
    bio: (en: 'Olympic 5000m champion and world record holder at both 5000m and 10,000m, Cheptegei brought Ugandan distance running to the very front.',
        sw: 'Bingwa wa Olympic ya 5000m na mshikaji rekodi ya dunia katika 5000m na 10,000m, Cheptegei alileta mbio za umbali za Uganda mbele kabisa.'),
    timeline: [
      LegendMilestone('2020', (en: '10,000m world record', sw: 'Rekodi ya dunia ya 10,000m')),
      LegendMilestone('2020', (en: '5000m world record', sw: 'Rekodi ya dunia ya 5000m')),
      LegendMilestone('2021', (en: 'Olympic 5000m gold, Tokyo', sw: 'Dhahabu ya Olympic ya 5000m, Tokyo')),
    ],
    records: [(en: '5000m WR 12:35.36', sw: 'Rekodi ya dunia ya 5000m 12:35.36'), (en: '10,000m WR 26:11.00', sw: 'Rekodi ya dunia ya 10,000m 26:11.00')],
    quotes: [(en: 'Dream big, work quietly.', sw: 'Ndoto kubwa, fanya kazi kimya.')],
    emoji: '🌍',
    accent: _kUganda,
    eraStartYear: 2017,
    personalBests: {
      '10,000m': '26:11.00',
      '5000m': '12:35.36',
      '15K': '41:05',
      '10K (road)': '26:38',
    },
    trainingPhilosophy:
        (en: 'Cheptegei trained under Addy Ruiter in the Netherlands and at altitude in Uganda, blending European structure with African endurance. He is renowned for meticulous pacing and a powerful, methodical build-up — "dream big, work quietly" summarises his low-key, high-output approach.',
        sw: 'Cheptegei alifanya mazoezi chini ya Addy Ruiter nchini Uholanzi na katika kimo nchini Uganda, akichanganya muundo wa Ulaya na uvumilivu wa Kiafrika. Anajulikana kwa kudhibiti kasi kwa uangalifu na kuongeza nguvu kwa utaratibu — "ndoto kubwa, fanya kazi kimya" inafupisha mbinu yake ya utulivu na matokeo makubwa.'),
    rivalries: ['kenenisa-bekele'],
    notableRaces: [
      (en: 'Monaco 2020 — 5000m world record 12:35.36.', sw: 'Monaco 2020 — Rekodi ya dunia ya 5000m 12:35.36.'),
      (en: 'Valencia 2020 — 10,000m world record 26:11.00.', sw: 'Valencia 2020 — Rekodi ya dunia ya 10,000m 26:11.00.'),
      (en: 'Tokyo 2021 — Olympic 5000m gold.', sw: 'Tokyo 2021 — Dhahabu ya Olympic ya 5000m.'),
    ],
    funFact: (en: 'He started as a 10,000m specialist and only later chased the 5000m record.', sw: 'Alianza kama mtaalamu wa 10,000m na baadaye tu alifuata rekodi ya 5000m.'),
    relatedLegends: ['kenenisa-bekele', 'stephen-kiprotich'],
    quotesExtra: [
      LegendQuote('training', (en: 'The plan is nothing without the quiet work.', sw: 'Mpango ni uwongo bila kazi ya kimya.')),
      LegendQuote('racing', (en: 'Records fall when you respect the process.', sw: 'Rekodi huanguka unapoziheshimu mchakato.')),
      LegendQuote('legacy', (en: 'I run for all of Uganda.', sw: 'Nakimbia kwa ajili ya Uganda yote.')),
    ],
  ),
  Legend(
    slug: 'stephen-kiprotich',
    name: 'Stephen Kiprotich',
    country: (en: 'Uganda', sw: 'Uganda'),
    flag: '🇺🇬',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'Uganda\'s Olympic marathon hero.', sw: 'Shujaa wa Olympic wa marathon wa Uganda.'),
    bio: (en: 'Surprise Olympic marathon champion in 2012 and world champion in 2013, Kiprotich carried Ugandan hopes on a fearless final-kilometre surge.',
        sw: 'Mshindi wa kushangaza wa marathon ya Olympic mwaka 2012 na bingwa wa dunia mwaka 2013, Kiprotich alibeba matumaini ya Uganda kwenye msukumo wa ujasiri wa kilomita ya mwisho.'),
    timeline: [
      LegendMilestone('2012', (en: 'Olympic marathon gold, London', sw: 'Dhahabu ya Olympic ya marathon, London')),
      LegendMilestone('2013', (en: 'World marathon champion', sw: 'Bingwa wa dunia wa marathon')),
    ],
    records: [(en: 'Olympic marathon champion 2012', sw: 'Bingwa wa Olympic wa marathon 2012')],
    quotes: [(en: 'Believe, then run.', sw: 'Amini, kisha kimbia.')],
    emoji: '🥇',
    accent: _kUganda,
    eraStartYear: 2012,
    personalBests: {
      'Marathon': '2:06:33',
      'Half Marathon': '1:02:00',
      '10,000m': '27:58',
    },
    trainingPhilosophy:
        (en: 'Kiprotich trained in the Kapchorwa highlands of eastern Uganda, a region now famous for its sprinters and distance runners alike. He built his races around a devastating finishing surge, often sitting back before unleashing a final-kilometre charge.',
        sw: 'Kiprotich alifanya mazoezi katika nyanda za juu za Kapchorwa mashariki mwa Uganda, eneo ambalo sasa lina fimbo ya sprinters na wakimbiaji wa umbali. Alijenga mbio zake kuzunguka msukumo wa kumalizia wa kuharibu, mara nyingi akikaa nyuma kabla ya kutoa shtaka la kilomita ya mwisho.'),
    rivalries: ['joshua-cheptegei'],
    notableRaces: [
      (en: 'London 2012 — Olympic marathon gold in a shock upset.', sw: 'London 2012 — Dhahabu ya Olympic ya marathon katika mshtuko.'),
      (en: 'Moscow 2013 — World marathon champion.', sw: 'Moscow 2013 — Bingwa wa dunia wa marathon.'),
    ],
    funFact: (en: 'He was a pacemaker early in his career before blossoming into a champion.', sw: 'Alikuwa mpimiaji mapema katika kazi yake kabla ya kuwa bingwa.'),
    relatedLegends: ['joshua-cheptegei'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I waited, then I flew in the last kilometre.', sw: 'Nilisubiri, kisha nikaruka kilomita ya mwisho.')),
      LegendQuote('life', (en: 'Believe, then run — that is all I know.', sw: 'Amini, kisha kimbia — ndiyo yote ninayojua.')),
    ],
  ),
  Legend(
    slug: 'geoffrey-kamworor',
    name: 'Geoffrey Kamworor',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Half Marathon / Cross Country', sw: 'Nusu Marathon / Msituni'),
    tagline: (en: 'The undisputed king of the half.', sw: 'Mfalme asiye na shaka wa nusu.'),
    bio: (en: 'Multiple world half-marathon champion and a relentless trainer in the camps of Kaptagat. A bridge between the cross-country roots and modern road racing.',
        sw: 'Bingwa mara nyingi wa dunia wa nusu marathon na mkimbiaji usiochoka kambini la Kaptagat. Daraja kati ya asili ya msituni na mbio za kisasa za barabarani.'),
    timeline: [
      LegendMilestone('2014', (en: 'World half marathon champion', sw: 'Bingwa wa dunia wa nusu marathon')),
      LegendMilestone('2016', (en: 'World half marathon champion', sw: 'Bingwa wa dunia wa nusu marathon')),
      LegendMilestone('2018', (en: 'World half marathon champion', sw: 'Bingwa wa dunia wa nusu marathon')),
    ],
    records: [(en: 'Half marathon 58:01 (former world record)', sw: 'Nusu marathon 58:01 (rekodi ya zamani ya dunia)')],
    quotes: [(en: 'Consistency is the secret.', sw: 'Utimizaji ndio siri.')],
    emoji: '🔁',
    accent: _kKenya,
    eraStartYear: 2014,
    personalBests: {
      'Half Marathon': '58:01',
      '10,000m': '26:52.65',
      '15K': '41:13',
    },
    trainingPhilosophy:
        (en: 'Kamworor is a pillar of the Kaptagat camp alongside Kipchoge, famous for his unshakeable consistency. He credits group training, the Thursday fartlek, and a simple life for his longevity — "consistency is the secret" is practically his motto.',
        sw: 'Kamworor ni nguzo ya kambi la Kaptagat pamoja na Kipchoge, anayejulikana kwa utimizaji wake usiochanganyika. Anashukuru mazoezi ya kikundi, fartlek ya Alhamisi, na maisha rahisi kwa uhai wake mrefu — "utimizaji ndio siri" kwa karibu ni kauli yake.'),
    rivalries: ['joshua-cheptegei'],
    notableRaces: [
      (en: 'Three World Half-Marathon titles (2014, 2016, 2018).', sw: 'Mataji matatu ya Dunia ya Nusu Marathon (2014, 2016, 2018).'),
      (en: 'Copenhagen 2019 — Half marathon world record 58:01.', sw: 'Copenhagen 2019 — Rekodi ya dunia ya nusu marathon 58:01.'),
    ],
    funFact: (en: 'He often trains twice a day, every day, for years on end without a break.', sw: 'Mara nyingi hufanya mazoezi mara mbili kwa siku, kila siku, kwa miaka bila kupumzika.'),
    relatedLegends: ['eliud-kipchoge', 'joshua-cheptegei'],
    quotesExtra: [
      LegendQuote('training', (en: 'Show up every day and the results take care of themselves.', sw: 'Tokea kila siku na matokeo hutunza yenyewe.')),
      LegendQuote('racing', (en: 'The half is won in the camp, not on the start line.', sw: 'Nusu hushindwa kambini, sio kwenye mstari wa mwanzo.')),
      LegendQuote('legacy', (en: 'I want to be the bridge to the next generation.', sw: 'Nataka kuwa daraja kwa kizazi kijacho.')),
    ],
    relatedCourseSlug: 'the-thursday-fartlek',
  ),
  Legend(
    slug: 'faith-kipyegon',
    name: 'Faith Kipyegon',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '1500m', sw: '1500m'),
    tagline: (en: 'The queen of the mile.', sw: 'Malkia wa maili.'),
    bio: (en: 'Double Olympic 1500m champion and multiple world record holder, Kipyegon combines blistering speed with tactical brilliance. She pushed the 1500m to 3:48.68 in 2025.',
        sw: 'Mshindi mara mbili wa Olympic ya 1500m na mshikaji rekodi nyingi za dunia, Kipyegon anachanganya kasi ya kuwasha na ustadi wa kiissa. Alisukuma 1500m hadi 3:48.68 mwaka 2025.'),
    timeline: [
      LegendMilestone('2016', (en: 'Olympic 1500m gold, Rio', sw: 'Dhahabu ya Olympic ya 1500m, Rio')),
      LegendMilestone('2021', (en: 'Olympic 1500m gold, Tokyo', sw: 'Dhahabu ya Olympic ya 1500m, Tokyo')),
      LegendMilestone('2023', (en: '1500m world record 3:49.11', sw: 'Rekodi ya dunia ya 1500m 3:49.11')),
      LegendMilestone('2025', (en: '1500m 3:48.68, Eugene', sw: '1500m 3:48.68, Eugene')),
    ],
    records: [(en: '1500m WR 3:48.68 (Eugene 2025)', sw: 'Rekodi ya dunia ya 1500m 3:48.68 (Eugene 2025)'), (en: '5000m 14:05.20 (2023)', sw: '5000m 14:05.20 (2023)')],
    quotes: [(en: 'Hard work dream big.', sw: 'Kazi ngumu ndoto kubwa.')],
    emoji: '👑',
    accent: _kKenya,
    beatLegendId: 'kipyegon-1500',
    eraStartYear: 2016,
    personalBests: {
      '1500m': '3:48.68',
      'Mile': '4:07.64',
      '5000m': '14:05.20',
    },
    trainingPhilosophy:
        (en: 'Kipyegon trains in the high Rift Valley and credits motherhood for a new mental edge. Her sessions blend raw speed (200m/400m repeats) with mileage, and she races with tactical patience before a blistering final-lap kick — the fastest closer in women\'s history.',
        sw: 'Kipyegon anafanya mazoezi katika Bonde la Rift la juu na ashukuru umama kwa uwezo mpya wa akili. Vipindi vyake vinachanganya kasi ya mbichi (marudio ya 200m/400m) na umbali, na anashindana kwa subira ya kiissa kabla ya teke la kuwasha la duara ya mwisho — mfungaji wa haraka zaidi katika historia ya wanawake.'),
    rivalries: ['beatrice-chebet'],
    notableRaces: [
      (en: 'Eugene 2025 — 1500m world record 3:48.68.', sw: 'Eugene 2025 — Rekodi ya dunia ya 1500m 3:48.68.'),
      (en: 'Paris 2023 — Double world record attempt, 1500m 3:49.11.', sw: 'Paris 2023 — Jaribio la rekodi mbili za dunia, 1500m 3:49.11.'),
      (en: 'Tokyo 2021 — Second Olympic 1500m gold.', sw: 'Tokyo 2021 — Dhahabu ya pili ya Olympic ya 1500m.'),
    ],
    funFact: (en: 'She returned to world dominance after having her daughter, saying it made her "fearless."', sw: 'Alirudi kutawala dunia baada ya kupata binti yake, akisema ilimfanya "asowe na woga."'),
    relatedLegends: ['beatrice-chebet', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('training', (en: 'Speed is born in the repetitions, not the race.', sw: 'Kasi inazaliwa katika marudio, sio mbio.')),
      LegendQuote('racing', (en: 'I let them lead, then I unleash the last lap.', sw: 'Naruhusu waongoze, kisha natoa duara ya mwisho.')),
      LegendQuote('life', (en: 'Being a mother gave me a new kind of fire.', sw: 'Kuwa mama kunipa aina mpya ya moto.')),
      LegendQuote('legacy', (en: 'I want girls to see the 1500m and dream.', sw: 'Nataka wasichana waione 1500m na kuota.')),
    ],
  ),
  Legend(
    slug: 'beatrice-chebet',
    name: 'Beatrice Chebet',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '5000m', sw: '5000m'),
    tagline: (en: 'The new face of the long track.', sw: 'Uso mpya wa nyanya ndefu.'),
    bio: (en: 'Olympic 5000m champion who lowered the world record to 13:58.06 in 2025, Chebet represents the next wave of Kenyan women on the track.',
        sw: 'Bingwa wa Olympic ya 5000m ambaye alipunguza rekodi ya dunia hadi 13:58.06 mwaka 2025, Chebet anawakilisha wimbi lijalo la wanawake wa Kenya kwenye nyanya.'),
    timeline: [
      LegendMilestone('2024', (en: 'Olympic 5000m gold', sw: 'Dhahabu ya Olympic ya 5000m')),
      LegendMilestone('2025', (en: '5000m world record 13:58.06', sw: 'Rekodi ya dunia ya 5000m 13:58.06')),
    ],
    records: [(en: '5000m WR 13:58.06 (Eugene 2025)', sw: 'Rekodi ya dunia ya 5000m 13:58.06 (Eugene 2025)')],
    quotes: [(en: 'Run your own race.', sw: 'Kimbia mbio yako mwenyewe.')],
    emoji: '🌸',
    accent: _kKenya,
    beatLegendId: 'chebet-5000',
    eraStartYear: 2024,
    personalBests: {
      '5000m': '13:58.06',
      '10,000m': '30:10',
    },
    trainingPhilosophy:
        (en: 'Chebet combines cross-country toughness with track precision, often training in large women\'s groups. She races with a calm, even stride and a punishing final kick, embodying the next generation of Kenyan women who now challenge the Ethiopians on the track.',
        sw: 'Chebet anachanganya uthabiti wa msituni na usahihi wa nyanya, mara nyingi akifanya mazoezi katika vikundi vikubwa vya wanawake. Anashindana kwa hatua ya utulivu na teke la mwisho la kuadhibu, akiwakilisha kizazi kijacho cha wanawake wa Kenya wanaochanganya Wauhabeshi kwenye nyanya.'),
    rivalries: ['faith-kipyegon'],
    notableRaces: [
      (en: 'Eugene 2025 — 5000m world record 13:58.06.', sw: 'Eugene 2025 — Rekodi ya dunia ya 5000m 13:58.06.'),
      (en: 'Paris 2024 — Olympic 5000m gold.', sw: 'Paris 2024 — Dhahabu ya Olympic ya 5000m.'),
    ],
    funFact: (en: 'She comes from a family of runners and was a junior world cross-country champion.', sw: 'Anatoka katika familia ya wakimbiaji na alikuwa bingwa mdogo wa dunia wa msituni.'),
    relatedLegends: ['faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I don\'t watch the others; I run my own race.', sw: 'Sioni wengine; nakimbia mbio yangu mwenyewe.')),
      LegendQuote('training', (en: 'The group pulls you when your legs say no.', sw: 'Kikundi hukuvuta unaposema sitaki kwa miguu.')),
      LegendQuote('legacy', (en: 'I am just getting started.', sw: 'Nimeanza tu.')),
    ],
  ),
  Legend(
    slug: 'brigid-kosgei',
    name: 'Brigid Kosgei',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'The woman who broke 2:15.', sw: 'Mwanamke aliyeivunja 2:15.'),
    bio: (en: 'Former marathon world record holder (2:14:04, Chicago 2019), Kosgei combined power and poise to dominate the women\'s marathon for years.',
        sw: 'Mshikaji zamani wa rekodi ya dunia ya marathon (2:14:04, Chicago 2019), Kosgei aliunganisha nguvu na utulivu kuongoza marathon ya wanawake kwa miaka.'),
    timeline: [
      LegendMilestone('2019', (en: 'London Marathon win', sw: 'Ushindi wa Marathon ya London')),
      LegendMilestone('2019', (en: 'Marathon WR 2:14:04, Chicago', sw: 'Rekodi ya dunia ya Marathon 2:14:04, Chicago')),
    ],
    records: [(en: 'Marathon WR 2:14:04 (Chicago 2019)', sw: 'Rekodi ya dunia ya Marathon 2:14:04 (Chicago 2019)')],
    quotes: [(en: 'Stay patient, then strike.', sw: 'Weka subira, kisha piga.')],
    emoji: '💪',
    accent: _kKenya,
    eraStartYear: 2017,
    personalBests: {
      'Marathon': '2:14:04',
      'Half Marathon': '1:05:28',
    },
    trainingPhilosophy:
        (en: 'Kosgei trained under Gianni Mauri, combining long Kenyan runs with structured European-style speed work. She raced with patience, sitting in the pack before a decisive surge — the blueprint for the modern women\'s marathon breakthrough.',
        sw: 'Kosgei alifanya mazoezi chini ya Gianni Mauri, akichanganya kukimbia kwa muda mrefu kwa Kikenya na kazi ya kasi ya mtindo wa Ulaya. Alishindana kwa subira, akikaa kwenye kundi kabla ya msukumo wa uhakika — ramani ya mafanikio ya kisasa ya marathon ya wanawake.'),
    rivalries: ['ruth-chepngetich', 'tigist-assefa'],
    notableRaces: [
      (en: 'Chicago 2019 — Marathon world record 2:14:04.', sw: 'Chicago 2019 — Rekodi ya dunia ya marathon 2:14:04.'),
      (en: 'London 2019 & 2020 — back-to-back wins.', sw: 'London 2019 na 2020 — ushindi mfululizo.'),
    ],
    funFact: (en: 'She is a mother of two who balanced training with family life in the camps.', sw: 'Ni mama wa watoto wawili aliyeweza mazoezi na maisha ya familia kambini.'),
    relatedLegends: ['ruth-chepngetich', 'tigist-assefa', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('racing', (en: 'Patience in the first half buys the second.', sw: 'Subira katika sehemu ya kwanza hununua ya pili.')),
      LegendQuote('training', (en: 'Trust the plan, and the plan repays you.', sw: 'Amini mpango, na mpango unalipa.')),
      LegendQuote('legacy', (en: 'I ran so my daughters would believe.', sw: 'Nilikimbia ili binti zangu waamini.')),
    ],
  ),
  Legend(
    slug: 'ruth-chepngetich',
    name: 'Ruth Chepngetich',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'The fearless front-runner.', sw: 'Mpiga mbele asiye na woga.'),
    bio: (en: 'In 2024 she became the first woman under 2:10 with a stunning 2:09:56 in Chicago, redefining what was possible in the women\'s marathon.',
        sw: 'Mwaka 2024 akawa mwanamke wa kwanza chini ya 2:10 kwa 2:09:56 ya kushangaza huko Chicago, akifafanua kile kinachowezekana katika marathon ya wanawake.'),
    timeline: [
      LegendMilestone('2019', (en: 'World marathon champion', sw: 'Bingwa wa dunia wa marathon')),
      LegendMilestone('2024', (en: 'Marathon 2:09:56, Chicago', sw: 'Marathon 2:09:56, Chicago')),
    ],
    records: [(en: 'Marathon 2:09:56 (Chicago 2024)', sw: 'Marathon 2:09:56 (Chicago 2024)')],
    quotes: [(en: 'Go for it. No fear.', sw: 'Endelea. Bila woga.')],
    emoji: '🔥',
    accent: _kKenya,
    eraStartYear: 2019,
    personalBests: {
      'Marathon': '2:09:56',
      'Half Marathon': '1:05:39',
    },
    trainingPhilosophy:
        (en: 'Chepngetich is famous for audacious, fast-starting races — she often goes to the front early and dares others to follow. Her high-risk style, backed by big-mileage training, produced the first sub-2:10 women\'s marathon in history.',
        sw: 'Chepngetich anajulikana kwa mbio za ujasiri za kuanza kwa kasi — mara nyingi huenda mbele mapema na kuwathubutu wengine kufuata. Mtindo wake wa hatari kubwa, unaoungwa mkono na mazoezi ya umbali mrefu, ulitoa marathon ya kwanza ya wanawake chini ya 2:10 katika historia.'),
    rivalries: ['brigid-kosgei', 'tigist-assefa'],
    notableRaces: [
      (en: 'Chicago 2024 — First women\'s marathon under 2:10 (2:09:56).', sw: 'Chicago 2024 — Marathon ya kwanza ya wanawake chini ya 2:10 (2:09:56).'),
      (en: 'World Championship marathon title (2019).', sw: 'Taji la ubingwa wa marathon ya dunia (2019).'),
    ],
    funFact: (en: 'She dedicated her Chicago record to the late Kelvin Kiptum.', sw: 'Aliweka rekodi yake ya Chicago kwa marehemu Kelvin Kiptum.'),
    relatedLegends: ['brigid-kosgei', 'tigist-assefa', 'kelvin-kiptum'],
    quotesExtra: [
      LegendQuote('racing', (en: 'If you wait, you lose. So I go.', sw: 'Ukipsubu, unapoteza. Kwa hiyo naenda.')),
      LegendQuote('training', (en: 'Big weeks make brave races.', sw: 'Wiki kubwa hufanya mbio za ujasiri.')),
      LegendQuote('legacy', (en: 'I moved the line for every woman behind me.', sw: 'Nilisogeza mstari kwa kila mwanamke nyuma yangu.')),
    ],
  ),
  Legend(
    slug: 'tigist-assefa',
    name: 'Tigist Assefa',
    country: (en: 'Ethiopia', sw: 'Uhabeshi'),
    flag: '🇪🇹',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'The Berlin blur.', sw: 'Ushtuko wa Berlin.'),
    bio: (en: 'Assefa shattered the women\'s marathon record with 2:11:53 in Berlin 2023, an audacious solo run that reset the bar for the event.',
        sw: 'Assefa alivunja rekodi ya marathon ya wanawake kwa 2:11:53 huko Berlin 2023, mbio ya pekee ya ujasiri iliyoweka kiwango kipya kwa tukio.'),
    timeline: [
      LegendMilestone('2022', (en: 'Berlin Marathon win', sw: 'Ushindi wa Marathon ya Berlin')),
      LegendMilestone('2023', (en: 'Marathon WR 2:11:53, Berlin', sw: 'Rekodi ya dunia ya Marathon 2:11:53, Berlin')),
    ],
    records: [(en: 'Marathon WR 2:11:53 (Berlin 2023)', sw: 'Rekodi ya dunia ya Marathon 2:11:53 (Berlin 2023)')],
    quotes: [(en: 'Push past the pain.', sw: 'Sukuma zaidi ya maumivu.')],
    emoji: '🌬️',
    accent: _kEthiopia,
    eraStartYear: 2015,
    personalBests: {
      'Marathon': '2:11:53',
      'Half Marathon': '1:06:28',
      '800m': '1:59.24',
    },
    trainingPhilosophy:
        (en: 'Assefa began as an 800m runner before reinventing herself as a marathoner. Coached by Gemedu Dedefo, she built unprecedented aerobic power and ran Berlin 2023 almost entirely alone off the front — a solo negative split that rewrote the women\'s record by more than two minutes.',
        sw: 'Assefa alianza kama mkimbiaji wa 800m kabla ya kujiboresha kuwa mwanamaria. Akiwa na mchezeshaji Gemedu Dedefo, alijenga nguvu isiyokuwa ya aerobiki na akakimbia Berlin 2023 karibu peke yake mbele — mgawanyo wa pekee hasi ulioandika rekodi ya wanawake kwa zaidi ya dakika mbili.'),
    rivalries: ['brigid-kosgei', 'ruth-chepngetich'],
    notableRaces: [
      (en: 'Berlin 2023 — Marathon world record 2:11:53.', sw: 'Berlin 2023 — Rekodi ya dunia ya marathon 2:11:53.'),
      (en: 'Berlin 2022 — Breakthrough win in 2:15:37.', sw: 'Berlin 2022 — Ushindi wa mafanikio katika 2:15:37.'),
    ],
    funFact: (en: 'She was a 1:59 800m runner before switching to the marathon.', sw: 'Alikuwa mkimbiaji wa 800m ya 1:59 kabla ya kubadilika kuelekea marathon.'),
    relatedLegends: ['brigid-kosgei', 'ruth-chepngetich', 'haile-gebrselassie'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I ran my own race, alone, and the record came.', sw: 'Nilikimbia mbio yangu mwenyewe, peke yangu, na rekodi ikaibuka.')),
      LegendQuote('training', (en: 'The track speed never left me; it just grew wings.', sw: 'Kasi ya nyanya haikuniacha kamwe; ilikua mabawa.')),
      LegendQuote('legacy', (en: 'From 800m to the world record — anything is possible.', sw: 'Kutoka 800m hadi rekodi ya dunia — chochote ni rahisi.')),
    ],
  ),
  Legend(
    slug: 'tegla-loroupe',
    name: 'Tegla Loroupe',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'Trailblazer and peacebuilder.', sw: 'Mpiga njia na mjenzi wa amani.'),
    bio: (en: 'The first African woman to hold a major marathon world record (2:20:43, Berlin 1999) and a tireless advocate for peace through sport across the region.',
        sw: 'Mwanamke wa kwanza wa Kiafrika kushikilia rekodi kuu ya marathon ya dunia (2:20:43, Berlin 1999) na mtetezi usiochoka wa amani kupitia michezo katika eneo lolote.'),
    timeline: [
      LegendMilestone('1994', (en: 'New York City Marathon win', sw: 'Ushindi wa Marathon ya New York City')),
      LegendMilestone('1999', (en: 'Marathon WR 2:20:43, Berlin', sw: 'Rekodi ya dunia ya Marathon 2:20:43, Berlin')),
      LegendMilestone('2003', (en: 'Founded Peace Marathon', sw: 'Alianzisha Marathon ya Amani')),
    ],
    records: [(en: 'Marathon WR 2:20:43 (Berlin 1999)', sw: 'Rekodi ya dunia ya Marathon 2:20:43 (Berlin 1999)')],
    quotes: [(en: 'Sport can build peace.', sw: 'Michezo inaweza kujenga amani.')],
    emoji: '🕊️',
    accent: _kKenya,
    eraStartYear: 1994,
    personalBests: {
      'Marathon': '2:20:43',
      'Half Marathon': '1:06:44',
      '10,000m': '31:27',
    },
    trainingPhilosophy:
        (en: 'Loroupe was a pioneering force who proved African women belonged on the global stage. She trained with quiet determination and later turned her platform toward peace, using sport to reconcile communities across conflict lines in East Africa.',
        sw: 'Loroupe alikuwa nguvu ya upainia aliyeonyesha wanawake Waafrika walikuwa kwenye jukwaa la kimataifa. Alifanya mazoezi kwa azimio la kimya na baadaye akageuza jukwaa lake kuelekea amani, akitumia michezo kuwiana jamii kuvuka mstari wa migogoro Afrika Mashariki.'),
    rivalries: [],
    notableRaces: [
      (en: 'Berlin 1999 — First African woman to hold the marathon world record.', sw: 'Berlin 1999 — Mwanamke wa kwanza wa Kiafrika kushikilia rekodi ya dunia ya marathon.'),
      (en: 'Three-time New York City Marathon champion.', sw: 'Bingwa mara tatu wa Marathon ya New York City.'),
    ],
    funFact: (en: 'She grew up in a family of 24 children and ran barefoot to school.', sw: 'Alikulia katika familia ya watoto 24 na kukimbia bila viatu kwenda shule.'),
    relatedLegends: ['mary-keitany', 'catherine-ndereba', 'brigid-kosgei'],
    quotesExtra: [
      LegendQuote('life', (en: 'Peace is the greatest victory of all.', sw: 'Amani ndiyo ushindi mkuu kabisa.')),
      LegendQuote('legacy', (en: 'I ran so African women would be seen.', sw: 'Nilikimbia ili wanawake Waafrika waonekane.')),
      LegendQuote('training', (en: 'Strength comes from believing you belong.', sw: 'Nguvu inatoka kwa kuamini unamiliki.')),
    ],
  ),
  Legend(
    slug: 'mary-keitany',
    name: 'Mary Keitany',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Half / Marathon', sw: 'Nusu / Marathon'),
    tagline: (en: 'The women-only world record holder.', sw: 'Mshikaji rekodi ya wanawake pekee.'),
    bio: (en: 'A dominant marathoner who set the women-only world record of 2:17:01 in London 2017 and won New York City four times.',
        sw: 'Mwanamaria mkuu aliyeweka rekodi ya dunia ya wanawake pekee ya 2:17:01 huko London 2017 na kushinda New York City mara nne.'),
    timeline: [
      LegendMilestone('2012', (en: 'London Marathon win', sw: 'Ushindi wa Marathon ya London')),
      LegendMilestone('2017', (en: 'Women-only WR 2:17:01, London', sw: 'Rekodi ya wanawake pekee 2:17:01, London')),
    ],
    records: [(en: 'Women-only marathon WR 2:17:01 (London 2017)', sw: 'Rekodi ya marathon ya wanawake pekee 2:17:01 (London 2017)')],
    quotes: [(en: 'Work hard in silence.', sw: 'Fanya kazi ngumu kimya.')],
    emoji: '🏅',
    accent: _kKenya,
    eraStartYear: 2010,
    personalBests: {
      'Marathon': '2:17:01',
      'Half Marathon': '1:05:50',
      '10K (road)': '30:38',
    },
    trainingPhilosophy:
        (en: 'Keitany was a ferocious competitor who often went for records alone off the front. She combined massive aerobic volume with fearless pacing, holding the women-only marathon world record for years and racking up four New York City titles.',
        sw: 'Keitany alikuwa mpinzani mkali ambaye mara nyingi alienda kwa rekodi peke yake mbele. Aliunganisha kiasi kikubwa cha aerobiki na kudhibiti kasi bila woga, akishikilia rekodi ya dunia ya marathon ya wanawake pekee kwa miaka na kupata mataji manne ya New York City.'),
    rivalries: ['tegla-loroupe', 'brigid-kosgei'],
    notableRaces: [
      (en: 'London 2017 — Women-only marathon world record 2:17:01.', sw: 'London 2017 — Rekodi ya dunia ya marathon ya wanawake pekee 2:17:01.'),
      (en: 'Four-time New York City Marathon champion.', sw: 'Bingwa mara nne wa Marathon ya New York City.'),
    ],
    funFact: (en: 'She ran the fastest marathon ever by a woman at the time — 2:17:01 — without male pacemakers.', sw: 'Alikimbia marathon ya haraka zaidi wakati huo na mwanamke — 2:17:01 — bila wapimiaji wa kiume.'),
    relatedLegends: ['brigid-kosgei', 'tegla-loroupe', 'faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I do not need a rabbit; I am my own engine.', sw: 'Sihitaji sukimawiki; mimi ndiye injini yangu.')),
      LegendQuote('training', (en: 'Silence and work — that is the formula.', sw: 'Kimya na kazi — ndiyo fomula.')),
    ],
  ),
  Legend(
    slug: 'peres-jepchirchir',
    name: 'Peres Jepchirchir',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Half / Marathon', sw: 'Nusu / Marathon'),
    tagline: (en: 'The Olympic marathon champion.', sw: 'Bingwa wa Olympic wa marathon.'),
    bio: (en: 'Olympic marathon gold medallist who also holds the women-only half marathon world record, a model of consistency on the biggest stages.',
        sw: 'Mshindi wa medali ya dhahabu ya Olympic ya marathon ambaye pia anashikilia rekodi ya dunia ya nusu marathon ya wanawake pekee, kielelezo cha utimizaji kwenye majukwaa makubwa.'),
    timeline: [
      LegendMilestone('2021', (en: 'Olympic marathon gold, Tokyo', sw: 'Dhahabu ya Olympic ya marathon, Tokyo')),
      LegendMilestone('2021', (en: 'Half marathon WR 1:05:16', sw: 'Rekodi ya dunia ya nusu marathon 1:05:16')),
    ],
    records: [(en: 'Half marathon WR 1:05:16', sw: 'Rekodi ya dunia ya nusu marathon 1:05:16'), (en: 'Olympic marathon champion 2021', sw: 'Bingwa wa Olympic wa marathon 2021')],
    quotes: [(en: 'Trust the process.', sw: 'Amini mchakato.')],
    emoji: '🌟',
    accent: _kKenya,
    eraStartYear: 2016,
    personalBests: {
      'Marathon': '2:17:43',
      'Half Marathon': '1:05:16',
      '10K (road)': '30:55',
    },
    trainingPhilosophy:
        (en: 'Jepchirchir built her career on the half marathon before conquering the full distance. She is a model of composure under pressure, winning Olympic gold and world-half titles with metronomic consistency and a calm, patient racing style.',
        sw: 'Jepchirchir alijenga kazi yake kwenye nusu marathon kabla ya kushinda umbali kamili. Yeye ni kielelezo cha utulivu chini ya shinikizo, akishinda dhahabu ya Olympic na mataji ya nusu dunia kwa utimizaji wa mdundo na mtindo wa mbio wa utulivu.'),
    rivalries: ['brigid-kosgei', 'ruth-chepngetich'],
    notableRaces: [
      (en: 'Tokyo 2021 — Olympic marathon gold.', sw: 'Tokyo 2021 — Dhahabu ya Olympic ya marathon.'),
      (en: 'Mixed half marathon — women-only world record 1:05:16.', sw: 'Nusu marathon mchanganyiko — rekodi ya dunia ya wanawake pekee 1:05:16.'),
    ],
    funFact: (en: 'She won the Olympic marathon on her birthday month, calling it a gift.', sw: 'Alishinda marathon ya Olympic katika mwezi wa siku yake ya kuzaliwa, akiita ni zawadi.'),
    relatedLegends: ['brigid-kosgei', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('racing', (en: 'Trust the process; the medal comes at the end.', sw: 'Amini mchakato; medali huja mwishoni.')),
      LegendQuote('training', (en: 'Patience in training is patience in racing.', sw: 'Subira katika mazoezi ni subira katika mbio.')),
      LegendQuote('legacy', (en: 'I want to be the steady one they remember.', sw: 'Nataka kuwa anayefahamika wa utulivu.')),
    ],
  ),
  Legend(
    slug: 'hellen-obiri',
    name: 'Hellen Obiri',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '5000m / Marathon', sw: '5000m / Marathon'),
    tagline: (en: 'From track queen to marathon winner.', sw: 'Kutoka malkia wa nyanya hadi mshindi wa marathon.'),
    bio: (en: 'A multiple world champion on the track who smoothly transitioned to marathons, winning Boston and New York City with tactical sharpness.',
        sw: 'Mshindi mara nyingi wa dunia kwenye nyanya ambaye alihamia vizuri kwenye marathon, akishinda Boston na New York City kwa ustadi wa kiissa.'),
    timeline: [
      LegendMilestone('2017', (en: 'World 5000m champion', sw: 'Bingwa wa dunia wa 5000m')),
      LegendMilestone('2022', (en: 'Boston Marathon win', sw: 'Ushindi wa Marathon ya Boston')),
      LegendMilestone('2023', (en: 'New York City Marathon win', sw: 'Ushindi wa Marathon ya New York City')),
    ],
    records: [(en: 'Two-time world 5000m champion', sw: 'Bingwa mara mbili wa dunia wa 5000m')],
    quotes: [(en: 'Be patient, be brave.', sw: 'Uwe mvumilivu, uwe shujaa.')],
    emoji: '🏃‍♀️',
    accent: _kKenya,
    eraStartYear: 2012,
    personalBests: {
      '5000m': '14:18.37',
      '10,000m': '30:14.11',
      'Marathon': '2:21:38',
    },
    trainingPhilosophy:
        (en: 'Obiri was a tactical genius on the track, famous for a perfectly-timed final-lap kick. She carried that sharpness to the roads, winning Boston and New York with smart, brave racing rather than pure front-running.',
        sw: 'Obiri alikuwa bingwa wa kiissa kwenye nyanya, anayejulikana kwa teke la wakati sahihi la duara ya mwisho. Alibeba ukali huo barabarani, akishinda Boston na New York kwa mbio za busara na ujasiri badala ya kupiga mbele tu.'),
    rivalries: ['faith-kipyegon', 'beatrice-chebet'],
    notableRaces: [
      (en: 'Boston 2022 — Marathon debut win.', sw: 'Boston 2022 — Ushindi wa kwanza wa marathon.'),
      (en: 'New York City 2023 — Second major title.', sw: 'New York City 2023 — Taji la pili kuu.'),
      (en: 'Multiple world 5000m titles.', sw: 'Mataji mengi ya dunia ya 5000m.'),
    ],
    funFact: (en: 'She is one of the few athletes to win global titles on both track and major marathons.', sw: 'Yeye ni mmoja wa wanariadha wachache kushinda mataji ya kimataifa kwenye nyanya na marathon kuu.'),
    relatedLegends: ['faith-kipyegon', 'beatrice-chebet'],
    quotesExtra: [
      LegendQuote('racing', (en: 'Be patient, then be brave in the last kilometre.', sw: 'Uwe mvumilivu, kisha uwe shujaa katika kilomita ya mwisho.')),
      LegendQuote('training', (en: 'The track kick never leaves you.', sw: 'Teke la nyanya halikuachi kamwe.')),
      LegendQuote('legacy', (en: 'I proved the track and the road are one sport.', sw: 'Nilithibitisha nyanya na barabara ni mchezo mmoja.')),
    ],
  ),
  Legend(
    slug: 'lornah-kiplagat',
    name: 'Lornah Kiplagat',
    country: (en: 'Kenya / Netherlands', sw: 'Kenya / Uholanzi'),
    flag: '🇰🇪',
    discipline: (en: 'Long Distance', sw: 'Umbali Mrefu'),
    tagline: (en: 'Champion and academy founder.', sw: 'Bingwa na mwanzilishi wa chuo.'),
    bio: (en: 'World cross-country champion and multiple world record holder who founded a high-altitude training centre for women in Kenya, giving back to the next generation.',
        sw: 'Bingwa wa dunia wa msituni na mshikaji rekodi nyingi za dunia ambaye alianzisha kituo cha mazoezi ya kimo cha juu kwa wanawake nchini Kenya, kurudisha kizazi kijacho.'),
    timeline: [
      LegendMilestone('2007', (en: 'World cross-country champion', sw: 'Bingwa wa dunia wa msituni')),
      LegendMilestone('2008', (en: 'Founded women\'s training centre', sw: 'Alianzisha kituo cha mazoezi ya wanawake')),
    ],
    records: [(en: 'Half marathon WR 1:06:25 (former)', sw: 'Rekodi ya dunia ya nusu marathon 1:06:25 (ya zamani)')],
    quotes: [(en: 'Lift as you climb.', sw: 'Inua unapopanda.')],
    emoji: '🌷',
    accent: _kKenya,
    eraStartYear: 2000,
    personalBests: {
      'Half Marathon': '1:06:25',
      'Marathon': '2:23:43',
      '10K (road)': '31:00',
    },
    trainingPhilosophy:
        (en: 'Kiplagat balanced elite racing with a mission to uplift others, founding the High Altitude Training Centre in Iten. She believed in structured, science-backed training combined with community — "lift as you climb" defined both her racing and her academy.',
        sw: 'Kiplagat aliweka sawa mbio za hali ya juu na dhamira ya kuinua wengine, akianzisha Kituo cha Mazoezi ya Kimo cha Juu huko Iten. Aliamini mazoezi yaliyopangwa, yenye msingi wa sayansi pamoja na jamii — "inua unapopanda" ilifafanua mbio zake na chuo chake.'),
    rivalries: ['tegla-loroupe'],
    notableRaces: [
      (en: '2007 World Cross-Country champion.', sw: '2007 Bingwa wa Dunia wa Msituni.'),
      (en: 'Former half marathon world record holder (1:06:25).', sw: 'Mshikaji zamani wa rekodi ya dunia ya nusu marathon (1:06:25).'),
    ],
    funFact: (en: 'She represented both Kenya and the Netherlands during her career.', sw: 'Aliwakilisha Kenya na Uholanzi wote wawili katika kazi yake.'),
    relatedLegends: ['tegla-loroupe', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('life', (en: 'Lift as you climb — no one rises alone.', sw: 'Inua unapopanda — hakuna anayepanda peke yake.')),
      LegendQuote('legacy', (en: 'The academy is my greatest medal.', sw: 'Chuo ndicho medali yangu kubwa zaidi.')),
      LegendQuote('training', (en: 'Science and sisterhood build champions.', sw: 'Sayansi na udugu hujenga mabingwa.')),
    ],
    relatedCourseSlug: 'training-camps',
  ),

  // ---- New legends (Step 2) ----

  Legend(
    slug: 'david-rudisha',
    name: 'David Rudisha',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '800m', sw: '800m'),
    tagline: (en: 'The man who owned two minutes.', sw: 'Mtu aliye miliki dakika mbili.'),
    bio: (en: 'The greatest 800m runner in history, Rudisha set the world record of 1:40.91 at the London 2012 Olympics — a front-running masterpiece many call the single greatest race ever run.',
        sw: 'Mkimbiaji mkuu wa 800m katika historia, Rudisha aliweka rekodi ya dunia ya 1:40.91 kwenye Olimpiki ya London 2012 — kazi ya kipanga mbele ambayo wengi waita mbio imoja kuu kabisa kuendeshwa.'),
    timeline: [
      LegendMilestone('2010', (en: '800m world record 1:41.09', sw: 'Rekodi ya dunia ya 800m 1:41.09')),
      LegendMilestone('2012', (en: 'Olympic 800m gold, London — WR 1:40.91', sw: 'Dhahabu ya Olympic ya 800m, London — WR 1:40.91')),
      LegendMilestone('2016', (en: 'Olympic 800m gold, Rio', sw: 'Dhahabu ya Olympic ya 800m, Rio')),
    ],
    records: [(en: '800m WR 1:40.91 (London 2012)', sw: 'Rekodi ya dunia ya 800m 1:40.91 (London 2012)'), (en: 'Only man under 1:41', sw: 'Mtu pekee chini ya 1:41')],
    quotes: [(en: 'I just ran my own race and enjoyed it.', sw: 'Nilikimbia mbio yangu mwenyewe na kufurahi.')],
    emoji: '🥁',
    accent: _kKenya,
    beatLegendId: 'rudisha-800',
    eraStartYear: 2006,
    personalBests: {
      '800m': '1:40.91',
      '600m': '1:13.10',
      '400m': '45.50',
    },
    trainingPhilosophy:
        (en: 'Rudisha trained under Brother Colm O\'Connell in Iten, building enormous aerobic strength before adding speed. He raced from the front with a fearless, even pace — a tactic that produced the most dominant 800m performance in history at London 2012, where he led from gun to tape.',
        sw: 'Rudisha alifanya mazoezi chini ya Brother Colm O\'Connell huko Iten, akijenga nguvu kubwa ya aerobiki kabla ya kuongeza kasi. Alishindana kutoka mbele kwa kasi ya usawa asiye na woga — mbinu iliyozaa utendaji wa kuongoza zaidi wa 800m katika historia huko London 2012, aliposonga kutoka bunduki hadi kamba.'),
    rivalries: [],
    notableRaces: [
      (en: 'London 2012 — Olympic 800m gold in a world record 1:40.91.', sw: 'London 2012 — Dhahabu ya Olympic ya 800m katika rekodi ya dunia 1:40.91.'),
      (en: 'Rio 2016 — Back-to-back Olympic gold.', sw: 'Rio 2016 — Dhahabu ya Olympic mfululizo.'),
      (en: '2010 — First broke 1:41 with 1:41.09.', sw: '2010 — Kwanza kuvunja 1:41 kwa 1:41.09.'),
    ],
    funFact: (en: 'His father won a silver medal for Kenya at the 1968 Mexico City Olympics.', sw: 'Babake alishinda medali ya fedha kwa Kenya kwenye Olimpiki ya Mexico City ya 1968.'),
    relatedLegends: ['kipchoge-keino', 'faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', (en: 'When I lead, I run free — no one tells me the pace.', sw: 'Ninapoongoza, nakimbia huru — hakuna anayeniambia kasi.')),
      LegendQuote('training', (en: 'The 800m is a sprint that needs a marathoner\'s lungs.', sw: '800m ni mbio ya kukimbia inayohitaji mapafu ya mwanamaria.')),
      LegendQuote('life', (en: 'I ran for joy before I ran for gold.', sw: 'Nilikimbia kwa furaha kabla ya kukimbia kwa dhahabu.')),
      LegendQuote('legacy', (en: 'That London race was for my country.', sw: 'Mbio hiyo ya London ilikuwa ya nchi yangu.')),
    ],
    relatedCourseSlug: 'altitude-training',
  ),
  Legend(
    slug: 'tirunesh-dibaba',
    name: 'Tirunesh Dibaba',
    country: (en: 'Ethiopia', sw: 'Uhabeshi'),
    flag: '🇪🇹',
    discipline: (en: '5000m / 10,000m', sw: '5000m / 10,000m'),
    tagline: (en: 'The Baby-Faced Destroyer.', sw: 'Mwangamizi wa uso wa mtoto.'),
    bio: (en: 'A three-time Olympic gold medallist and multiple world champion on the track, Dibaba dominated the long distances with a deadly kick and relentless strength.',
        sw: 'Mshindi wa medali ya dhahabu ya Olympic mara tatu na bingwa mara nyingi wa dunia kwenye nyanya, Dibaba alitawala umbali mrefu kwa teke ya kuua na nguvu isiyochoka.'),
    timeline: [
      LegendMilestone('2003', (en: 'World 5000m champion (teenager)', sw: 'Bingwa wa dunia wa 5000m (kijana)')),
      LegendMilestone('2008', (en: 'Olympic 5000m & 10,000m double, Beijing', sw: 'Jozi ya 5000m na 10,000m ya Olympic, Beijing')),
      LegendMilestone('2012', (en: 'Olympic 10,000m gold, London', sw: 'Dhahabu ya Olympic ya 10,000m, London')),
    ],
    records: [(en: '3x Olympic gold', sw: 'Medali 3 za dhahabu za Olympic'), (en: '10,000m 29:42.56', sw: '10,000m 29:42.56'), (en: '5000m 14:11.15', sw: '5000m 14:11.15')],
    quotes: [(en: 'I believe in my strength.', sw: 'Naamini nguvu yangu.')],
    emoji: '💎',
    accent: _kEthiopia,
    eraStartYear: 2001,
    personalBests: {
      '10,000m': '29:42.56',
      '5000m': '14:11.15',
      '3000m': '8:29.55',
      '1500m': '4:05.23',
    },
    trainingPhilosophy:
        (en: 'Dibaba combined Ethiopian high-altitude endurance with a world-class finishing kick. She often sat back in championship races, then unleashed a searing final-lap surge that left rivals stranded — the hallmark of the great Ethiopian women of the 2000s.',
        sw: 'Dibaba alichanganya uvumilivu wa kimo cha juu wa Uhabeshi na teke la hali ya juu la kumalizia. Mara nyingi alikaa nyuma katika mbio za ubingwa, kisha akatoa msukumo wa kuwasha wa duara ya mwisho uliowaacha wapinzani wametwaa — alama ya wanawake wakuu wa Uhabeshi wa miaka ya 2000.'),
    rivalries: ['meseret-defar'],
    notableRaces: [
      (en: 'Beijing 2008 — 5000m and 10,000m Olympic double.', sw: 'Beijing 2008 — Jozi ya Olympic ya 5000m na 10,000m.'),
      (en: 'London 2012 — Olympic 10,000m gold.', sw: 'London 2012 — Dhahabu ya Olympic ya 10,000m.'),
      (en: 'Multiple world titles across 5000m and 10,000m.', sw: 'Mataji mengi ya dunia katika 5000m na 10,000m.'),
    ],
    funFact: (en: 'She was just 18 when she became world 5000m champion.', sw: 'Alikuwa na miaka 18 tu alipokuwa bingwa wa dunia wa 5000m.'),
    relatedLegends: ['meseret-defar', 'kenenisa-bekele', 'sifan-hassan'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I wait, and then the last lap is mine.', sw: 'Nasubiri, kisha duara ya mwisho ni yangu.')),
      LegendQuote('training', (en: 'The kick is earned in the quiet kilometres.', sw: 'Teke hupatikana katika kilomita za kimya.')),
      LegendQuote('legacy', (en: 'I opened the door for Ethiopian girls.', sw: 'Nilifungua mlango kwa wasichana wa Uhabeshi.')),
    ],
  ),
  Legend(
    slug: 'meseret-defar',
    name: 'Meseret Defar',
    country: (en: 'Ethiopia', sw: 'Uhabeshi'),
    flag: '🇪🇹',
    discipline: (en: '5000m', sw: '5000m'),
    tagline: (en: 'The queen of the 5000m kick.', sw: 'Malkia wa teke la 5000m.'),
    bio: (en: 'Olympic 5000m champion and multiple world-record holder, Defar was the supreme closer of her generation, feared for an unmatched final-lap acceleration.',
        sw: 'Bingwa wa Olympic ya 5000m na mshikaji rekodi nyingi za dunia, Defar alikuwa mfungaji mkuu wa kizazi chake, akiogopwa kwa kuongeza kasi ya duara ya mwisho isiyo na kifani.'),
    timeline: [
      LegendMilestone('2004', (en: 'Olympic 5000m gold, Athens', sw: 'Dhahabu ya Olympic ya 5000m, Athens')),
      LegendMilestone('2007', (en: '5000m world record 14:16.63', sw: 'Rekodi ya dunia ya 5000m 14:16.63')),
      LegendMilestone('2012', (en: 'Olympic 5000m gold, London', sw: 'Dhahabu ya Olympic ya 5000m, London')),
    ],
    records: [(en: '5000m WR 14:12.88', sw: 'Rekodi ya dunia ya 5000m 14:12.88'), (en: 'Olympic 5000m champion x2', sw: 'Bingwa wa Olympic ya 5000m mara 2')],
    quotes: [(en: 'The last 200 metres are my gift.', sw: 'Mitri 200 ya mwisho ni zawadi yangu.')],
    emoji: '⚡',
    accent: _kEthiopia,
    eraStartYear: 2002,
    personalBests: {
      '5000m': '14:12.88',
      '3000m': '8:23.72',
      '2 Mile': '9:10.47',
      '1500m': '4:08.00',
    },
    trainingPhilosophy:
        (en: 'Defar specialized in the 5000m, building an aerobic base at altitude before sharpening a devastating kick with speed-endurance intervals. She raced tactically, often letting others set the pace before blowing past them in the final straight.',
        sw: 'Defar alitizama 5000m, akijenga msingi wa aerobiki katika kimo kabla ya kukomboa teke ya kuangamiza kwa vipindi vya kasi na uvumilivu. Alishindana kwa kiissa, mara nyingi akiwaruhusu wengine wapange kasi kabla ya kuwapitia moja kwa moja katika sehemu ya mwisho.'),
    rivalries: ['tirunesh-dibaba'],
    notableRaces: [
      (en: 'Athens 2004 — First Olympic 5000m gold.', sw: 'Athens 2004 — Dhahabu ya kwanza ya Olympic ya 5000m.'),
      (en: 'London 2012 — Second Olympic 5000m title.', sw: 'London 2012 — Taji la pili la Olympic ya 5000m.'),
      (en: 'Multiple 5000m world records.', sw: 'Rekodi nyingi za dunia za 5000m.'),
    ],
    funFact: (en: 'She held the 5000m world record and had a famed rivalry with Tirunesh Dibaba.', sw: 'Alishikilia rekodi ya dunia ya 5000m na alikuwa na ushindani uliojulikana na Tirunesh Dibaba.'),
    relatedLegends: ['tirunesh-dibaba', 'sifan-hassan'],
    quotesExtra: [
      LegendQuote('racing', (en: 'The last 200 metres are my gift to myself.', sw: 'Mitri 200 ya mwisho ni zawadi yangu kwa nafsi yangu.')),
      LegendQuote('training', (en: 'Speed-endurance is the whole secret.', sw: 'Kasi na uvumilivu ndio siri nzima.')),
      LegendQuote('legacy', (en: 'I made the kick an Ethiopian art form.', sw: 'Nilifanya teke kuwa sanaa ya Kihabeshi.')),
    ],
  ),
  Legend(
    slug: 'sifan-hassan',
    name: 'Sifan Hassan',
    country: (en: 'Ethiopia → Netherlands', sw: 'Uhabeshi → Uholanzi'),
    flag: '🇳🇱',
    discipline: (en: '1500m–Marathon', sw: '1500m–Marathon'),
    tagline: (en: 'The distance chameleon.', sw: 'Mbadiliko wa umbali.'),
    bio: (en: 'An Olympic champion from the 1500m to the marathon, Hassan stunned the world with a 5000m/10,000m/marathon triple at Paris 2024 — racing with audacious, unpredictable surges.',
        sw: 'Bingwa wa Olympic kutoka 1500m hadi marathon, Hassan alishangaza ulimwengu kwa tatu la 5000m/10,000m/marathon huko Paris 2024 — akishindana kwa misukumo ya ujasiri isiyotabirika.'),
    timeline: [
      LegendMilestone('2019', (en: 'World 1500m & 10,000m champion', sw: 'Bingwa wa dunia wa 1500m na 10,000m')),
      LegendMilestone('2021', (en: 'Olympic 5000m & 10,000m gold, Tokyo', sw: 'Dhahabu ya Olympic ya 5000m na 10,000m, Tokyo')),
      LegendMilestone('2023', (en: 'Marathon debut 2:13:44, London', sw: 'Mbio ya kwanza ya marathon 2:13:44, London')),
      LegendMilestone('2024', (en: 'Olympic marathon gold, Paris', sw: 'Dhahabu ya Olympic ya marathon, Paris')),
    ],
    records: [(en: 'Olympic champion 1500m/5000m/10,000m/Marathon', sw: 'Bingwa wa Olympic 1500m/5000m/10,000m/Marathon'), (en: 'Marathon 2:13:44', sw: 'Marathon 2:13:44')],
    quotes: [(en: 'I just keep going, no matter what.', sw: 'Naendelea tu, bila kujali nini.')],
    emoji: '🌈',
    accent: _kNetherlands,
    eraStartYear: 2014,
    personalBests: {
      'Marathon': '2:13:44',
      '10,000m': '29:06.82',
      '5000m': '14:13.42',
      '1500m': '3:51.95',
      'Mile': '4:12.33',
    },
    trainingPhilosophy:
        (en: 'Hassan blends Ethiopian endurance roots with Dutch innovation under coach Tim Rowberry. She is famous for unpredictable, repeated surges that break opponents, and an almost cheerful willingness to do the impossible — running a championship marathon days after track finals.',
        sw: 'Hassan anachanganya mizizi ya uvumilivu ya Uhabeshi na ubunifu wa Uholanzi chini ya mchezeshaji Tim Rowberry. Anajulikana kwa misukumo isiyotabirika ya mara kwa mara inayovunja wapinzani, na utayari wa karibu wa furaha wa kufanya isiwezekanayo — kukimbia marathon ya ubingwa siku chache baada ya fainali za nyanya.'),
    rivalries: ['tirunesh-dibaba', 'faith-kipyegon'],
    notableRaces: [
      (en: 'Paris 2024 — Olympic marathon gold after a 5000m/10,000m double.', sw: 'Paris 2024 — Dhahabu ya Olympic ya marathon baada ya jozi ya 5000m/10,000m.'),
      (en: 'Tokyo 2021 — 5000m and 10,000m Olympic gold.', sw: 'Tokyo 2021 — Dhahabu ya Olympic ya 5000m na 10,000m.'),
      (en: 'London 2023 — Marathon debut 2:13:44, fourth-fastest ever.', sw: 'London 2023 — Mbio ya kwanza ya marathon 2:13:44, ya nne ya haraka zaidi.'),
    ],
    funFact: (en: 'She fled Ethiopia as a refugee at 15 and learned to run in the Netherlands.', sw: 'Alitoroka Uhabeshi akiwa mkimbizi wa miaka 15 na kujifunza kukimbia nchini Uholanzi.'),
    relatedLegends: ['tirunesh-dibaba', 'faith-kipyegon'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I smile in the pain because I chose this.', sw: 'Nitabasamu katika maumivu kwa sababu nimechagua hiki.')),
      LegendQuote('training', (en: 'Surges are not tactics; they are who I am.', sw: 'Misukumo sio mbinu; ni yule ninayekuwa.')),
      LegendQuote('life', (en: 'I run for every refugee who dared to dream.', sw: 'Nakimbia kwa ajili ya kila mkimbizi aliyejaribu kuota.')),
      LegendQuote('legacy', (en: 'One body, every distance — why choose?', sw: 'Mwili mmoja, umbali wote — kwa nini uchague?')),
    ],
  ),
  Legend(
    slug: 'catherine-ndereba',
    name: 'Catherine Ndereba',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'Catherine the Great.', sw: 'Catherine Mkuu.'),
    bio: (en: 'A two-time Olympic silver medallist and four-time Boston Marathon winner, Ndereba was the dominant women\'s marathoner of the early 2000s and a pioneer for Kenyan women.',
        sw: 'Mshindi mara mbili wa fedha ya Olympic na mshindi mara nne wa Marathon ya Boston, Ndereba alikuwa mwanamaria mkuu wa wanawake wa miaka ya mapema ya 2000 na mpainia wa wanawake wa Kenya.'),
    timeline: [
      LegendMilestone('2000', (en: 'Boston Marathon win', sw: 'Ushindi wa Marathon ya Boston')),
      LegendMilestone('2001', (en: 'Marathon WR 2:18:47, Chicago', sw: 'Rekodi ya dunia ya Marathon 2:18:47, Chicago')),
      LegendMilestone('2004', (en: 'Olympic marathon silver, Athens', sw: 'Fedha ya Olympic ya marathon, Athens')),
      LegendMilestone('2005', (en: '4th Boston Marathon title', sw: 'Taji la 4 la Marathon ya Boston')),
    ],
    records: [(en: 'Marathon 2:18:47 (former WR)', sw: 'Marathon 2:18:47 (rekodi ya zamani ya dunia)'), (en: '4x Boston champion', sw: 'Bingwa mara 4 wa Boston')],
    quotes: [(en: 'Run your own race, at your own pace.', sw: 'Kimbia mbio yako mwenyewe, kwa kasi yako.')],
    emoji: '👑',
    accent: _kKenya,
    eraStartYear: 1998,
    personalBests: {
      'Marathon': '2:18:47',
      'Half Marathon': '1:08:10',
    },
    trainingPhilosophy:
        (en: 'Ndereba was a model of steady, even-paced excellence, winning four Boston titles with relentless consistency. She carried the torch for Kenyan women before the modern wave, proving the marathon was theirs to own.',
        sw: 'Ndereba alikuwa kielelezo cha ubora thabiti, wa kasi sawa, akishinda mataji manne ya Boston kwa utimizaji usiochoka. Alibeba tochi ya wanawake wa Kenya kabla ya wimbi la kisasa, akithibitisha marathon ilikuwa yao ya kumiliki.'),
    rivalries: ['tegla-loroupe'],
    notableRaces: [
      (en: 'Chicago 2001 — Marathon world record 2:18:47.', sw: 'Chicago 2001 — Rekodi ya dunia ya marathon 2:18:47.'),
      (en: 'Four Boston Marathon victories.', sw: 'Ushindi manne wa Marathon ya Boston.'),
      (en: 'Two Olympic marathon silver medals.', sw: 'Medali mbili za fedha za Olympic ya marathon.'),
    ],
    funFact: (en: 'She was known as "Catherine the Great" for her calm, unshakeable dominance.', sw: 'Alijulikana kama "Catherine Mkuu" kwa uongozi wake wa utulivu usiochanganyika.'),
    relatedLegends: ['tegla-loroupe', 'mary-keitany', 'brigid-kosgei'],
    quotesExtra: [
      LegendQuote('racing', (en: 'Even pace, even heart — that wins Boston.', sw: 'Kasi sawa, moyo sawa — ndiyo hushinda Boston.')),
      LegendQuote('legacy', (en: 'I was the bridge for Kenyan women at the marathon.', sw: 'Nilikuwa daraja kwa wanawake wa Kenya kwenye marathon.')),
      LegendQuote('training', (en: 'Steady miles, steady mind.', sw: 'Maili thabiti, akili thabiti.')),
    ],
  ),
  Legend(
    slug: 'edna-kiplagat',
    name: 'Edna Kiplagat',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'The ageless champion.', sw: 'Bingwa asiye na umri.'),
    bio: (en: 'A two-time world marathon champion who won global titles deep into her thirties, Kiplagat became a symbol of longevity and smart, patient racing.',
        sw: 'Bingwa mara mbili wa dunia wa marathon ambaye alishinda mataji ya kimataifa akiwa katika miaka ya thelathini, Kiplagat akawa alama ya uhai mrefu na mbio za busara, za subira.'),
    timeline: [
      LegendMilestone('2011', (en: 'World marathon champion', sw: 'Bingwa wa dunia wa marathon')),
      LegendMilestone('2013', (en: 'World marathon champion', sw: 'Bingwa wa dunia wa marathon')),
      LegendMilestone('2021', (en: 'Boston Marathon win at age 41', sw: 'Ushindi wa Marathon ya Boston akiwa na miaka 41')),
    ],
    records: [(en: '2x World marathon champion', sw: 'Bingwa mara 2 wa dunia wa marathon'), (en: 'Boston 2021 champion', sw: 'Bingwa wa Boston 2021')],
    quotes: [(en: 'Age is just a number on the start line.', sw: 'Umri ni nambari tu kwenye mstari wa mwanzo.')],
    emoji: '🌿',
    accent: _kKenya,
    eraStartYear: 2009,
    personalBests: {
      'Marathon': '2:19:50',
      'Half Marathon': '1:09:19',
    },
    trainingPhilosophy:
        (en: 'Kiplagat built a long, durable career on patient, intelligent training and racing. She proved that marathon success need not fade with age, winning a world title at 33 and Boston at 41 through smart pacing and experience.',
        sw: 'Kiplagat alijenga kazi ndefu, ya kudumu kwa mazoezi ya subira na busara. Alithibitisha kuwa mafanikio ya marathon hayapaswi kufifia na umri, akishinda taji la dunia akiwa 33 na Boston akiwa 41 kupitia kudhibiti kasi na uzoefu.'),
    rivalries: ['catherine-ndereba', 'mary-keitany'],
    notableRaces: [
      (en: '2011 & 2013 — Back-to-back world marathon titles.', sw: '2011 na 2013 — Mataji ya dunia ya marathon mfululizo.'),
      (en: 'Boston 2021 — Marathon major win at age 41.', sw: 'Boston 2021 — Ushindi mkuu wa marathon akiwa na miaka 41.'),
    ],
    funFact: (en: 'She became a world champion at 31, relatively late for an elite marathoner.', sw: 'Alikuwa bingwa wa dunia akiwa 31, ya kuchelewa kwa mwanamaria hodari.'),
    relatedLegends: ['catherine-ndereba', 'mary-keitany'],
    quotesExtra: [
      LegendQuote('life', (en: 'Age is just a number on the start line.', sw: 'Umri ni nambari tu kwenye mstari wa mwanzo.')),
      LegendQuote('racing', (en: 'Experience is the pace I trust most.', sw: 'Uzoefu ndio kasi ninayoamini zaidi.')),
      LegendQuote('legacy', (en: 'I showed women they can peak late.', sw: 'Niliwaonyesha wanawake wanaweza kufikia kilele marehemu.')),
    ],
  ),
  Legend(
    slug: 'moses-tanui',
    name: 'Moses Tanui',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon / 10,000m', sw: 'Marathon / 10,000m'),
    tagline: (en: 'The first sub-60 half marathoner.', sw: 'Mwanamume wa kwanza wa nusu marathon chini ya 60.'),
    bio: (en: 'A world 10,000m champion who became the first man to break 60 minutes for the half marathon (59:47, Milan 1993), Tanui helped usher in the era of road-racing speed.',
        sw: 'Bingwa wa dunia wa 10,000m ambaye akawa mtu wa kwanza kuvunja dakika 60 kwa nusu marathon (59:47, Milan 1993), Tanui alisaidia kuleta enzi ya kasi ya mbio za barabarani.'),
    timeline: [
      LegendMilestone('1991', (en: 'World 10,000m champion', sw: 'Bingwa wa dunia wa 10,000m')),
      LegendMilestone('1993', (en: 'First half marathon under 60:00 (59:47)', sw: 'Nusu marathon ya kwanza chini ya 60:00 (59:47)')),
      LegendMilestone('1996', (en: 'Boston Marathon win', sw: 'Ushindi wa Marathon ya Boston')),
    ],
    records: [(en: 'Half marathon 59:47 (first sub-60)', sw: 'Nusu marathon 59:47 (ya kwanza chini ya 60)'), (en: 'Boston 1996 champion', sw: 'Bingwa wa Boston 1996')],
    quotes: [(en: 'Break the barrier and others will follow.', sw: 'Vunja kizuizi na wengine watafuata.')],
    emoji: '⏱️',
    accent: _kKenya,
    eraStartYear: 1989,
    personalBests: {
      'Half Marathon': '59:47',
      'Marathon': '2:06:16',
      '10,000m': '27:22.46',
    },
    trainingPhilosophy:
        (en: 'Tanui was a pioneer of the road-racing revolution, translating track speed to the half and full marathon. His 59:47 half marathon proved Kenyans could dominate the roads with pace, not just endurance.',
        sw: 'Tanui alikuwa mpainia wa mapinduzi ya mbio za barabarani, akibadilisha kasi ya nyanya kuwa nusu na marathon kamili. Nusu marathon yake ya 59:47 ilithibitisha Wa kenya wangeweza kutawala barabara kwa kasi, sio uvumilivu tu.'),
    rivalries: [],
    notableRaces: [
      (en: 'Milan 1993 — First half marathon under 60 minutes.', sw: 'Milan 1993 — Nusu marathon ya kwanza chini ya dakika 60.'),
      (en: 'Boston 1996 — Marathon major victory.', sw: 'Boston 1996 — Ushindi mkuu wa marathon.'),
      (en: '1991 World 10,000m champion.', sw: '1991 Bingwa wa dunia wa 10,000m.'),
    ],
    funFact: (en: 'His sub-60 half marathon stood as a Kenyan milestone for years.', sw: 'Nusu marathon yake chini ya 60 ilikuwa ni hatua ya Kenya kwa miaka.'),
    relatedLegends: ['paul-tergat', 'eliud-kipchoge'],
    quotesExtra: [
      LegendQuote('racing', (en: 'Sub-60 was a wall; I just ran through it.', sw: 'Chini ya 60 ilikuwa ukuta; niliipitia tu.')),
      LegendQuote('legacy', (en: 'I opened the road door for Kenya.', sw: 'Nilifungua mlango wa barabara kwa Kenya.')),
      LegendQuote('training', (en: 'Track speed made my half marathon fast.', sw: 'Kasi ya nyanya ilifanya nusu marathon yangu kuwa ya haraka.')),
    ],
  ),
  Legend(
    slug: 'ibrahim-hussein',
    name: 'Ibrahim Hussein',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: 'Marathon', sw: 'Mbio ya Marathon'),
    tagline: (en: 'The first African Boston winner.', sw: 'Mshindi wa kwanza wa Kiafrika wa Boston.'),
    bio: (en: 'The first African to win the Boston Marathon (1988), Hussein was a trailblazer who proved East Africans could conquer the world\'s oldest marathon.',
        sw: 'Mwafrika wa kwanza kushinda Marathon ya Boston (1988), Hussein alikuwa mpiga njia aliyeonyesha Waafrika wa Afrika Mashariki wangeweza kushinda marathon ya zamani kabisa ya ulimwengu.'),
    timeline: [
      LegendMilestone('1988', (en: 'Boston Marathon win (first African)', sw: 'Ushindi wa Marathon ya Boston (Mwafrika wa kwanza)')),
      LegendMilestone('1991', (en: 'Boston Marathon win', sw: 'Ushindi wa Marathon ya Boston')),
      LegendMilestone('1992', (en: 'Boston Marathon win', sw: 'Ushindi wa Marathon ya Boston')),
    ],
    records: [(en: '3x Boston Marathon champion', sw: 'Bingwa mara 3 wa Marathon ya Boston'), (en: 'First African Boston winner', sw: 'Mshindi wa kwanza wa Kiafrika wa Boston')],
    quotes: [(en: 'I ran for a continent.', sw: 'Nilikimbia kwa ajili ya bara.')],
    emoji: '🌍',
    accent: _kKenya,
    eraStartYear: 1985,
    personalBests: {
      'Marathon': '2:08:43',
      'Half Marathon': '1:02:00',
    },
    trainingPhilosophy:
        (en: 'Hussein was a bold, tactical racer who took on the hills of Boston with courage. His victories in the late 1980s and early 1990s broke a racial barrier and inspired the Kenyan marathon boom that followed.',
        sw: 'Hussein alikuwa mshindani wa ujasiri wa kiissa ambaye alichukua milima ya Boston kwa ujasiri. Ushindi wake mwishoni mwa miaka ya 1980 na mapema 1990 ulivunja kizuizi cha rangi na kuhamasisha uongezeko wa marathon ya Kenya uliofuata.'),
    rivalries: [],
    notableRaces: [
      (en: 'Boston 1988 — First African winner of the marathon.', sw: 'Boston 1988 — Mshindi wa kwanza wa Kiafrika wa marathon.'),
      (en: 'Boston 1991 & 1992 — Back-to-back titles.', sw: 'Boston 1991 na 1992 — Mataji mfululizo.'),
    ],
    funFact: (en: 'He trained at the University of New Mexico before his Boston breakthrough.', sw: 'Alifanya mazoezi katika Chuo Kikuu cha New Mexico kabla ya mafanikio yake ya Boston.'),
    relatedLegends: ['catherine-ndereba', 'paul-tergat'],
    quotesExtra: [
      LegendQuote('legacy', (en: 'I ran for a continent, not just myself.', sw: 'Nilikimbia kwa ajili ya bara, sio mimi tu.')),
      LegendQuote('racing', (en: 'Boston\'s hills frightened everyone but me.', sw: 'Milima ya Boston iliwaogopa kila mtu isipokuwa mimi.')),
      LegendQuote('life', (en: 'Breaking the barrier was the real medal.', sw: 'Kuvunja kizuizi ndiyo medali ya kweli.')),
    ],
  ),
  Legend(
    slug: 'abel-mutai',
    name: 'Abel Mutai',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '3000m SC', sw: '3000m SC'),
    tagline: (en: 'The steeplechase star.', sw: 'Nyota ya steeplechase.'),
    bio: (en: 'Olympic 3000m steeplechase bronze medallist and world champion, Mutai was a master of the barriers and water jump in the golden era of Kenyan steeplechasing.',
        sw: 'Mshindi wa medali ya shaba ya Olympic ya 3000m steeplechase na bingwa wa dunia, Mutai alikuwa bwana wa vizuia na kuruka maji katika enzi ya dhahabu ya steeplechase ya Kenya.'),
    timeline: [
      LegendMilestone('2009', (en: 'World steeplechase silver', sw: 'Fedha ya duniani ya steeplechase')),
      LegendMilestone('2011', (en: 'World steeplechase champion', sw: 'Bingwa wa dunia wa steeplechase')),
      LegendMilestone('2012', (en: 'Olympic steeplechase bronze, London', sw: 'Shaba ya Olympic ya steeplechase, London')),
    ],
    records: [(en: 'World steeplechase champion 2011', sw: 'Bingwa wa dunia wa steeplechase 2011'), (en: 'Olympic bronze 2012', sw: 'Shaba ya Olympic 2012')],
    quotes: [(en: 'Clear the barrier, then fly.', sw: 'Vunja kizuizi, kisha ruka.')],
    emoji: '🚧',
    accent: _kKenya,
    eraStartYear: 2006,
    personalBests: {
      '3000m SC': '7:59.16',
      '1500m': '3:38',
    },
    trainingPhilosophy:
        (en: 'Mutai honed his barrier technique and water-jump rhythm through countless repetition on the track. He was part of Kenya\'s steeplechase dynasty, combining fluid hurdle clearance with the raw speed needed to break eight minutes.',
        sw: 'Mutai alisagia mbinu yake ya vizuia na mdundo wa kuruka maji kupitia marudio mengi kwenye nyanya. Alikuwa sehemu ya nasaba ya steeplechase ya Kenya, akichanganya uvukaji laini wa vizuia na kasi ya mbichi inayohitajika kuvunja dakika nane.'),
    rivalries: ['ezekiel-kemboi'],
    notableRaces: [
      (en: 'Daegu 2011 — World 3000m steeplechase champion.', sw: 'Daegu 2011 — Bingwa wa dunia wa 3000m steeplechase.'),
      (en: 'London 2012 — Olympic steeplechase bronze.', sw: 'London 2012 — Shaba ya Olympic ya steeplechase.'),
    ],
    funFact: (en: 'He famously misinterpreted the finish at a 2012 cross-country race, costing him a win — a rare stumble for a precise technician.', sw: 'Aliyasisha vibaya mwisho katika mbio ya msituni ya 2012, ikamgharimu ushindi — kutakwaa adimu kwa fundi sahihi.'),
    relatedLegends: ['ezekiel-kemboi', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('racing', (en: 'Clear the barrier, then fly to the line.', sw: 'Vunja kizuizi, kisha ruka hadi mstari.')),
      LegendQuote('training', (en: 'The water jump is rhythm, not courage.', sw: 'Kuruka maji ni mdundo, sio ujasiri.')),
      LegendQuote('legacy', (en: 'I kept Kenya on top of the steeple.', sw: 'Niliweka Kenya juu ya steeple.')),
    ],
  ),
  Legend(
    slug: 'ezekiel-kemboi',
    name: 'Ezekiel Kemboi',
    country: (en: 'Kenya', sw: 'Kenya'),
    flag: '🇰🇪',
    discipline: (en: '3000m SC', sw: '3000m SC'),
    tagline: (en: 'The showman of the steeplechase.', sw: 'Mwigizaji wa steeplechase.'),
    bio: (en: 'A four-time world 3000m steeplechase champion and Olympic gold medallist, Kemboi was as flamboyant as he was dominant, celebrating before the line.',
        sw: 'Bingwa mara nne wa dunia wa 3000m steeplechase na mshindi wa medali ya dhahabu ya Olympic, Kemboi alikuwa mtemberezi kama alivyokuwa mtawala, akisherehekea kabla ya mstari.'),
    timeline: [
      LegendMilestone('2004', (en: 'Olympic steeplechase gold, Athens', sw: 'Dhahabu ya Olympic ya steeplechase, Athens')),
      LegendMilestone('2009', (en: 'World steeplechase champion', sw: 'Bingwa wa dunia wa steeplechase')),
      LegendMilestone('2011', (en: 'World steeplechase champion', sw: 'Bingwa wa dunia wa steeplechase')),
      LegendMilestone('2015', (en: '4th world title', sw: 'Taji la 4 la dunia')),
    ],
    records: [(en: '4x World steeplechase champion', sw: 'Bingwa mara 4 wa dunia wa steeplechase'), (en: 'Olympic gold 2004', sw: 'Dhahabu ya Olympic 2004')],
    quotes: [(en: 'I am the steeplechase!', sw: 'Mimi ni steeplechase!')],
    emoji: '🏆',
    accent: _kKenya,
    eraStartYear: 2001,
    personalBests: {
      '3000m SC': '7:55.76',
      '1500m': '3:37',
    },
    trainingPhilosophy:
        (en: 'Kemboi trained with theatrical flair but deadly seriousness, famous for his signature celebration mid-race and his ferocious kick over the final barrier. He dominated the steeplechase for over a decade with sheer confidence and a perfectly timed final surge.',
        sw: 'Kemboi alifanya mazoezi kwa mtindo wa kuigiza lakini ya uzito wa kifo, akijulikana kwa sherehe yake ya saini katikati ya mbio na teke yake kali juu ya kizuizi cha mwisho. Alitawala steeplechase kwa zaidi ya muongo kwa kujiamini kabisa na msukumo wa wakati sahihi wa mwisho.'),
    rivalries: ['abel-mutai'],
    notableRaces: [
      (en: 'Athens 2004 — Olympic steeplechase gold.', sw: 'Athens 2004 — Dhahabu ya Olympic ya steeplechase.'),
      (en: 'Four world steeplechase titles (2009, 2011, 2013, 2015).', sw: 'Mataji manne ya dunia ya steeplechase (2009, 2011, 2013, 2015).'),
    ],
    funFact: (en: 'He often began his victory celebration before crossing the finish line.', sw: 'Mara nyingi alianza sherehe yake ya ushindi kabla ya kuvuka mstari wa mwisho.'),
    relatedLegends: ['abel-mutai', 'kipchoge-keino'],
    quotesExtra: [
      LegendQuote('racing', (en: 'I am the steeplechase — ask anyone!', sw: 'Mimi ni steeplechase — uliza yeyote!')),
      LegendQuote('training', (en: 'Confidence is a muscle; I train it daily.', sw: 'Kujiamini ni misuli; naufanya mazoezi kila siku.')),
      LegendQuote('legacy', (en: 'I made the steeple fun to watch.', sw: 'Nilifanya steeple ifurahishe kutazamwa.')),
    ],
  ),
];

Map<String, Legend>? _legendBySlug;

Legend legendForSlug(String slug) {
  _legendBySlug ??= {for (final l in legends) l.slug: l};
  return _legendBySlug![slug] ?? legends.first;
}

Color legendAccent(Legend l) => {
      'orange': const Color(0xFFFF5A1F),
      'gold': const Color(0xFFFFD15C),
      'green': const Color(0xFF2BB673),
    }[l.accent] ?? const Color(0xFFFF5A1F);