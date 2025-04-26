MODULE Demo;

IMPORT crt, psGraphics;

BEGIN
  crt.ClrScr;
  psGraphics.pixelMode := {psGraphics.QuarterBlock};  (* Default: QuarterBlock *)
  psGraphics.Clear;

  (* Diagonal cross *)
  psGraphics.DrawLine(0, 0, 159, 49);
  psGraphics.DrawLine(0, 49, 159, 0);

  (* Rectangle in center *)
  psGraphics.DrawRect(50, 15, 60, 20);

  (* Circle top-right *)
  psGraphics.DrawCircle(130, 8, 8);

  (* Oval bottom-right *)
  psGraphics.DrawOval(130, 40, 15, 8);

  psGraphics.Refresh;
END Demo.
