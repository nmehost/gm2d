package gm2d.svg;

import gm2d.geom.Matrix;
import gm2d.display.GradientType;
import gm2d.display.SpreadMethod;
import gm2d.display.InterpolationMethod;
import gm2d.display.CapsStyle;
import gm2d.display.JointStyle;
import gm2d.display.LineScaleMode;

typedef PathSegments = Array<PathSegment>;

class Path
{
   public function new() { }

   public var matrix:Matrix;
   public var name:String;
   public var font_size:Float;
   public var fill:FillType;
   public var fill_alpha:Float;
   public var stroke_alpha:Float;
   public var stroke_colour:Null<Int>;
   public var stroke_width:Float;
   public var stroke_caps:CapsStyle;
   public var joint_style:JointStyle;
   public var miter_limit:Float;

   public var segments:PathSegments;
}
