package gm2d.skin;

import nme.display.BitmapData;

enum FillStyle
{
   FillNone;
   FillLight;
   FillMedium;
   FillButton;
   FillDark;
   FillHighlight;
   FillDisabled;
   FillTransparent;
   FillRowOdd;
   FillRowEven;
   FillRowSelect;
   FillBitmap( bmp:BitmapData );
   FillSolid( rgb:Int, a:Float );
}

