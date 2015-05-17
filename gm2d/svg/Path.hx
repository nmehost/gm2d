package gm2d.svg;

import nme.geom.Matrix;

typedef PathSegments = Array<PathSegment>;

class Path extends DisplayElement
{
   public var segments:PathSegments;

   public function new()
   {
      super();
      segments = [];
   }

   override function toString():String return "Path(" + (segments==null ? "0" : segments.length+"") + ")";


   override public function asPath() : Path return this;

}
