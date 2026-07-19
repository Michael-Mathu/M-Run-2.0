/// Template-based milestone stories (no AI). Given an achievement, returns a
/// short, motivational paragraph rooted in East African running heritage.
/// Fully offline and deterministic.
String buildMilestoneStory({
  required String achievement,
  String name = 'Runner',
}) {
  const openers = [
    'The red dirt of the Rift Valley has shaped champions for generations, and today it shaped you.',
    'From the training camps of Iten to the streets of Berlin, every great Kenyan runner started with one brave step.',
    'Kipchoge once said the will is what matters most. Yours just grew a little stronger.',
    'In Eldoret they say a run is a conversation with the earth. You listened closely today.',
  ];
  final opener = openers[achievement.length % openers.length];
  return '$opener\n\n'
      'Congratulations, $name — you unlocked "$achievement". '
      'Legends like Keino, Tergat and Kipyegon were once where you are now: lacing up, showing up, and refusing to quit. '
      'Keep showing up. The next milestone is already within reach.';
}

/// Shorter, punchy variant for toast-style celebration.
String milestoneToast(String achievement) =>
    'Milestone unlocked: $achievement. Keep the streak alive!';
