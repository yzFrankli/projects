(use oop_graphics.smt)

;; -----------------------------------------------------------------------------
;; ------------ Testing Intersection with NoPoints -----------------------------
;; -----------------------------------------------------------------------------

;; NoPoints, NoPoints
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (NoPoints new)
                        (NoPoints new))
  (NoPoints new)))

;; Point, NoPoints
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 0.0 0.0)
                        (NoPoints new))
  (NoPoints new)))

;; NoPoints, Point
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (NoPoints new)
                        (Point withX:y: 0.0 0.0))
  (NoPoints new)))

;; Line, NoPoints
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 0.0 0.0)
                        (NoPoints new))
  (NoPoints new)))

;; NoPoints, Line
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (NoPoints new)
                        (Line withM:b: 0.0 0.0))
  (NoPoints new)))

;; VerticalLine, NoPoints
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: 0.0)
                        (NoPoints new))
  (NoPoints new)))

;; NoPoints, VerticalLine
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (NoPoints new)
                        (VerticalLine withX: 0.0))
  (NoPoints new)))

;; LineSegment, NoPoints
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 1.0 2.0 3.0)
                        (NoPoints new))
  (NoPoints new)))

;; NoPoints, LineSegment
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (NoPoints new)
                        (LineSegment withX1:y1:x2:y2: 0.0 1.0 2.0 3.0))
  (NoPoints new)))

;; -----------------------------------------------------------------------------
;; ------------ Testing Intersection with Point --------------------------------
;; -----------------------------------------------------------------------------

;; Point, Point, IntersectionExists
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 4.0 0.0)
                        (Point withX:y: ~4.0 0.0))
  (Point withX:y: 4.0 0.0)))

;; Point, Point, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 4.0 0.0)
                        (Point withX:y: 5.0 0.0))
  (NoPoints new)))

;; Point, Line, Intersection Exists
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 1.0 6.0)
                        (Line withM:b:  ~4.0 2.0))
  (Point withX:y: 1.0 6.0)))

; Line, Point, Intersection Exists
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b:  ~4.0 2.0)
                        (Point withX:y: 1.0 6.0))
  (Point withX:y: 1.0 6.0)))

;; Point, Line, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 2.0 6.0)
                        (Line withM:b:  4.0 2.0))
  (NoPoints new)))

;; Line, Point, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b:  4.0 2.0)
                        (Point withX:y: 2.0 6.0))
  (NoPoints new)))

;; Point, VerticalLine, Intersection Exists
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 4.0 6.0)
                        (VerticalLine withX: ~4.0))
  (Point withX:y: 4.0 6.0)))

;; VerticalLine, Point, Intersection Exists
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: ~4.0)
                        (Point withX:y: 4.0 6.0))
  (Point withX:y: 4.0 6.0)))

;; Point, VerticalLine, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 5.0 6.0)
                        (VerticalLine withX: ~4.0))
  (NoPoints new)))

;; VerticalLine, Point,  No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: ~4.0)
                        (Point withX:y: 5.0 6.0))
  (NoPoints new)))

;; Point, LineSegment, Endpoint Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 4.0 6.0)
                        (LineSegment withX1:y1:x2:y2: ~4.0 6.0 2.0 8.0))
  (Point withX:y: 4.0 6.0)))

;; LineSegment, Point, Endpoint Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 4.0 6.0 2.0 8.0)
                        (Point withX:y: 2.0 8.0))
  (Point withX:y: 2.0 8.0)))

;; Point, LineSegment, Midway Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 3.0 6.0)
                        (LineSegment withX1:y1:x2:y2: 4.0 4.0 2.0 8.0))
  (Point withX:y: 3.0 6.0)))

;; LineSegment, Point, Midway Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 4.0 4.0 2.0 8.0)
                        (Point withX:y: 3.0 6.0))
  (Point withX:y: 3.0 6.0)))

;; Point, LineSegment, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Point withX:y: 3.0 6.0)
                        (LineSegment withX1:y1:x2:y2: 3.0 7.0 2.0 8.0))
  (NoPoints new)))

;; LineSegment, Point, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 3.0 7.0 2.0 8.0)
                        (Point withX:y: 3.0 6.0))
  (NoPoints new)))

;; -----------------------------------------------------------------------------
;; ------------ Testing Intersection with Line ---------------------------------
;; -----------------------------------------------------------------------------

;; Line, Line, Intersection at a Point
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 0.0 0.0)
                        (Line withM:b: 4.0 0.0))
  (Point withX:y: 0.0 0.0)))

;; Line, Line, Intersection is a Line
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: ~4.0 ~4.0)
                        (Line withM:b: 4.0 ~4.0))
  (Line withM:b: 4.0 ~4.0)))

;; Line, Line, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 5.0 8.0)
                        (Line withM:b: 5.0 6.0))
  (NoPoints new)))

;; Line, VerticalLine
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 2.0 3.0)
                        (VerticalLine withX: 3.0))
  (Point withX:y: 3.0 9.0)))

;; VerticalLine, Line
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: 3.0)
                        (Line withM:b: 2.0 3.0))
  (Point withX:y: 3.0 9.0)))

;; Line, LineSegment, Endpoint Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 0.0 ~4.0)
                        (LineSegment withX1:y1:x2:y2: 4.0 4.0 2.0 8.0))
  (Point withX:y: 4.0 4.0)))

;; LineSegment, Line, Endpoint Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 4.0 4.0 6.0 8.0)
                        (Line withM:b: 0.0 ~4.0))
  (Point withX:y: 4.0 4.0)))
  
;; Line, LineSegment, Midway Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 0.0 ~4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 0.0 8.0 8.0))
  (Point withX:y: 4.0 4.0)))

;; LineSegment, Line, Midway Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 8.0 8.0)
                        (Line withM:b: 0.0 ~4.0))
  (Point withX:y: 4.0 4.0)))

;; Line, LineSegment, Intersection at a LineSegment
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 8.0 8.0)
                        (Line withM:b: 1.0 0.0))
  (LineSegment withX1:y1:x2:y2: 8.0 8.0 0.0 0.0)))

;; LineSegment, Line, Intersection at a LineSegment
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 1.0 0.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 0.0 8.0 8.0))
  (LineSegment withX1:y1:x2:y2: 8.0 8.0 0.0 0.0)))

;; Line, LineSegment, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (Line withM:b: 0.0 4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 3.0))
  (NoPoints new)))

;; LineSegment, Line, NoIntersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 3.0)
                        (Line withM:b: 0.0 4.0))
  (NoPoints new)))

;; -----------------------------------------------------------------------------
;; ------------ Testing Intersection with VerticalLine -------------------------
;; -----------------------------------------------------------------------------

;; VerticalLine, VerticalLine, IntersectionExists
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: 4.0)
                        (VerticalLine withX: ~4.0))
  (VerticalLine withX: 4.0)))

;; VerticalLine, VerticalLine, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: 4.0)
                        (VerticalLine withX: 5.0))
  (NoPoints new)))

;; VerticalLine, LineSegment, Endpoint Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: ~4.0)
                        (LineSegment withX1:y1:x2:y2: 4.0 4.0 2.0 8.0))
  (Point withX:y: 4.0 4.0)))

;; LineSegment, VerticalLine, Endpoint Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 4.0 4.0 6.0 8.0)
                        (VerticalLine withX: ~4.0))
  (Point withX:y: 4.0 4.0)))
  
;; VerticalLine, LineSegment, Midway Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: ~4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 0.0 8.0 8.0))
  (Point withX:y: 4.0 4.0)))

;; LineSegment, VerticalLine, Midway Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 8.0 8.0)
                        (VerticalLine withX: ~4.0))
  (Point withX:y: 4.0 4.0)))

;; VerticalLine, LineSegment, Intersection at a LineSegment
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 4.0 0.0 4.0 8.0)
                        (VerticalLine withX: 4.0))
  (LineSegment withX1:y1:x2:y2: 4.0 8.0 4.0 0.0)))

;; LineSegment, VerticalLine, Intersection at a LineSegment
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: 4.0)
                        (LineSegment withX1:y1:x2:y2: 4.0 0.0 4.0 8.0))
  (LineSegment withX1:y1:x2:y2: 4.0 8.0 4.0 0.0)))

;; VerticalLine, LineSegment, No Intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (VerticalLine withX: 4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 3.0))
  (NoPoints new)))

;; LineSegment, VerticalLine, NoIntersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 3.0)
                        (VerticalLine withX: 4.0))
  (NoPoints new)))

;; -----------------------------------------------------------------------------
;; ------------ Testing Intersection of Line Segments (From U Washington) ------
;; -----------------------------------------------------------------------------

;; intersection: vertical segments overlapping
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 2.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 1.0 0.0 3.0))
  (LineSegment withX1:y1:x2:y2: 0.0 2.0 0.0 1.0)))

;; intersection: vertical segment containment
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 1.0 0.0 3.0))
  (LineSegment withX1:y1:x2:y2: 0.0 3.0 0.0 1.0)))

;; intersection: vertical segments no intersection
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 10.0 0.0 13.0))
  (NoPoints new)))

;; intersection: vertical segments just touching
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 0.0 4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 4.0 0.0 5.0))
  (Point withX:y: 0.0 4.0)))

;; intersection: overlapping non-vertical segments
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 2.0 4.0)
                        (LineSegment withX1:y1:x2:y2: 1.0 2.0 3.0 6.0))
  (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 2.0)))

;; intersection: non-vertical segment containment
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 0.0 0.0 3.0 6.0)
                        (LineSegment withX1:y1:x2:y2: 1.0 2.0 2.0 4.0))
  (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 2.0)))

;; intersection: non-vertical segment containment, reversed order
(check-assert (check:Prog: value:value:
  (Intersect withE1:e2: (LineSegment withX1:y1:x2:y2: 1.0 2.0 2.0 4.0)
                        (LineSegment withX1:y1:x2:y2: 0.0 0.0 3.0 6.0))
  (LineSegment withX1:y1:x2:y2: 2.0 4.0 1.0 2.0)))
