package gm2d.skin;

import gm2d.ui.Widget;

import nme.display.BitmapData;
import nme.geom.Rectangle;

enum Style
{
   StyleNone;
   StyleRect;
   StyleRectFlags(flags:Int);
   StyleUnderlineRect;
   StyleRoundRect;
   StyleRoundRectRad(inRad:Float);
   StyleRoundRectFlags(flags:Int, inRad:Float);
   StyleScale9(bmp:BitmapData, inner:Rectangle, edgeScale:Float);
   StyleShadowRect(depth:Float,flags:Int);
   StyleCustom( renderer:Widget->Void );
}

