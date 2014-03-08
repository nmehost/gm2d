package gm2d.gfx;

import nme.geom.Matrix;
import nme.display.GradientType;
import nme.display.SpreadMethod;
import nme.display.InterpolationMethod;
import nme.display.CapsStyle;
import nme.display.JointStyle;
import nme.display.LineScaleMode;
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

