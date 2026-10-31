## ------------------------------------------------------------------------------------ ##
#  Colour helpers                                                                        #
## ------------------------------------------------------------------------------------ ##
{ lib }:

let
  digits = lib.strings.stringToCharacters "0123456789abcdef";
  digitIdx = c: lib.lists.findFirstIndex (x: x == c) 0 digits;

  # Read channel `i` (0-2) of a "#rrggbb" string as an integer.
  channel =
    s: i:
    let
      pair = lib.strings.substring (1 + i * 2) 2 s;
    in
    digitIdx (lib.strings.substring 0 1 pair) * 16 + digitIdx (lib.strings.substring 1 1 pair);

  hexOf = n: builtins.elemAt digits (lib.mod (n / 16) 16) + builtins.elemAt digits (lib.mod n 16);
in
{
  /*
    Blend two "#rrggbb" colours.

    `ratio` is how far the result sits from `a` toward `b`: 0 returns `a`,
    1 returns `b`, 0.5 is the midpoint. Useful for the tones a base16 palette
    does not provide, e.g. a surface sitting between base01 and base02.

    Example:
      blend 0.4 "#0b342d" "#184e45" => "#103e36"
  */
  blend =
    ratio: a: b:
    let
      mix = i: channel a i + lib.floor ((channel b i - channel a i) * ratio);
    in
    "#"
    + lib.concatMapStrings hexOf (
      map mix [
        0
        1
        2
      ]
    );
}
