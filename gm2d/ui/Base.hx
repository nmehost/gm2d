package gm2d.ui;

import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;
import gm2d.display.DisplayObjectContainer;
import gm2d.events.MouseEvent;
import gm2d.ui.Layout;


class Base extends gm2d.display.Sprite
{
   var highlightColour:Int;

   public function new()
   {
      super();
      name = "item";
      highlightColour = 0x0000ff;
   }

   public function getItemsRecurse(outList : Array<Base>)
   {
      if (wantFocus())
         outList.push(this);
      for(i in 0...numChildren)
      {
         var child = getChildAt(i);
         if (Std.is(child,Base))
         {
            var child:Base = cast child;
            child.getItemsRecurse(outList);
          }
      }
   }

   public function wantFocus() { return true; }

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

   public function setCurrent()
   {
      var p = parent;
      while(p!=null)
      {
         trace(p);
         if (Std.is(p,Window))
         {
            var window : Window = cast p;
            window.setCurrentItem(this);
            return;
         }
         p = p.parent;
      }
   }

}


