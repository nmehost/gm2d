package gm2d.svg;

import nme.geom.Matrix;

class Marker extends DisplayElement
{
   public var path:Path;
   public var refX:Float;
   public var refY:Float;
   public var orient:String;

   public function new()
   {
      super();
   }

   override public function asMarker() : Marker return this;
}
