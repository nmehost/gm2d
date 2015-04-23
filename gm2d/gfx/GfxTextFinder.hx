package gm2d.gfx;

import gm2d.svg.Text;

class GfxTextFinder extends Gfx
{
   public var text : Text;

   public function new() { super(); }

   override public function geometryOnly() { return true; }
   override public function renderText(inText:Text, m:nme.geom.Matrix)
   {
      if (text==null)
         text = inText;
   }
}

