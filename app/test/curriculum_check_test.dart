import 'package:flutter_test/flutter_test.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';

void main() {
  test('Verify Learn screen courses count and structure', () {
    expect(courses.length, 10, reason: 'There should be exactly 10 courses in total');

    final expectedSlugs = [
      'how-to-start-running',
      'heart-rate-zones',
      'running-form',
      'nutrition-for-runners',
      'injury-prevention',
      'women-in-running',
      'altitude-training',
      'history-of-east-african-running',
      'the-thursday-fartlek',
      'training-camps',
    ];

    for (int i = 0; i < expectedSlugs.length; i++) {
      expect(courses[i].slug, expectedSlugs[i], reason: 'Course at index $i should have slug ${expectedSlugs[i]}');
      expect(courses[i].title.en.isNotEmpty, true, reason: 'Course ${courses[i].slug} English title should not be empty');
      expect(courses[i].title.sw.isNotEmpty, true, reason: 'Course ${courses[i].slug} Swahili title should not be empty');
      expect(courses[i].lessons.isNotEmpty, true, reason: 'Course ${courses[i].slug} should have lessons');

      for (final lesson in courses[i].lessons) {
        expect(lesson.title.en.isNotEmpty, true, reason: 'Lesson title in ${courses[i].slug} should not be empty');
        expect(lesson.title.sw.isNotEmpty, true, reason: 'Lesson Swahili title in ${courses[i].slug} should not be empty');
        expect(lesson.summary.en.isNotEmpty, true, reason: 'Lesson summary in ${courses[i].slug} should not be empty');
        expect(lesson.summary.sw.isNotEmpty, true, reason: 'Lesson Swahili summary in ${courses[i].slug} should not be empty');
        expect(lesson.paragraphs.isNotEmpty, true, reason: 'Lesson ${lesson.title.en} in ${courses[i].slug} should have paragraphs');

        for (final p in lesson.paragraphs) {
          expect(p.en.isNotEmpty, true, reason: 'Paragraph in ${lesson.title.en} should not be empty');
          expect(p.sw.isNotEmpty, true, reason: 'Swahili paragraph in ${lesson.title.en} should not be empty');
        }
      }
    }
  });
}
