import 'package:flutter_test/flutter_test.dart';
import 'package:pingme/utils/motivational_quotes.dart';

void main() {
  group('MotivationalQuotes Tests', () {
    test('getRandomQuote should return a valid quote', () {
      final quote = MotivationalQuotes.getRandomQuote();
      expect(quote, isNotNull);
      expect(quote['quote'], isNotNull);
      expect(quote['author'], isNotNull);
    });

    test('getQuoteByIndex should return quote at valid index', () {
      final quote = MotivationalQuotes.getQuoteByIndex(0);
      expect(quote, isNotNull);
      expect(quote['quote'], isNotNull);
      expect(quote['author'], isNotNull);
    });

    test('totalQuotes should be 20', () {
      expect(MotivationalQuotes.totalQuotes, 20);
    });
  });
}
