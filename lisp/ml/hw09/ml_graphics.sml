(* ml_graphics.sml
 *
 * Starter code for Part A of Homework 09, CS 105: Programming Langauges
 *
 * This homework (and starter code) is adapted from an assignment for a
 * Programming Languages course at the University of Washington.
 *
 * Edited for CS 105 by Sasha Fedchin and Richard Townsend
 *)

datatype geom_exp = 
    NoPoints
  | Point of real * real
  | Line of real * real
  | VerticalLine of real
  | LineSegment of real * real * real * real
  | Intersect of geom_exp * geom_exp
  | Let of string * geom_exp * geom_exp
  | Var of string
  | Shift of real * real * geom_exp

type env = (string * geom_exp) list

exception BadProgram of string
exception Impossible of string
exception NotImplemented

(***************************************************)
(******** Helper Functions and Definitions *********)
(***************************************************)

(* The error we're willing to admit when comparing two floats for equality. 
   DO NOT MODIFY THIS VALUE! *)
val epsilon = 0.00001

(* realClose : real -> real -> bool

   Returns true if r1 and r2 are "close enough" to be considered equal. *)
fun realClose r1 r2 =
  Real.abs (r1 - r2) < epsilon

(* realClosePoint : real -> real -> real -> real -> bool

   Returns true if the points (x1, y1) and (x2, y2) are "close enough" to be
   considered equal. *)
fun realClosePoint x1 y1 x2 y2 =
  realClose x1 x2 andalso realClose y1 y2

(* intersect : geom_exp * geom_exp -> geom_exp 
 *
 * Return the intersection of two geometric literal expressions. There are 25
 * cases to consider because there are 5 kinds of values (each of which could
 * intersect with every other kind of value), but many cases can be captured at
 * once via pattern matching, especially because intersection is commutative.
 *
 * Raises an Impossible exception if either argument is a non-literal
 * expression.
 *)
fun intersect (v1, v2) =
  case (v1, v2) of
    (NoPoints, _) => NoPoints (* 5 cases *)
  | (_, NoPoints) => NoPoints (* 4 additional cases *)
  | (Point (x, y), Point (x', y'))   => if realClosePoint x y x' y' 
                                        then v1 
                                        else NoPoints
  | (Point (x, y), Line (m, b))      => if realClose y (m * x + b) 
                                        then v1 
                                        else NoPoints
  | (Point (x, _), VerticalLine x')  => if realClose x x' 
                                        then v1 
                                        else NoPoints
  | (Point _, LineSegment _)         => intersect (v2, v1)
  | (Line (m1, b1), VerticalLine x2) => Point (x2, m1 * x2 + b1)
  | (Line (m1, b1), Line (m2, b2))   => if realClose m1 m2 
                                        then if realClose b1 b2 
                                             then v1 (* same line *)
                                             else NoPoints 
                                        else (* one-point intersection *)
                                             let val x = (b2 - b1) / (m1 - m2)
                                                 val y = m1 * x + b1
                                             in Point (x, y) end
  | (Line _, LineSegment _)          => intersect (v2, v1)
  | (Line _, Point _)                => intersect (v2, v1)
  | (VerticalLine x1, VerticalLine x2) => if realClose x1 x2 
                                          then v1 
                                          else NoPoints
  | (VerticalLine _, Point _)          => intersect (v2, v1)
  | (VerticalLine _, Line _)           => intersect (v2, v1)
  | (VerticalLine _, LineSegment _)    => intersect (v2, v1)
  | (LineSegment (x1, y1, x2, y2), _)  =>
    (* twoPointsToLine : real * real * real * real -> geom_exp
     *
     * Return the Line or VerticalLine containing points (x1, y1) and (x2, y2).
     *)
    let fun twoPointsToLine (x1, y1, x2, y2) =
              if realClose x1 x2 
              then VerticalLine x1
              else let val m = (y1 - y2) / (x1 - x2)
                       val b = y2 - m * x2
                   in Line (m, b) end
    in (* The hard case, actually 4 cases because v2 could be:
        * a point, line, vertical line, or line segment.
        * First compute the intersection of (1) the line containing the segment 
        * and (2) v2. Then use that result to compute what we need. *)
       (case intersect (twoPointsToLine (x1, y1, x2, y2), v2) of
         NoPoints => NoPoints
       | Point (x0, y0) => (* see if the point is within the segment bounds *)
          (* assumes v1 was properly preprocessed *)
          let fun inbetween v end1 end2 =
                   (end1 - epsilon <= v andalso v <= end2 + epsilon)
            orelse (end2 - epsilon <= v andalso v <= end1 + epsilon) 
          in if inbetween x0 x2 x1 andalso inbetween y0 y2 y1
             then Point (x0, y0)
             else NoPoints
          end
       | Line _ => v1 (* so the segment is on line v2 *)
       | VerticalLine _ => v1 (* so the segment is on vertical-line v2 *)
       | LineSegment (ox1, oy1, ox2, oy2) => 
       (* the hard case in the hard case: the two segments are on the same
        * line (or vertical line), but they could be (1) disjoint or 
        * (2) overlapping or (3) one inside the other or (4) just touching.
        * And we treat vertical segments differently, so there are 4*2 cases. *)
         let val seg = (x1, y1, x2, y2)
             val seg2 = (ox1, oy1, ox2, oy2)
         in if realClose x1 x2 
            then (* the segments are on a vertical line *)
              (* let segment a start at or below start of segment b *)
              let val ((aXend, aYend, aXstart, aYstart),
                       (bXend, bYend, bXstart, bYstart)) = 
                      if y2 < oy2 then (seg, seg2) else (seg2, seg)
              in if realClose aYend bYstart 
                 then Point (aXend, aYend) (* just touching *)
                 else if aYend < bYstart
                      then NoPoints (* disjoint *)
                      else if aYend > bYend 
                                (* b inside a *)
                           then LineSegment (bXend, bYend, bXstart, bYstart) 
                                (* overlap *)
                           else LineSegment (aXend, aYend, bXstart, bYstart) 
              end
            else (* the segments are on a non-vertical line *)
              (* let segment a start at or to the left of start of segment b *)
              let val ((aXend, aYend, aXstart, aYstart),
                       (bXend, bYend, bXstart, bYstart)) = 
                      if x2 < ox2 then (seg, seg2) else (seg2, seg)
              in if realClose aXend bXstart 
                 then Point (aXend, aYend) (* just touching *)
                 else if aXend < bXstart 
                      then NoPoints (* disjoint *)
                      else if aXend > bXend 
                                (* b inside a *)
                           then LineSegment (bXend, bYend, bXstart, bYstart) 
                                (* overlap *)
                           else LineSegment (aXend, aYend, bXstart, bYstart)
              end
         end
       | _ => raise Impossible "bad result from intersecting with a line") 
    end
  | _ => raise Impossible "bad call to intersect: only for shape values"

(*****************************************************)
(******** The Interpreter (Problems 1 and 2) *********)
(*****************************************************)

(* evalProg : geom_exp -> env -> geom_exp
 *
 * This function is the interpreter for our language. Given a preprocessed 
 * expression e and an evironment rho, evaluate e under rho and return the
 * resulting geometry value (represented as a literal expression). See the
 * homework spec for the definition of a "preprocessed" expression.
 *
 * Raises the following exceptions:
 *   - BadProgram: if e is an unbound variable
 *   - Impossible: if we attempt to shift a non-value (to be implemented as part
 *     of the assignment)
 *)
fun evalProg e rho =
  case e of
    NoPoints       => e (* first 5 cases are all values, so no computation *)
  | Point _        => e
  | Line _         => e
  | VerticalLine _ => e
  | LineSegment _  => e
  | Var s => (case List.find (fn (s2, _) => s = s2) rho of
                NONE        => raise BadProgram ("var not found: " ^ s)
              | SOME (_, v) => v)
  | Let (s, e1, e2)    => evalProg e2 ((s, evalProg e1 rho) :: rho)
  | Intersect (e1, e2) => intersect (evalProg e1 rho, evalProg e2 rho)
  | Shift (dx, dy, e') => 
      let 
          val v = evalProg e' rho
      in
          case v of NoPoints       => v
                  | Point (x, y)   => Point (x + dx, y + dy)
                  | Line (m, b)    => Line (m, b + dy - m * dx)
                  | VerticalLine x => VerticalLine (x + dx)
                  | LineSegment (x1, y1, x2, y2) => 
                      LineSegment (x1 + dx, y1 + dy, x2 + dx, y2 + dy)
                  | _ => raise Impossible "Not a value"
      end
                    
            

(* preprocessProg takes in a geometric expression, preprocesses it, and *)
(* returns the preprocessed geometric expression *)
fun preprocessProg e =
    case e of LineSegment (x1, y1, x2, y2) =>
                  if realClosePoint x1 y1 x2 y2 then Point (x1, y1)
                  else 
                      if realClose x1 x2 then 
                          if y1 < y2 then LineSegment (x2, y2, x1, y1)
                          else LineSegment (x1, y1, x2, y2)
                      else 
                          if x1 < x2 then LineSegment (x2, y2, x1, y1)
                          else LineSegment (x1, y1, x2, y2)
            | Intersect (e1, e2) => 
                  Intersect (preprocessProg e1, preprocessProg e2)
            | Let (s, e1, e2) => Let (s, preprocessProg e1, preprocessProg e2)
            | Shift (dx, dy, e') => Shift (dx, dy, preprocessProg e')
            | _ => e

(* runProg : geom_exp -> geom_exp 
 *
 * Interpret a geometric expression e after preprocessing it. Returns a
 * geometric value (represented as a literal expression).
 *)
fun runProg e = evalProg (preprocessProg e) []

(***************************************************)
(************ Unit Testing Framework ***************)
(***************************************************)


(* valEqual : geom_exp -> geom_exp -> bool
 *
 * Check whether two geometric expressions are equivalent. We say expressions e1
 * and e2 are equivalent if they represent the same kind of geometric value
 * (non-value expressions are never equivalent to anything) and if their
 * floating point components are close enough to each other.
 *)
fun valEqual e1 e2 = 
  case (e1, e2) of
    (NoPoints, NoPoints)            => true
  | (Point (x1, y1), Point(x2, y2)) => realClosePoint x1 y1 x2 y2
  | (Line (m1, b1),  Line(m2, b2))  => realClose m1 m2 andalso realClose b1 b2
  | (VerticalLine x1,  VerticalLine x2)  => realClose x1 x2 
  | (LineSegment(x1, y1, x2, y2), LineSegment(x1', y1', x2', y2')) =>
    realClosePoint x1 y1 x1' y1' andalso realClosePoint x2 y2 x2' y2'
  | _ => false


(* checkPreprocess : string -> geom_exp -> geom_exp -> unit 
 * 
 * Given a test 'description', an 'input' geometric expression to preprocess,
 * and an expected 'output' geometric literal expression, produce a unit test
 * that will pass if preprocessing input yields a value that's equivalent
 * ("close enough") to the expected output.
 *)
fun checkPreprocess description input output = 
    Unit.checkAssert description
      (fn () => valEqual (preprocessProg input) output)

(* checkEval : string -> geom_exp -> geom_exp -> unit 
 * 
 * Given a test 'description', an 'input' geometric expression to evaluate,
 * and an expected 'output' geometric literal expression, produce a unit test
 * that will pass if evaluting input (after preprocessing it) yields a value 
 * that's equivalent ("close enough") to the expected output.
 *)
fun checkEval description input output = 
    Unit.checkAssert description
      (fn () => valEqual (runProg input) output)
 

(**** Testing Preprocessing ****)

        val _ = checkPreprocess
            "Preprocessing LineSegment -> Point (exact)"
            (LineSegment (3.2, 4.1, 3.2, 4.1))
            (Point (3.2, 4.1))

        val _ = checkPreprocess
            "Preprocessing LineSegment -> Point (exact x, close enough y)"
            (LineSegment (3.2, 4.1, 3.2, 4.100001))
            (Point (3.2, 4.1))

        val _ = checkPreprocess
            "Preprocessing LineSegment -> Point (trivial, close enough)"
            (LineSegment (3.2, 4.100001, 3.2, 4.1))
            (Point (3.2, 4.100001))

        val _ = checkPreprocess
            "Preprocessing LineSegment -> Point (x differs)"
            (LineSegment (3.2, 4.100001, 3.200001, 4.1))
            (Point (3.200001, 4.1))
        
        val _ = checkPreprocess
            "Preprocessing LineSegment -> Point (both x and y differ)"
            (LineSegment (4.100001, 4.1, 4.1, 4.100001))
            (Point (4.100001, 4.1))
        
        val _ = checkPreprocess
            "Preprocessing Endpoint Order (order on x)"
            (LineSegment (~3.2, ~4.1, 3.2, 4.1))
            (LineSegment (3.2, 4.1, ~3.2, ~4.1))
        
        val _ = checkPreprocess
            "Preprocessing Endpoint Order (order on y when x is equal) "
            (LineSegment (3.2, ~4.1, 3.2, 4.1))
            (LineSegment (3.2, 4.1, 3.2, ~4.1))
        
        val _ = checkPreprocess
            "Preprocessing Endpoint Order (order on y when x is close) "
            (LineSegment (4.1, 3.0, 4.100001, 6.0))
            (LineSegment (4.100001, 6.0, 4.1, 3.0))
        

(**** Testing Shifting ****)

        val _ = checkEval
            "Shift: line segment by dy (without preprocessing)"
            (Shift (0.0, 4.0, LineSegment (2.0, ~3.0, 1.0, 4.0)))
            (LineSegment (2.0, 1.0, 1.0, 8.0))

        val _ = checkEval
            "shift: Using let expression"
            (Shift (1.0, 1.0, Let ("x", Point (3.0, 4.0), Var "x")))
            (Point (4.0, 5.0))

        val _ = checkEval
            "shift: intersect segments"
            (Shift (1.0, 1.0, Intersect (LineSegment (~1.0, ~1.0, 1.0, 1.0), 
                                         LineSegment (~1.0, 1.0, 1.0, ~1.0))))
            (Point (1.0, 1.0))

        val _ = checkEval
            "shift: intersect overlapping line + segment"
            (Shift (2.0, 0.0, Intersect (LineSegment (~1.0, ~2.0, 1.0, 2.0), 
                                        Line (2.0, 0.0))))
            (LineSegment (3.0, 2.0, 1.0, ~2.0))

        val _ = checkEval
            "shift: intersect overlapping lines"
            (Shift (2.0, 0.0, Intersect (Line (2.0, 0.0), Line (2.0, 0.0))))
            (Line (2.0, ~4.0))

        val _ = checkEval
            "shift: line"
            (Shift (0.0, 2.0, Line (2.0, 0.0)))
            (Line (2.0, 2.0))

        val _ = checkEval
            "Shift: point by just dx"
            (Shift (2.0, 0.0, Point (3.0, 5.0)))
            (Point (5.0, 5.0))

        val _ = checkEval
            "Shift: NoPoints in expression"
            (Shift (138.2, 2.398, NoPoints))
            NoPoints

        val _ = checkEval
            "Shift: VerticalLine by dy and dx"
            (Shift (6.18, 3.0, VerticalLine 2.2))
            (VerticalLine 8.38)

        val _ = checkEval
            "Shift: LineSegment by just dx (with preprocessing)"
            (Shift (6.18, 0.0, LineSegment (2.2, 1.0, 3.2, ~2.0)))
            (LineSegment (9.38, ~2.0, 8.38, 1.0))

        val _ = checkEval
            "Shift: LineSegment by just dx (no preprocessing)"
            (Shift (6.18, 0.0, LineSegment (3.2, 1.0, 2.2, ~2.0)))
            (LineSegment (9.38, 1.0, 8.38, ~2.0))

        val _ = checkEval
            "Shift: shifted point"
            (Shift (0.0, 2.0, Shift (2.0, 0.0, Point (3.0, 5.0))))
            (Point (5.0, 7.0))

        
(**** Testing intersection of line segments (from U Washington) ****)

        val _ = checkEval
            "Intersection: vertical segments overlapping"
            (Intersect (LineSegment (0.0, 0.0, 0.0, 2.0), 
                        LineSegment (0.0, 1.0, 0.0, 3.0)))
            (LineSegment (0.0, 2.0, 0.0, 1.0))
        
        val _ = checkEval
            "Intersection: vertical segment containment"
            (Intersect (LineSegment (0.0, 0.0, 0.0, 4.0), 
                        LineSegment (0.0, 1.0, 0.0, 3.0)))
            (LineSegment (0.0, 3.0, 0.0, 1.0))
        
        val _ = checkEval
            "Intersection: vertical segments no intersection"
            (Intersect (LineSegment (0.0, 0.0, 0.0, 4.0), 
                        LineSegment (0.0, 10.0, 0.0, 13.0)))
            NoPoints
        
        val _ = checkEval
            "Intersection: vertical segments just touching"
            (Intersect (LineSegment (0.0, 0.0, 0.0, 4.0), 
                        LineSegment (0.0, 4.0, 0.0, 5.0)))
            (Point (0.0, 4.0))
        
        val _ = checkEval
           "Intersection: overlapping non-vertical segments"
           (Intersect (LineSegment (0.0, 0.0, 2.0, 4.0), 
                       LineSegment (1.0, 2.0, 3.0, 6.0)))
           (LineSegment (2.0, 4.0, 1.0, 2.0))
        
        val _ = checkEval
            "Intersection: non-vertical segment containment"
            (Intersect (LineSegment (0.0, 0.0, 3.0, 6.0), 
                        LineSegment (1.0, 2.0, 2.0, 4.0)))
            (LineSegment (2.0, 4.0, 1.0, 2.0))
        
        val _ = checkEval
            "Intersection: non-vertical segment containment, reversed order"
            (Intersect (LineSegment (1.0, 2.0, 2.0, 4.0), 
                        LineSegment (0.0, 0.0, 3.0, 6.0)))
            (LineSegment (2.0, 4.0, 1.0, 2.0))

(* keep me always at the end *)
val () = Unit.reportWhenFailures () 
