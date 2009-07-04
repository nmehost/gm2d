package gm2d.ui;

import flash.filters.BitmapFilterType;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.events.MouseEvent;


class Base extends flash.display.Sprite
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
         var glow = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
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
