import 'dart:math';

class MotivationalQuotes {
  static final List<Map<String, String>> _quotes = [
    {
      'quote': 'Focus is the gateway to thinking clearly.',
      'author': 'Naval Ravikant',
    },
    {
      'quote':
          'The successful warrior is the average man, with laser-like focus.',
      'author': 'Bruce Lee',
    },
    {
      'quote':
          'Concentrate all your thoughts upon the work in hand. The sun\'s rays do not burn until brought to a focus.',
      'author': 'Alexander Graham Bell',
    },
    {
      'quote':
          'It\'s not always that we need to do more but rather that we need to focus on less.',
      'author': 'Nathan W. Morris',
    },
    {
      'quote': 'Where focus goes, energy flows.',
      'author': 'Tony Robbins',
    },
    {
      'quote':
          'The key to success is to focus our conscious mind on things we desire, not things we fear.',
      'author': 'Brian Tracy',
    },
    {
      'quote':
          'Lack of direction, not lack of time, is the problem. We all have twenty-four hour days.',
      'author': 'Zig Ziglar',
    },
    {
      'quote': 'Your focus determines your reality.',
      'author': 'George Lucas',
    },
    {
      'quote':
          'The shorter way to do many things is to only do one thing at a time.',
      'author': 'Mozart',
    },
    {
      'quote': 'Starve your distractions, feed your focus.',
      'author': 'Unknown',
    },
    {
      'quote': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss',
    },
    {
      'quote':
          'The ability to concentrate and to use your time well is everything.',
      'author': 'Lee Iacocca',
    },
    {
      'quote': 'What you stay focused on will grow.',
      'author': 'Roy T. Bennett',
    },
    {
      'quote':
          'One reason so few of us achieve what we truly want is that we never direct our focus.',
      'author': 'Tony Robbins',
    },
    {
      'quote':
          'The secret of change is to focus all of your energy not on fighting the old, but on building the new.',
      'author': 'Socrates',
    },
    {
      'quote':
          'You can\'t depend on your eyes when your imagination is out of focus.',
      'author': 'Mark Twain',
    },
    {
      'quote': 'Concentration is the secret of strength.',
      'author': 'Ralph Waldo Emerson',
    },
    {
      'quote':
          'The most important thing is to keep the most important thing the most important thing.',
      'author': 'Donald P. Coduto',
    },
    {
      'quote':
          'Productivity is never an accident. It is always the result of a commitment to excellence.',
      'author': 'Paul J. Meyer',
    },
    {
      'quote':
          'Deep work is the ability to focus without distraction on a cognitively demanding task.',
      'author': 'Cal Newport',
    },
  ];

  static Map<String, String> getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  static Map<String, String> getQuoteByIndex(int index) {
    return _quotes[index % _quotes.length];
  }

  static int get totalQuotes => _quotes.length;
}
