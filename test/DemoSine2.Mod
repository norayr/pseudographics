MODULE DemoSine2;
IMPORT crt, psGraphics, Math, Out, SYSTEM;

CONST
  Pi = 3.14159;

VAR
  angle, step, sineVal: REAL;
  x, y: INTEGER;

PROCEDURE CleanUp;
BEGIN
  (* Clear status line explicitly *)
  crt.GotoXY(1, psGraphics.offsetY + psGraphics.actY + 1);
  Out.String("                                                      "); (* Clear line *)
END CleanUp;


BEGIN
  crt.ClrScr;
  psGraphics.pixelMode := {psGraphics.QuarterBlock};

  (* Set viewport to bottom-right quarter of 150x50 terminal *)
  psGraphics.SetViewport(75, 25, 75, 25);
  psGraphics.Clear;

  Out.String("Drawing axes..."); Out.Ln;

  (* Local coordinates within viewport *)
  (* X-axis *)
  psGraphics.DrawLine(0, psGraphics.actY*2 -1, psGraphics.actX*2 -1, psGraphics.actY*2 -1);
  (* Y-axis *)
  psGraphics.DrawLine(psGraphics.actX*2 DIV 2, 0, psGraphics.actX*2 DIV 2, psGraphics.actY*2 -1);

  Out.String("Drawing sine..."); Out.Ln;

  angle := -Pi;
  step := 2.0 * Pi / (psGraphics.actX*2 -1);
  FOR x := 0 TO psGraphics.actX*2 -1 DO
    sineVal := Math.sin(angle);
    y := psGraphics.actY*2 DIV 2 - SYSTEM.VAL(INTEGER, ENTIER(sineVal * (psGraphics.actY*2 DIV 4)));
    psGraphics.PutPixel(x, y);
    angle := angle + step;
  END;

  Out.String("Refreshing..."); Out.Ln;
  psGraphics.Refresh;
  CleanUp;
  Out.String("Wait 3 seconds before exiting..."); Out.Ln;
  crt.Delay(3000);
END DemoSine2.
