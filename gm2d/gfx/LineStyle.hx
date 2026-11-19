package gm2d.gfx;

import nme.display.LineScaleMode;
import nme.display.CapsStyle;
import nme.display.JointStyle;
import nme.display.LineOrder;

class LineStyle
{
   public var thickness:Float;
   public var color:Int;
   public var gradient:Gradient;
   public var alpha:Float;
   public var pixelHinting:Bool;
   public var scaleMode:LineScaleMode;
   public var capsStyle:CapsStyle;
   public var jointStyle:JointStyle;
   public var miterLimit:Float;
   // Whether the line is drawn over or under the fill - the svg paint-order
   public var order:LineOrder;

   public function new()
   {
      thickness = 1.0;
      color = 0x000000;
      gradient = null;
      alpha = 1.0;
      pixelHinting = false;
      scaleMode = LineScaleMode.NORMAL;
      capsStyle = CapsStyle.ROUND;
      jointStyle = JointStyle.ROUND;
      miterLimit = 3.0;
      order = LineOrder.OVER_FILL;
   }
}
