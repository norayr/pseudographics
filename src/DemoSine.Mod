MODULE DemoSine;
IMPORT crt, psGraphics, Math, Out, SYSTEM;

CONST
  Pi = 3.14159;

VAR
  angle, step, sineVal: REAL;
  x, y: INTEGER;

BEGIN
  crt.ClrScr;
  psGraphics.pixelMode := {psGraphics.QuarterBlock};
  psGraphics.Clear;

  Out.String("Drawing axes..."); Out.Ln;

  psGraphics.DrawLine(0, 24, 159, 24);   (* X-axis *)
  psGraphics.DrawLine(80, 0, 80, 49);    (* Y-axis *)

  Out.String("Drawing sine..."); Out.Ln;

  angle := -Pi;
  step := 2.0 * Pi / 159.0;
  FOR x := 0 TO 159 DO
    sineVal := Math.sin(angle);
    y := 24 - SYSTEM.VAL(INTEGER, ENTIER(sineVal * 20.0));
    psGraphics.PutPixel(x, y);
    angle := angle + step;
  END;

  Out.String("Refreshing..."); Out.Ln;
  psGraphics.Refresh;

  Out.String("Wait 3 seconds before exiting..."); Out.Ln;
  crt.Delay(3000);
END DemoSine.
