package gm2d.svg;

import nme.geom.Matrix;

class Link extends DisplayElement
{
   public function new()
   {
      super();
      width = height = 1.0;
   } 

   public var link:String;
   public var width:Float;
   public var height:Float;

   override function toString() return 'Link($link)';

   override public function asLink() : Link return this;


}


