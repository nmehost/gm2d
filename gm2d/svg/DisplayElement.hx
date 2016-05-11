package gm2d.svg;

import nme.geom.Matrix;
import nme.display.GradientType;
import nme.display.SpreadMethod;
import nme.display.InterpolationMethod;
import nme.display.CapsStyle;
import nme.display.JointStyle;
import nme.display.LineScaleMode;

typedef Style = Map<String,String>;


class DisplayElement
{


   public var name:String;
   public var id:String;
   public var x:Float;
   public var y:Float;
   public var matrix:Matrix;

   public var style:Style;

   public function new()
   {
      name = "";
      id = "";
      x = 0;
      y = 0;
   }


   function toString():String return "DisplayElement";


   public function asGroup() : Group return null;
   public function asPath() : Path return null;
   public function asLink() : Link return null;
   public function asText() : Text return null;
   public function asMarker() : Marker return null;

}

