package gm2d.ui;

import gm2d.Gradient;
import nme.display.BitmapData;
import nme.geom.Rectangle;

enum SkinFill
{
   SF_NONE;
   SF_SOLID(rgb:Int,a:Float);
   SF_GRAD(grad:Gradient,vertical:Bool);
   SF_BITMAP(bitmap:BitmapData);
   SF_SCALE9(bitmap:BitmapData,strectArea:Rectangle);
   SF_BITMAP_REF(bitmapName:String);
   SF_SCALE9_REF(bitmapName:String,strectArea:Rectangle);
}

