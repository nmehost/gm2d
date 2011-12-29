package gm2d.icons;

import gm2d.display.Graphics;
import gm2d.display.BitmapData;
import gm2d.geom.Matrix;

class Icon
{
   public var width(getWidth,null) : Int;
   public var height(getHeight,null) : Int;

   function getWidth() : Int { return 48; }
   function getHeight() : Int { return 48; }

   function new() { }

   public function render(g:Graphics) { }

   public function toBitmap(scale:Float = 1.0) : BitmapData
   {
      var bmp = new BitmapData( Std.int(width*scale+0.99), Std.int(height*scale+0.99),
        true, gm2d.RGB.CLEAR);

      var shape = new gm2d.display.Shape();
      render(shape.graphics);
      var m = new Matrix();
      m.scale(scale,scale);
      bmp.draw(shape,m);

      return bmp;
   }
}
