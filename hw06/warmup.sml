(***** Problem 1 *****)

(* mynull : 'a list -> bool *)
(* function when applied to a list tells whether the list is empty *)
fun mynull [] = true
    | mynull _ = false;

(* Unit Test *)
        val () =
            Unit.checkAssert "[] is null"
            (fn () => mynull [])

        val () =
            Unit.checkAssert "[1, 2, 3] is not null"
            (fn () => not (mynull [1, 2, 3]))


(***** Problem 2a *****)
(* function that reverses a list *)
fun reverse xs =
  foldl (fn (x, acc) => x :: acc) [] xs;

(* Unit Test *)
        val () =
            Unit.checkExpectWith (Unit.listString Unit.intString)
            "reverse of [1, 2, 3] is [3, 2, 1]"
            (fn () => reverse [1, 2, 3])
            [3, 2, 1]

(***** Problem 2b *****)
(* returns the smallest element of a nonempty list of integers *)
fun minlist xs =
  case xs of
      []      => raise Match
    | x :: xr => foldl Int.min x xr;

(* Unit Test *)
        val () =
            Unit.checkExpectWith Unit.intString
            "minlist of [5, 2, ~3, 4] is ~3"
            (fn () => minlist [5, 2, ~3, 4])
            ~3

val () = Unit.reportWhenFailures ()  (* put me at the _end_ *)

(***** Problem 3 *****)
(* takes a pair of lists (of equal length) and returns the equivalent 
list of pairs *)
exception Mismatch;
fun zip (xs, ys) =
  case (xs, ys) of
      ([], []) => []
    | (x::xr, y::yr) => (x, y) :: zip (xr, yr)
    | _ => raise Mismatch;

(* Unit Test *)
        val () =
            Unit.checkExpectWith (Unit.listString (Unit.pairString Unit.intString Unit.boolString))
            "zip ([1, 2], [true, false])"
            (fn () => zip ([1, 2], [true, false]))
            [(1, true), (2, false)]


(***** Problem 4 *****)
(* function that behaves like foldr, but walks a three-argument function over 
a pair of lists of equal length *)
fun pairfoldrEq f z (xs, ys) =
case (xs, ys) of
    ([], []) => z
    | (x::xr, y::yr) =>
        f (x, y, pairfoldrEq f z (xr, yr))
    | _ => raise Mismatch;

(* Unit Test *)
        val () =
            Unit.checkExpectWith Unit.intString
            "pairfoldrEq dot product of [1, 2] and [3, 4]"
            (fn () => pairfoldrEq (fn (x, y, acc) => x * y + acc) 0 ([1, 2], [3, 4]))
            11  (* (1*3) + (2*4) *)


(***** Problem 5 *****)
(* function that takes a list of lists of 'a and produces a single list of 
'a containing all the elements in the correct order *)
fun concat xss =
  foldr (op @) [] xss;

(* Unit Test *)
        (* val () = *)
            (* Unit.checkExpectWith int_list_toString
            "concat example"
            (fn () => concat [[1], [2,3,4], [], [5,6]])
            [1,2,3,4,5,6]; *)

        val () =
            Unit.checkExpectWith (Unit.listString Unit.intString)
            "concat [[1], [2, 3], [4]]"
            (fn () => concat [[1], [2, 3], [4]])
            [1, 2, 3, 4]

(***** Problem 6 *****)
datatype ordsx 
  = BOOL of bool
  | NUM  of int
  | SYM  of string
  | SXS  of ordsx list

(* function that converts a list of numbers into an ordinary S-expression. *)
fun numbersSx ns =
  SXS (map NUM ns);

(* function that extracts just the symbols from an ordinary S-expression *)
fun sxString (SYM s)   = s
| sxString (NUM n)   = Unit.intString n
| sxString (BOOL b)  = if b then "true" else "false"
| sxString (SXS sxs) =
    "(" ^ String.concatWith " "
        (map sxString sxs)
    ^ ")";

(* Unit Test *)
        val () =
            Unit.checkExpectWith (fn x => x)
            "sxString nested list"
            (fn () => sxString (SXS [NUM 1, SXS [SYM "a", BOOL true]]))
            "(1 (a true))"

        val () =
        Unit.checkExpectWith (fn x => sxString x)
            "numbersSx example"
            (fn () => numbersSx [1,2,3])
            (SXS [NUM 1, NUM 2, NUM 3]);

        val () =
        Unit.checkExpectWith sxString
            "numbersSx empty"
            (fn () => numbersSx [])
            (SXS []);

        val () =
        Unit.checkExpectWith sxString
            "numbersSx negatives"
            (fn () => numbersSx [~1, 5])
            (SXS [NUM ~1, NUM 5]);