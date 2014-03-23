package gm2d.ui;

import gm2d.Gradient;

enum SkinLine
{
   SL_NONE;
   SL_SOLID(rgb:Int,a:Float,width:Float);
   SL_GRAD(grad:Gradient,vertical:Bool,width:Float);
}


