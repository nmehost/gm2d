package gm2d.svg;

import nme.geom.Matrix;

class Marker extends Group
{
   public var path:Path;
   public var refX:Float;
   public var refY:Float;
   public var orient:String;

   public function new()
   {
      super();
      refX = refY = 0;
   }

   override public function asMarker() : Marker return this;
}
