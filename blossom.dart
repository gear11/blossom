import 'dart:io';
import 'dart:convert';
import 'dart:async';

void main(List<String> args) async {
  if (args.length != 2) {
    throw ArgumentError('Usage: blossom.dart [required letter] [available letters]');
  }
  final requiredLetter = args[0].toLowerCase();
  if (requiredLetter.length > 1) {
    throw ArgumentError('Usage: blossom.dart [required letter] [available letters], "$requiredLetter" must be one letter');
  }
  final availableChars = asSet(args[1].toLowerCase());
  availableChars.add(requiredLetter);
  final Set<String> dictionary = await loadWords('scrabble.txt');
  final Set<String> invalidWords = await loadWords('invalid.txt');
  Set<String> words = {};
  dictionary.forEach((word) {
    if (!invalidWords.contains(word) &&
        word.length > 3 &&
        word.contains(requiredLetter) &&
        containsOnly(availableChars, word)
    ) {
      words.add(word);
    }
  });

  while (true) {
    print('Enter the next bonus letter: ');
    String? bonusLetter = stdin.readLineSync();
    if (bonusLetter == null || bonusLetter.length != 1) {
      break;
    }
    final word = findBestWord(words, availableChars, requiredLetter, bonusLetter);
    words.remove(word); // Can't replay a word
  }
}

/**
 * Loads words from the given file, one per line.
 */
Future<Set<String>> loadWords(String filename) async {
  final file = File(filename);
  Stream<String> lines = file.openRead()
      .transform(utf8.decoder)       // Decode bytes to UTF-8.
      .transform(LineSplitter())    // Convert stream to individual lines
      .transform(toLowerCase());

  final Set<String> words = {};
  try {
    await lines.forEach((line) { words.add(line); });
    print('Loaded ${words.length} words from $filename.');
  } catch (e) {
    print('Error: $e');
  }
  return words;
}

/**
 * Finds the best scoring word from the given list of valid words, considering
 * available letters, the required letter, and the current bonus letter.
 */
String findBestWord(Set<String> validWords, Set<String> availableLetters, String requiredLetter, String bonusLetter) {
  String bestWord = '';
  int bestScore = 0;
  int bestRequired = 0;
  for (String word in validWords) {
    final wordScore = score(availableLetters, word, bonusLetter);
    final wordRequired = count(word, requiredLetter);
    final isBetter = wordScore > bestScore
      || (wordScore == bestScore && word.length - wordRequired < bestWord.length - bestRequired); // if equal score, favor shorter or more required
    if (isBetter) {
      bestScore = wordScore;
      bestWord = word;
      bestRequired = wordRequired;
    }
  }
  print('$bestWord: ${bestScore} points');
  return bestWord;
}

/**
 * Counts the instances of a character in the given word.
 */
int count(String word, String char) {
  int cnt = 0;
  for (int i = 1; i < word.length; ++i) {
    if (word[i] == char) {
      ++cnt;
    }
  }
  return cnt;
}

/**
 * Returns true iff the given word contains only characters in the given set.
 */
bool containsOnly(Set<String> chars, String word) {
  for (var ch in word.split('')) {
    if (!chars.contains(ch)) {
      //print('Excluding $value due to $ch');
      return false;
    }
  }
  return true;
}

/**
 * Scores the given word based on Webster Blossom rules.
 */
int score(Set<String> availableLetters, String word, String bonusChar) {
  var score = 0;
  if (word.length == 4) {
    score = 2;
  } else if (word.length == 5) {
    score = 4;
  } else if (word.length == 6) {
    score = 6;
  } else if (word.length == 7) {
    score = 12;
  } else {
    score = 15;
  }
  // Is it a pangram?
  if (containsOnly(asSet(word), availableLetters.join(''))) {
    score += 7;
  }
  word.split('').forEach((ch) {
    if (ch == bonusChar) {
      score += 5;
    }
  });
  return score;
}

/**
 * Converts the given string to a set of single-character strings.
 */
Set<String> asSet(String value) {
  final Set<String> chars = {};
  value.split('').forEach((ch) { chars.add(ch); });
  return chars;
}

/**
 * A stream transformer to lowercase its input.
 */
StreamTransformer<String,String> toLowerCase() {
  return StreamTransformer.fromHandlers(handleData: (value, sink) {
    sink.add(value.toLowerCase());
  });
}

