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
    author: (en: 'Mwendo Coaches', sw: 'Wakocha wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Why Run?', sw: 'Kwa Nini Kukimbia?'),
        minutes: 3,
        summary: (en: 'Motivational case for running, set in a Kenyan community context.', sw: 'Faida za afya na akili za kusonga.'),
        paragraphs: [
          (en: 'Running is the most democratic sport on earth. You need no membership, no special venue—just a pair of shorts and the desire to move. For millions of Kenyans, running is woven into daily life: children run to school, farmers jog to the shamba, and champions are born on red‑dirt roads. The benefits go far beyond a medal. Regular running strengthens your heart, boosts your mood by releasing endorphins, improves sleep quality, and can cut the risk of chronic diseases like diabetes and hypertension by half. In a country where high blood pressure is rising, a 20‑minute jog three times a week is a powerful preventative medicine.', sw: 'Running is the most democratic sport on earth. You need no membership, no special venue—just a pair of shorts and the desire to move. For millions of Kenyans, running is woven into daily life: children run to school, farmers jog to the shamba, and champions are born on red‑dirt roads. The benefits go far beyond a medal. Regular running strengthens your heart, boosts your mood by releasing endorphins, improves sleep quality, and can cut the risk of chronic diseases like diabetes and hypertension by half. In a country where high blood pressure is rising, a 20‑minute jog three times a week is a powerful preventative medicine.'),
          (en: 'Beyond the body, running reshapes your mind. The rhythm of footfalls creates a meditative space where stress dissolves and problems shrink. Many newcomers find that their first month of running brings more mental clarity than any self‑help book. And in the Kenyan context, running is rarely solo. It’s a communal act—whether it’s a Saturday morning group in Karura Forest or a few friends meeting at dawn in Eldoret. That social connection is a lifeline; it turns exercise into a shared ritual that cements friendships and holds you accountable.', sw: 'Beyond the body, running reshapes your mind. The rhythm of footfalls creates a meditative space where stress dissolves and problems shrink. Many newcomers find that their first month of running brings more mental clarity than any self‑help book. And in the Kenyan context, running is rarely solo. It’s a communal act—whether it’s a Saturday morning group in Karura Forest or a few friends meeting at dawn in Eldoret. That social connection is a lifeline; it turns exercise into a shared ritual that cements friendships and holds you accountable.'),
          (en: 'This course is your first step into that world. You’ll learn everything from tying your shoes to crossing the finish line of your first 5K. The goal isn’t speed or distance—it’s consistency. By the end of these six lessons, you’ll have a blueprint to make running a joyful, lifelong habit. Let’s lace up.', sw: 'This course is your first step into that world. You’ll learn everything from tying your shoes to crossing the finish line of your first 5K. The goal isn’t speed or distance—it’s consistency. By the end of these six lessons, you’ll have a blueprint to make running a joyful, lifelong habit. Let’s lace up.'),
        ],
      ),
      Lesson(
        title: (en: 'Gear You Actually Need', sw: 'Vifaa Unavyohitaji Kweli'),
        minutes: 4,
        summary: (en: 'Shoes as the key investment; everything else is optional.', sw: 'Weka rahisi na urahimu kwa viungo vyako.'),
        paragraphs: [
          (en: 'Walk into a sports store and you’ll be bombarded with compression sleeves, GPS watches, and carbon‑plated super shoes. Ignore all of it. A beginner needs exactly one piece of specialised equipment: a decent pair of running shoes. In Kenya, countless champions started in canvas sneakers or even barefoot. Today we know that a shoe that fits your foot shape and running style reduces impact forces and prevents blisters. Visit a shop where staff can watch you jog; they’ll recommend a model based on your arch type and heel‑strike pattern. Spend KSh 3,000–6,000 on a daily trainer—no need for race‑day rockets yet. Replace them every 600–800 kilometres, or when the midsole feels flat.', sw: 'Walk into a sports store and you’ll be bombarded with compression sleeves, GPS watches, and carbon‑plated super shoes. Ignore all of it. A beginner needs exactly one piece of specialised equipment: a decent pair of running shoes. In Kenya, countless champions started in canvas sneakers or even barefoot. Today we know that a shoe that fits your foot shape and running style reduces impact forces and prevents blisters. Visit a shop where staff can watch you jog; they’ll recommend a model based on your arch type and heel‑strike pattern. Spend KSh 3,000–6,000 on a daily trainer—no need for race‑day rockets yet. Replace them every 600–800 kilometres, or when the midsole feels flat.'),
          (en: 'Your clothing should be comfortable, not cotton‑heavy. Cotton soaks up sweat and chafes. A simple polyester T‑shirt and lightweight shorts or tights will keep you dry. In the cool early mornings of Nairobi or the Rift Valley, layer a second‑hand fleece you can tie around your waist once you warm up. Women should invest in a supportive sports bra that minimises bounce; cheap options exist at local markets, but test the fit by jogging in place before buying. Accessories like a cap for sun, a reusable water bottle, and a basic digital watch (or your phone in an armband) round out the kit. Nothing else is required—not gels, not heart‑rate monitors, not fashion brands. Start simple, spend little, and let consistency be your badge.', sw: 'Your clothing should be comfortable, not cotton‑heavy. Cotton soaks up sweat and chafes. A simple polyester T‑shirt and lightweight shorts or tights will keep you dry. In the cool early mornings of Nairobi or the Rift Valley, layer a second‑hand fleece you can tie around your waist once you warm up. Women should invest in a supportive sports bra that minimises bounce; cheap options exist at local markets, but test the fit by jogging in place before buying. Accessories like a cap for sun, a reusable water bottle, and a basic digital watch (or your phone in an armband) round out the kit. Nothing else is required—not gels, not heart‑rate monitors, not fashion brands. Start simple, spend little, and let consistency be your badge.'),
        ],
      ),
      Lesson(
        title: (en: 'The Walk‑Run Method', sw: 'The Walk‑Run Method'),
        minutes: 5,
        summary: (en: '1 min run / 2 min walk ratio, 30‑min goal in 2 months.', sw: '1 min run / 2 min walk ratio, 30‑min goal in 2 months.'),
        paragraphs: [
          (en: 'The biggest mistake new runners make is trying to run continuously from day one. Lungs burn, legs ache, and discouragement follows. The walk‑run method breaks the barrier gently. Begin with a 5‑minute brisk walk to warm up. Then alternate 1 minute of easy jogging with 2 minutes of walking. Repeat this cycle five times, finishing with a 5‑minute cool‑down walk. That’s 20 minutes total, and it’s your first successful workout. Do it three times per week on non‑consecutive days.', sw: 'The biggest mistake new runners make is trying to run continuously from day one. Lungs burn, legs ache, and discouragement follows. The walk‑run method breaks the barrier gently. Begin with a 5‑minute brisk walk to warm up. Then alternate 1 minute of easy jogging with 2 minutes of walking. Repeat this cycle five times, finishing with a 5‑minute cool‑down walk. That’s 20 minutes total, and it’s your first successful workout. Do it three times per week on non‑consecutive days.'),
          (en: 'Each week, you’ll shift the ratio. Week 2: jog 2 min, walk 1 min. Week 3: jog 3 min, walk 1 min. By week 5, you’ll be running 5‑minute segments and walking only 1 minute between them. The goal by week 8 is to string together a full 30‑minute run without walking. This method respects your body’s need to adapt—tendons, ligaments, and bones strengthen much more slowly than your heart and lungs. Kenyan coaches often say, “You have to become a runner before you can train as one.” The walk‑run method is that becoming.', sw: 'Each week, you’ll shift the ratio. Week 2: jog 2 min, walk 1 min. Week 3: jog 3 min, walk 1 min. By week 5, you’ll be running 5‑minute segments and walking only 1 minute between them. The goal by week 8 is to string together a full 30‑minute run without walking. This method respects your body’s need to adapt—tendons, ligaments, and bones strengthen much more slowly than your heart and lungs. Kenyan coaches often say, “You have to become a runner before you can train as one.” The walk‑run method is that becoming.'),
          (en: 'Hills are part of Kenyan life. If your route is undulating, walk the uphills and run the downhills until you’re stronger. Always listen to your breath: you should be able to speak in short sentences. If you’re gasping, slow your jog to a shuffle. Progress will feel slow, but in two months you’ll be amazed. You’ve built a foundation of 90 minutes of weekly movement—enough to transform your health and ready you for the 5K plan ahead.', sw: 'Hills are part of Kenyan life. If your route is undulating, walk the uphills and run the downhills until you’re stronger. Always listen to your breath: you should be able to speak in short sentences. If you’re gasping, slow your jog to a shuffle. Progress will feel slow, but in two months you’ll be amazed. You’ve built a foundation of 90 minutes of weekly movement—enough to transform your health and ready you for the 5K plan ahead.'),
        ],
      ),
      Lesson(
        title: (en: 'Warming Up & Cooling Down', sw: 'Kuanza na Kumalizia'),
        minutes: 4,
        summary: (en: '5‑min brisk walk + dynamic swings, post‑run stretching.', sw: 'Linda mwili wako kabla na baada.'),
        paragraphs: [
          (en: 'A warm‑up is not a few half‑hearted toe touches. It’s a deliberate sequence that raises your heart rate, lubricates joints, and prepares your nervous system for the task. Start with 5 minutes of brisk walking or very light jogging—just enough to break a light sweat. Then perform dynamic mobility exercises: leg swings forward and sideways (10 each leg), walking lunges with a torso twist (8 per side), hip circles, and arm swings. These movements open the hips and shoulders, activate your glutes, and signal to your body that it’s time to run. Kenyan athletes in Kaptagat do a series of drills called “A‑skips” and “B‑skips” to prime the running motion; you don’t need to copy them exactly, but the principle is the same: move before you move.', sw: 'A warm‑up is not a few half‑hearted toe touches. It’s a deliberate sequence that raises your heart rate, lubricates joints, and prepares your nervous system for the task. Start with 5 minutes of brisk walking or very light jogging—just enough to break a light sweat. Then perform dynamic mobility exercises: leg swings forward and sideways (10 each leg), walking lunges with a torso twist (8 per side), hip circles, and arm swings. These movements open the hips and shoulders, activate your glutes, and signal to your body that it’s time to run. Kenyan athletes in Kaptagat do a series of drills called “A‑skips” and “B‑skips” to prime the running motion; you don’t need to copy them exactly, but the principle is the same: move before you move.'),
          (en: 'After your run, resist the urge to collapse onto the couch. A cool‑down brings your heart rate back to normal gradually, preventing blood pooling in your legs. Walk for 5 minutes until your breathing steadies. Then, while muscles are warm, stretch the major running groups: quadriceps, hamstrings, calves, hip flexors, and lower back. Hold each stretch for 20–30 seconds without bouncing. This improves flexibility and may reduce next‑day soreness. In Kenya, post‑run group stretching is a social ritual—runners form a circle, chat, and share a laugh as they touch their toes. Make your cool‑down equally sacred. It’s your body’s way of saying “thank you” after the effort.', sw: 'After your run, resist the urge to collapse onto the couch. A cool‑down brings your heart rate back to normal gradually, preventing blood pooling in your legs. Walk for 5 minutes until your breathing steadies. Then, while muscles are warm, stretch the major running groups: quadriceps, hamstrings, calves, hip flexors, and lower back. Hold each stretch for 20–30 seconds without bouncing. This improves flexibility and may reduce next‑day soreness. In Kenya, post‑run group stretching is a social ritual—runners form a circle, chat, and share a laugh as they touch their toes. Make your cool‑down equally sacred. It’s your body’s way of saying “thank you” after the effort.'),
        ],
      ),
      Lesson(
        title: (en: 'Your First 5K Plan', sw: 'Mpango Wako wa 5K wa Kwanza'),
        minutes: 6,
        summary: (en: '3×/week structure, 8‑week goal race.', sw: 'Njia ya wiki nane kuelekea kilomita 5.'),
        paragraphs: [
          (en: 'A 5K race—just 5 kilometres—is the perfect first goal. It’s long enough to feel like an achievement, short enough to train for safely. This plan assumes you’ve completed the walk‑run progression and can run 20 minutes continuously. You’ll run three days a week: one easy day, one day of short intervals, and one longer day.', sw: 'A 5K race—just 5 kilometres—is the perfect first goal. It’s long enough to feel like an achievement, short enough to train for safely. This plan assumes you’ve completed the walk‑run progression and can run 20 minutes continuously. You’ll run three days a week: one easy day, one day of short intervals, and one longer day.'),
          (en: '**Week 1–2:** Easy run 20 min; interval day: 4 × 2 min at a “comfortably hard” effort with 2 min walk/jog recovery; long run 25 min at an easy pace.', sw: '**Week 1–2:** Easy run 20 min; interval day: 4 × 2 min at a “comfortably hard” effort with 2 min walk/jog recovery; long run 25 min at an easy pace.'),
          (en: '**Week 3–4:** Easy run 25 min; intervals: 5 × 3 min; long run 30 min.', sw: '**Week 3–4:** Easy run 25 min; intervals: 5 × 3 min; long run 30 min.'),
          (en: '**Week 5–6:** Easy run 30 min; intervals: 4 × 4 min; long run 35 min, including the last 5 min at a “race effort” to practise finishing strong.', sw: '**Week 5–6:** Easy run 30 min; intervals: 4 × 4 min; long run 35 min, including the last 5 min at a “race effort” to practise finishing strong.'),
          (en: '**Week 7:** Easy run 25 min; intervals: 3 × 5 min; long run 30 min. This is a lighter week to absorb training.', sw: '**Week 7:** Easy run 25 min; intervals: 3 × 5 min; long run 30 min. This is a lighter week to absorb training.'),
          (en: '**Week 8 (Race week):** On Tuesday, jog 15 min with 3 × 1 min at race pace. Rest Thursday. Race on Saturday or Sunday.', sw: '**Week 8 (Race week):** On Tuesday, jog 15 min with 3 × 1 min at race pace. Rest Thursday. Race on Saturday or Sunday.'),
          (en: 'The key is pacing: start slower than you think, and if you feel good at the 3‑km mark, pick it up. Kenyan runners often say the race begins at the 4‑km mark; everything before is just positioning. Choose a local event—perhaps a weekend fun run in Nairobi’s Uhuru Park—and enjoy the atmosphere. Your goal is simply to finish with a smile.', sw: 'The key is pacing: start slower than you think, and if you feel good at the 3‑km mark, pick it up. Kenyan runners often say the race begins at the 4‑km mark; everything before is just positioning. Choose a local event—perhaps a weekend fun run in Nairobi’s Uhuru Park—and enjoy the atmosphere. Your goal is simply to finish with a smile.'),
        ],
      ),
      Lesson(
        title: (en: 'Staying Motivated', sw: 'Kudumisha Msisimko'),
        minutes: 4,
        summary: (en: 'Habit over motivation, kit prep, Mwendo streak.', sw: 'Tabia zinazodumu msimu wa mvua.'),
        paragraphs: [
          (en: 'Motivation is a fleeting guest; habit is the house you build. The secret to sticking with running is making it automatic. Lay out your running clothes the night before—shoes by the door, water bottle filled. When the alarm rings, you only have to stand up, dress, and step outside. This “friction‑less” start is how the world’s most consistent runners operate. Kenyan athletes often rise before dawn, not because they’re always motivated, but because the routine is baked into their community. If you struggle to go alone, join a running group or recruit a friend. The promise of company is a powerful alarm clock.', sw: 'Motivation is a fleeting guest; habit is the house you build. The secret to sticking with running is making it automatic. Lay out your running clothes the night before—shoes by the door, water bottle filled. When the alarm rings, you only have to stand up, dress, and step outside. This “friction‑less” start is how the world’s most consistent runners operate. Kenyan athletes often rise before dawn, not because they’re always motivated, but because the routine is baked into their community. If you struggle to go alone, join a running group or recruit a friend. The promise of company is a powerful alarm clock.'),
          (en: 'Set a 30‑day “Mwendo Streak”—a commitment to run (or walk‑run) at least 10 minutes every single day. The distance doesn’t matter; the daily check‑mark does. In the M‑Run app, your streak counter becomes a source of pride. After 30 days, you’ve built a neural pathway that says “I am a runner.” When motivation dips, remember your “why”: maybe it’s to keep up with your children, to manage stress, or to feel strong in your own body. Write it down and place it where you’ll see it. Finally, celebrate small wins—a new personal best in the 5K, or simply a week where you never missed a session. Those tiny victories fuel the next one. Run for life, not just for a race.', sw: 'Set a 30‑day “Mwendo Streak”—a commitment to run (or walk‑run) at least 10 minutes every single day. The distance doesn’t matter; the daily check‑mark does. In the M‑Run app, your streak counter becomes a source of pride. After 30 days, you’ve built a neural pathway that says “I am a runner.” When motivation dips, remember your “why”: maybe it’s to keep up with your children, to manage stress, or to feel strong in your own body. Write it down and place it where you’ll see it. Finally, celebrate small wins—a new personal best in the 5K, or simply a week where you never missed a session. Those tiny victories fuel the next one. Run for life, not just for a race.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'heart-rate-zones',
    title: (en: 'Heart Rate Zones', sw: 'Maeneo ya Mapigo ya Moyo'),
    subtitle: (en: 'Train smarter by listening to your pulse.', sw: 'Fanya mazoezi kwa busara kwa kusikiliza mapigo yako.'),
    category: CourseCategory.science,
    author: (en: 'Dr. A. Were', sw: 'Daktari A. Were'),
    lessons: [
      Lesson(
        title: (en: 'The Five Zones', sw: 'Maeneo Matano'),
        minutes: 5,
        summary: (en: 'Zone definitions, Kenyan “easy days easy” philosophy.', sw: 'Kile kila kiwango cha nguvu kinakufanyia.'),
        paragraphs: [
          (en: 'Heart‑rate training divides your cardiovascular effort into five zones, each representing a percentage of your maximum heart rate (HRmax). Zone 1 (50‑60% HRmax) is active recovery—walking or very light jogging. Zone 2 (60‑70%) is the “conversational” pace where you build aerobic endurance and burn fat efficiently. Zone 3 (70‑80%) sits in the grey area—moderately hard but not truly challenging; it’s often called “junk miles” because it adds fatigue without the specific adaptations of higher zones. Zone 4 (80‑90%) is the tempo zone, right at or just below your lactate threshold, where your breathing deepens but you can sustain the effort for 30‑60 minutes. Zone 5 (90‑100%) is maximal effort—intervals, hill sprints, and finishing kicks—where you can speak only a word or two.', sw: 'Heart‑rate training divides your cardiovascular effort into five zones, each representing a percentage of your maximum heart rate (HRmax). Zone 1 (50‑60% HRmax) is active recovery—walking or very light jogging. Zone 2 (60‑70%) is the “conversational” pace where you build aerobic endurance and burn fat efficiently. Zone 3 (70‑80%) sits in the grey area—moderately hard but not truly challenging; it’s often called “junk miles” because it adds fatigue without the specific adaptations of higher zones. Zone 4 (80‑90%) is the tempo zone, right at or just below your lactate threshold, where your breathing deepens but you can sustain the effort for 30‑60 minutes. Zone 5 (90‑100%) is maximal effort—intervals, hill sprints, and finishing kicks—where you can speak only a word or two.'),
          (en: 'In the Kenyan training tradition, the mantra “easy days easy, hard days hard” maps perfectly onto these zones. Athletes spend up to 80% of their mileage in Zones 1 and 2—gentle runs on the red dirt of Iten, chatting in Swahili. The remaining 20% is brutally hard: fartlek Thursdays in Zone 4–5, or hill repeats on the Kaptagat slopes. This polarised approach builds a massive aerobic engine without burning out. For recreational runners, mimicking this distribution prevents overtraining and unlocks sustainable progress.', sw: 'In the Kenyan training tradition, the mantra “easy days easy, hard days hard” maps perfectly onto these zones. Athletes spend up to 80% of their mileage in Zones 1 and 2—gentle runs on the red dirt of Iten, chatting in Swahili. The remaining 20% is brutally hard: fartlek Thursdays in Zone 4–5, or hill repeats on the Kaptagat slopes. This polarised approach builds a massive aerobic engine without burning out. For recreational runners, mimicking this distribution prevents overtraining and unlocks sustainable progress.'),
        ],
      ),
      Lesson(
        title: (en: 'Finding Your Max', sw: 'Kupata Upeo Wako'),
        minutes: 4,
        summary: (en: '220‑age formula, talk test, fitness tracking over time.', sw: 'Mfumo wa 220-umri na juhudi inayohisiwa.'),
        paragraphs: [
          (en: 'You need a reliable HRmax to set your zones. The simple formula “220 minus your age” gives a population average but can be off by 10–15 beats for individuals. A more accurate field test: warm up for 15 minutes, then run a 3‑minute uphill sprint as hard as you can, jog back down, and repeat twice more. The highest number you see on your monitor during that third sprint is close to your true max. Do this only if you’re cleared for intense exercise. Alternatively, the “talk test” serves as a no‑gadget guide. In Zone 2, you can speak full sentences comfortably. In Zone 3, sentences shorten. In Zone 4, you’re pushing out 3‑5 words. In Zone 5, grunts replace words.', sw: 'You need a reliable HRmax to set your zones. The simple formula “220 minus your age” gives a population average but can be off by 10–15 beats for individuals. A more accurate field test: warm up for 15 minutes, then run a 3‑minute uphill sprint as hard as you can, jog back down, and repeat twice more. The highest number you see on your monitor during that third sprint is close to your true max. Do this only if you’re cleared for intense exercise. Alternatively, the “talk test” serves as a no‑gadget guide. In Zone 2, you can speak full sentences comfortably. In Zone 3, sentences shorten. In Zone 4, you’re pushing out 3‑5 words. In Zone 5, grunts replace words.'),
          (en: 'Once you have a max, calculate your resting heart rate (RHR) by measuring it first thing in the morning before getting up. As you get fitter, RHR drops, and your heart can achieve more work per beat. Record these numbers monthly in the M‑Run app. Watching your RHR fall from 70 to 60 beats per minute over eight weeks is a tangible sign that your heart is growing stronger—a physiological medal more meaningful than any race time.', sw: 'Once you have a max, calculate your resting heart rate (RHR) by measuring it first thing in the morning before getting up. As you get fitter, RHR drops, and your heart can achieve more work per beat. Record these numbers monthly in the M‑Run app. Watching your RHR fall from 70 to 60 beats per minute over eight weeks is a tangible sign that your heart is growing stronger—a physiological medal more meaningful than any race time.'),
        ],
      ),
      Lesson(
        title: (en: 'Zone 2 Deep Dive', sw: 'Kuzama Kwenye Eneo la 2'),
        minutes: 5,
        summary: (en: 'Why easy runs are the foundation, how to pace yourself for your level.', sw: 'Kwa nini mbio rahisi ndio msingi.'),
        paragraphs: [
          (en: 'Zone 2 is not a jog of shame; it’s the cornerstone of endurance. At this intensity, your body builds mitochondria—the energy factories inside your muscle cells—and improves capillary density, allowing more oxygen delivery. The adaptation is slow but profound. The catch: most recreational runners run their easy days in Zone 3 because Zone 2 feels too slow. You must leave your ego at the door. On flat ground, a beginner’s Zone 2 pace might be a brisk walk or a 9‑min/km jog. That’s fine. Use the talk test religiously or set a heart‑rate alarm on your watch to beep whenever you creep above 70% HRmax.', sw: 'Zone 2 is not a jog of shame; it’s the cornerstone of endurance. At this intensity, your body builds mitochondria—the energy factories inside your muscle cells—and improves capillary density, allowing more oxygen delivery. The adaptation is slow but profound. The catch: most recreational runners run their easy days in Zone 3 because Zone 2 feels too slow. You must leave your ego at the door. On flat ground, a beginner’s Zone 2 pace might be a brisk walk or a 9‑min/km jog. That’s fine. Use the talk test religiously or set a heart‑rate alarm on your watch to beep whenever you creep above 70% HRmax.'),
          (en: 'A practical session: after a 10‑minute warm‑up, run 30‑45 minutes strictly below your Zone 2 ceiling. If you live in a hilly area like Ngong, walk the steep sections to keep your heart rate down. Over weeks, you’ll notice that the same heart rate yields a faster pace—that’s the aerobic engine improving. Kenyan champions credit their longevity to years of patient base building. Eliud Kipchoge reportedly runs many of his morning sessions at a serene 4:30–5:00 min/km, which for him is deep Zone 2. Imitate the principle, not the pace.', sw: 'A practical session: after a 10‑minute warm‑up, run 30‑45 minutes strictly below your Zone 2 ceiling. If you live in a hilly area like Ngong, walk the steep sections to keep your heart rate down. Over weeks, you’ll notice that the same heart rate yields a faster pace—that’s the aerobic engine improving. Kenyan champions credit their longevity to years of patient base building. Eliud Kipchoge reportedly runs many of his morning sessions at a serene 4:30–5:00 min/km, which for him is deep Zone 2. Imitate the principle, not the pace.'),
        ],
      ),
      Lesson(
        title: (en: 'Using a Watch vs. Feel', sw: 'Kutumia Saa dhidi ya Hisia'),
        minutes: 4,
        summary: (en: 'Wrist‑based monitors, chest straps, and perceived exertion (RPE).', sw: 'Kupima kiwango cha juhudi yako.'),
        paragraphs: [
          (en: 'Wrist‑based optical heart‑rate sensors are convenient but can lag during sudden surges or give erratic readings in cold weather. A chest strap provides near‑instantaneous, electrocardiogram‑accurate data and is worth the investment if you plan to train seriously by zones. Whichever tool you use, pair it with the Rating of Perceived Exertion (RPE) scale from 1 to 10. Zone 1: RPE 2‑3; Zone 2: 4‑5; Zone 3: 5‑6; Zone 4: 7‑8; Zone 5: 9‑10. Learn to gauge your effort without glancing at your wrist; on a hilly trail, looking at your watch can be hazardous, and in a race, adrenaline can skew your perception. The Kenyan approach relies heavily on feel—coaches like Patrick Sang often prescribe effort levels (“conversational”, “strong”, “fast”) rather than precise beats.', sw: 'Wrist‑based optical heart‑rate sensors are convenient but can lag during sudden surges or give erratic readings in cold weather. A chest strap provides near‑instantaneous, electrocardiogram‑accurate data and is worth the investment if you plan to train seriously by zones. Whichever tool you use, pair it with the Rating of Perceived Exertion (RPE) scale from 1 to 10. Zone 1: RPE 2‑3; Zone 2: 4‑5; Zone 3: 5‑6; Zone 4: 7‑8; Zone 5: 9‑10. Learn to gauge your effort without glancing at your wrist; on a hilly trail, looking at your watch can be hazardous, and in a race, adrenaline can skew your perception. The Kenyan approach relies heavily on feel—coaches like Patrick Sang often prescribe effort levels (“conversational”, “strong”, “fast”) rather than precise beats.'),
          (en: 'During a session, check the watch periodically to calibrate your sense of exertion. If your heart rate is 150 bpm but you feel like a 7 out of 10 on RPE, you may be dehydrated or accumulating fatigue—reasons to cut the session short. Technology is a servant, not a master. Use it to learn, then trust your body.', sw: 'During a session, check the watch periodically to calibrate your sense of exertion. If your heart rate is 150 bpm but you feel like a 7 out of 10 on RPE, you may be dehydrated or accumulating fatigue—reasons to cut the session short. Technology is a servant, not a master. Use it to learn, then trust your body.'),
        ],
      ),
      Lesson(
        title: (en: 'Lactate Threshold & Tempo', sw: 'Kizingiti cha Lactate na Tempo'),
        minutes: 5,
        summary: (en: 'What lactate threshold is, how tempo runs improve it.', sw: 'Jinsi mbio za tempo zinavyoongeza kikomo chako.'),
        paragraphs: [
          (en: 'Lactate threshold (LT) is the exercise intensity at which lactate builds up in the blood faster than the body can clear it. It’s the tipping point where burning legs and heavy breathing become unsustainable. For well‑trained runners, LT occurs around 85‑90% HRmax—the upper end of Zone 4. Raising your LT means you can run faster before hitting that wall. The best tool to do so is the tempo run: a sustained effort of 20‑40 minutes at a “comfortably hard” pace, just below the point where speech is reduced to single words. Kenyan runners often do continuous tempo runs on Thursday mornings or extended fartlek blocks that hover around LT.', sw: 'Lactate threshold (LT) is the exercise intensity at which lactate builds up in the blood faster than the body can clear it. It’s the tipping point where burning legs and heavy breathing become unsustainable. For well‑trained runners, LT occurs around 85‑90% HRmax—the upper end of Zone 4. Raising your LT means you can run faster before hitting that wall. The best tool to do so is the tempo run: a sustained effort of 20‑40 minutes at a “comfortably hard” pace, just below the point where speech is reduced to single words. Kenyan runners often do continuous tempo runs on Thursday mornings or extended fartlek blocks that hover around LT.'),
          (en: 'A classic session: 3 km warm‑up, then 20 minutes at tempo effort, followed by 2 km cool‑down. The pace should feel like a 7 or 8 out of 10. Over a few months, you can extend the tempo segment to 40 minutes. The adaptation is twofold: your slow‑twitch muscle fibres become more efficient at using oxygen, and your body gets better at recycling lactate as fuel. A higher LT is one of the strongest predictors of distance‑running performance. It’s the physiological reason why a 40‑minute 10K runner can suddenly run 37 minutes after a dedicated tempo block.', sw: 'A classic session: 3 km warm‑up, then 20 minutes at tempo effort, followed by 2 km cool‑down. The pace should feel like a 7 or 8 out of 10. Over a few months, you can extend the tempo segment to 40 minutes. The adaptation is twofold: your slow‑twitch muscle fibres become more efficient at using oxygen, and your body gets better at recycling lactate as fuel. A higher LT is one of the strongest predictors of distance‑running performance. It’s the physiological reason why a 40‑minute 10K runner can suddenly run 37 minutes after a dedicated tempo block.'),
        ],
      ),
      Lesson(
        title: (en: 'Building Your Week', sw: 'Kujenga Wiki Yako'),
        minutes: 4,
        summary: (en: 'Polarised training schedule across zones for recreational runners.', sw: 'Ratiba ya mazoezi yaliyotawanyika katika maeneo.'),
        paragraphs: [
          (en: 'A week that touches all zones ensures comprehensive development. Here’s a template for a runner aiming for a 10K:', sw: 'A week that touches all zones ensures comprehensive development. Here’s a template for a runner aiming for a 10K:'),
          (en: '- **Monday:** Rest or Zone 1 active recovery (30‑min walk).', sw: '- **Monday:** Rest or Zone 1 active recovery (30‑min walk).'),
          (en: '- **Tuesday:** Zone 2 easy run (40‑60 min).', sw: '- **Tuesday:** Zone 2 easy run (40‑60 min).'),
          (en: '- **Wednesday:** Zone 4/5 intervals (e.g., 6 × 3 min at 5K pace with 2‑min jog recoveries).', sw: '- **Wednesday:** Zone 4/5 intervals (e.g., 6 × 3 min at 5K pace with 2‑min jog recoveries).'),
          (en: '- **Thursday:** Zone 2 easy run (30‑40 min) or cross‑training.', sw: '- **Thursday:** Zone 2 easy run (30‑40 min) or cross‑training.'),
          (en: '- **Friday:** Zone 2 easy run with 4 × 15‑second hill sprints (Zone 5) to recruit fast‑twitch fibres.', sw: '- **Friday:** Zone 2 easy run with 4 × 15‑second hill sprints (Zone 5) to recruit fast‑twitch fibres.'),
          (en: '- **Saturday:** Long run in Zone 2, building up to 90 minutes.', sw: '- **Saturday:** Long run in Zone 2, building up to 90 minutes.'),
          (en: '- **Sunday:** Rest or light yoga.', sw: '- **Sunday:** Rest or light yoga.'),
          (en: 'Notice that only two days are hard. This 80/20 polarised split mirrors the Kenyan model: the easy days repair and build, the hard days sharpen. Listen to your body: if you’re feeling run‑down, swap Wednesday’s intervals for an extra Zone 2 run. Consistency trumps intensity. Use the M‑Run app to log which zone you actually spent time in, and gradually increase total weekly volume by no more than 10%.', sw: 'Notice that only two days are hard. This 80/20 polarised split mirrors the Kenyan model: the easy days repair and build, the hard days sharpen. Listen to your body: if you’re feeling run‑down, swap Wednesday’s intervals for an extra Zone 2 run. Consistency trumps intensity. Use the M‑Run app to log which zone you actually spent time in, and gradually increase total weekly volume by no more than 10%.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'running-form',
    title: (en: 'Effortless Running Form', sw: 'Sura ya Kupendeza ya Mbio'),
    subtitle: (en: 'Posture, cadence and foot strike.', sw: 'Mwinuko, kadensi na mguso wa mguu.'),
    category: CourseCategory.technique,
    author: (en: 'Mwendo Coaches', sw: 'Wakocha wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Posture & Relaxation', sw: 'Mwinuko na Kulegea'),
        minutes: 4,
        summary: (en: 'Forward lean, soft knee, tension check.', sw: 'Kimbia wima, legeza mabega.'),
        paragraphs: [
          (en: 'Imagine a string pulling you from the crown of your head toward the sky. Your chin is level, eyes gazing 20‑30 metres ahead, not down at your feet. Shoulders are low and relaxed, not hunched around your ears. A slight whole‑body forward lean comes from the ankles, not a bend at the waist—like a ski jumper in suspension. This lean harnesses gravity to propel you forward, reducing the muscular effort needed to push off. Your knees should be soft upon landing, never locked straight; think of catching the ground and springing off it lightly.', sw: 'Imagine a string pulling you from the crown of your head toward the sky. Your chin is level, eyes gazing 20‑30 metres ahead, not down at your feet. Shoulders are low and relaxed, not hunched around your ears. A slight whole‑body forward lean comes from the ankles, not a bend at the waist—like a ski jumper in suspension. This lean harnesses gravity to propel you forward, reducing the muscular effort needed to push off. Your knees should be soft upon landing, never locked straight; think of catching the ground and springing off it lightly.'),
          (en: 'Check tension every kilometre: are you clenching your fists? Hold a potato chip between thumb and forefinger—firm enough not to drop it, light enough not to crush it. Is your jaw tight? Wiggle it loose. Frowning wastes energy. Kenyan runners are famed for their serene expressions even at high speed. Kipchoge’s smile mid‑marathon isn’t just for show; it signals total relaxation. Practise “body scans” during easy runs: from scalp to toes, consciously release any tightness. A relaxed runner is an efficient runner.', sw: 'Check tension every kilometre: are you clenching your fists? Hold a potato chip between thumb and forefinger—firm enough not to drop it, light enough not to crush it. Is your jaw tight? Wiggle it loose. Frowning wastes energy. Kenyan runners are famed for their serene expressions even at high speed. Kipchoge’s smile mid‑marathon isn’t just for show; it signals total relaxation. Practise “body scans” during easy runs: from scalp to toes, consciously release any tightness. A relaxed runner is an efficient runner.'),
        ],
      ),
      Lesson(
        title: (en: 'Cadence & Stride', sw: 'Kadensi na Hatua'),
        minutes: 5,
        summary: (en: '170–180 steps per minute, don’t force it.', sw: 'Kwa nini hatua ~180 kwa dakika ni muhimu.'),
        paragraphs: [
          (en: 'Cadence is the number of steps you take per minute. Elite distance runners typically fall between 170 and 180 steps per minute regardless of pace—they simply shorten or lengthen their stride to change speed. A lower cadence often means you’re over‑striding, landing with your foot far in front of your centre of mass, which acts like a brake on every step. Count your left‑foot strikes for 30 seconds and multiply by four. If you’re below 160, you likely over‑stride.', sw: 'Cadence is the number of steps you take per minute. Elite distance runners typically fall between 170 and 180 steps per minute regardless of pace—they simply shorten or lengthen their stride to change speed. A lower cadence often means you’re over‑striding, landing with your foot far in front of your centre of mass, which acts like a brake on every step. Count your left‑foot strikes for 30 seconds and multiply by four. If you’re below 160, you likely over‑stride.'),
          (en: 'Don’t artificially leap to 180 overnight—that risks calf strain. Instead, increase by 5‑10 steps per minute and hold the new rhythm for a few weeks. Use a metronome app or a playlist with songs at that BPM. As cadence rises, your stride will naturally shorten, and your foot will land closer to your body, reducing impact. The sensation is akin to “running on eggshells.” Kenyan children grow up running to and from school, often barefoot, which naturally encourages a quick, light cadence. Aim for quiet, scuff‑free footfalls. The less noise you make, the more gracefully you’re moving.', sw: 'Don’t artificially leap to 180 overnight—that risks calf strain. Instead, increase by 5‑10 steps per minute and hold the new rhythm for a few weeks. Use a metronome app or a playlist with songs at that BPM. As cadence rises, your stride will naturally shorten, and your foot will land closer to your body, reducing impact. The sensation is akin to “running on eggshells.” Kenyan children grow up running to and from school, often barefoot, which naturally encourages a quick, light cadence. Aim for quiet, scuff‑free footfalls. The less noise you make, the more gracefully you’re moving.'),
        ],
      ),
      Lesson(
        title: (en: 'Arm Drive & Upper Body', sw: 'Msukumo wa Mikono na Mwili wa Juu'),
        minutes: 4,
        summary: (en: 'Efficient arm swing to balance and propel.', sw: 'Kuswingi kwa mikono kwa ufanisi kusawazisha na kusukuma.'),
        paragraphs: [
          (en: 'Your arms are not passengers; they counterbalance the powerful forces generated by your legs. Bend your elbows at roughly 90 degrees and swing them from the shoulder joint, not the elbow. The motion is forward and backward, not across your chest—imagine wiping a table at hip height. Your hands should move from “hip to lip”: near the pocket of your shorts on the backswing to around chest height in front. A cross‑body swing rotates your torso and wastes energy.', sw: 'Your arms are not passengers; they counterbalance the powerful forces generated by your legs. Bend your elbows at roughly 90 degrees and swing them from the shoulder joint, not the elbow. The motion is forward and backward, not across your chest—imagine wiping a table at hip height. Your hands should move from “hip to lip”: near the pocket of your shorts on the backswing to around chest height in front. A cross‑body swing rotates your torso and wastes energy.'),
          (en: 'Coordinate arm tempo with your stride: faster arms cue faster legs. If you feel yourself flagging, focus on pumping your arms a little quicker; your legs will follow like obedient dance partners. Relaxed hands are key. Avoid tight fists; imagine you’re holding a delicate egg in each palm. On uphills, exaggerate the arm swing slightly to help drive your knees up. On downhills, let your arms drop a little lower to control balance. Video yourself running for a few seconds—many runners are surprised to see a chicken‑wing flail they never felt. Fixing the arms instantly cleans up the whole kinetic chain.', sw: 'Coordinate arm tempo with your stride: faster arms cue faster legs. If you feel yourself flagging, focus on pumping your arms a little quicker; your legs will follow like obedient dance partners. Relaxed hands are key. Avoid tight fists; imagine you’re holding a delicate egg in each palm. On uphills, exaggerate the arm swing slightly to help drive your knees up. On downhills, let your arms drop a little lower to control balance. Video yourself running for a few seconds—many runners are surprised to see a chicken‑wing flail they never felt. Fixing the arms instantly cleans up the whole kinetic chain.'),
        ],
      ),
      Lesson(
        title: (en: 'Breathing Rhythm & Cadence Syncing', sw: 'Breathing Rhythm & Cadence Syncing'),
        minutes: 4,
        summary: (en: 'Diaphragmatic breathing and step‑matched patterns.', sw: 'Diaphragmatic breathing and step‑matched patterns.'),
        paragraphs: [
          (en: 'Shallow chest breathing limits oxygen intake and creates side stitches. Breathe deep into your belly, expanding your diaphragm. A common rhythmic pattern is 2‑to‑2: inhale for two steps, exhale for two steps. During harder efforts, shift to 2‑to‑1 or even 1‑to‑1. The rhythm prevents frantic panting and paces your effort. Many Kenyan runners unconsciously sync their breath to their cadence, creating a meditative, almost hypnotic state that helps them chew through kilometres.', sw: 'Shallow chest breathing limits oxygen intake and creates side stitches. Breathe deep into your belly, expanding your diaphragm. A common rhythmic pattern is 2‑to‑2: inhale for two steps, exhale for two steps. During harder efforts, shift to 2‑to‑1 or even 1‑to‑1. The rhythm prevents frantic panting and paces your effort. Many Kenyan runners unconsciously sync their breath to their cadence, creating a meditative, almost hypnotic state that helps them chew through kilometres.'),
          (en: 'Practice belly breathing off the run first: lie on your back, place a hand on your stomach, and make it rise and fall without moving your chest. Once comfortable, integrate it during easy runs. If you get a stitch, slow down and forcefully exhale when the foot opposite the stitch hits the ground. The rhythmic pressure change can release the cramp. Over time, your breathing becomes a metronome that locks you into an efficient, steady effort.', sw: 'Practice belly breathing off the run first: lie on your back, place a hand on your stomach, and make it rise and fall without moving your chest. Once comfortable, integrate it during easy runs. If you get a stitch, slow down and forcefully exhale when the foot opposite the stitch hits the ground. The rhythmic pressure change can release the cramp. Over time, your breathing becomes a metronome that locks you into an efficient, steady effort.'),
        ],
      ),
      Lesson(
        title: (en: 'Foot‑Strike: Heel, Midfoot, Forefoot', sw: 'Foot‑Strike: Heel, Midfoot, Forefoot'),
        minutes: 4,
        summary: (en: 'Understanding strike types and ground contact time.', sw: 'Understanding strike types and ground contact time.'),
        paragraphs: [
          (en: 'There are three general foot‑strike patterns: heel‑strike (rearfoot), midfoot, and forefoot. Heel‑striking often occurs when runners over‑stride, sending a sharp impact shock up the leg. It’s not inherently evil—many amateur runners heel‑strike without injury—but it’s associated with higher braking and loading rates. A midfoot strike lands under the hips, engaging the arch’s natural spring, while a pure forefoot strike (landing on the ball of the foot) is common in sprinters and elite Kenyans running at high speeds.', sw: 'There are three general foot‑strike patterns: heel‑strike (rearfoot), midfoot, and forefoot. Heel‑striking often occurs when runners over‑stride, sending a sharp impact shock up the leg. It’s not inherently evil—many amateur runners heel‑strike without injury—but it’s associated with higher braking and loading rates. A midfoot strike lands under the hips, engaging the arch’s natural spring, while a pure forefoot strike (landing on the ball of the foot) is common in sprinters and elite Kenyans running at high speeds.'),
          (en: 'Rather than consciously forcing a midfoot landing, focus on a quick cadence and landing softly with your foot beneath your knee. That usually produces a midfoot or gentle heel‑first strike. Barefoot strides on grass once a week can heighten your awareness of how your foot interacts with the ground. Aim to minimise ground contact time—imagine the ground is hot coals. Plyometric exercises like jump rope and hopping drills also condition the lower legs for a springy, responsive stride.', sw: 'Rather than consciously forcing a midfoot landing, focus on a quick cadence and landing softly with your foot beneath your knee. That usually produces a midfoot or gentle heel‑first strike. Barefoot strides on grass once a week can heighten your awareness of how your foot interacts with the ground. Aim to minimise ground contact time—imagine the ground is hot coals. Plyometric exercises like jump rope and hopping drills also condition the lower legs for a springy, responsive stride.'),
        ],
      ),
      Lesson(
        title: (en: 'Hill Running Form', sw: 'Sura ya Kukimbia Milimani'),
        minutes: 4,
        summary: (en: 'Techniques for climbing and descending efficiently.', sw: 'Kupanda na kushuka kwa ufanisi.'),
        paragraphs: [
          (en: 'Uphill: shorten your stride, increase your cadence, and lean slightly into the hill from the ankles—not the waist. Drive your arms a bit more vigorously, pumping from the shoulders. Keep your eyes fixed on the crest, not your feet. The effort should feel like you’re pushing the ground away. In Kenya’s undulating terrain, runners learn to “float” over hills by maintaining effort, not pace.', sw: 'Uphill: shorten your stride, increase your cadence, and lean slightly into the hill from the ankles—not the waist. Drive your arms a bit more vigorously, pumping from the shoulders. Keep your eyes fixed on the crest, not your feet. The effort should feel like you’re pushing the ground away. In Kenya’s undulating terrain, runners learn to “float” over hills by maintaining effort, not pace.'),
          (en: 'Downhill: lean forward slightly from the ankles, let gravity do the work, and keep your cadence high with light, quick steps to avoid braking. Don’t lean back—that jams your heels and quads. Imagine you’re cycling downhill; you’d stay centred over the pedals. Practise downhill strides on a gentle slope to build eccentric quadriceps strength safely. Races are won and lost on hills; mastering form turns them from enemies into allies.', sw: 'Downhill: lean forward slightly from the ankles, let gravity do the work, and keep your cadence high with light, quick steps to avoid braking. Don’t lean back—that jams your heels and quads. Imagine you’re cycling downhill; you’d stay centred over the pedals. Practise downhill strides on a gentle slope to build eccentric quadriceps strength safely. Races are won and lost on hills; mastering form turns them from enemies into allies.'),
        ],
      ),
      Lesson(
        title: (en: 'Fatigue‑Proofing Your Form', sw: 'Fatigue‑Proofing Your Form'),
        minutes: 3,
        summary: (en: 'Recognising and correcting late‑run breakdown.', sw: 'Recognising and correcting late‑run breakdown.'),
        paragraphs: [
          (en: 'When tired, runners typically slump forward, cross their arms, shuffle, and over‑stride. The fix begins with awareness. Film yourself at the end of a long run and compare it to the start. In the final kilometres, do a “form check” every few minutes: head up, shoulders back, arms straight, cadence quick. Simple cues like “run tall” can reset your posture. Include strength training—planks, deadlifts, and core work—to build the muscular endurance that holds form together when you’re fatigued. Kenyan runners do daily core routines, often just 10 minutes of body‑weight exercises, to ensure that when legs burn, the trunk stays solid. The finish‑line photo should look as elegant as the starting line.', sw: 'When tired, runners typically slump forward, cross their arms, shuffle, and over‑stride. The fix begins with awareness. Film yourself at the end of a long run and compare it to the start. In the final kilometres, do a “form check” every few minutes: head up, shoulders back, arms straight, cadence quick. Simple cues like “run tall” can reset your posture. Include strength training—planks, deadlifts, and core work—to build the muscular endurance that holds form together when you’re fatigued. Kenyan runners do daily core routines, often just 10 minutes of body‑weight exercises, to ensure that when legs burn, the trunk stays solid. The finish‑line photo should look as elegant as the starting line.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'nutrition-for-runners',
    title: (en: 'Fuel for the Run', sw: 'Lishe ya Mbio'),
    subtitle: (en: 'Eat like a champion, the Kenyan way.', sw: 'Kula kama bingwa, kwa mtindo wa Kenya.'),
    category: CourseCategory.health,
    author: (en: 'Mwendo Coaches', sw: 'Wakocha wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Everyday Nutrition', sw: 'Lishe ya Kila Siku'),
        minutes: 5,
        summary: (en: 'Ugali/beans/rice baseline, timing around runs.', sw: 'Kabohidreti ni rafiki yako.'),
        paragraphs: [
          (en: 'A runner’s daily plate should resemble a traditional Kenyan meal: a carbohydrate base (ugali, rice, chapati, or sweet potatoes), a protein source (beans, ndengu, fish, or lean meat), a generous portion of greens (sukuma wiki, spinach), and a small amount of healthy fat (avocado, groundnut stew). Carbohydrates are your primary fuel—aim for them to fill about half your plate. Protein repairs muscles; include it at every meal. The “Kenyan runner’s diet” isn’t exotic: it’s simple, whole, and abundant in vegetables grown in the shamba.', sw: 'A runner’s daily plate should resemble a traditional Kenyan meal: a carbohydrate base (ugali, rice, chapati, or sweet potatoes), a protein source (beans, ndengu, fish, or lean meat), a generous portion of greens (sukuma wiki, spinach), and a small amount of healthy fat (avocado, groundnut stew). Carbohydrates are your primary fuel—aim for them to fill about half your plate. Protein repairs muscles; include it at every meal. The “Kenyan runner’s diet” isn’t exotic: it’s simple, whole, and abundant in vegetables grown in the shamba.'),
          (en: 'Timing matters. Eat a full meal 2‑3 hours before a run to avoid stomach upset. For early‑morning sessions, a small snack—a ripe banana or a slice of bread with honey—30 minutes prior can prevent low blood sugar without causing slosh. After the run, don’t postpone breakfast; your muscles are most receptive to refuelling within 30‑60 minutes. A bowl of porridge (uji) with milk and a spoon of sugar, followed by a balanced lunch later, works beautifully. Kenyan elites often start their day with chai and bread before a light morning jog, then return for a substantial late breakfast of eggs, ugali, and greens.', sw: 'Timing matters. Eat a full meal 2‑3 hours before a run to avoid stomach upset. For early‑morning sessions, a small snack—a ripe banana or a slice of bread with honey—30 minutes prior can prevent low blood sugar without causing slosh. After the run, don’t postpone breakfast; your muscles are most receptive to refuelling within 30‑60 minutes. A bowl of porridge (uji) with milk and a spoon of sugar, followed by a balanced lunch later, works beautifully. Kenyan elites often start their day with chai and bread before a light morning jog, then return for a substantial late breakfast of eggs, ugali, and greens.'),
        ],
      ),
      Lesson(
        title: (en: 'Hydration', sw: 'Unyevu'),
        minutes: 3,
        summary: (en: 'Drink to thirst, salt + carbs in heat.', sw: 'Kunywa kwa kiu, panga kwa joto.'),
        paragraphs: [
          (en: 'Thirst is a reliable guide for daily hydration. Drink when you’re thirsty; don’t force gallons. For runs under an hour, water alone suffices. In the East African heat, especially in places like Garissa or along the coast, sweat losses rise. Sip 150–250 ml every 20 minutes during long runs. Adding a pinch of salt and a teaspoon of sugar to your water bottle creates a cheap, effective oral rehydration solution that replaces sodium and glucose. Commercial sports drinks do the same but cost more. Kenyan runners often use boiled water with a squeeze of lemon and a dash of salt, carried in reused bottles.', sw: 'Thirst is a reliable guide for daily hydration. Drink when you’re thirsty; don’t force gallons. For runs under an hour, water alone suffices. In the East African heat, especially in places like Garissa or along the coast, sweat losses rise. Sip 150–250 ml every 20 minutes during long runs. Adding a pinch of salt and a teaspoon of sugar to your water bottle creates a cheap, effective oral rehydration solution that replaces sodium and glucose. Commercial sports drinks do the same but cost more. Kenyan runners often use boiled water with a squeeze of lemon and a dash of salt, carried in reused bottles.'),
          (en: 'Post‑run, a simple check: your urine should be pale straw colour. Darker means you need more fluids. Don’t over‑hydrate to the point of clear urine, which can wash out electrolytes. In very long runs or races, alternate water and an electrolyte drink. Practice your hydration strategy during training—nothing new on race day.', sw: 'Post‑run, a simple check: your urine should be pale straw colour. Darker means you need more fluids. Don’t over‑hydrate to the point of clear urine, which can wash out electrolytes. In very long runs or races, alternate water and an electrolyte drink. Practice your hydration strategy during training—nothing new on race day.'),
        ],
      ),
      Lesson(
        title: (en: 'Pre‑Race & Pre‑Workout Fueling', sw: 'Pre‑Race & Pre‑Workout Fueling'),
        minutes: 4,
        summary: (en: 'Low‑fibre, high‑carb meals and meal timing.', sw: 'Low‑fibre, high‑carb meals and meal timing.'),
        paragraphs: [
          (en: 'The pre‑race meal, eaten 3‑4 hours before the start, should be high in easily digestible carbohydrates, moderate in protein, and low in fat and fibre to minimise gut distress. A classic Kenyan pre‑race breakfast might be plain white rice, a boiled egg, and a glass of fresh juice. Avoid heavy stews, beans, or raw vegetables that could cause bloating. If nerves make solid food unappealing, a smoothie of banana, mango, and yoghurt is light yet calorie‑dense.', sw: 'The pre‑race meal, eaten 3‑4 hours before the start, should be high in easily digestible carbohydrates, moderate in protein, and low in fat and fibre to minimise gut distress. A classic Kenyan pre‑race breakfast might be plain white rice, a boiled egg, and a glass of fresh juice. Avoid heavy stews, beans, or raw vegetables that could cause bloating. If nerves make solid food unappealing, a smoothie of banana, mango, and yoghurt is light yet calorie‑dense.'),
          (en: 'In the final hour before the race, top off energy with a simple 30‑g carbohydrate snack: half a banana, a slice of plain bread, or a few plain biscuits. This “carbo‑top” tops off liver glycogen stores. Kenyan marathoners often sip on a small bottle of sugary tea. During the race, for efforts over 90 minutes, aim for 30‑60 grams of carbohydrate per hour via gels, sports drink, or real food like boiled potato chunks. Practice this intake in training to train your gut—digestion is trainable just like legs.', sw: 'In the final hour before the race, top off energy with a simple 30‑g carbohydrate snack: half a banana, a slice of plain bread, or a few plain biscuits. This “carbo‑top” tops off liver glycogen stores. Kenyan marathoners often sip on a small bottle of sugary tea. During the race, for efforts over 90 minutes, aim for 30‑60 grams of carbohydrate per hour via gels, sports drink, or real food like boiled potato chunks. Practice this intake in training to train your gut—digestion is trainable just like legs.'),
        ],
      ),
      Lesson(
        title: (en: 'Recovery Nutrition & The 30‑Minute Window', sw: 'Recovery Nutrition & The 30‑Minute Window'),
        minutes: 4,
        summary: (en: 'Refuel, repair, rehydrate.', sw: 'Refuel, repair, rehydrate.'),
        paragraphs: [
          (en: 'After a hard session, you have a roughly 30‑minute “glycogen window” where muscles soak up carbohydrates like a sponge. Pair carbs with protein in a 3‑to‑1 or 4‑to‑1 ratio to jumpstart muscle repair. Recovery doesn’t require fancy powders. A glass of milk (or mursik) and a banana, a bowl of millet porridge with groundnuts, or a chapati roll with beans all fit the bill. Kenyan runners in training camps often have a communal post‑run meal of githeri (maize and beans) and avocado—simple, affordable, and perfect.', sw: 'After a hard session, you have a roughly 30‑minute “glycogen window” where muscles soak up carbohydrates like a sponge. Pair carbs with protein in a 3‑to‑1 or 4‑to‑1 ratio to jumpstart muscle repair. Recovery doesn’t require fancy powders. A glass of milk (or mursik) and a banana, a bowl of millet porridge with groundnuts, or a chapati roll with beans all fit the bill. Kenyan runners in training camps often have a communal post‑run meal of githeri (maize and beans) and avocado—simple, affordable, and perfect.'),
          (en: 'In the hours that follow, continue to eat balanced meals to replenish glycogen stores fully, which can take up to 24 hours. Don’t skimp on recovery calories; chronic under‑fueling leads to persistent fatigue, injury, and overtraining syndrome. Use the M‑Run app to note how you felt after different recovery meals—you’ll soon identify what your body likes best.', sw: 'In the hours that follow, continue to eat balanced meals to replenish glycogen stores fully, which can take up to 24 hours. Don’t skimp on recovery calories; chronic under‑fueling leads to persistent fatigue, injury, and overtraining syndrome. Use the M‑Run app to note how you felt after different recovery meals—you’ll soon identify what your body likes best.'),
        ],
      ),
      Lesson(
        title: (en: 'Electrolytes & Running in East African Heat', sw: 'Electrolytes & Running in East African Heat'),
        minutes: 4,
        summary: (en: 'Sodium, potassium, magnesium, and the Kenyan climate.', sw: 'Sodium, potassium, magnesium, and the Kenyan climate.'),
        paragraphs: [
          (en: 'Sweat isn’t just water; it’s salty. Sodium is the main electrolyte lost, and a deficiency causes muscle cramps, nausea, and dangerous hyponatremia (low blood sodium) if you drink only water during long, hot runs. Kenyan runners often add a pinch of salt to their drinking water or consume lightly salted porridge. Potassium, plentiful in bananas, sweet potatoes, and greens, prevents muscle cramping. Magnesium, found in nuts and dark leafy vegetables, aids muscle relaxation.', sw: 'Sweat isn’t just water; it’s salty. Sodium is the main electrolyte lost, and a deficiency causes muscle cramps, nausea, and dangerous hyponatremia (low blood sodium) if you drink only water during long, hot runs. Kenyan runners often add a pinch of salt to their drinking water or consume lightly salted porridge. Potassium, plentiful in bananas, sweet potatoes, and greens, prevents muscle cramping. Magnesium, found in nuts and dark leafy vegetables, aids muscle relaxation.'),
          (en: 'In humid coastal regions like Mombasa, sweat doesn’t evaporate as well, so the body gets hotter. In these conditions, increase your fluid and electrolyte intake slightly, and consider running early or late. In the dry Rift Valley heat, sweat evaporates quickly, which can mask fluid loss; weigh yourself before and after a long run—each kilogram lost equals about 1 litre of sweat. Replenish 1.5 times that volume over the next few hours, with electrolytes. A simple homemade sports drink: 1 litre water, 1/4 teaspoon salt, 4 teaspoons sugar, and a squeeze of citrus. It costs pennies and works as well as any branded product.', sw: 'In humid coastal regions like Mombasa, sweat doesn’t evaporate as well, so the body gets hotter. In these conditions, increase your fluid and electrolyte intake slightly, and consider running early or late. In the dry Rift Valley heat, sweat evaporates quickly, which can mask fluid loss; weigh yourself before and after a long run—each kilogram lost equals about 1 litre of sweat. Replenish 1.5 times that volume over the next few hours, with electrolytes. A simple homemade sports drink: 1 litre water, 1/4 teaspoon salt, 4 teaspoons sugar, and a squeeze of citrus. It costs pennies and works as well as any branded product.'),
        ],
      ),
      Lesson(
        title: (en: 'Sports Drinks vs. Real Food', sw: 'Vinywaji vya Michezo dhidi ya Chakula Halisi'),
        minutes: 4,
        summary: (en: 'When to use each, Kenyan alternatives.', sw: 'Wakati wa kutumia jeli na wakati wa kula ndizi.'),
        paragraphs: [
          (en: 'Commercial sports drinks and gels are convenient, precisely formulated, and easy to carry—ideal for races and long runs where chewing is tough. But they’re not magical. Real foods offer superior satiety, more micronutrients, and are often cheaper. Kenyan athletes on the global circuit use gels during marathons, but in training camps they rely on bananas, mandazi (slightly sweet fried dough), boiled potatoes with a dab of salt, and small packets of honey. For runs under 90 minutes, you don’t need mid‑run fuel at all. For longer efforts, experiment with half a banana every 30 minutes, or a handful of raisins. Make sure you can tolerate them while running—practice is key. The golden rule: eat real food in training, use gels for racing convenience if you like them, and never try something new on race day.', sw: 'Commercial sports drinks and gels are convenient, precisely formulated, and easy to carry—ideal for races and long runs where chewing is tough. But they’re not magical. Real foods offer superior satiety, more micronutrients, and are often cheaper. Kenyan athletes on the global circuit use gels during marathons, but in training camps they rely on bananas, mandazi (slightly sweet fried dough), boiled potatoes with a dab of salt, and small packets of honey. For runs under 90 minutes, you don’t need mid‑run fuel at all. For longer efforts, experiment with half a banana every 30 minutes, or a handful of raisins. Make sure you can tolerate them while running—practice is key. The golden rule: eat real food in training, use gels for racing convenience if you like them, and never try something new on race day.'),
        ],
      ),
      Lesson(
        title: (en: 'Weight & Running Performance (Sensitively)', sw: 'Weight & Running Performance (Sensitively)'),
        minutes: 4,
        summary: (en: 'Body composition, energy availability, and health.', sw: 'Body composition, energy availability, and health.'),
        paragraphs: [
          (en: 'Lighter runners often run faster uphill, but chasing weight loss can decimate performance and health. The focus should be on energy availability—consuming enough calories to support training plus daily life. Signs of under‑fueling: persistent fatigue, missed periods (in women), frequent illness, irritability, and stagnant or declining performance despite hard training. If you’re carrying extra weight, gentle, gradual changes over months—swapping sugary drinks for water, increasing vegetable portions, eating mindfully—yield sustainable results without tanking your training.', sw: 'Lighter runners often run faster uphill, but chasing weight loss can decimate performance and health. The focus should be on energy availability—consuming enough calories to support training plus daily life. Signs of under‑fueling: persistent fatigue, missed periods (in women), frequent illness, irritability, and stagnant or declining performance despite hard training. If you’re carrying extra weight, gentle, gradual changes over months—swapping sugary drinks for water, increasing vegetable portions, eating mindfully—yield sustainable results without tanking your training.'),
          (en: 'Kenyan runners, especially the marathoners, are naturally lean due to genetics, high training volumes, and a diet rich in unprocessed foods. But forced weight loss has derailed many promising careers. Aim for a body that feels strong, energetic, and resilient. If you’re concerned, work with a sports dietitian who understands runners. Celebrate what your body can do, not just what it looks like. A well‑fuelled runner is a powerful runner.', sw: 'Kenyan runners, especially the marathoners, are naturally lean due to genetics, high training volumes, and a diet rich in unprocessed foods. But forced weight loss has derailed many promising careers. Aim for a body that feels strong, energetic, and resilient. If you’re concerned, work with a sports dietitian who understands runners. Celebrate what your body can do, not just what it looks like. A well‑fuelled runner is a powerful runner.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'injury-prevention',
    title: (en: 'Stay Injury‑Free', sw: 'Stay Injury‑Free'),
    subtitle: (en: 'Strength, rest and listening to pain.', sw: 'Strength, rest and listening to pain.'),
    category: CourseCategory.health,
    author: (en: 'Dr. A. Were', sw: 'Daktari A. Were'),
    lessons: [
      Lesson(
        title: (en: 'The 10% Rule', sw: 'The 10% Rule'),
        minutes: 4,
        summary: (en: 'Gradual volume progression and its limits.', sw: 'Gradual volume progression and its limits.'),
        paragraphs: [
          (en: 'The 10% rule states: increase your total weekly running distance or time by no more than 10% compared to the previous week. For example, if you ran 20 km this week, aim for 22 km next week. This gives bones, tendons, and ligaments time to adapt to the pounding. Even Kenyan elites follow gradual build‑ups; they don’t jump from 100 km to 140 km in a week—they spread it over a month with cutback weeks.', sw: 'The 10% rule states: increase your total weekly running distance or time by no more than 10% compared to the previous week. For example, if you ran 20 km this week, aim for 22 km next week. This gives bones, tendons, and ligaments time to adapt to the pounding. Even Kenyan elites follow gradual build‑ups; they don’t jump from 100 km to 140 km in a week—they spread it over a month with cutback weeks.'),
          (en: 'The rule isn’t ironclad. Beginners with very low volume may increase by a slightly larger percentage safely, while someone already running 80 km per week might only manage a 5% bump. The key is listening to your body. If a new ache persists beyond 48 hours or worsens during a run, hold your mileage steady or back off slightly. Use the M‑Run app to log weekly volume and spot spikes. Consistency beats heroic leaps.', sw: 'The rule isn’t ironclad. Beginners with very low volume may increase by a slightly larger percentage safely, while someone already running 80 km per week might only manage a 5% bump. The key is listening to your body. If a new ache persists beyond 48 hours or worsens during a run, hold your mileage steady or back off slightly. Use the M‑Run app to log weekly volume and spot spikes. Consistency beats heroic leaps.'),
        ],
      ),
      Lesson(
        title: (en: 'Strength for Runners', sw: 'Strength for Runners'),
        minutes: 5,
        summary: (en: 'Key exercises: squats, calf raises, single‑leg work, core.', sw: 'Key exercises: squats, calf raises, single‑leg work, core.'),
        paragraphs: [
          (en: 'Running is a series of single‑leg hops; strength training makes those hops resilient. Twice a week, perform a short routine focusing on the posterior chain and stabilisers. Body‑weight squats (2 sets of 15), walking lunges (10 each leg), single‑leg calf raises on a step (2 × 12 per leg), glute bridges (2 × 15), and a plank hold (3 × 30 seconds) form a bulletproof foundation. Progress to goblet squats with a jerrycan of water or a backpack filled with books for added resistance.', sw: 'Running is a series of single‑leg hops; strength training makes those hops resilient. Twice a week, perform a short routine focusing on the posterior chain and stabilisers. Body‑weight squats (2 sets of 15), walking lunges (10 each leg), single‑leg calf raises on a step (2 × 12 per leg), glute bridges (2 × 15), and a plank hold (3 × 30 seconds) form a bulletproof foundation. Progress to goblet squats with a jerrycan of water or a backpack filled with books for added resistance.'),
          (en: 'Kenyan runners in training camps do strength circuits on rest days—push‑ups, sit‑ups, and “A‑skips” for hip mobility—often in a group, with laughter lightening the load. Strength work doesn’t bulk you up; it improves neuromuscular control, corrects imbalances, and increases the elasticity of your tendons, storing energy with each footfall. If you’re time‑poor, even 10 minutes after a run helps. The best time is right after a run, when muscles are warm, or on a cross‑training day.', sw: 'Kenyan runners in training camps do strength circuits on rest days—push‑ups, sit‑ups, and “A‑skips” for hip mobility—often in a group, with laughter lightening the load. Strength work doesn’t bulk you up; it improves neuromuscular control, corrects imbalances, and increases the elasticity of your tendons, storing energy with each footfall. If you’re time‑poor, even 10 minutes after a run helps. The best time is right after a run, when muscles are warm, or on a cross‑training day.'),
        ],
      ),
      Lesson(
        title: (en: 'Acute Injury Management: PEACE & LOVE', sw: 'Acute Injury Management: PEACE & LOVE'),
        minutes: 4,
        summary: (en: 'Immediate care and follow‑up rehab.', sw: 'Immediate care and follow‑up rehab.'),
        paragraphs: [
          (en: 'The old RICE (Rest, Ice, Compression, Elevation) has been updated to PEACE & LOVE. Immediately after a soft‑tissue injury (sprain, strain), protect the area: avoid pain‑provoking movements for 1–3 days. Elevate the limb. Avoid anti‑inflammatory medications in the first 48 hours unless pain is unbearable, as inflammation is needed for tissue repair. Compress with a bandage to limit swelling. Educate yourself: understand that some pain is normal, but sharp or worsening pain is not.', sw: 'The old RICE (Rest, Ice, Compression, Elevation) has been updated to PEACE & LOVE. Immediately after a soft‑tissue injury (sprain, strain), protect the area: avoid pain‑provoking movements for 1–3 days. Elevate the limb. Avoid anti‑inflammatory medications in the first 48 hours unless pain is unbearable, as inflammation is needed for tissue repair. Compress with a bandage to limit swelling. Educate yourself: understand that some pain is normal, but sharp or worsening pain is not.'),
          (en: 'After a few days, move into LOVE: Load—gradually introduce movement and weight‑bearing as pain allows, because tissues heal stronger under appropriate stress. Optimism—stay positive; catastrophising prolongs recovery. Vascularisation—light, pain‑free cardio like walking or stationary cycling to boost blood flow. Exercise—start active rehab, like gentle range‑of‑motion drills and eventually return‑to‑run programmes. Kenyan athletes often use warm‑water soaks and massage with herbal oils as part of their “compression and elevation” tradition, blending local wisdom with modern science.', sw: 'After a few days, move into LOVE: Load—gradually introduce movement and weight‑bearing as pain allows, because tissues heal stronger under appropriate stress. Optimism—stay positive; catastrophising prolongs recovery. Vascularisation—light, pain‑free cardio like walking or stationary cycling to boost blood flow. Exercise—start active rehab, like gentle range‑of‑motion drills and eventually return‑to‑run programmes. Kenyan athletes often use warm‑water soaks and massage with herbal oils as part of their “compression and elevation” tradition, blending local wisdom with modern science.'),
        ],
      ),
      Lesson(
        title: (en: 'Common Running Injuries', sw: 'Majeraha ya Kawaida ya Mbio'),
        minutes: 5,
        summary: (en: 'ITBS, shin splints, plantar fasciitis — causes and fixes.', sw: 'ITBS, shin splints, na plantar fasciitis.'),
        paragraphs: [
          (en: '**Iliotibial Band Syndrome (ITBS):** Sharp pain on the outside of the knee, often from weak hip abductors. Fix: side‑lying leg raises, clamshells, foam‑rolling the IT band, and temporarily reducing downhill running.', sw: '**Iliotibial Band Syndrome (ITBS):** Sharp pain on the outside of the knee, often from weak hip abductors. Fix: side‑lying leg raises, clamshells, foam‑rolling the IT band, and temporarily reducing downhill running.'),
          (en: '**Shin Splints (Medial Tibial Stress Syndrome):** Dull ache along the inner shin, usually when increasing mileage too quickly. Fix: rest from running, ice, calf stretches, and switching to softer surfaces. Gradual return with strides.', sw: '**Shin Splints (Medial Tibial Stress Syndrome):** Dull ache along the inner shin, usually when increasing mileage too quickly. Fix: rest from running, ice, calf stretches, and switching to softer surfaces. Gradual return with strides.'),
          (en: '**Plantar Fasciitis:** Stabbing pain in the heel bottom, worst in the morning. Fix: calf stretching, rolling a frozen water bottle under the arch, and wearing supportive shoes. Avoid barefoot walking on hard floors until healed.', sw: '**Plantar Fasciitis:** Stabbing pain in the heel bottom, worst in the morning. Fix: calf stretching, rolling a frozen water bottle under the arch, and wearing supportive shoes. Avoid barefoot walking on hard floors until healed.'),
          (en: 'Each of these has a mechanical root, often linked to training errors. Kenyan runners historically battled such injuries before the era of physiotherapists; they used rest, massage, and natural anti‑inflammatory herbs like stinging nettle. Today, combining evidence‑based exercises with rest gets you back to the red‑dirt roads faster. If pain lasts more than two weeks, seek professional assessment.', sw: 'Each of these has a mechanical root, often linked to training errors. Kenyan runners historically battled such injuries before the era of physiotherapists; they used rest, massage, and natural anti‑inflammatory herbs like stinging nettle. Today, combining evidence‑based exercises with rest gets you back to the red‑dirt roads faster. If pain lasts more than two weeks, seek professional assessment.'),
        ],
      ),
      Lesson(
        title: (en: 'Sleep as Recovery', sw: 'Usingizi kama Urejeaji'),
        minutes: 4,
        summary: (en: 'Why elite Kenyans nap.', sw: 'Kwa nini Wakenya wasomi wanalala mchana.'),
        paragraphs: [
          (en: 'Sleep is when your body releases growth hormone, repairs micro‑tears in muscle, and consolidates learning from that day’s workout. Kenyan distance runners are famous for their “sleep‑hard” culture. In training camps, athletes rise at 5 a.m. for a morning run, eat breakfast, then nap from 10 a.m. to noon before the afternoon session. They’re often in bed by 9 p.m. That’s 9‑10 hours of sleep plus a 1‑2 hour nap, totalling over 10 hours of daily rest—and it’s considered as important as the running itself.', sw: 'Sleep is when your body releases growth hormone, repairs micro‑tears in muscle, and consolidates learning from that day’s workout. Kenyan distance runners are famous for their “sleep‑hard” culture. In training camps, athletes rise at 5 a.m. for a morning run, eat breakfast, then nap from 10 a.m. to noon before the afternoon session. They’re often in bed by 9 p.m. That’s 9‑10 hours of sleep plus a 1‑2 hour nap, totalling over 10 hours of daily rest—and it’s considered as important as the running itself.'),
          (en: 'Aim for at least 7‑8 hours of quality sleep at night. Create a cool, dark environment; avoid screens an hour before bed. If you can, a 20‑minute power nap post‑lunch boosts alertness and recovery. Track your sleep with a journal or wearable; if you consistently sleep less than 7 hours, reduce training intensity until you catch up. Chronic sleep debt raises cortisol, impairs immunity, and increases injury risk. Treat sleep as a performance‑enhancing drug.', sw: 'Aim for at least 7‑8 hours of quality sleep at night. Create a cool, dark environment; avoid screens an hour before bed. If you can, a 20‑minute power nap post‑lunch boosts alertness and recovery. Track your sleep with a journal or wearable; if you consistently sleep less than 7 hours, reduce training intensity until you catch up. Chronic sleep debt raises cortisol, impairs immunity, and increases injury risk. Treat sleep as a performance‑enhancing drug.'),
        ],
      ),
      Lesson(
        title: (en: 'Cross‑Training for Resilience', sw: 'Cross‑Training for Resilience'),
        minutes: 4,
        summary: (en: 'Swimming, cycling, and strength when you can’t run.', sw: 'Swimming, cycling, and strength when you can’t run.'),
        paragraphs: [
          (en: 'Cross‑training maintains aerobic fitness while offloading injured or overworked legs. Swimming and aqua‑jogging are zero‑impact and mimic running motion. Cycling (outdoor or stationary) builds quadriceps and cardiovascular endurance. A Kenyan runner with a minor calf strain might spend a week riding a bicycle along camp roads instead of running. Aim for sessions that mimic your intended run time and intensity: 45 minutes of steady cycling in Zone 2, or pool intervals of 3‑minute hard efforts.', sw: 'Cross‑training maintains aerobic fitness while offloading injured or overworked legs. Swimming and aqua‑jogging are zero‑impact and mimic running motion. Cycling (outdoor or stationary) builds quadriceps and cardiovascular endurance. A Kenyan runner with a minor calf strain might spend a week riding a bicycle along camp roads instead of running. Aim for sessions that mimic your intended run time and intensity: 45 minutes of steady cycling in Zone 2, or pool intervals of 3‑minute hard efforts.'),
          (en: 'Cross‑training also breaks monotony. It develops supporting muscles, corrects muscle imbalances, and can even improve running economy by making you a more well‑rounded athlete. Include one cross‑training day per week even when healthy. In the M‑Run app, log these sessions under “cross‑train” to see your total aerobic load. It’s a safety net: when injury strikes, you don’t lose all fitness; you simply shift gears.', sw: 'Cross‑training also breaks monotony. It develops supporting muscles, corrects muscle imbalances, and can even improve running economy by making you a more well‑rounded athlete. Include one cross‑training day per week even when healthy. In the M‑Run app, log these sessions under “cross‑train” to see your total aerobic load. It’s a safety net: when injury strikes, you don’t lose all fitness; you simply shift gears.'),
        ],
      ),
      Lesson(
        title: (en: 'When to See a Physio', sw: 'Wakati wa Kumwona Mtaalamu'),
        minutes: 3,
        summary: (en: 'Red flags and finding local help.', sw: 'Kutambua bendera nyekundu za majeraha.'),
        paragraphs: [
          (en: 'Most niggles resolve with a few days of rest and the measures above. Seek a physiotherapist if: pain causes you to alter your gait for more than a week; pain wakes you at night; you see swelling or bruising; the pain intensifies during a run instead of loosening; or you’ve rested two weeks without improvement. Early intervention prevents a minor strain from becoming a stress fracture. In Kenya, physios in cities like Nairobi and Eldoret specialise in runners; local running clubs can often recommend someone. Don’t “run through” severe pain—it’s not toughness, it’s a ticket to a long layoff. A good physio will not just treat the symptom but find the root cause and equip you with exercises to prevent recurrence.', sw: 'Most niggles resolve with a few days of rest and the measures above. Seek a physiotherapist if: pain causes you to alter your gait for more than a week; pain wakes you at night; you see swelling or bruising; the pain intensifies during a run instead of loosening; or you’ve rested two weeks without improvement. Early intervention prevents a minor strain from becoming a stress fracture. In Kenya, physios in cities like Nairobi and Eldoret specialise in runners; local running clubs can often recommend someone. Don’t “run through” severe pain—it’s not toughness, it’s a ticket to a long layoff. A good physio will not just treat the symptom but find the root cause and equip you with exercises to prevent recurrence.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'women-in-running',
    title: (en: 'Women in Running', sw: 'Wanawake katika Mbio'),
    subtitle: (en: 'Strength, physiology and community.', sw: 'Nguvu, fiziolojia na jamii.'),
    category: CourseCategory.health,
    author: (en: 'Mwendo Community', sw: 'Jamii ya Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Training Through Life', sw: 'Mazoezi katika Maisha'),
        minutes: 5,
        summary: (en: 'Hormonal cycle adaptation, Loroupe/Kipyegon lineage.', sw: 'Kubadilisha kwa mwili wa kike.'),
        paragraphs: [
          (en: 'The menstrual cycle is not a weakness; it’s an ebb and flow of hormones that can be harnessed. In the first half (follicular phase), rising oestrogen boosts energy, pain tolerance, and muscle repair—ideal for high‑intensity intervals and personal best attempts. Ovulation brings a peak in strength. In the second half (luteal phase), progesterone raises core temperature and heart rate at rest; endurance may dip and perceived effort climbs. Adjust expectations: move hard workouts earlier in the cycle, and embrace easy aerobic runs in the days before menstruation. When cramps hit, gentle yoga, jogging, or a rest day are all valid.', sw: 'The menstrual cycle is not a weakness; it’s an ebb and flow of hormones that can be harnessed. In the first half (follicular phase), rising oestrogen boosts energy, pain tolerance, and muscle repair—ideal for high‑intensity intervals and personal best attempts. Ovulation brings a peak in strength. In the second half (luteal phase), progesterone raises core temperature and heart rate at rest; endurance may dip and perceived effort climbs. Adjust expectations: move hard workouts earlier in the cycle, and embrace easy aerobic runs in the days before menstruation. When cramps hit, gentle yoga, jogging, or a rest day are all valid.'),
          (en: 'Kenya’s female running icons, from Tegla Loroupe breaking the marathon world record in 1999 to Faith Kipyegon shattering 1500m marks, have navigated these cycles while managing immense physical demands. Many describe learning to listen to their bodies rather than fighting them. Track your cycle alongside your training log in M‑Run; patterns will emerge that help you plan key sessions. Your body is a finely tuned instrument, not a flaw to overcome.', sw: 'Kenya’s female running icons, from Tegla Loroupe breaking the marathon world record in 1999 to Faith Kipyegon shattering 1500m marks, have navigated these cycles while managing immense physical demands. Many describe learning to listen to their bodies rather than fighting them. Track your cycle alongside your training log in M‑Run; patterns will emerge that help you plan key sessions. Your body is a finely tuned instrument, not a flaw to overcome.'),
        ],
      ),
      Lesson(
        title: (en: 'Pregnancy & Postpartum Running', sw: 'Pregnancy & Postpartum Running'),
        minutes: 4,
        summary: (en: 'Safe running while pregnant, gradual return after birth.', sw: 'Safe running while pregnant, gradual return after birth.'),
        paragraphs: [
          (en: 'Running during pregnancy can be safe with medical clearance. The guideline: you can continue what your body is accustomed to, but don’t start a new intense regimen. First trimester fatigue and nausea may limit training; walk‑run sessions count. Avoid overheating, stay well‑hydrated, and skip intervals that leave you breathless. A supportive belly band reduces pelvic discomfort. In Kenya, many women stay active through farm work and walking; formal running may pause, but movement continues. Postpartum, wait for bleeding to stop and get your doctor’s green light—typically around 6 weeks for an uncomplicated vaginal birth, longer for C‑sections. Return gradually, prioritising pelvic floor and core rehab before impact. Imagine rebuilding the foundation of a house; rushing leads to leaking roofs (incontinence, prolapse). Kipyegon returned to world‑record form after giving birth, proving that motherhood can coexist with elite performance. Celebrate small milestones: the first postpartum mile, the first 5K. Your journey is uniquely yours.', sw: 'Running during pregnancy can be safe with medical clearance. The guideline: you can continue what your body is accustomed to, but don’t start a new intense regimen. First trimester fatigue and nausea may limit training; walk‑run sessions count. Avoid overheating, stay well‑hydrated, and skip intervals that leave you breathless. A supportive belly band reduces pelvic discomfort. In Kenya, many women stay active through farm work and walking; formal running may pause, but movement continues. Postpartum, wait for bleeding to stop and get your doctor’s green light—typically around 6 weeks for an uncomplicated vaginal birth, longer for C‑sections. Return gradually, prioritising pelvic floor and core rehab before impact. Imagine rebuilding the foundation of a house; rushing leads to leaking roofs (incontinence, prolapse). Kipyegon returned to world‑record form after giving birth, proving that motherhood can coexist with elite performance. Celebrate small milestones: the first postpartum mile, the first 5K. Your journey is uniquely yours.'),
        ],
      ),
      Lesson(
        title: (en: 'Iron Deficiency in Female Runners', sw: 'Iron Deficiency in Female Runners'),
        minutes: 4,
        summary: (en: 'Why women are at risk, detection, dietary solutions.', sw: 'Why women are at risk, detection, dietary solutions.'),
        paragraphs: [
          (en: 'Iron deficiency is the most common nutritional deficiency among female endurance athletes, worsened by menstrual blood loss, foot‑strike hemolysis (destruction of red blood cells from impact), and low dietary intake. Symptoms: unusual fatigue, shortness of breath on easy runs, pale skin, and declining performance. A simple blood test—serum ferritin—reveals your stores. Levels below 30 ng/mL can impair running; athletes often aim for 50+.', sw: 'Iron deficiency is the most common nutritional deficiency among female endurance athletes, worsened by menstrual blood loss, foot‑strike hemolysis (destruction of red blood cells from impact), and low dietary intake. Symptoms: unusual fatigue, shortness of breath on easy runs, pale skin, and declining performance. A simple blood test—serum ferritin—reveals your stores. Levels below 30 ng/mL can impair running; athletes often aim for 50+.'),
          (en: 'Kenyan dishes can be excellent iron sources. Pair iron‑rich foods (beef, liver, sardines, dark green leaves, beans) with vitamin C (squeeze of lemon, fresh tomato) to boost absorption. Avoid tea or coffee with meals; tannins block iron uptake. Cooking in iron pots, common in rural areas, adds a helpful dose. If ferritin is low, an oral supplement under medical guidance may be needed, but dietary changes are the first line. A well‑nourished woman runs with vibrant energy.', sw: 'Kenyan dishes can be excellent iron sources. Pair iron‑rich foods (beef, liver, sardines, dark green leaves, beans) with vitamin C (squeeze of lemon, fresh tomato) to boost absorption. Avoid tea or coffee with meals; tannins block iron uptake. Cooking in iron pots, common in rural areas, adds a helpful dose. If ferritin is low, an oral supplement under medical guidance may be needed, but dietary changes are the first line. A well‑nourished woman runs with vibrant energy.'),
        ],
      ),
      Lesson(
        title: (en: 'Building a Women’s Running Community', sw: 'Building a Women’s Running Community'),
        minutes: 4,
        summary: (en: 'Sisterhood, local groups, and mentorship.', sw: 'Sisterhood, local groups, and mentorship.'),
        paragraphs: [
          (en: 'Running doesn’t have to be solitary. Women‑only running groups create a sanctuary where beginners feel safe, mothers share childcare tips, and veterans mentor newcomers. In Nairobi, informal “Ladies’ Jogging Clubs” meet on weekends in parks; in Iten, local women’s running camps are emerging, inspired by the success of Lornah Kiplagat’s High Altitude Training Centre. If such a group doesn’t exist near you, start one: pick a time and place, invite friends via WhatsApp, and run‑walk together for 30 minutes. The shared experience dismantles intimidation.', sw: 'Running doesn’t have to be solitary. Women‑only running groups create a sanctuary where beginners feel safe, mothers share childcare tips, and veterans mentor newcomers. In Nairobi, informal “Ladies’ Jogging Clubs” meet on weekends in parks; in Iten, local women’s running camps are emerging, inspired by the success of Lornah Kiplagat’s High Altitude Training Centre. If such a group doesn’t exist near you, start one: pick a time and place, invite friends via WhatsApp, and run‑walk together for 30 minutes. The shared experience dismantles intimidation.'),
          (en: 'Community brings accountability. On days you’d rather stay in bed, knowing someone is waiting for you gets you out the door. It also amplifies voice—groups can advocate for safer streets, better lighting, and respect for women runners in public spaces. Celebrate each other’s wins, whether it’s finishing a first 5K or simply showing up. As the saying goes, “If you want to go fast, go alone. If you want to go far, go together.”', sw: 'Community brings accountability. On days you’d rather stay in bed, knowing someone is waiting for you gets you out the door. It also amplifies voice—groups can advocate for safer streets, better lighting, and respect for women runners in public spaces. Celebrate each other’s wins, whether it’s finishing a first 5K or simply showing up. As the saying goes, “If you want to go fast, go alone. If you want to go far, go together.”'),
        ],
      ),
      Lesson(
        title: (en: 'Safety for Women Runners', sw: 'Usalama kwa Wakimbiaji wa Kike'),
        minutes: 4,
        summary: (en: 'Practical precautions without fear‑mongering.', sw: 'Tahadhari za vitendo wakati wa kukimbia.'),
        paragraphs: [
          (en: 'Running should be liberating, not frightening. Still, women face real risks. Run with a buddy or group whenever possible, especially in early morning or evening darkness. Share your live location with a trusted contact via smartphone. Vary your routes and times to avoid predictability. Wear reflective gear and a headlamp. Ditch headphones or use open‑ear bone‑conduction models so you can hear your surroundings. Carry a whistle or personal alarm—it’s a powerful deterrent.', sw: 'Running should be liberating, not frightening. Still, women face real risks. Run with a buddy or group whenever possible, especially in early morning or evening darkness. Share your live location with a trusted contact via smartphone. Vary your routes and times to avoid predictability. Wear reflective gear and a headlamp. Ditch headphones or use open‑ear bone‑conduction models so you can hear your surroundings. Carry a whistle or personal alarm—it’s a powerful deterrent.'),
          (en: 'Trust your intuition: if a street feels off, turn back. In Kenyan towns, public matatu stages can be crowded; plan routes along well‑lit, populated areas. Many female runners also find confidence in self‑defence classes. These measures are not about living in fear; they’re about empowerment. You deserve to claim the roads as much as any man. By taking sensible precautions, you can run with the same freedom as the champions who train on the highland trails at dawn.', sw: 'Trust your intuition: if a street feels off, turn back. In Kenyan towns, public matatu stages can be crowded; plan routes along well‑lit, populated areas. Many female runners also find confidence in self‑defence classes. These measures are not about living in fear; they’re about empowerment. You deserve to claim the roads as much as any man. By taking sensible precautions, you can run with the same freedom as the champions who train on the highland trails at dawn.'),
        ],
      ),
      Lesson(
        title: (en: 'Body Image & Running', sw: 'Sura ya Mwili na Mbio'),
        minutes: 4,
        summary: (en: 'Celebrating strength over shape.', sw: 'Kushangilia nguvu juu ya sura.'),
        paragraphs: [
          (en: 'The running community often celebrates a lean aesthetic, but performance comes in all shapes. Focusing on what your body can achieve—a faster parkrun, a pain‑free 10K—rather than a number on the scale builds a healthier relationship with the sport. Elite runners come in different heights, builds, and running styles; Sifan Hassan looks very different from Brigid Kosgei, yet both are champions.', sw: 'The running community often celebrates a lean aesthetic, but performance comes in all shapes. Focusing on what your body can achieve—a faster parkrun, a pain‑free 10K—rather than a number on the scale builds a healthier relationship with the sport. Elite runners come in different heights, builds, and running styles; Sifan Hassan looks very different from Brigid Kosgei, yet both are champions.'),
          (en: 'Your body shape will adapt to your training naturally. Forcing weight loss through restrictive eating often leads to Relative Energy Deficiency in Sport (RED-S), a dangerous condition that degrades bone density, hormonal balance, and immune function.', sw: 'Your body shape will adapt to your training naturally. Forcing weight loss through restrictive eating often leads to Relative Energy Deficiency in Sport (RED-S), a dangerous condition that degrades bone density, hormonal balance, and immune function.'),
          (en: 'Cultivate a performance identity based on strength, endurance, and consistency. Nourish your body to support your training, and celebrate its capacity to move, adapt, and grow stronger with every kilometre.', sw: 'Cultivate a performance identity based on strength, endurance, and consistency. Nourish your body to support your training, and celebrate its capacity to move, adapt, and grow stronger with every kilometre.'),
        ],
      ),
      Lesson(
        title: (en: 'Legendary Pioneers', sw: 'Mashujaa wa Kike wa Mbio'),
        minutes: 4,
        summary: (en: 'Inspiration from icons who rewrote the rules.', sw: 'Uvuvio kutoka kwa icons za kike.'),
        paragraphs: [
          (en: 'The path for female runners in East Africa was paved by courageous pioneers who fought social expectations to compete. Tegla Loroupe was the first African woman to win the New York City Marathon in 1994, using her platform to become a global peace ambassador.', sw: 'The path for female runners in East Africa was paved by courageous pioneers who fought social expectations to compete. Tegla Loroupe was the first African woman to win the New York City Marathon in 1994, using her platform to become a global peace ambassador.'),
          (en: 'Catherine Ndereba, known as \'Catherine the Great,\' won the Boston Marathon four times and two World Championships, showing unmatched consistency. Lornah Kiplagat, a former world-record holder, built the High Altitude Training Centre in Iten, providing a dedicated space for women and international runners.', sw: 'Catherine Ndereba, known as \'Catherine the Great,\' won the Boston Marathon four times and two World Championships, showing unmatched consistency. Lornah Kiplagat, a former world-record holder, built the High Altitude Training Centre in Iten, providing a dedicated space for women and international runners.'),
          (en: 'More recently, Faith Kipyegon has dominated the middle distances, proving that athletes can return from motherhood to break world records. These pioneers are not just champions; they are leaders who have opened doors for thousands of women to run freely.', sw: 'More recently, Faith Kipyegon has dominated the middle distances, proving that athletes can return from motherhood to break world records. These pioneers are not just champions; they are leaders who have opened doors for thousands of women to run freely.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'altitude-training',
    title: (en: 'The Altitude Advantage', sw: 'Faida ya Kimo cha Juu'),
    subtitle: (en: 'Why the Rift Valley makes champions.', sw: 'Kwa nini Bonde la Rift hufanya mabingwa.'),
    category: CourseCategory.heritage,
    author: (en: 'Mwendo Heritage', sw: 'Urithi wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: 'Life at 2,400 Metres', sw: 'Maisha kwenye Mita 2,400'),
        minutes: 6,
        summary: (en: 'Erythropoiesis and red dirt.', sw: 'Uzalishaji wa seli nyekundu na udongo mwekundu.'),
        paragraphs: [
          (en: 'Training at altitude stimulates the body to produce more erythropoietin (EPO), a hormone that triggers the production of red blood cells. More red blood cells mean more oxygen can be delivered to working muscles, enhancing endurance. When athletes from Iten or Kaptagat return to sea level for races, they feel as though they have an extra gear.', sw: 'Training at altitude stimulates the body to produce more erythropoietin (EPO), a hormone that triggers the production of red blood cells. More red blood cells mean more oxygen can be delivered to working muscles, enhancing endurance. When athletes from Iten or Kaptagat return to sea level for races, they feel as though they have an extra gear.'),
          (en: 'The altitude also imposes a natural governor on speed. In the first few days, even easy runs feel difficult as your body fights for oxygen. This forces patience and builds aerobic efficiency.', sw: 'The altitude also imposes a natural governor on speed. In the first few days, even easy runs feel difficult as your body fights for oxygen. This forces patience and builds aerobic efficiency.'),
          (en: 'Beyond the oxygen thinness, the geography itself shapes champions. The undulating red-dirt roads of the Rift Valley are soft, reducing impact on joints, while the long, steady climbs condition the heart and legs.', sw: 'Beyond the oxygen thinness, the geography itself shapes champions. The undulating red-dirt roads of the Rift Valley are soft, reducing impact on joints, while the long, steady climbs condition the heart and legs.'),
        ],
      ),
      Lesson(
        title: (en: 'The Acclimatisation Timeline', sw: 'Muda wa Kuzoea Kimo'),
        minutes: 5,
        summary: (en: 'Adapting to the thin air step-by-step.', sw: 'Kuzoea hewa nyembamba hatua kwa hatua.'),
        paragraphs: [
          (en: 'When you first arrive at high altitude, your body responds immediately by increasing your breathing rate and heart rate, even at rest. This is a temporary response to compensate for the lower oxygen pressure. You may experience mild headaches, dehydration, or trouble sleeping during the first 48 hours.', sw: 'When you first arrive at high altitude, your body responds immediately by increasing your breathing rate and heart rate, even at rest. This is a temporary response to compensate for the lower oxygen pressure. You may experience mild headaches, dehydration, or trouble sleeping during the first 48 hours.'),
          (en: 'During the first week, your body starts to conserve water and increase its concentration of hemoglobin. Coaches recommend keeping all runs strictly in Zone 1 or 2 during this phase. Attempting hard intervals too early can lead to extreme fatigue and set back your training by weeks.', sw: 'During the first week, your body starts to conserve water and increase its concentration of hemoglobin. Coaches recommend keeping all runs strictly in Zone 1 or 2 during this phase. Attempting hard intervals too early can lead to extreme fatigue and set back your training by weeks.'),
          (en: 'By week three, active erythropoiesis is underway, and your body begins to adapt more deeply. You will find you can run at your normal effort levels without the gasping sensation. A full adaptation takes four to six weeks, which is why elite camps are usually scheduled for at least a month.', sw: 'By week three, active erythropoiesis is underway, and your body begins to adapt more deeply. You will find you can run at your normal effort levels without the gasping sensation. A full adaptation takes four to six weeks, which is why elite camps are usually scheduled for at least a month.'),
        ],
      ),
      Lesson(
        title: (en: 'Sea-Level Performance Boost', sw: 'Nguvu Mpya Ufuoni'),
        minutes: 5,
        summary: (en: 'Translating altitude gains to faster times.', sw: 'Kutafsiri mafanikio ya kimo hadi kasi.'),
        paragraphs: [
          (en: 'The physiological benefits of altitude training—increased red blood cell mass, improved oxygen transport, and higher buffering capacity—reach their peak just as you return to sea level. Athletes often report feeling an incredible lightness in their legs and a sense that they can breathe effortlessly at paces that previously felt challenging.', sw: 'The physiological benefits of altitude training—increased red blood cell mass, improved oxygen transport, and higher buffering capacity—reach their peak just as you return to sea level. Athletes often report feeling an incredible lightness in their legs and a sense that they can breathe effortlessly at paces that previously felt challenging.'),
          (en: 'To maximize this effect, timing is critical. Many runners aim to race within 48 to 72 hours of leaving altitude, before the body begins to adjust back to sea-level oxygen levels. Another favorable racing window opens around 10 to 14 days later, once the initial fatigue of travel and re-acclimatisation has cleared.', sw: 'To maximize this effect, timing is critical. Many runners aim to race within 48 to 72 hours of leaving altitude, before the body begins to adjust back to sea-level oxygen levels. Another favorable racing window opens around 10 to 14 days later, once the initial fatigue of travel and re-acclimatisation has cleared.'),
          (en: 'The boost in red blood cells gradually fades over three to four weeks as the body returns to its baseline production. However, the mental toughness and the aerobic engine built during those weeks of hard climbing remain, providing a lasting foundation for the racing season.', sw: 'The boost in red blood cells gradually fades over three to four weeks as the body returns to its baseline production. However, the mental toughness and the aerobic engine built during those weeks of hard climbing remain, providing a lasting foundation for the racing season.'),
        ],
      ),
      Lesson(
        title: (en: 'Heat Training as a Substitute', sw: 'Mazoezi ya Joto kama Badala'),
        minutes: 4,
        summary: (en: 'Using heat to mimic blood plasma expansion.', sw: 'Kutumia joto kuiga upanuzi wa plasma.'),
        paragraphs: [
          (en: 'Not everyone can travel to Iten to train. Fortunately, sports science shows that heat training can act as a \'poor man\\\'s altitude.\' Training in hot, humid conditions forces the body to sweat more, which triggers an expansion of blood plasma volume to keep you cool.', sw: 'Not everyone can travel to Iten to train. Fortunately, sports science shows that heat training can act as a \'poor man\\\'s altitude.\' Training in hot, humid conditions forces the body to sweat more, which triggers an expansion of blood plasma volume to keep you cool.'),
          (en: 'This increase in plasma volume improves cardiovascular efficiency by allowing the heart to pump more blood per beat, mimicking some of the aerobic benefits of altitude training. A two-week block of running in hot weather—or using saunas after runs—can significantly boost performance.', sw: 'This increase in plasma volume improves cardiovascular efficiency by allowing the heart to pump more blood per beat, mimicking some of the aerobic benefits of altitude training. A two-week block of running in hot weather—or using saunas after runs—can significantly boost performance.'),
          (en: 'The key is safety: monitor your hydration levels, run at a lower intensity, and allow your body to adapt to the heat gradually. Start with short sessions and slowly build up to 45 minutes of heat exposure.', sw: 'The key is safety: monitor your hydration levels, run at a lower intensity, and allow your body to adapt to the heat gradually. Start with short sessions and slowly build up to 45 minutes of heat exposure.'),
        ],
      ),
      Lesson(
        title: (en: 'Altitude Sickness & Recovery', sw: 'Ugonjwa wa Kimo na Urejeaji'),
        minutes: 4,
        summary: (en: 'Preventing and managing altitude-related issues.', sw: 'Kuzuia na kudhibiti shida za kimo.'),
        paragraphs: [
          (en: 'Acute Mountain Sickness (AMS) can affect anyone, regardless of fitness level. Symptoms include dizziness, fatigue, nausea, and loss of appetite. To prevent AMS, stay hydrated, avoid alcohol, and consume plenty of iron, which your body needs to produce new red blood cells.', sw: 'Acute Mountain Sickness (AMS) can affect anyone, regardless of fitness level. Symptoms include dizziness, fatigue, nausea, and loss of appetite. To prevent AMS, stay hydrated, avoid alcohol, and consume plenty of iron, which your body needs to produce new red blood cells.'),
          (en: 'If you experience symptoms, rest and avoid further ascent. Light walking is acceptable, but strenuous running should be avoided until symptoms resolve. Most mild cases of AMS clear up within 24 to 48 hours as the body adapts.', sw: 'If you experience symptoms, rest and avoid further ascent. Light walking is acceptable, but strenuous running should be avoided until symptoms resolve. Most mild cases of AMS clear up within 24 to 48 hours as the body adapts.'),
          (en: 'Sleep disruption is also common at high altitude due to changes in breathing patterns. Ensure a quiet, dark sleep environment, and avoid heavy meals close to bedtime to help your body recover.', sw: 'Sleep disruption is also common at high altitude due to changes in breathing patterns. Ensure a quiet, dark sleep environment, and avoid heavy meals close to bedtime to help your body recover.'),
        ],
      ),
      Lesson(
        title: (en: 'Borrowing the High-Altitude Mindset', sw: 'Kuchukua Mtazamo wa Kimo cha Juu'),
        minutes: 4,
        summary: (en: 'Simplicity and focus in daily training.', sw: 'Urahisi na umakini katika mazoezi.'),
        paragraphs: [
          (en: 'The success of Kenyan runners is not just physiological; it is cultural. Training in camps like Kaptagat is characterized by extreme simplicity. Athletes live in shared dormitories, wash their own clothes, and focus entirely on running, eating, and sleeping.', sw: 'The success of Kenyan runners is not just physiological; it is cultural. Training in camps like Kaptagat is characterized by extreme simplicity. Athletes live in shared dormitories, wash their own clothes, and focus entirely on running, eating, and sleeping.'),
          (en: 'You can borrow this mindset by eliminating distractions in your own training. Focus on the basics: consistency, quality rest, and proper nutrition. Dedicate specific times for running and recovery, and protect those boundaries.', sw: 'You can borrow this mindset by eliminating distractions in your own training. Focus on the basics: consistency, quality rest, and proper nutrition. Dedicate specific times for running and recovery, and protect those boundaries.'),
          (en: 'Embrace the community aspect of running. Run with others, share your goals, and support each other through the training cycle. The shared effort builds accountability and turns hard workouts into a source of connection.', sw: 'Embrace the community aspect of running. Run with others, share your goals, and support each other through the training cycle. The shared effort builds accountability and turns hard workouts into a source of connection.'),
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
        title: (en: 'The First Steps', sw: 'The First Steps'),
        minutes: 6,
        summary: (en: 'Roots of a running culture.', sw: 'Roots of a running culture.'),
        paragraphs: [
          (en: 'Long before world records and Olympic medals, running was an integral part of life for many communities in East Africa. In the Rift Valley, cattle herding required traveling long distances on foot, often at a jog. Running was also used for communication, with messengers carrying news across hills and valleys.', sw: 'Long before world records and Olympic medals, running was an integral part of life for many communities in East Africa. In the Rift Valley, cattle herding required traveling long distances on foot, often at a jog. Running was also used for communication, with messengers carrying news across hills and valleys.'),
          (en: 'These traditional practices built a foundation of physical endurance and spatial awareness. The transition to competitive sports began in the mid-20th century under British colonial rule, as school and military competitions introduced structured athletic training.', sw: 'These traditional practices built a foundation of physical endurance and spatial awareness. The transition to competitive sports began in the mid-20th century under British colonial rule, as school and military competitions introduced structured athletic training.'),
          (en: 'After independence in 1963, running became a symbol of national identity and pride. The young republic of Kenya looked to its athletes to project its presence on the global stage, and they responded with historic performances.', sw: 'After independence in 1963, running became a symbol of national identity and pride. The young republic of Kenya looked to its athletes to project its presence on the global stage, and they responded with historic performances.'),
        ],
      ),
      Lesson(
        title: (en: 'Mexico 1968', sw: 'Mexico 1968'),
        minutes: 6,
        summary: (en: 'Kip Keino ignites an era.', sw: 'Kip Keino anaanzisha enzi.'),
        paragraphs: [
          (en: 'The 1968 Olympic Games in Mexico City were a turning point for East African athletics. Kipchoge Keino, running despite a severe gallbladder infection, won gold in the 1500 meters, defeating the heavily favored American world-record holder, Jim Ryun, by a historic margin.', sw: 'The 1968 Olympic Games in Mexico City were a turning point for East African athletics. Kipchoge Keino, running despite a severe gallbladder infection, won gold in the 1500 meters, defeating the heavily favored American world-record holder, Jim Ryun, by a historic margin.'),
          (en: 'Keino\\\'s victory was a revelation. It proved that African athletes could compete and win at the highest level, inspiring a generation of young runners across the continent. His performances laid the foundation for the dominance that followed.', sw: 'Keino\\\'s victory was a revelation. It proved that African athletes could compete and win at the highest level, inspiring a generation of young runners across the continent. His performances laid the foundation for the dominance that followed.'),
          (en: 'Keino\\\'s legacy extends beyond his medals; his humility, philanthropy, and dedication to his community set a standard for all future champions, showing that a true legend runs for more than just personal glory.', sw: 'Keino\\\'s legacy extends beyond his medals; his humility, philanthropy, and dedication to his community set a standard for all future champions, showing that a true legend runs for more than just personal glory.'),
        ],
      ),
      Lesson(
        title: (en: 'The Pioneers of Women\'s Running', sw: 'Mashujaa wa Kike wa Kwanza'),
        minutes: 5,
        summary: (en: 'Tegla Loroupe and Catherine Ndereba.', sw: 'Tegla Loroupe na Catherine Ndereba.'),
        paragraphs: [
          (en: 'The rise of female distance running in East Africa was marked by significant social and cultural hurdles. Tegla Loroupe was a trailblazer, winning the New York City Marathon in 1994, the first African woman to do so. She went on to set world records and advocate for peace and women\\\'s rights.', sw: 'The rise of female distance running in East Africa was marked by significant social and cultural hurdles. Tegla Loroupe was a trailblazer, winning the New York City Marathon in 1994, the first African woman to do so. She went on to set world records and advocate for peace and women\\\'s rights.'),
          (en: 'Catherine Ndereba, nicknamed \'Catherine the Great,\' followed in Loroupe\\\'s footsteps, winning the Boston Marathon four times and earning two World Championship gold medals. Her consistency and elegant running style made her a global icon.', sw: 'Catherine Ndereba, nicknamed \'Catherine the Great,\' followed in Loroupe\\\'s footsteps, winning the Boston Marathon four times and earning two World Championship gold medals. Her consistency and elegant running style made her a global icon.'),
          (en: 'These pioneers dismantled the stereotype that distance running was only for men. They created paths for future champions like Faith Kipyegon and Beatrice Chebet, proving that the strength of East African running is shared equally by its daughters.', sw: 'These pioneers dismantled the stereotype that distance running was only for men. They created paths for future champions like Faith Kipyegon and Beatrice Chebet, proving that the strength of East African running is shared equally by its daughters.'),
        ],
      ),
      Lesson(
        title: (en: 'The Regional Rivalry', sw: 'Ushindani wa Kikanda'),
        minutes: 5,
        summary: (en: 'Ethiopian and Ugandan brotherhood.', sw: 'Ushirikiano wa Ethiopia na Uganda.'),
        paragraphs: [
          (en: 'The story of distance running in East Africa is not limited to Kenya. Ethiopia has a long and storied history of athletic excellence, led by legends like Abebe Bikila, Haile Gebrselassie, Kenenisa Bekele, and the Dibaba sisters. Their rivalry with Kenyan runners has pushed both nations to higher levels of performance.', sw: 'The story of distance running in East Africa is not limited to Kenya. Ethiopia has a long and storied history of athletic excellence, led by legends like Abebe Bikila, Haile Gebrselassie, Kenenisa Bekele, and the Dibaba sisters. Their rivalry with Kenyan runners has pushed both nations to higher levels of performance.'),
          (en: 'Uganda has also emerged as a major power, with champions like Stephen Kiprotich, Joshua Cheptegei, and Jacob Kiplimo. Their success shows that the Rift Valley\\\'s running heritage spans across borders, united by similar geography and training philosophies.', sw: 'Uganda has also emerged as a major power, with champions like Stephen Kiprotich, Joshua Cheptegei, and Jacob Kiplimo. Their success shows that the Rift Valley\\\'s running heritage spans across borders, united by similar geography and training philosophies.'),
          (en: 'This regional competition is characterized by mutual respect. While they fight fiercely on the track and road, off the field, athletes often train together, share coaches, and celebrate each other\\\'s achievements, recognizing that they are all part of a shared history.', sw: 'This regional competition is characterized by mutual respect. While they fight fiercely on the track and road, off the field, athletes often train together, share coaches, and celebrate each other\\\'s achievements, recognizing that they are all part of a shared history.'),
        ],
      ),
      Lesson(
        title: (en: 'Political & Cultural Impact', sw: 'Athari za Kisiasa na Kitamaduni'),
        minutes: 4,
        summary: (en: 'Running as a path to economic and social development.', sw: 'Kukimbia kama njia ya maendeleo.'),
        paragraphs: [
          (en: 'In Kenya and Ethiopia, running is more than a sport; it is a major pathway for social mobility and economic advancement. Winning a major international race can transform a runner\\\'s life, providing resources to build homes, invest in farms, and support extended families.', sw: 'In Kenya and Ethiopia, running is more than a sport; it is a major pathway for social mobility and economic advancement. Winning a major international race can transform a runner\\\'s life, providing resources to build homes, invest in farms, and support extended families.'),
          (en: 'Many successful athletes use their earnings to fund community projects, such as building schools, clinics, and clean water systems. They also create employment by establishing training camps and hiring local staff, acting as engines of development in rural areas.', sw: 'Many successful athletes use their earnings to fund community projects, such as building schools, clinics, and clean water systems. They also create employment by establishing training camps and hiring local staff, acting as engines of development in rural areas.'),
          (en: 'The sport also offers career paths within national institutions like the police, military, and prison services, which sponsor athletic teams. This institutional support provides stability and security for runners as they develop their careers.', sw: 'The sport also offers career paths within national institutions like the police, military, and prison services, which sponsor athletic teams. This institutional support provides stability and security for runners as they develop their careers.'),
        ],
      ),
      Lesson(
        title: (en: 'The Diaspora and Global Exchange', sw: 'Diaspora na Mabadilishano ya Dunia'),
        minutes: 4,
        summary: (en: 'Movement of talent across borders.', sw: 'Mzunguko wa talanta mipakani.'),
        paragraphs: [
          (en: 'The success of East African running has created a global network of exchange. Many Kenyan and Ethiopian athletes travel to Europe, the United States, and Asia to train and compete, sharing their methods and learning from other cultures.', sw: 'The success of East African running has created a global network of exchange. Many Kenyan and Ethiopian athletes travel to Europe, the United States, and Asia to train and compete, sharing their methods and learning from other cultures.'),
          (en: 'Conversely, runners and coaches from all over the world travel to places like Iten and Addis Ababa to study the training methods, experience the altitude, and run on the red-dirt trails. This exchange of ideas has enriched the global running community.', sw: 'Conversely, runners and coaches from all over the world travel to places like Iten and Addis Ababa to study the training methods, experience the altitude, and run on the red-dirt trails. This exchange of ideas has enriched the global running community.'),
          (en: 'Some athletes have also chosen to represent other nations, creating a diaspora that spreads East African running talent globally. While this presents complex questions about sports citizenship, it highlights the universal appeal and reach of their running culture.', sw: 'Some athletes have also chosen to represent other nations, creating a diaspora that spreads East African running talent globally. While this presents complex questions about sports citizenship, it highlights the universal appeal and reach of their running culture.'),
        ],
      ),
    ],
  ),
  Course(
    slug: 'the-thursday-fartlek',
    title: (en: 'The Thursday Fartlek', sw: 'Fartlek ya Alhamisi'),
    subtitle: (en: 'The group workout that built an empire.', sw: 'Mazoezi ya kikundi yaliyojenga ufalme.'),
    category: CourseCategory.heritage,
    author: (en: 'Mwendo Heritage', sw: 'Urithi wa Mwendo'),
    lessons: [
      Lesson(
        title: (en: '15 km, Effort Over Pace', sw: 'Kilomita 15, Juhudi Zaidi ya Kasi'),
        minutes: 6,
        summary: (en: 'The legendary session, decoded.', sw: 'Kipindi cha kihistoria, kimefafanuliwa.'),
        paragraphs: [
          (en: 'Every Thursday morning in Iten and Kaptagat, hundreds of runners gather for the weekly fartlek. Fartlek is a Swedish word meaning \'speed play,\' and the session involves alternating periods of fast and slow running. The most famous format is the 15-kilometre effort built on a 3-minute hard, 1-minute easy surge structure.', sw: 'Every Thursday morning in Iten and Kaptagat, hundreds of runners gather for the weekly fartlek. Fartlek is a Swedish word meaning \'speed play,\' and the session involves alternating periods of fast and slow running. The most famous format is the 15-kilometre effort built on a 3-minute hard, 1-minute easy surge structure.'),
          (en: 'The pace is dictated entirely by feel and the group\\\'s collective energy, never by GPS watches. The lead runners push the pace on the surges, and the pack must respond, creating a fluid, high-intensity workout that simulates the unpredictability of racing.', sw: 'The pace is dictated entirely by feel and the group\\\'s collective energy, never by GPS watches. The lead runners push the pace on the surges, and the pack must respond, creating a fluid, high-intensity workout that simulates the unpredictability of racing.'),
          (en: 'This session is designed to train both the aerobic and anaerobic systems, teaching the body to clear lactate while running at a high effort. It also builds mental resilience, as runners must learn to tolerate discomfort and recover on the move.', sw: 'This session is designed to train both the aerobic and anaerobic systems, teaching the body to clear lactate while running at a high effort. It also builds mental resilience, as runners must learn to tolerate discomfort and recover on the move.'),
        ],
      ),
      Lesson(
        title: (en: 'The Origin of the Session', sw: 'Asili ya Kipindi Hiki'),
        minutes: 5,
        summary: (en: 'How speed play was adapted in Kenya.', sw: 'Jinsi speed play ilivyobadilishwa nchini Kenya.'),
        paragraphs: [
          (en: 'Fartlek training was developed in Sweden in the 1930s by coach Gösta Holmér. It was designed to make training more engaging and to build both speed and endurance through structured variety.', sw: 'Fartlek training was developed in Sweden in the 1930s by coach Gösta Holmér. It was designed to make training more engaging and to build both speed and endurance through structured variety.'),
          (en: 'In the 1980s, pioneering coaches in Kenya, including Brother Colm O\\\'Connell, adapted the concept for large group sessions on the dirt roads of the Rift Valley. They found that the format was perfect for managing large groups of runners of varying abilities.', sw: 'In the 1980s, pioneering coaches in Kenya, including Brother Colm O\\\'Connell, adapted the concept for large group sessions on the dirt roads of the Rift Valley. They found that the format was perfect for managing large groups of runners of varying abilities.'),
          (en: 'Over decades, the Thursday fartlek became a cornerstone of the national training system. It transformed a solitary training tool into a collective ritual where Olympic champions and aspiring youngsters run shoulder-to-shoulder, pushing each other to new heights.', sw: 'Over decades, the Thursday fartlek became a cornerstone of the national training system. It transformed a solitary training tool into a collective ritual where Olympic champions and aspiring youngsters run shoulder-to-shoulder, pushing each other to new heights.'),
        ],
      ),
      Lesson(
        title: (en: 'Patrick Sang & Coaching Philosophy', sw: 'Patrick Sang & Coaching Philosophy'),
        minutes: 5,
        summary: (en: 'Humility and mentorship.', sw: 'Humility and mentorship.'),
        paragraphs: [
          (en: 'Patrick Sang, an Olympic silver medalist in the steeplechase, is widely regarded as one of the greatest coaches in running history. He is best known for his long-term partnership with Eliud Kipchoge and his leadership of the Global Sports Communication camp in Kaptagat.', sw: 'Patrick Sang, an Olympic silver medalist in the steeplechase, is widely regarded as one of the greatest coaches in running history. He is best known for his long-term partnership with Eliud Kipchoge and his leadership of the Global Sports Communication camp in Kaptagat.'),
          (en: 'Sang\\\'s coaching philosophy extends far beyond training schedules. He emphasizes character development, humility, and mental discipline, believing that a successful athlete must first be a well-rounded human being.', sw: 'Sang\\\'s coaching philosophy extends far beyond training schedules. He emphasizes character development, humility, and mental discipline, believing that a successful athlete must first be a well-rounded human being.'),
          (en: 'Under Sang\\\'s guidance, the camp operates as a family, where tasks are shared equally and veterans mentor younger athletes. This environment of mutual support and shared responsibility is, in his view, the true secret behind their long-term success.', sw: 'Under Sang\\\'s guidance, the camp operates as a family, where tasks are shared equally and veterans mentor younger athletes. This environment of mutual support and shared responsibility is, in his view, the true secret behind their long-term success.'),
        ],
      ),
      Lesson(
        title: (en: 'Adapting Fartlek for Beginners', sw: 'Kubadilisha Fartlek kwa Wanaoanza'),
        minutes: 4,
        summary: (en: 'Bringing speed play into your training.', sw: 'Kuleta speed play katika mazoezi yako.'),
        paragraphs: [
          (en: 'You do not need to be an elite runner to benefit from fartlek training. The format is highly adaptable and can be scaled to any fitness level. For beginners, a simple landmark-to-landmark approach works best: jog to the next telephone pole, sprint to the tree, and walk to recover.', sw: 'You do not need to be an elite runner to benefit from fartlek training. The format is highly adaptable and can be scaled to any fitness level. For beginners, a simple landmark-to-landmark approach works best: jog to the next telephone pole, sprint to the tree, and walk to recover.'),
          (en: 'Another beginner-friendly option is a structured time-based fartlek: alternate 1 minute of strong running with 2 minutes of easy jogging. Perform this cycle five to eight times during a normal run.', sw: 'Another beginner-friendly option is a structured time-based fartlek: alternate 1 minute of strong running with 2 minutes of easy jogging. Perform this cycle five to eight times during a normal run.'),
          (en: 'The key is to keep it playful and listen to your body. Do not worry about your exact pace; focus on changing your breathing rate and effort level. Fartleks are a great way to introduce speed training without the pressure of the track.', sw: 'The key is to keep it playful and listen to your body. Do not worry about your exact pace; focus on changing your breathing rate and effort level. Fartleks are a great way to introduce speed training without the pressure of the track.'),
        ],
      ),
      Lesson(
        title: (en: 'Sample Fartlek Workouts', sw: 'Mifano ya Mazoezi ya Fartlek'),
        minutes: 4,
        summary: (en: 'Three classic routines to try.', sw: 'Mifano mitatu ya fartlek kujaribu.'),
        paragraphs: [
          (en: 'Here are three classic fartlek sessions you can incorporate into your training program:', sw: 'Here are three classic fartlek sessions you can incorporate into your training program:'),
          (en: '**The 1-on-1:** Alternate 1 minute hard and 1 minute easy for 15 to 20 minutes. This is a great introduction to speed play and builds quick turnover.', sw: '**The 1-on-1:** Alternate 1 minute hard and 1 minute easy for 15 to 20 minutes. This is a great introduction to speed play and builds quick turnover.'),
          (en: '**The Pyramid:** Run 1 min hard, 1 min easy, 2 min hard, 2 min easy, 3 min hard, 3 min easy, then work your way back down (2 min hard, 2 min easy, 1 min hard, 1 min easy). This session teaches pacing and mental stamina.', sw: '**The Pyramid:** Run 1 min hard, 1 min easy, 2 min hard, 2 min easy, 3 min hard, 3 min easy, then work your way back down (2 min hard, 2 min easy, 1 min hard, 1 min easy). This session teaches pacing and mental stamina.'),
          (en: '**The Ladder:** Run 2 min hard, 1 min easy, 3 min hard, 1 min easy, 4 min hard, 2 min easy. This is a challenging workout that simulates the late-race surges of a 5K or 10K.', sw: '**The Ladder:** Run 2 min hard, 1 min easy, 3 min hard, 1 min easy, 4 min hard, 2 min easy. This is a challenging workout that simulates the late-race surges of a 5K or 10K.'),
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
        title: (en: 'A Map of Camps', sw: 'A Map of Camps'),
        minutes: 5,
        summary: (en: 'Where legends are made.', sw: 'Where legends are made.'),
        paragraphs: [
          (en: 'The high-altitude towns of the Rift Valley host a network of training camps that are the engines of East African running success. Iten, sitting on the edge of the escarpment at 2,400 meters, is the most famous, calling itself the \'City of Champions.\'', sw: 'The high-altitude towns of the Rift Valley host a network of training camps that are the engines of East African running success. Iten, sitting on the edge of the escarpment at 2,400 meters, is the most famous, calling itself the \'City of Champions.\''),
          (en: 'Nearby Kaptagat is known for its forest trails and the Global Sports Communication camp, which favors a secluded, natural environment. Eldoret and Ngong Hills also host major camps, each offering a unique blend of terrain, climate, and community support.', sw: 'Nearby Kaptagat is known for its forest trails and the Global Sports Communication camp, which favors a secluded, natural environment. Eldoret and Ngong Hills also host major camps, each offering a unique blend of terrain, climate, and community support.'),
          (en: 'These camps are not luxury training facilities; they are simple, functional environments designed to eliminate distractions and foster a singular focus on training and recovery.', sw: 'These camps are not luxury training facilities; they are simple, functional environments designed to eliminate distractions and foster a singular focus on training and recovery.'),
        ],
      ),
      Lesson(
        title: (en: 'A Day in the Life at Kaptagat', sw: 'Siku Moja Kule Kaptagat'),
        minutes: 5,
        summary: (en: 'Routine, simplicity, and community work.', sw: 'Ratiba, urahisi, na kazi ya pamoja.'),
        paragraphs: [
          (en: 'A typical day in a Kenyan training camp begins before dawn. At 5:00 AM, runners rise for their first training session, usually a long, progressive run on the dirt roads. Returning to camp, they share a simple breakfast of tea, bread, and eggs.', sw: 'A typical day in a Kenyan training camp begins before dawn. At 5:00 AM, runners rise for their first training session, usually a long, progressive run on the dirt roads. Returning to camp, they share a simple breakfast of tea, bread, and eggs.'),
          (en: 'Mid-morning is dedicated to recovery and daily chores. In camps like Kaptagat, even world champions clean the toilets, sweep the compound, and fetch water. This shared labor keeps athletes grounded and reinforces the camp\\\'s egalitarian culture.', sw: 'Mid-morning is dedicated to recovery and daily chores. In camps like Kaptagat, even world champions clean the toilets, sweep the compound, and fetch water. This shared labor keeps athletes grounded and reinforces the camp\\\'s egalitarian culture.'),
          (en: 'After lunch and a long nap, athletes head out for a second, lighter run at 4:00 PM. The evening is spent relaxing, sharing stories, and eating a dinner of ugali, greens, and beans before an early bedtime at 9:00 PM.', sw: 'After lunch and a long nap, athletes head out for a second, lighter run at 4:00 PM. The evening is spent relaxing, sharing stories, and eating a dinner of ugali, greens, and beans before an early bedtime at 9:00 PM.'),
        ],
      ),
      Lesson(
        title: (en: 'The Camp Economics', sw: 'Uchumi wa Kambi za Mbio'),
        minutes: 5,
        summary: (en: 'How running lifts entire regions.', sw: 'Jinsi mafanikio yanavyoinua maeneo yote.'),
        paragraphs: [
          (en: 'The financial rewards of distance running are significant, and in Kenya, they are quickly distributed through the community. Prize money won at international marathons is used to buy land, invest in dairy farms, and build commercial properties in towns like Eldoret.', sw: 'The financial rewards of distance running are significant, and in Kenya, they are quickly distributed through the community. Prize money won at international marathons is used to buy land, invest in dairy farms, and build commercial properties in towns like Eldoret.'),
          (en: 'Many athletes support their families and pay school fees for relative children. They also fund local development projects, including building churches, supporting local schools, and funding clean water initiatives.', sw: 'Many athletes support their families and pay school fees for relative children. They also fund local development projects, including building churches, supporting local schools, and funding clean water initiatives.'),
          (en: 'This economic model ensures that running is not just an individual pursuit but a collective endeavor, where the success of a single athlete can lift an entire village, providing a powerful motivator for the next generation of runners.', sw: 'This economic model ensures that running is not just an individual pursuit but a collective endeavor, where the success of a single athlete can lift an entire village, providing a powerful motivator for the next generation of runners.'),
        ],
      ),
      Lesson(
        title: (en: 'Managers, Agents, and Global Circuit', sw: 'Meneja, Mawakala, na Mashindano ya Dunia'),
        minutes: 4,
        summary: (en: 'Navigating the professional business.', sw: 'Kuelekeza biashara ya kitaalamu.'),
        paragraphs: [
          (en: 'Behind the athletes is a network of coaches, managers, and agents who handle the business of professional running. They coordinate race entries, manage sponsorships, and handle travel logistics, allowing athletes to focus entirely on their training.', sw: 'Behind the athletes is a network of coaches, managers, and agents who handle the business of professional running. They coordinate race entries, manage sponsorships, and handle travel logistics, allowing athletes to focus entirely on their training.'),
          (en: 'Many agencies, such as Global Sports Communication and Rosa Associati, have long-standing relationships with Kenyan camps, providing coaching support and physiological testing.', sw: 'Many agencies, such as Global Sports Communication and Rosa Associati, have long-standing relationships with Kenyan camps, providing coaching support and physiological testing.'),
          (en: 'Navigating this professional landscape requires trust and mutual understanding. A good manager protects the athlete\\\'s interests, manages their racing schedule to prevent burnout, and helps them build a sustainable career.', sw: 'Navigating this professional landscape requires trust and mutual understanding. A good manager protects the athlete\\\'s interests, manages their racing schedule to prevent burnout, and helps them build a sustainable career.'),
        ],
      ),
      Lesson(
        title: (en: 'How to Visit and Train', sw: 'Jinsi ya Kutembelea na Kufanya Mazoezi'),
        minutes: 4,
        summary: (en: 'Respecting local trails and champions.', sw: 'Kuheshimu njia na mashujaa wa eneo.'),
        paragraphs: [
          (en: 'Every year, hundreds of international runners travel to Iten to experience high-altitude training. Guest houses like Lornah Kiplagat\\\'s High Altitude Training Centre provide modern facilities, while allowing visitors to run on the same red-dirt roads as the champions.', sw: 'Every year, hundreds of international runners travel to Iten to experience high-altitude training. Guest houses like Lornah Kiplagat\\\'s High Altitude Training Centre provide modern facilities, while allowing visitors to run on the same red-dirt roads as the champions.'),
          (en: 'When visiting, respect for local customs and trails is essential. Be mindful of the local farming communities, greet people on the roads, and run in single file on busy sections.', sw: 'When visiting, respect for local customs and trails is essential. Be mindful of the local farming communities, greet people on the roads, and run in single file on busy sections.'),
          (en: 'Do not attempt to match the pace of the elite groups on your first day. Start slowly, give your body time to adapt to the altitude, and focus on learning from the local runners\\\' patience and dedication.', sw: 'Do not attempt to match the pace of the elite groups on your first day. Start slowly, give your body time to adapt to the altitude, and focus on learning from the local runners\\\' patience and dedication.'),
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
