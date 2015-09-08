# countdown
Solver for the puzzles featured on the game show Countdown

## Usage
Make sure countdown.pl and words.txt are in the same directory, then run
`./countdown.pl --_mode_ <args>` where mode and args are described below.

### Modes
--letters  
Args should be either 9 letters (separated by spaces) or a 9 character string.
eg. `./countdown.pl --letters abcdefghi`. The solver will look for any words in
 words.txt that can be formed using only the provided letters and then print
 them in order from shortest to longest.

--conundrum  
The same as --letters, but the solver will only consider 9 letter words.

--numbers
Args should be 7 numbers separated by spaces, the 6 chosen numbers should appear
 first and the target number last.
eg. `./countdown.pl --numbers 100 25 4 7 3 5 297`. The solver will build a set
 of expression trees that use the chosen numbers at most once each and give a
 value within 10 (above or below) of the target.

## Todo
* Implement teaser mode (same as conundrum but could use less than 9 letters)
* Improve numbers solver efficiency
* Add validation to numbers mode
  * numbers must be positive
  * values > 10 can appear at most once each and must be a multiple of 25
  * values <= 10 can appear twice at most
