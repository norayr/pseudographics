MODULE demo;
IMPORT psGraphics, crt, Platform;

BEGIN
  TermGraphics.Init(80, 50);
  TermGraphics.Clear(crt.Black);
  TermGraphics.DrawRect(4, 4, 40, 20, crt.Green);
  TermGraphics.DrawCircle(60, 25, 10, crt.LightRed);
  TermGraphics.DrawLine(0, 0, 79, 49, crt.Yellow);
  TermGraphics.DrawOval(30, 15, 10, 5, crt.Cyan);
  TermGraphics.Refresh;
  Platform.Delay(5000);
END demo.

