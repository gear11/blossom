# blossom
A simple solver for the [Webster Blossom](https://www.merriam-webster.com/games/blossom-word-game) game

Usage:
  
>  dart blossom.dart [required letter] [available letters]

Loops asking the user to enter the current bonus letter and picks the highest scoring word.
Words are loaded from a Scrabble dictionary (Collins Scrabble Dictionary) in the file `scrabble.txt`.
Many of the Scrabble words are not playable in Blossom; if a word is not playable, simply keep entering the
bonus letter until a playable word is found. Non-playable words can be added to `invalid.txt` to remove them from
future consideration.
