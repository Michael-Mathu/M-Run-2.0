import 'package:flutter_test/flutter_test.dart';
import 'package:mwendo_fit_parser/mwendo_fit_parser.dart';

void main() {
  test('MwendoFitParser singleton instance check', () {
    final parser = MwendoFitParser.instance;
    expect(parser, isNotNull);
  });
}
