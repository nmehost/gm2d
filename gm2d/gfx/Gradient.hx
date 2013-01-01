package gm2d.gfx;

import gm2d.geom.Matrix;
import gm2d.display.GradientType;
import gm2d.display.SpreadMethod;
import gm2d.display.InterpolationMethod;
import gm2d.display.CapsStyle;
import gm2d.display.JointStyle;
import gm2d.display.LineScaleMode;
import gm2d.CInt;

class Gradient
{
   public function new()
   {
      type = GradientType.LINEAR;
      colors = [];
      alphas = [];
      ratios = [];
      matrix = new Matrix();
      spread = SpreadMethod.PAD;
      interp = InterpolationMethod.RGB;
      focus = 0.0;
   }

   public var type:GradientType;
   public var colors:Array<CInt>;
   public var alphas:Array<Float>;
   public var ratios:Array<Int>;
   public var matrix: Matrix;
   public var spread: SpreadMethod;
   public var interp:InterpolationMethod;
   public var focus:Float;

}

