MODULE psGraphics;
IMPORT Out, crt, Math;

CONST
  QuarterBlock* = 0;  DosShaded* = 1;

TYPE
  RowArray = POINTER TO ARRAY OF INTEGER;
  Surface = POINTER TO ARRAY OF RowArray;
  CharSeq = ARRAY 5 OF CHAR;

VAR
  pixelMode*: SET;
  cell: Surface;
  offsetX, offsetY: INTEGER;
  actX-, actY-: INTEGER;
  quarterChar: ARRAY 16 OF CharSeq;
  shadingChar: ARRAY 5 OF CharSeq;


PROCEDURE Init*;
BEGIN
  (* Initialize character tables *)
  COPY(" ", quarterChar[0]);
  COPY("▗", quarterChar[1]);
  COPY("▖", quarterChar[2]);
  COPY("▄", quarterChar[3]);
  COPY("▝", quarterChar[4]);
  COPY("▐", quarterChar[5]);
  COPY("▞", quarterChar[6]);
  COPY("▟", quarterChar[7]);
  COPY("▘", quarterChar[8]);
  COPY("▚", quarterChar[9]);
  COPY("▌", quarterChar[10]);
  COPY("▙", quarterChar[11]);
  COPY("▀", quarterChar[12]);
  COPY("▜", quarterChar[13]);
  COPY("▛", quarterChar[14]);
  COPY("█", quarterChar[15]);

  COPY(" ", shadingChar[0]);
  COPY("░", shadingChar[1]);
  COPY("▒", shadingChar[2]);
  COPY("▓", shadingChar[3]);
  COPY("█", shadingChar[4]);
END Init;

PROCEDURE SetViewport*(ox, oy, ax, ay: INTEGER);
VAR i: INTEGER;
BEGIN
  offsetX := ox;
  offsetY := oy;
  actX := ax;
  actY := ay;

  (* Allocate new surface *)
  IF (actX > 0) & (actY > 0) THEN
    NEW(cell, actY);
    FOR i := 0 TO actY-1 DO
      NEW(cell^[i], actX);
    END;
  ELSE
    cell := NIL;
  END;
END SetViewport;

PROCEDURE Clear*;
VAR i, j: INTEGER;
BEGIN
  IF cell # NIL THEN
    FOR i := 0 TO actY-1 DO
      FOR j := 0 TO actX-1 DO
        cell^[i]^[j] := 0;
      END;
    END;
  END;
END Clear;


PROCEDURE PutPixel*(x, y: INTEGER);
VAR
  cx, cy, mask: INTEGER;
BEGIN
  IF (x < 0) OR (x >= actX*2) OR (y < 0) OR (y >= actY*2) THEN RETURN END;
  IF cell = NIL THEN RETURN END;

  cx := x DIV 2;
  cy := y DIV 2;

  IF (cx < 0) OR (cx >= actX) OR (cy < 0) OR (cy >= actY) THEN RETURN END;

  IF (x MOD 2 = 0) & (y MOD 2 = 0) THEN mask := 8
  ELSIF (x MOD 2 = 1) & (y MOD 2 = 0) THEN mask := 4
  ELSIF (x MOD 2 = 0) & (y MOD 2 = 1) THEN mask := 2
  ELSE mask := 1
  END;

  cell^[cy]^[cx] := cell^[cy]^[cx] + mask;
END PutPixel;

PROCEDURE DrawLine*(x0, y0, x1, y1: INTEGER);
VAR dx, dy, sx, sy, err: INTEGER;
BEGIN
  dx := ABS(x1 - x0);
  dy := ABS(y1 - y0);
  IF x0 < x1 THEN sx := 1 ELSE sx := -1 END;
  IF y0 < y1 THEN sy := 1 ELSE sy := -1 END;

  IF dx > dy THEN
    err := dx DIV 2;
    WHILE x0 # x1 DO
      PutPixel(x0, y0);
      DEC(err, dy);
      IF err < 0 THEN
        INC(y0, sy);
        INC(err, dx);
      END;
      INC(x0, sx);
    END;
  ELSE
    err := dy DIV 2;
    WHILE y0 # y1 DO
      PutPixel(x0, y0);
      DEC(err, dx);
      IF err < 0 THEN
        INC(x0, sx);
        INC(err, dy);
      END;
      INC(y0, sy);
    END;
  END;
  PutPixel(x1, y1);
END DrawLine;

PROCEDURE DrawRect*(x, y, w, h: INTEGER);
VAR x2, y2: INTEGER;
BEGIN
  x2 := x + w - 1;
  y2 := y + h - 1;
  DrawLine(x, y, x2, y);
  DrawLine(x2, y, x2, y2);
  DrawLine(x2, y2, x, y2);
  DrawLine(x, y2, x, y);
END DrawRect;

PROCEDURE DrawCircle*(cx, cy, r: INTEGER);
VAR x, y, d: INTEGER;
BEGIN
  IF r < 0 THEN r := -r END;
  x := 0;  y := r;
  d := 3 - 2*r;
  WHILE x <= y DO
    PutPixel(cx + x, cy + y);
    PutPixel(cx - x, cy + y);
    PutPixel(cx + x, cy - y);
    PutPixel(cx - x, cy - y);
    PutPixel(cx + y, cy + x);
    PutPixel(cx - y, cy + x);
    PutPixel(cx + y, cy - x);
    PutPixel(cx - y, cy - x);
    IF d < 0 THEN
      d := d + 4*x + 6
    ELSE
      d := d + 4*(x - y) + 10;
      DEC(y)
    END;
    INC(x)
  END
END DrawCircle;

PROCEDURE DrawOval*(cx, cy, a, b: INTEGER);
VAR
  x, y: INTEGER;
  a2, b2: LONGINT;
  lx, ly: LONGINT;
  d1, d2, px, py: LONGINT;
BEGIN
  a2 := a * a;  (* Direct conversion to LONGINT *)
  b2 := b * b;

  x := 0; y := b;
  lx := x;  (* Direct assignment instead of SYSTEM.GET *)
  ly := y;

  d1 := b2 - (a2 * b) + (a2 DIV 4);
  px := 0; py := 2 * a2 * b;

  WHILE px < py DO
    PutPixel(cx + x, cy + y);
    PutPixel(cx - x, cy + y);
    PutPixel(cx + x, cy - y);
    PutPixel(cx - x, cy - y);
    INC(x);
    lx := x;  (* Update longint version *)
    px := px + 2 * b2;
    IF d1 < 0 THEN
      d1 := d1 + px + b2
    ELSE
      DEC(y);
      ly := y;  (* Update longint version *)
      py := py - 2 * a2;
      d1 := d1 + px - py + b2
    END;
  END;

  d2 := b2*(lx*lx) + a2*(ly*ly) - a2*b2;

  WHILE y >= 0 DO
    PutPixel(cx + x, cy + y);
    PutPixel(cx - x, cy + y);
    PutPixel(cx + x, cy - y);
    PutPixel(cx - x, cy - y);
    DEC(y);
    ly := y;  (* Update longint version *)
    py := py - 2*a2;
    IF d2 > 0 THEN
      d2 := d2 + a2 - py
    ELSE
      INC(x);
      lx := x;  (* Update longint version *)
      px := px + 2*b2;
      d2 := d2 + a2 - py + px
    END
  END
END DrawOval;

PROCEDURE Refresh*;
VAR i, j, bits, count: INTEGER;
BEGIN
  IF cell = NIL THEN RETURN END;

  FOR i := 0 TO actY-1 DO
    crt.GotoXY(offsetX + 1, offsetY + i + 1);
    FOR j := 0 TO actX-1 DO
      bits := cell^[i]^[j];
      IF QuarterBlock IN pixelMode THEN
        IF (bits >= 0) & (bits <= 15) THEN
          Out.String(quarterChar[bits])
        ELSE
          Out.String(" ")
        END
      ELSE
        count := 0;
        IF (bits MOD 2 # 0) THEN INC(count) END;
        IF (bits DIV 2 MOD 2 # 0) THEN INC(count) END;
        IF (bits DIV 4 MOD 2 # 0) THEN INC(count) END;
        IF (bits DIV 8 MOD 2 # 0) THEN INC(count) END;
        IF (count >= 0) & (count <= 4) THEN
          Out.String(shadingChar[count])
        ELSE
          Out.String(" ")
        END
      END;
    END;
  END;
  
  (* Move to new line before status message *)
  crt.GotoXY(1, offsetY + actY + 1);  (* Position after viewport *)
  Out.String("*** Refresh complete ***");
  Out.Ln
END Refresh;
BEGIN
  pixelMode := {QuarterBlock};
  Init;
  cell := NIL;
  offsetX := 0; offsetY := 0;
  actX := 80; actY := 25;
  SetViewport(0, 0, actX, actY);
END psGraphics.
