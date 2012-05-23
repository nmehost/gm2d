package gm2d.svg;

import gm2d.geom.Matrix;
import gm2d.geom.Rectangle;

class RenderContext
{
   public function new(inMatrix:Matrix,?inRectangle:Rectangle)
   {
      matrix = inMatrix;
      rect = inRectangle;
      firstX = 0;
      firstY = 0;
      lastX = 0;
      lastY = 0;
   }
   public function  transX(inX:Float, inY:Float)
   {
      var x =  matrix==null ? inX : (inX*matrix.a + inY*matrix.c + matrix.tx);
      return rect==null || x<rect.x ? x : x + rect.width*2;
   }
   public function  transY(inX:Float, inY:Float)
   {
      var y =  matrix==null ? inY : (inX*matrix.b + inY*matrix.d + matrix.ty);
      return rect==null || y<rect.y ? y : y + rect.width;
   }


   public function setLast(inX:Float, inY:Float)
   {
      lastX = transX(inX,inY);
      lastY = transY(inX,inY);
   }
   public var matrix:Matrix;
   public var rect:Rectangle;

   public var firstX:Float;
   public var firstY:Float;
   public var lastX:Float;
   public var lastY:Float;
}
