package gm2d.gfx;

import gm2d.geom.Matrix;
import gm2d.geom.Rectangle;

class GfxExtent extends Gfx
{
   public var extent : Rectangle;

   public function new()
   {
     super();
     extent = new Rectangle(0,0,-1,-1);
   }

   function addExtent(inX:Float, inY:Float)
   {
      if (extent.width<0)
      {
         extent.x = inX;
         extent.y = inY;
         extent.width = extent.height = 0;
         return;
      }
      if (inX<extent.left) extent.left = inX;
      if (inX>extent.right) extent.right = inX;
      if (inY<extent.top) extent.top = inY;
      if (inY>extent.bottom) extent.bottom = inY;
   }


   override public function geometryOnly() { return true; }
   override public function moveTo(inX:Float, inY:Float)
   {
      addExtent(inX,inY);
   }
   override public function lineTo(inX:Float, inY:Float)
   {
      addExtent(inX,inY);
   }
   override public function curveTo(inCX:Float, inCY:Float,inX:Float,inY:Float)
   {
      addExtent(inCX,inCY);
      addExtent(inX,inY);
   }
}

