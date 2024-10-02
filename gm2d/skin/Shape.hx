package gm2d.skin;

import gm2d.ui.Widget;

import nme.display.BitmapData;
import nme.geom.Rectangle;

enum Shape
{
   ShapeNone;
   ShapeRect;
   ShapeRectFlags(flags:Int);
   ShapeUnderlineRect;
   ShapeRoundRect;
   ShapeRoundRectRad(inRad:Float);
   ShapeRoundRectFlags(flags:Int, inRad:Float);
   ShapeScale9(bmp:BitmapData, inner:Rectangle, edgeScale:Float);
   ShapeShadowRect(depth:Float,flags:Int);
   ShapeCustom( renderer:Widget->Void );
   ShapeItemRect;
}

