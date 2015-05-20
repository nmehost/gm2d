package gm2d.skin;

import gm2d.ui.Widget;

import nme.display.BitmapData;
import nme.geom.Rectangle;

enum Style
{
   StyleNone;
   StyleRect;
   StyleUnderlineRect;
   StyleRoundRect;
   StyleRoundRectRad(inRad:Float);
   StyleScale9(bmp:BitmapData, inner:Rectangle, edgeScale:Float);
   StyleShadowRect(depth:Float);
   StyleCustom( renderer:Widget->Void );
}

