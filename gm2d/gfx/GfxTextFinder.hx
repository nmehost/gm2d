package gm2d.gfx;

import gm2d.svg.Text;
import gm2d.svg.TextStyle;

class GfxTextFinder extends Gfx
{
   public var text : Text;
   public var style : TextStyle;

   public function new() { super(); }

   override public function geometryOnly() { return true; }
   override public function renderText(inText:Text, m:nme.geom.Matrix, inStyle:TextStyle)
   {
      if (text==null)
      {
         text = inText;
         style = inStyle;
      }
   }
}

