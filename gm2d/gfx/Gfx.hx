package gm2d.gfx;

import gm2d.display.GradientType;
import gm2d.display.SpreadMethod;
import gm2d.display.InterpolationMethod;
import gm2d.display.CapsStyle;
import gm2d.display.JointStyle;
import gm2d.display.LineScaleMode;

import gm2d.geom.Matrix;

class Gfx
{
   public function new() { }
   public function geometryOnly() { return false; }
   public function size(inWidth:Float,inHeight:Float) { }
   public function beginGradientFill(grad:Gradient) { }

	public function beginFill(color:Int, alpha:Float) { }
   public function endFill() { }

   public function lineStyle(style:LineStyle) { }
   public function endLineStyle() { }

   public function moveTo(inX:Float, inY:Float) { }
   public function lineTo(inX:Float, inY:Float) { }
   public function curveTo(inCX:Float, inCY:Float,inX:Float,inY:Float) { }

   public function eof() {}
}



