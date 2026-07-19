import 'package:flutter/material.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';

enum CourseCategory { science, technique, health, heritage }

extension CourseCategoryMeta on CourseCategory {
  static const Map<String, LocalizedText> _labels = {
    'science': (en: 'Running Science', sw: 'Sayansi ya Mbio'),
    'technique': (en: 'Technique & Health', sw: 'Ufundi na Afya'),
    'health': (en: 'Technique & Health', sw: 'Ufundi na Afya'),
    'heritage': (en: 'Heritage & Culture', sw: 'Urithi na Utamaduni'),
  };

  LocalizedText get label => _labels[name]!;

  IconData get icon => {
        CourseCategory.science: Icons.science_rounded,
        CourseCategory.technique: Icons.accessibility_new_rounded,
        CourseCategory.health: Icons.favorite_rounded,
        CourseCategory.heritage: Icons.account_balance_rounded,
      }[this]!;

  Color get accent => {
        CourseCategory.science: const Color(0xFF4A90E2),
        CourseCategory.technique: const Color(0xFF2BB673),
        CourseCategory.health: const Color(0xFFFF5A1F),
        CourseCategory.heritage: const Color(0xFFFFD15C),
      }[this]!;
}

class Lesson {
  final LocalizedText title;
  final int minutes;
  final LocalizedText summary;
  final List<LocalizedText> paragraphs;

  const Lesson({
    required this.title,
    required this.minutes,
    required this.summary,
    required this.paragraphs,
  });
}

class Course {
  final String slug;
  final LocalizedText title;
  final LocalizedText subtitle;
  final CourseCategory category;
  final LocalizedText author;
  final List<Lesson> lessons;

  const Course({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.author,
    required this.lessons,
  });

  int get minutes => lessons.fold(0, (s, l) => s + l.minutes);
}

const List<Course> courses = [
  Course(
    slug: 'how-to-start-running',
    title: (en: 'How to Start Running', sw: 'Jinsi ya Kuanza Kukimbia'),
    subtitle: (en: 'From the sofa to your first 5K, one walk-run at a time.', sw: 'Kutoka kiti hadi 5K yako ya kwanza, hatua kwa hatua.'),
    category: CourseCategory.technique,
    author: (en: 'Mwendo Coaches', sw: 'Wachezaaji wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Why Run?', sw: 'Kwa Nini Kukimbia?'),
        minutes: 3,
        summary: (en: 'The case for building a running habit.', sw: 'Hamu ya kujenga tabia ya kukimbia.'),
        paragraphs: [
          (en: 'Running is the most accessible sport on earth. No court, no club, no expensive kit — just you, a pair of shoes, and the open road.', sw: 'Kukimbia ni mchezo unaofikika zaidi duniani. Hakuna uwanja, hakuna klabu, hakuna vifaa vigumu — wewe tu, jozi ya viatu, na barabara ya wazi.'),
          (en: 'Regular running strengthens your heart, clears your mind, and builds a kind of confidence that spills into every corner of life. In Kenya it is also community: a shared language spoken from Nairobi to Eldoret.', sw: 'Kukimbia mara kwa mara kunaimari moyo wako, kutakasa akili yako, na kujenga aina ya ujasiri unaojaa kona zote za maisha. Nchini Kenya pia ni jamii: lugha ya pamoja inayozungumzwa kutoka Nairobi hadi Eldoret.'),
        ],
      ),
      Lesson(
        title: (en: 'Gear You Actually Need', sw: 'Vifaa Unavyohitaji Kweli'),
        minutes: 4,
        summary: (en: 'Keep it simple and kind to your joints.', sw: 'Weka rahisi na urahimu kwa viungo vyako.'),
        paragraphs: [
          (en: 'A proper pair of running shoes is the single best investment you can make. Visit a specialist shop and get fitted — the right shoe prevents most beginner injuries.', sw: 'Jozi sahihi ya viatu vya mbio ni uwekezaji pekee mzuri unaoweza kufanya. Tembelea duka la kitaalamu na upimwe — viatu vya haki vinazuilia majeraha mengi ya mwanzo.'),
          (en: 'Everything else — watches, vests, headphones — is optional. Start with what you have and add only what genuinely helps you show up.', sw: 'Kila kitu kingine — saa, vesti, vifaa vya masikioni — ni cha hiari. Anza kwa ulicho nacho na uongeze tu kile kinachokusaidia kuja.'),
        ],
      ),
      Lesson(
        title: (en: 'The Walk-Run Method', sw: 'Njia ya Tembea-Kimbia'),
        minutes: 5,
        summary: (en: 'The gentle on-ramp to continuous running.', sw: 'Njia nyororu ya kuelekea mbio za kuendelea.'),
        paragraphs: [
          (en: 'Run for one minute, walk for two. Repeat. This simple ratio builds aerobic base without overwhelming untrained legs.', sw: 'Kimbia dakika moja, tembea dakika mbili. Rudia. Uwiano huu rahisi hujenga msingi wa aerobiki bila kushinda miguu isiyofanya mazoezi.'),
          (en: 'Over weeks, tip the balance toward more running and less walking. Most beginners reach a continuous 30 minutes within two months.', sw: 'Kwa wiki, zingatia usawa kuelekea kukimbia zaidi na kutembea kidogo. Wengi wanafanikisha dakika 30 za kuendelea ndani ya miezi miwili.'),
        ],
      ),
      Lesson(
        title: (en: 'Warming Up & Cooling Down', sw: 'Kuanza na Kumalizia'),
        minutes: 4,
        summary: (en: 'Protect your body before and after.', sw: 'Linda mwili wako kabla na baada.'),
        paragraphs: [
          (en: 'A brisk five-minute walk plus dynamic leg swings prepares muscles and joints for effort.', sw: 'Tembea ya dakika 5 kwa haraka pamoja na mazungumzo ya miguu yanawaandaa misuli na viungo kwa juhudi.'),
          (en: 'Afterward, walk calmly and stretch the big muscle groups. Your future self — and your knees — will thank you.', sw: 'Baadaye, tembea kwa utulivu na nyoosha vikundi vikubwa vya misuli. Nafs yako ya baadaye — na magoti yako — zitakushukuru.'),
        ],
      ),
      Lesson(
        title: (en: 'Your First 5K Plan', sw: 'Mpango Wako wa 5K wa Kwanza'),
        minutes: 6,
        summary: (en: 'An eight-week path to 5 kilometres.', sw: 'Njia ya wiki nane kuelekea kilomita 5.'),
        paragraphs: [
          (en: 'Three sessions a week is enough. Alternate walk-run days with rest, and add one longer weekend effort.', sw: 'Vipindi vitatu kwa wiki ni vya kutosha. Badilisha siku za tembea-kimbia na mapumziko, na uongeze juhudi moja ndefu ya wikendi.'),
          (en: 'By week eight, lace up for a measured 5K. Go easy, enjoy it, and celebrate — you are now a runner.', sw: 'Wiki ya nane, vaa viatu kwa 5K iliyopimwa. Nenda polepole, furahia, na shangilia — sasa wewe ni mkimbiaji.'),
        ],
      ),
      Lesson(
        title: (en: 'Staying Motivated', sw: 'Kudumisha Msisimko'),
        minutes: 4,
        summary: (en: 'Habits that survive the rainy season.', sw: 'Tabia zinazodumu msimu wa mvua.'),
        paragraphs: [
          (en: 'Habit beats motivation. Lay your kit out the night before and treat the run as a non-negotiable appointment.', sw: 'Tabia inashinda msisimko. Andaa vifaa vyako usiku kabla na uone mbio kama mazungumzo yasiyobadilishika.'),
          (en: 'Track every step in Mwendo, chase a streak, and let the heritage of East African champions pull you forward on the hard days.', sw: 'Fuatilia hatua zote katika Mwendo, fuata mfululizo, na uruhusu urithi wa mabingwa wa Afrika Mashariki kukuvuta mbele siku ngumu.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'heart-rate-zones',
    title: (en: 'Heart Rate Zones', sw: 'Maeneo ya频率 ya Moyo'),
    subtitle: (en: 'Train smarter by listening to your pulse.', sw: 'Fanya mazoezi kwa busara kwa kusikilia pULSI yako.'),
    category: CourseCategory.science,
    author: (en: 'Dr. A. Were', sw: 'Dr. A. Were'),
    lessons: [
      Lesson(
        title: (en: 'The Five Zones', sw: 'Maeneo Matano'),
        minutes: 5,
        summary: (en: 'What each intensity band does for you.', sw: 'Kile kila kikosi cha nguvu kinakufanyia.'),
        paragraphs: [
          (en: 'Zone 1–2 (recovery, aerobic) build the engine. Zone 3 (tempo) raises threshold. Zone 4–5 (threshold, anaerobic) sharpen speed.', sw: 'Maeneo 1–2 (urejee, aerobiki) hujenga injini. Eneo la 3 (tempo) huinua kizingiti. Maeneo 4–5 (kizingiti, anaerobiki) huosha kasi.'),
          (en: 'Most of your weekly volume should sit comfortably in Zones 1–2. The famous Kenyan "easy days easy" rule is built on this.', sw: 'Kiasi kikubwa cha kiasi chako cha kila wiki kinapaswa kukaa kwa urahisi katika maeneo 1–2. Kanuni maarufu ya Kenya "siku rahisi rahisi" inajengwa juu ya hii.'),
        ],
      ),
      Lesson(
        title: (en: 'Finding Your Max', sw: 'Kupata Upeo Wako'),
        minutes: 4,
        summary: (en: 'A safe estimate without a lab.', sw: 'Kadirio salama bila maabara.'),
        paragraphs: [
          (en: 'A rough max is 220 minus your age, but individual variety is large. Use feel and the talk test: in Zone 2 you can hold a conversation.', sw: 'Upeo wa kukubiota ni 220 kupunguza umri wako, lakini utofauti wa mtu binafsi ni mkubwa. Tumia hisia na jaribio la mazungumzo: katika eneo la 2 unaweza kuwa na mazungumzo.'),
          (en: 'Over time, the same pace will drop your heart rate — the clearest sign your fitness is climbing.', sw: 'Kwa muda, kasi ile ile itashusha kasi ya moyo wako — ishara wazi zaidi kwamba uwezo wako wa mazoezi unaongea.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'running-form',
    title: (en: 'Effortless Running Form', sw: 'Sura ya Kupendeza ya Mbio'),
    subtitle: (en: 'Posture, cadence and foot strike.', sw: 'Mwinuko, kadensi na mguso wa mguu.'),
    category: CourseCategory.technique,
    author: (en: 'Mwendo Coaches', sw: 'Wachezaaji wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Posture & Relaxation', sw: 'Mwinuko na Uvumilivu'),
        minutes: 4,
        summary: (en: 'Run tall, relax the shoulders.', sw: 'Kimbia wima, lasima mabega.'),
        paragraphs: [
          (en: 'A slight forward lean from the ankles, a soft knee, and relaxed arms keep you efficient and injury-free.', sw: 'Kuinua kidoko kutoka mafululizo, goti laini, na mikono iliyovumilia hukufanya uwe na ufanisi na bila majeraha.'),
          (en: 'Tension in the neck and fists wastes energy. Check in every few minutes and shake it out.', sw: 'Mshindo shingoni na ngumi hupoteza nishati. Angalia kila dakika chache na uitute.'),
        ],
      ),
      Lesson(
        title: (en: 'Cadence & Stride', sw: 'Kadensi na Hatua'),
        minutes: 5,
        summary: (en: 'Why ~180 steps per minute matters.', sw: 'Kwa nini hatua ~180 kwa dakika ni muhimu.'),
        paragraphs: [
          (en: 'A quicker, shorter stride reduces braking forces and landing impact. Aim for around 170–180 steps per minute.', sw: 'Hatua fupi za haraka hupunguza nguvu za kusimama na athari ya kutua. Lenga kwa hatua 170–180 kwa dakika.'),
          (en: 'Don\'t force it overnight — let cadence rise naturally as your fitness and strength improve.', sw: 'Usifanye kwa ghafla — acha kadensi iongeze kwa asili kwa ufanisi na nguvu zako zinazoendelea.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'nutrition-for-runners',
    title: (en: 'Fuel for the Run', sw: 'Mafuta ya Mbio'),
    subtitle: (en: 'Eat like a champion, the Kenyan way.', sw: 'Kula kama bingwa, kwa mtindo wa Kenya.'),
    category: CourseCategory.health,
    author: (en: 'Mwendo Coaches', sw: 'Wachezaaji wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Everyday Nutrition', sw: 'Lishe ya Kila Siku'),
        minutes: 5,
        summary: (en: 'Carbs are your friend.', sw: 'Kabohidreti ni rafiki yako.'),
        paragraphs: [
          (en: 'The staple of many champion training camps is simple: ugali, vegetables, rice, beans and tea. Plenty of carbohydrates, modest protein, little processed food.', sw: 'Msingi wa kambi nyingi za mabingwa ni rahisi: ugali, mboga, mchele, maharage na chai. Kwingi kwa kabohidreti, protini ndogo, chakula kiliyochakatwa kidogo.'),
          (en: 'Fuel the day around your runs — a light carbohydrate snack an hour before, a balanced meal after.', sw: 'Weka mafuta siku kuzunguka mbio zako — kinyasio cha kabohidreti kijini saa moja kabla, mlo uliowana baada.'),
        ],
      ),
      Lesson(
        title: (en: 'Hydration', sw: 'Unyevu'),
        minutes: 3,
        summary: (en: 'Drink to thirst, plan for heat.', sw: 'Kunywa kwa kiu, panga kwa joto.'),
        paragraphs: [
          (en: 'For most runs, water to thirst is enough. In heat or on long efforts, add a little salt and carbohydrate.', sw: 'Kwa mbio nyingi, maji kwa kiu ni ya kutosha. Katika joto au juhudi ndefu, ongeza chumvi kidogo na kabohidreti.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'injury-prevention',
    title: (en: 'Stay Injury-Free', sw: 'Kaa Bila Majeraha'),
    subtitle: (en: 'Strength, rest and listening to pain.', sw: 'Nguvu, mapumziko na kusikilia maumivu.'),
    category: CourseCategory.health,
    author: (en: 'Dr. A. Were', sw: 'Dr. A. Were'),
    lessons: [
      Lesson(
        title: (en: 'The 10% Rule', sw: 'Kanuni ya 10%'),
        minutes: 4,
        summary: (en: 'Grow volume gradually.', sw: 'Ongoza kiasi polepole.'),
        paragraphs: [
          (en: 'Increase weekly distance by no more than about 10%. Most injuries come from doing too much, too soon.', sw: 'Ongeza umbi wa kila wiki kwa zaidi ya asilimia 10%. Majeraha mengi hutokana na kufanya mengi, mapema mno.'),
        ],
      ),
      Lesson(
        title: (en: 'Strength for Runners', sw: 'Nguvu kwa Wakimbiaji'),
        minutes: 5,
        summary: (en: 'A little goes a long way.', sw: 'Kidogo kinatolea mbali.'),
        paragraphs: [
          (en: 'Two short sessions a week of squats, calf raises and single-leg work protect knees, ankles and hips.', sw: 'Vipindi viwili vya fupi kwa wiki vya squats, kuinua mfuko wa mguu, na kazi ya mguu mmoja hulinda magoti, mafundo na kiuno.'),
          (en: 'Strong feet and hips are the unsung heroes behind every sub-2:05 marathon.', sw: 'Miguu na kiuno vya nguvu ni watu wa ajabu wasiojulikana nyuma ya marathon kila chini ya 2:05.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'women-in-running',
    title: (en: 'Women in Running', sw: 'Wanawake katika Mbio'),
    subtitle: (en: 'Strength, physiology and community.', sw: 'Nguvu, fiziologia na jamii.'),
    category: CourseCategory.health,
    author: (en: 'Mwendo Community', sw: 'Jamii ya Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Training Through Life', sw: 'Mazoezi katika Maisha'),
        minutes: 5,
        summary: (en: 'Adapting to the female body.', sw: 'Kubadilisha kwa mwili wa kike.'),
        paragraphs: [
          (en: 'Hormonal cycles affect energy and recovery. Track how you feel and adjust hard days accordingly — there is no single right answer.', sw: 'Mizunguko ya homoni huathiri nishati na urejee. Fuatilia jinsi unavyohisi na rekebisha siku ngumu hivyo — hakuna jibu moja la haki.'),
          (en: 'From Tegla Loroupe to Faith Kipyegon, women have rewritten the record books. Your run is part of that lineage.', sw: 'Kutoka Tegla Loroupe hadi Faith Kipyegon, wanawake wameandika upya vitabu vya rekodi. Mbio zako ni sehemu ya ule msimbo.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'altitude-training',
    title: (en: 'The Altitude Advantage', sw: 'Faida ya Kimo'),
    subtitle: (en: 'Why the Rift Valley makes champions.', sw: 'Kwa nini Bonde la Rift hufanya mabingwa.'),
    category: CourseCategory.heritage,
    author: (en: 'Mwendo Heritage', sw: 'Urithi wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Life at 2,400 Metres', sw: 'Maisha kwa Mita 2,400'),
        minutes: 6,
        summary: (en: 'Erythropoiesis and red dirt.', sw: 'Uzalishaji wa seli nyekundu na udongo mwekundu.'),
        paragraphs: [
          (en: 'Training at altitude stimulates extra red-blood-cell production, boosting oxygen delivery when athletes return to sea level.', sw: 'Mazoezi kimo cha juu huhamisi uzalishaji wa ziada wa seli za damu nyekundu, kuboresha usambazaji wa oksijini wanapoondoka kwa kiwango cha bahari.'),
          (en: 'The red-dirt roads of Iten and Kaptagat are soft and forgiving on joints, and the close-knit camps turn training into a shared ritual.', sw: 'Barabara za udongo mwekundu za Iten na Kaptagat ni laini na zinazosameheana kwa viungo, na kambi za karibu hufanya mazoezi kuwa desturi ya pamoja.'),
        ],
      ),
      Lesson(
        title: (en: 'Can You Train Like Them?', sw: 'Je, Unaweza Kufanya Mazoezi Kama Wanavyofanya?'),
        minutes: 5,
        summary: (en: 'What travels, and what doesn\'t.', sw: 'Kile kinachosafiri, na kile kisichosafiri.'),
        paragraphs: [
          (en: 'You can borrow the discipline, the easy-day patience, and the community mindset anywhere. True altitude camps are a bonus, not a prerequisite.', sw: 'Unaweza kukopa nidhamu, subira ya siku rahisi, na mtindo wa jamii popote. Kambi za kweli za kimo ni faida, sio sharti.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'history-of-east-african-running',
    title: (en: 'A History of Greatness', sw: 'Historia ya Ukuu'),
    subtitle: (en: 'From pre-colonial traditions to global dominance.', sw: 'Kutoka desturi za kabla ya ukoloni hadi utawala wa kimataifa.'),
    category: CourseCategory.heritage,
    author: (en: 'Mwendo Heritage', sw: 'Urithi wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'The First Steps', sw: 'Hatua za Kwanza'),
        minutes: 6,
        summary: (en: 'Roots of a running culture.', sw: 'Mizizi ya utamaduni wa mbio.'),
        paragraphs: [
          (en: 'Long before world records, running was woven into community life across the Rift Valley — messages carried on foot, cattle trails turned to races.', sw: 'Muda mrefu kabla ya rekodi za dunia, mbio zilishonwa katika maisha ya jamii kote Bonde la Rift — ujumbe uliobebwa kwa miguu, njia za mifugo ziligeuzwa kuwa mashindano.'),
          (en: 'Independence-era athletes carried national pride onto the world stage, laying the foundation for everything that followed.', sw: 'Wanariadha wa enzi ya uhuru walibeba fahari ya taifa kwenye jukwaa la dunia, kuweka msingi wa kila kitu kilichofuata.'),
        ],
      ),
      Lesson(
        title: (en: 'Mexico 1968 & Beyond', sw: 'Mexico 1968 na Baadaye'),
        minutes: 7,
        summary: (en: 'Kipchoge Keino ignites an era.', sw: 'Kipchoge Keino anaondoa enzi.'),
        paragraphs: [
          (en: 'Kipchoge Keino\'s 1968 Olympic gold announced East Africa as a distance-running powerhouse and inspired generations.', sw: 'Dhahabu ya Olympic ya 1968 ya Kipchoge Keino ilitangaza Afrika Mashariki kama nguvu ya mbio za umbali na kuwahamasisha vizazi.'),
          (en: 'Decades later the torch passed to Tergat, then Kipchoge and Kipyegon — a continuous relay of excellence.', sw: 'Miongo mingi baadaye mwisho ulifanywa kwa Tergat, kisha Kipchoge na Kipyegon — usambazaji wa kuendelea wa ubora.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'the-thursday-fartlek',
    title: (en: 'The Thursday Fartlek', sw: 'Fartlek ya Alhamisi'),
    subtitle: (en: 'The group workout that built an empire.', sw: 'Mazoezi ya kikundi yaliyojiweka kuwa ufalme.'),
    category: CourseCategory.heritage,
    author: (en: 'Mwendo Heritage', sw: 'Urithi wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: '15 km, Effort Over Pace', sw: 'Kilomita 15, Juhidi Zaidi ya Kasi'),
        minutes: 6,
        summary: (en: 'The legendary session, decoded.', sw: 'Kipindi cha kujulikana, kufafanuliwa.'),
        paragraphs: [
          (en: 'Every Thursday, champions gather for a 15 km effort built on 3/1, 2/1 and 1/1 minute surges. The pace is dictated by feel, never the watch.', sw: 'Kila Alhamisi, mabingwa hukutana kwa juhudi ya kilomita 15 yenye msukumo wa dakika 3/1, 2/1 na 1/1. Kasi inaongozwa na hisia, siyo kamwe saa.'),
          (en: 'The philosophy — clear lactate, build resilience, and suffer together — is the soul of Kenyan training.', sw: 'Falsafa — safisha lactate, jenga uvumilivu, na pumzika pamoja — ndio roho ya mazoezi ya Kenya.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'training-camps',
    title: (en: 'The Valley of Champions', sw: 'Bonde la Mabingwa'),
    subtitle: (en: 'Iten, Kaptagat, Eldoret and Ngong.', sw: 'Iten, Kaptagat, Eldoret na Ngong.'),
    category: CourseCategory.heritage,
    author: (en: 'Mwendo Heritage', sw: 'Urithi wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'A Map of Camps', sw: 'Ramani ya Kambi'),
        minutes: 5,
        summary: (en: 'Where legends are made.', sw: 'Ambapo mabingwa hufanywa.'),
        paragraphs: [
          (en: 'Iten sits high above the Great Rift Valley and calls itself the "City of Champions". Nearby Kaptagat hosts the famous forest tempo runs.', sw: 'Iten inakaa juu sana ya Bonde Kubwa la Rift na kijiita "Jiji la Mabingwa". Karibu Kaptagat ina mbio za tempo za msitu zinazojulikana.'),
          (en: 'Eldoret and Ngong each add their own chapters to the story — proof that place, community and purpose shape performance as much as training plans.', sw: 'Eldoret na Ngong kila moja inaongeza sura zake kwenye hadithi — ushahidi kwamba mahali, jamii, na kusudi huchanua utendaji kama mpango wa mazoezi.'),
        ],
      ),
    ],
  ),
];

Map<String, Course>? _courseBySlug;

Course courseForSlug(String slug) {
  _courseBySlug ??= {for (final c in courses) c.slug: c};
  return _courseBySlug![slug] ?? courses.first;
}