;; oop_graphics.smt
;;
;; Starter code for Part B of Homework 09, CS 105: Programming Langauges
;;
;; This homework (and starter code) is adapted from an assignment for a
;; Programming Languages course at the University of Washington.
;;
;; Edited for CS 105 by Sasha Fedchin and Richard Townsend
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; Helper Blocks (that look like functions) and Definitions ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(val epsilon ((1 / 1000) asFloat))

(define float-close (f1 f2)
  (((f1 - f2) abs) < epsilon))

(define float-close-point (x1 y1 x2 y2)
  ((float-close value:value: x1 x2) and: {(float-close value:value: y1 y2)}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Classes comprising the interpreter (Problems 3-5)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(class GeometryExpression
  [subclass-of Object]

  (method evalProg: (env) (self subclassResponsibility))

  (method inline () (self inline:With (Dictionary new)))
  (method inline:With (env) (self subclassResponsibility))

  (method preprocessProg () self)
)



(class GeometryValue
  [subclass-of GeometryExpression]

  ;; All values are by definition already evaluated
  (method evalProg: (env) self)

  (method shift:Dx:Dy (dx dy) (self subclassResponsibility))

  ;; Generate the line that intersects two given points
  (class-method two:Points:To:Line: (x1 y1 x2 y2) [locals m b]
    ((float-close value:value: x1 x2) 
     ifTrue:ifFalse: 
        {(VerticalLine withX: x1)} 
        {(set m ((y1 - y2) / (x1 - x2)))
         (set b (y2 - (m * x2)))
         (Line withM:b: m b)}))

  (method intersect: (aGeoExpression) (self subclassResponsibility))
  (method intersect:NoPoints (np) np)
  (method intersect:LineSegment (seg)
    ((self intersect: (GeometryValue two:Points:To:Line:
                      (seg x1) (seg y1) (seg x2) (seg y2))) 
     intersect:SegmentAsLineResult seg))
  (method intersect:SegmentAsLineResult (seg) (self subclassResponsibility))

  (method inline:With (env) self)

)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;               Geometry value classes                     ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(class NoPoints
  [subclass-of GeometryValue]

  (method shift:Dx:Dy (dx dy) self)

  (method intersect: (other) (other intersect:NoPoints self))
  (method intersect:Point (p) self)
  (method intersect:Line (line) self)
  (method intersect:VerticalLine (vline) self)
  (method intersect:SegmentAsLineResult (seg) self)

)



(class Point
  [subclass-of GeometryValue]
  [ivars x y]

  (class-method withX:y: (x y) ((self new) initX:andY: x y))
  (method initX:andY: (anX aY) ;; private
    (set x anX)
    (set y aY)
    self)

  (method x () x)
  (method y () y)

  (method shift:Dx:Dy (dx dy) (Point withX:y: (x + dx) (y + dy)))

  (method intersect: (other) (other intersect:Point self))

  (method intersect:Point (aPoint) 
    ((float-close-point value:value:value:value: x y (aPoint x) (aPoint y)) 
      ifTrue:ifFalse: 
        {self}
        {(NoPoints new)}))
  
  (method intersect:Line (aLine)
    ((float-close value:value: y (((aLine m) * x) + (aLine b))) 
      ifTrue:ifFalse: 
        {self}
        {(NoPoints new)}))
  
  (method intersect:VerticalLine (aVertical)
    ((float-close value:value: x (aVertical x)) 
      ifTrue:ifFalse: 
        {self}
        {(NoPoints new)}))

  ;; inSeg: takes in a LineSegment seg, and tells whether the current point
  ;; lies on seg. Private.
  (method inSeg: (seg) 
    ((((((seg x1) - epsilon) <= x) & (x <= ((seg x2) + epsilon))) | 
      ((((seg x2) - epsilon) <= x) & (x <= ((seg x1) + epsilon)))) 
     &
     (((((seg y1) - epsilon) <= y) & (y <= ((seg y2) + epsilon))) | 
      ((((seg y2) - epsilon) <= y) & (y <= ((seg y1) + epsilon))))))

  (method intersect:SegmentAsLineResult (seg)
    ((self inSeg: seg) ifTrue:ifFalse: 
      {self}
      {(NoPoints new)}))

)



(class Line
  [subclass-of GeometryValue]
  [ivars m b]

  (class-method withM:b: (m b) ((self new) initM:andB: m b))
  (method initM:andB: (anM aB) ;; private
    (set m anM)
    (set b aB)
    self)

  (method m () m)
  (method b () b)

  (method shift:Dx:Dy (dx dy) (Line withM:b: m ((b + dy) - (m * dx))))

  (method intersect: (other) (other intersect:Line self))

  (method intersect:Point (aPoint) (aPoint intersect:Line self))
  
  (method intersect:Line (aLine)
    [locals x y]
    ((float-close value:value: m (aLine m)) ifTrue:ifFalse:
        {((float-close value:value: b (aLine b)) ifTrue:ifFalse: 
              {self} 
              {(NoPoints new)})}
        {(set x (((aLine b) - b) / (m - (aLine m))))
         (set y ((m * x) + b))
         (Point withX:y: x y)}))
  
  (method intersect:VerticalLine (aVertical)
    (Point withX:y: (aVertical x) ((m * (aVertical x)) + b)))
  
  (method intersect:SegmentAsLineResult (seg) seg)

)



(class VerticalLine
  [subclass-of GeometryValue]
  [ivars x]

  (class-method withX: (x) ((self new) initX: x))
  (method initX: (anX) ;; private
    (set x anX)
    self)

  (method x () x)

  (method shift:Dx:Dy (dx dy) (VerticalLine withX: (x + dx)))

  (method intersect: (other) (other intersect:VerticalLine self))

  (method intersect:Point (aPoint) (aPoint intersect:VerticalLine self))
  
  (method intersect:Line (aLine) (aLine intersect:VerticalLine self))
  
  (method intersect:VerticalLine (aVertical)
    ((float-close value:value: x (aVertical x)) ifTrue:ifFalse: 
        {self}
        {(NoPoints new)}))

  (method intersect:SegmentAsLineResult (seg) seg)

)



(class LineSegment
  [subclass-of GeometryValue]
  [ivars x1 y1 x2 y2]

  (class-method withX1:y1:x2:y2: (x1 y1 x2 y2)
        ((self new) initX1:andY1:andX2:andY2: x1 y1 x2 y2))
  (method initX1:andY1:andX2:andY2: (anX1 aY1 anX2 aY2) ;; private
    (set x1 anX1)
    (set x2 anX2)
    (set y1 aY1)
    (set y2 aY2)
    self)

  (method x1 () x1)
  (method y1 () y1)
  (method x2 () x2)
  (method y2 () y2)

  (method shift:Dx:Dy (dx dy) 
      (LineSegment withX1:y1:x2:y2: (x1 + dx) (y1 + dy) (x2 + dx) (y2 + dy)))

  (method preprocessProg () 
      ((float-close-point value:value:value:value: x1 y1 x2 y2) ifTrue:ifFalse: 
          {(Point withX:y: x1 y1)}
          {((float-close value:value: x1 x2) ifTrue:ifFalse: 
              {((y1 < y2) ifTrue:ifFalse: 
                  {(LineSegment withX1:y1:x2:y2: x2 y2 x1 y1)}
                  {self})}
              {((x1 < x2) ifTrue:ifFalse: 
                  {(LineSegment withX1:y1:x2:y2: x2 y2 x1 y1)}
                  {self})})}))
  
  (method intersect: (other) (other intersect:LineSegment self))

  (method intersect:Point (aPoint) (aPoint intersect:LineSegment self))
  
  (method intersect:Line (aLine) (aLine intersect:LineSegment self))
  
  (method intersect:VerticalLine (aVertical) 
                                (aVertical intersect:LineSegment self))

  ;; Below is the hardest part of the intersection logic,
  ;; which we implemented for you, so you dont need to change it!
  (method intersect:SegmentAsLineResult (seg) 
    [locals first second 
            aXend aYend aXstart aYstart 
            bXend bYend bXstart bYstart]
    (set first self)
    (set second seg)
    ((float-close value:value: x1 x2)
      ifTrue:ifFalse:
        {((y2 >= (seg y2)) 
         ifTrue: 
         {(set first seg)
          (set second self)})}
        {((x2 >= (seg x2)) 
         ifTrue: 
         {(set first seg)
          (set second self)})})
    (set aXend   (first x1))
    (set aYend   (first y1))
    (set aXstart (first x2))
    (set aYstart (first y2))
    (set bXend   (second x1))
    (set bYend   (second y1))
    (set bXstart (second x2))
    (set bYstart (second y2))
    ((float-close value:value: x1 x2)
      ifTrue:ifFalse:
        {((float-close value:value: aYend bYstart)
           ifTrue:ifFalse:
             {(Point withX:y: aXend aYend)}
             {((aYend < bYstart)
                ifTrue:ifFalse:
                  {(NoPoints new)}
                  {((aYend > bYend)
                     ifTrue:ifFalse:
                       {(LineSegment withX1:y1:x2:y2: 
                                     bXend bYend bXstart bYstart)}
                       {(LineSegment withX1:y1:x2:y2: 
                                     aXend aYend bXstart bYstart)})})})}
        {((float-close value:value: aXend bXstart)
           ifTrue:ifFalse:
             {(Point withX:y: aXend aYend)}
             {((aXend < bXstart)
                ifTrue:ifFalse:
                  {(NoPoints new)}
                  {((aXend > bXend)
                     ifTrue:ifFalse:
                       {(LineSegment withX1:y1:x2:y2: 
                                     bXend bYend bXstart bYstart)}
                       {(LineSegment withX1:y1:x2:y2: 
                                     aXend aYend bXstart bYstart)})})})}))

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;               Geometry expression classes                ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(class Intersect
  [subclass-of GeometryExpression]
  [ivars e1 e2]

  (class-method withE1:e2: (e1 e2) ((self new) initE1:andE2: e1 e2))
  (method initE1:andE2: (anE1 anE2) ;; private
    (set e1 anE1)
    (set e2 anE2)
    self)

  ;; These getters should only be used in the provided unit testing framework
  (method e1 () e1) ;; very private!
  (method e2 () e2) ;; very private!

  (method preprocessProg () 
    (Intersect withE1:e2: (e1 preprocessProg) (e2 preprocessProg)))

  (method evalProg: (rho) ((e1 evalProg: rho) intersect: (e2 evalProg: rho)))

  (method inline:With (env) 
    (Intersect withE1:e2: (e1 inline:With env) (e2 inline:With env)))

)

(class Let
  [subclass-of GeometryExpression]
  [ivars s e1 e2]

  (class-method withS:e1:e2: (s e1 e2) ((self new) initS:andE1:andE2: s e1 e2))
  (method initS:andE1:andE2: (anS anE1 anE2) ;; private
    (set s anS)
    (set e1 anE1)
    (set e2 anE2)
    self)

  (method preprocessProg () 
    (Let withS:e1:e2: s (e1 preprocessProg) (e2 preprocessProg)))
  
  (method evalProg: (rho) 
    [locals hasOriginal originalS v]
    ((rho includesKey: s) ifTrue:ifFalse: {(set hasOriginal true)
                                           (set originalS (rho at: s))}
                                          {(set hasOriginal false)})
    (rho at:put: s (e1 evalProg: rho))
    (set v (e2 evalProg: rho))
    (hasOriginal ifTrue:ifFalse: {(rho at:put: s originalS)}
                                 {(rho removeKey: s)})
    v)
  
  (method inline:With (env) 
    (env at:put: s (e1 inline:With env))
    (e2 inline:With env))

)

(class Var
  [subclass-of GeometryExpression]
  [ivars s]

  (class-method withS: (s) ((self new) initS: s))
  (method initS: (anS) ;; private
    (set s anS)
    self)

  (method evalProg: (rho) (rho at: s))
  
  (method inline:With (env) (env at: s))

)

(class Shift
  [subclass-of GeometryExpression]
  [ivars dx dy e]

  (class-method withDx:dy:e: (dx dy e) ((self new) initDx:andDy:andE: dx dy e))
  (method initDx:andDy:andE: (aDX aDY anE) ;; private
    (set dx aDX)
    (set dy aDY)
    (set e anE)
    self)

  ;; These getters should only be used in the provided unit testing framework
  (method dx () dx) ;; very private!
  (method dy () dy) ;; very private!
  (method e () e)   ;; very private!

  (method preprocessProg () (Shift withDx:dy:e: dx dy (e preprocessProg)))

  (method evalProg: (rho) ((e evalProg: rho) shift:Dx:Dy dx dy))
  
  (method inline:With (env) (Shift withDx:dy:e: dx dy (e inline:With env)))

)



;;;;;;;;;;;;;;;;;;;;;;;
;; TESTING FRAMEWORK ;;
;;;;;;;;;;;;;;;;;;;;;;;


;; Some shorthands to use later in the tests:
(val smidge ((1 / 10000) asFloat)) ;; smaller than our epsilon for comparison
(val 3.2 ((32 / 10) asFloat))
(val 4.1 ((41 / 10) asFloat))
(val ~4.1 ((4100001 / 1000000) asFloat))
(val -3.2 ((-32 / 10) asFloat))
(val -4.1 ((-41 / 10) asFloat))
(val 0.0 (0 asFloat))
(val 1.0 (1 asFloat))
(val 2.0 (2 asFloat))
(val 3.0 (3 asFloat))
(val 4.0 (4 asFloat))
(val ~4.0 ((4000001 / 1000000) asFloat))
(val 5.0 (5 asFloat))
(val 6.0 (6 asFloat))
(val 7.0 (7 asFloat))
(val 8.0 (8 asFloat))
(val 9.0 (9 asFloat))
(val 10.0 (10 asFloat))
(val 13.0 (13 asFloat))

;; Use this for comparing two GeometryValue.
;; Note: This approach does not work for non-value geometry expressions because 
;;       they do not have getters defined. 
(define compare:Geometry:Value: (v1 v2 eq?)
  (((v1 isMemberOf: NoPoints)       and:
   {(v2 isMemberOf: NoPoints)}) 
   or:
     {(((v1 isMemberOf: Point)                  and:
      {((v2 isMemberOf: Point)                  and:
      {((eq? value:value: (v1 x) (v2 x))        and:
      {( eq? value:value: (v1 y) (v2 y))})})}) 
   or:
     {(((v1 isMemberOf: Line)                   and:
      {((v2 isMemberOf: Line)                   and:
      {((eq? value:value: (v1 m) (v2 m))        and:
      {( eq? value:value: (v1 b) (v2 b))})})})
   or:
     {(((v1 isMemberOf: VerticalLine)           and:
      {((v2 isMemberOf: VerticalLine)           and:
      {(eq? value:value: (v1 x) (v2 x))})})
   or:
     {((v1 isMemberOf: LineSegment)             and:
      {((v2 isMemberOf: LineSegment)            and:
      {((eq? value:value: (v1 x1) (v2 x1))      and:
      {((eq? value:value: (v1 y1) (v2 y1))      and: 
      {((eq? value:value: (v1 x2) (v2 x2))      and: 
      {( eq? value:value: (v1 y2) (v2 y2))})})})})})})})})}))

(define close:GeometryValue: (v1 v2)
  (compare:Geometry:Value: value:value:value: v1 v2 float-close))

;; -----------------------------------------------------------------------------
;; ------------ Testing Preprocessing ------------------------------------------
;; -----------------------------------------------------------------------------

;; Put your unit tests for preprocessing here!

        ;; NoPoints
        (check-assert (close:GeometryValue: value:value: 
                          ((NoPoints new) preprocessProg)
                          (NoPoints new)))
        ;; Point
        (check-assert (close:GeometryValue: value:value: 
                          ((Point withX:y: 3.2 4.1) preprocessProg)
                          (Point withX:y: 3.2 4.1)))
        ;; Line
        (check-assert (close:GeometryValue: value:value: 
                          ((Line withM:b: 2.0 4.0) preprocessProg)
                          (Line withM:b: 2.0 4.0)))

        ;; LineSegment
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 1.0 2.0 3.0 4.0) 
                                                                preprocessProg)
                          (LineSegment withX1:y1:x2:y2: 3.0 4.0 1.0 2.0)))

        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 3.2 4.1 3.2 4.1) 
                                                                preprocessProg)
                          (Point withX:y: 3.2 4.1)))

        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 3.2 4.1 3.2 ~4.1) 
                                                                preprocessProg)
                          (Point withX:y: 3.2 4.1)))

        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 3.2 ~4.1 3.2 4.1) 
                                                                preprocessProg)
                          (Point withX:y: 3.2 ~4.1)))
      
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 
                                (3.2 + smidge) ~4.1 3.2 4.1) preprocessProg)
                          (Point withX:y: (3.2 + smidge) ~4.1)))
      
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 4.1 1.0 ~4.1 2.0) 
                                                                preprocessProg)
                          (LineSegment withX1:y1:x2:y2: ~4.1 2.0 4.1 1.0)))
      
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: ~4.1 2.0 4.1 1.0) 
                                                                preprocessProg)
                          (LineSegment withX1:y1:x2:y2: ~4.1 2.0 4.1 1.0)))

        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: -3.2 -4.1 3.2 4.1) 
                                                                preprocessProg)
                          (LineSegment withX1:y1:x2:y2: 3.2 4.1 -3.2 -4.1)))
    
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 3.2 -4.1 3.2 4.1) 
                                                                preprocessProg)
                          (LineSegment withX1:y1:x2:y2: 3.2 4.1 3.2 -4.1)))
        
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 4.1 3.0 ~4.1 6.0) 
                                                                preprocessProg)
                          (LineSegment withX1:y1:x2:y2: ~4.1 6.0 4.1 3.0)))
        

;; ------------------------------------------------------------------------
;; ------------ Testing Shifting ------------------------------------------
;; ------------------------------------------------------------------------


        ;; Shifting a Point
        (check-assert (close:GeometryValue: value:value:
                          ((Point withX:y: 4.0 4.0) shift:Dx:Dy 3.0 4.0)
                          (Point withX:y: 7.0 8.0)))

        ;; Shifting a VerticalLine
        (check-assert (close:GeometryValue: value:value:
                          ((VerticalLine withX: 2.0) shift:Dx:Dy 3.0 5.0)
                          (VerticalLine withX: 5.0)))

        ;; Shifting a NoPoint
        (check-assert (close:GeometryValue: value:value:
                          ((NoPoints new) shift:Dx:Dy 3.0 5.0)
                          (NoPoints new)))

        ;; Segment
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 2.0 0.0 1.0 4.0) 
                              shift:Dx:Dy 0.0 4.0)
                          (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 8.0)))

        ;; point by just dx
        (check-assert (close:GeometryValue: value:value:
                          ((Point withX:y: 3.0 5.0) shift:Dx:Dy 2.0 0.0)
                          (Point withX:y: 5.0 5.0)))

        ;; VerticalLine by dy and dx
        (check-assert (close:GeometryValue: value:value:
                          ((VerticalLine withX: 2.0) shift:Dx:Dy 6.0 3.0)
                          (VerticalLine withX: 8.0)))
        
        ;; LineSegment by just dx (no preprocessing)
        (check-assert (close:GeometryValue: value:value:
                          ((LineSegment withX1:y1:x2:y2: 3.0 1.0 2.0 2.0)
                            shift:Dx:Dy 6.0 0.0)
                          (LineSegment withX1:y1:x2:y2: 9.0 1.0 8.0 2.0)))
        
        ;; Line
        (check-assert (close:GeometryValue: value:value:
                          ((Line withM:b: 2.0 0.0) shift:Dx:Dy 0.0 2.0)
                          (Line withM:b: 2.0 2.0)))
        
        ;; Line
        (check-assert (close:GeometryValue: value:value:
                          ((Line withM:b: 2.0 0.0) shift:Dx:Dy 2.0 0.0)
                          (Line withM:b: 2.0 (0.0 - 4.0))))
        
        ;; Line
        (check-assert (close:GeometryValue: value:value:
                          ((Line withM:b: 2.0 0.0) shift:Dx:Dy 2.0 2.0)
                          (Line withM:b: 2.0 (0.0 - 2.0))))


;; --------------------------------------------------------------------------
;; ------------ Testing Evaluation ------------------------------------------
;; --------------------------------------------------------------------------

;; Evaluate a Graphics program. Given an expression e to evaluate, 
;; preprocess it first and then evaluate it with a fresh environment.
(define runProg: (e)
  ((e preprocessProg) evalProg: (Dictionary new)))

;; Check whether evaluating geometric expression e yields an 
;; expected result.
(define check:Prog: (e result)
  (close:GeometryValue: value:value: (runProg: value: e) result))

        ; Check that accessing an unbound variable causes an error
        (check-error (runProg: value: (Var withS: 'a)))

        ;;' Shifting a Point
        (check-assert (check:Prog: value:value:
          (Shift withDx:dy:e: 3.0 4.0 (Point withX:y: 4.0 4.0))
          (Point withX:y: 7.0 8.0)))

        ;; Let with var in body
        (check-assert (check:Prog: value:value:
          (Let withS:e1:e2: 'x (Point withX:y: 3.2 4.1)
                                (Var withS: 'x))
          (Point withX:y: 3.2 4.1)))

        ;; Sequential Let, using 2nd variable
        (check-assert (check:Prog: value:value:
          (Let withS:e1:e2: 'x (Point withX:y: 3.2 4.1)
            (Let withS:e1:e2: 'y (Point withX:y: 4.1 3.2)
              (Var withS: 'y)))
          (Point withX:y: 4.1 3.2)))
        
        ;; Sequential Let with vertical line shift
        (check-assert (check:Prog: value:value:
          (Let withS:e1:e2: 'x (VerticalLine withX: 4.1)
            (Let withS:e1:e2: 'y (Point withX:y: 4.1 3.2)
              (Var withS: 'y)))
          (Point withX:y: 4.1 3.2)))

        ;; Shifting with let I
        (check-assert (check:Prog: value:value:
                          (Shift withDx:dy:e: 10.0 10.0
                                              (Let withS:e1:e2: 
                                                  'x 
                                                  (NoPoints new) 
                                                  (Var withS: 'x)))
                          (NoPoints new)))

        ;; Shifting with let II
        (check-assert (check:Prog: value:value:
                          (Let withS:e1:e2: 'x
                                            (NoPoints new) 
                                            (Shift withDx:dy:e: 10.0 10.0 
                                                              (Var withS: 'x)))
                          (NoPoints new)))

        ;; Shifting NP
        (check-assert (check:Prog: value:value:
                          (Shift withDx:dy:e: 0.0 0.0 (NoPoints new))
                          (NoPoints new)))

        ;; NoPoints
        (check-assert (check:Prog: value:value:
                          (NoPoints new)
                          (NoPoints new)))
        
        ;; with let
        (check-assert (check:Prog: value:value:
                          (Shift withDx:dy:e: 1.0 1.0 
                              (Let withS:e1:e2: 'x 
                                                (Point withX:y: 3.0 4.0) 
                                                (Var withS: 'x)))
                          (Point withX:y: 4.0 5.0)))

        ;; Intersection: intersect lines 
        (check-assert (check:Prog: value:value:
                          (Intersect withE1:e2: 
                              (Line withM:b: 1.0 0.0) 
                              (Line withM:b: (1.0 - 2.0) 0.0))
                          (Point withX:y: 0.0 0.0)))

        ;; Intersection: intersect segments
        (check-assert (check:Prog: value:value:
                          (Intersect withE1:e2: 
                              (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 2.0) 
                              (LineSegment withX1:y1:x2:y2: 0.0 2.0 2.0 0.0))
                          (Point withX:y: 1.0 1.0)))


        ;; Intersection: intersect segments + point 
        (check-assert (check:Prog: value:value:
                          (Intersect withE1:e2: 
                              (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 2.0) 
                              (Point withX:y: 1.0 1.0))
                          (Point withX:y: 1.0 1.0)))

        ;; Intersection: intersect segments + point 
        (check-assert (check:Prog: value:value:
                          (Intersect withE1:e2: 
                              (LineSegment withX1:y1:x2:y2: 0.0 0.0 10.0 10.0) 
                              (Point withX:y: 2.0 2.0))
                          (Point withX:y: 2.0 2.0)))

        ;; Intersection: vertical segments overlapping
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 2.0) 
                            (LineSegment withX1:y1:x2:y2: 0.0 1.0 0.0 3.0))
                        (LineSegment withX1:y1:x2:y2: 0.0 2.0 0.0 1.0)))

        ;; Intersection: vertical segment containment
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 4.0) 
                            (LineSegment withX1:y1:x2:y2: 0.0 1.0 0.0 3.0))
                        (LineSegment withX1:y1:x2:y2: 0.0 3.0 0.0 1.0)))

        ;; Intersection: vertical segments no intersection
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 4.0) 
                            (LineSegment withX1:y1:x2:y2: 0.0 10.0 0.0 13.0))
                        (NoPoints new)))

        ;; Intersection: vertical segments just touching
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 4.0) 
                            (LineSegment withX1:y1:x2:y2: 0.0 4.0 0.0 4.0))
                        (Point withX:y: 0.0 4.0)))

        ;; Intersection: overlapping non-vertical segments
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 4.0) 
                            (LineSegment withX1:y1:x2:y2: 1.0 2.0 3.0 6.0))
                        (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 2.0)))

        ;; Intersection: non-vertical segment containment
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 3.0 6.0) 
                            (LineSegment withX1:y1:x2:y2: 1.0 2.0 2.0 4.0))
                        (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 2.0)))

        ;; Intersection: non-vertical segment containment, reversed order
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (LineSegment withX1:y1:x2:y2: 1.0 2.0 2.0 4.0) 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 3.0 6.0))
                        (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 2.0)))

        ;; Intersection with let as one sub-expression I
        (check-assert (check:Prog: value:value:
                        (Intersect withE1:e2: 
                            (Let withS:e1:e2: 
                                'x 
                                (LineSegment withX1:y1:x2:y2: 1.0 2.0 2.0 4.0) 
                                (Var withS: 'x)) 
                            (LineSegment withX1:y1:x2:y2: 0.0 0.0 3.0 6.0))
                        (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 2.0)))

        ;; Intersection with let as one sub-expression II
        (check-error (runProg: value:
                        (Intersect withE1:e2: 
                            (Let withS:e1:e2: 
                                'v
                                (LineSegment withX1:y1:x2:y2: 1.0 2.0 2.0 4.0)
                                (Var withS: 'x))
                            (Var withS: 'v))))

        ;;' check inSeg:
        (check-assert ((Point withX:y: 0.0 0.0) inSeg: 
                       (LineSegment withX1:y1:x2:y2: 0.0 0.0 1.0 1.0)))

        (check-assert ((Point withX:y: 1.0 1.0) inSeg: 
                       (LineSegment withX1:y1:x2:y2: 0.0 0.0 1.0 1.0)))

        (check-assert ((Point withX:y: 4.0 0.0) inSeg: 
                       (LineSegment withX1:y1:x2:y2: ~4.0 0.0 1.0 0.0)))


;; -----------------------------------------------------------------------------
;; ------------ Testing Inlining --------------------------------------------
;; -----------------------------------------------------------------------------

;; We can use this for inline testing because we should have the exact same
;; object as what was bound to a variable taking the place of that variable.
(define float-exact (f1 f2) (f1 = f2))

;; Use this to compare Geometry Expressions (without Let or Var)
(define compare:Geometry:ExpressionSimpl: (v1 v2 eq?)
  ((compare:Geometry:Value: value:value:value: v1 v2 eq?) 
   or: {(((v1 isMemberOf: Shift) and: 
        {((v2 isMemberOf: Shift) and: 
        {(((v1 dx) = (v2 dx)) and: 
        {(((v1 dy) = (v2 dy)) and: 
        {(compare:Geometry:ExpressionSimpl: 
          value:value:value: (v1 e) (v2 e) eq?)})})})}) 
   or: {((v1 isMemberOf: Intersect) and: 
       {((v2 isMemberOf: Intersect) and: 
       {((compare:Geometry:ExpressionSimpl: 
          value:value:value: (v1 e1) (v2 e1) eq?) and: 
        {(compare:Geometry:ExpressionSimpl: 
          value:value:value: (v1 e2) (v2 e2) eq?)})})})})}))

;; Check whether inlining, then preprocessing geometric expression e 
;; is equivalent to (not just close enough to) geometric literal ans.
(define check:inline: (e ans)
  ([block (e1 e2) (compare:Geometry:ExpressionSimpl: 
                   value:value:value: e1 e2 float-exact)] 
   value:value: ((e preprocessProg) inline) (ans preprocessProg)))

        ;; Put your unit tests for inlining here!

        ;; inlining Let, where the introduced variable is immediately used
        (check-assert (check:inline: value:value:
          (Let withS:e1:e2: 'a (Line withM:b: 2.0 1.0) (Var withS: 'a))
          (Line withM:b: 2.0 1.0)))
        
        ;; inlining double Let
        (check-assert (check:inline: value:value:
          (Let withS:e1:e2: 'a 
                            (Line withM:b: 2.0 1.0) 
                            (Let withS:e1:e2: 'b
                                              (Point withX:y: 0.0 1.0) 
                                              (Intersect withE1:e2: 
                                                            (Var withS: 'a) 
                                                            (Var withS: 'b))))
          (Intersect withE1:e2: (Line withM:b: 2.0 1.0) 
                                (Point withX:y: 0.0 1.0))))

        ;; inlining double let shift
        (check-assert (check:inline: value:value:
          (Let withS:e1:e2: 'a
                            (LineSegment withX1:y1:x2:y2: 2.0 1.0 1.0 2.0)
                            (Shift withDx:dy:e: 2.0 2.0 (Var withS: 'a)))
          (Shift withDx:dy:e: 2.0 2.0 
                              (LineSegment withX1:y1:x2:y2: 2.0 1.0 1.0 2.0))))

        ;; inlineing double let intersect line and LineSegment
        (check-assert (check:inline: value:value:
          (Let withS:e1:e2: 'a
                            (Line withM:b: 2.0 0.0) 
                            (Let withS:e1:e2: 'b
                                              (LineSegment withX1:y1:x2:y2: 
                                                            1.0 2.0 0.0 0.0) 
                                              (Intersect withE1:e2: 
                                                            (Var withS: 'a) 
                                                            (Var withS: 'b))))
          (Intersect withE1:e2: (Line withM:b: 2.0 0.0) 
                                (LineSegment withX1:y1:x2:y2: 
                                                1.0 2.0 0.0 0.0))))

        ;; inlining double let in intersection
        (check-assert (check:inline: value:value:
          (Intersect withE1:e2:
            (Let withS:e1:e2: 
                    'a
                    (Point withX:y: 1.0 2.0)
                    (Let withS:e1:e2:
                            'b
                            (VerticalLine withX: 1.0)
                            (Intersect withE1:e2:
                                      (Var withS: 'a)
                                      (Var withS: 'b))))
            (Point withX:y: 1.0 2.0))
          (Intersect withE1:e2: (Intersect withE1:e2: 
                                      (Point withX:y: 1.0 2.0)
                                      (VerticalLine withX: 1.0))
                                (Point withX:y: 1.0 2.0))))
      