package gm2d.ui;

import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;
import gm2d.events.MouseEvent;


class Base extends gm2d.display.Sprite
{
   var current:Bool;
   var highlightColour:Int;

   public function new()
   {
      super();
      current = false;
      highlightColour = 0x0000ff;
   }

   public dynamic function onCurrentChanged(inCurrent:Bool)
   {
      if (inCurrent)
      {
         var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
         filters = [ glow ];
      }
      else
         filters = null;
   }

   public function activate(inDirection:Int) { }

   public function setCurrent(inCurrent:Bool)
   {
      current = inCurrent;
      onCurrentChanged(inCurrent);
   }

}
