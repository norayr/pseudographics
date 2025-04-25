MODULE psGraphics;
IMPORT Out, Strings, VT100, crt;

CONST
  MaxW = 160;
  MaxH = 100;

TYPE
  Pixel = RECORD
    bits: SET;    (* set of 0..3 representing 4 pixels in a character cell *)
    color: SHORTINT;
  END;

VAR
  w, h: INTEGER;               (* width and height in virtual pixels *)
  buf: ARRAY MaxH DIV 2, MaxW DIV 2 OF Pixel;

CONST
  UnicodeBlocks = ARRAY 16 OF CHAR {
    " ",    (* 0000 *)
    "▗",    (* 0001 *)
    "▖",    (* 0010 *)
    "▄",    (* 0011 *)
    "▝",    (* 0100 *)
    "▐",    (* 0101 *)
    "▞",    (* 0110 *)
    "▟",    (* 0111 *)
    "▘",    (* 1000 *)
    "▚",    (* 1001 *)
    "▌",    (* 1010 *)
    "▙",    (* 1011 *)
    "▀",    (* 1100 *)
    "▜",    (* 1101 *)
    "▛",    (* 1110 *)
    "█"     (* 1111 *)
  };

PROCEDURE Init*(width, height: INTEGER);
VAR i, j: INTEGER;
BEGIN
  w := width; h := height;
  FOR i := 0 TO h DIV 2 - 1 DO
    FOR j := 0 TO w DIV 2 - 1 DO
      buf[i, j].bits := {};
      buf[i, j].color := crt.White;
    END
  END;
  crt.ClrScr;
END Init;

PROCEDURE Clear*(color: SHORTINT);
VAR i, j: INTEGER;
BEGIN
  FOR i := 0 TO h DIV 2 - 1 DO
    FOR j := 0 TO w DIV 2 - 1 DO
      buf[i, j].bits := {};
      buf[i, j].color := color;
    END
  END;
END Clear;

PROCEDURE SetPixel(x, y: INTEGER; color: SHORTINT);
VAR cx, cy, bit: INTEGER;
BEGIN
  IF (x < 0) OR (x >= w) OR (y < 0) OR (y >= h) THEN RETURN END;
  cx := x DIV 2;
  cy := y DIV 2;
  bit := 0;
  IF (x MOD 2 = 0) & (y MOD 2 = 0) THEN bit := 2;       (* top-left *)
  ELSIF (x MOD 2 = 1) & (y MOD 2 = 0) THEN bit := 3;    (* top-right *)
  ELSIF (x MOD 2 = 0) & (y MOD 2 = 1) THEN bit := 0;    (* bottom-left *)
  ELSE bit := 1;                                        (* bottom-right *)
  END;
  INCL(buf[cy, cx].bits, bit);
  buf[cy, cx].color := color;
END SetPixel;

PROCEDURE FlushChar(x, y: INTEGER);
VAR ch: CHAR; bits, code: INTEGER;
BEGIN
  bits := 0; code := 0;
  IF (x < 0) OR (x >= w DIV 2) OR (y < 0) OR (y >= h DIV 2) THEN RETURN END;
  IF 0 IN buf[y,x].bits THEN INC(code, 1) END;
  IF 1 IN buf[y,x].bits THEN INC(code, 2) END;
  IF 2 IN buf[y,x].bits THEN INC(code, 4) END;
  IF 3 IN buf[y,x].bits THEN INC(code, 8) END;
  ch := UnicodeBlocks[code];
  crt.GotoXY(x+1, y+1);
  crt.TextColor(buf[y,x].color);
  Out.Char(ch);
END FlushChar;

PROCEDURE Refresh*;
VAR y, x: INTEGER;
BEGIN
  FOR y := 0 TO h DIV 2 - 1 DO
    FOR x := 0 TO w DIV 2 - 1 DO
      FlushChar(x, y);
    END
  END;
  crt.NormVideo;
END Refresh;

PROCEDURE DrawLine*(x0, y0, x1, y1, color: SHORTINT);
VAR dx, dy, sx, sy, err, e2: INTEGER;
BEGIN
  dx := ABS(x1 - x0); sx := -1;
  IF x0 < x1 THEN sx := 1 END;
  dy := -ABS(y1 - y0); sy := -1;
  IF y0 < y1 THEN sy := 1 END;
  err := dx + dy;
  WHILE TRUE DO
    SetPixel(x0, y0, color);
    IF (x0 = x1) & (y0 = y1) THEN EXIT END;
    e2 := 2 * err;
    IF e2 >= dy THEN err := err + dy; x0 := x0 + sx END;
    IF e2 <= dx THEN err := err + dx; y0 := y0 + sy END;
  END;
END DrawLine;

PROCEDURE DrawRect*(x1, y1, x2, y2, color: SHORTINT);
BEGIN
  DrawLine(x1, y1, x2, y1, color);
  DrawLine(x2, y1, x2, y2, color);
  DrawLine(x2, y2, x1, y2, color);
  DrawLine(x1, y2, x1, y1, color);
END DrawRect;

PROCEDURE DrawCircle*(cx, cy, r, color: SHORTINT);
VAR x, y, err: INTEGER;
BEGIN
  x := r; y := 0; err := 0;
  WHILE x >= y DO
    SetPixel(cx + x, cy + y, color);
    SetPixel(cx + y, cy + x, color);
    SetPixel(cx - y, cy + x, color);
    SetPixel(cx - x, cy + y, color);
    SetPixel(cx - x, cy - y, color);
    SetPixel(cx - y, cy - x, color);
    SetPixel(cx + y, cy - x, color);
    SetPixel(cx + x, cy - y, color);
    INC(y);
    IF err <= 0 THEN err := err + 2 * y + 1
    ELSE DEC(x); err := err - 2 * x + 1 END;
  END;
END DrawCircle;

PROCEDURE DrawOval*(cx, cy, rx, ry, color: SHORTINT);
VAR x, y: INTEGER;
    angle: REAL;
    pi := 3.14159;
    step := 0.01;
BEGIN
  angle := 0.0;
  WHILE angle <= 2*pi DO
    x := cx + ENTIER(rx * Math.cos(angle));
    y := cy + ENTIER(ry * Math.sin(angle));
    SetPixel(x, y, color);
    angle := angle + step;
  END;
END DrawOval;

END psGraphics.

