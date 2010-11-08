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

   static public function getItemsRecurse(inParent:DisplayObjectContainer,outList : Array<Base>)
   {
      if (!inParent.mouseEnabled) return;
      for(i in 0...inParent.numChildren)
      {
         var child = inParent.getChildAt(i);
         if (Std.is(child,Base))
         {
            var child:Base = cast child;
            if (child.wantFocus())
               outList.push(child);
         }
         if (Std.is(child,DisplayObjectContainer))
           getItemsRecurse(cast child, outList);
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

   public function layout(inW:Float,inH:Float):Void
   {
      //width = inW;
      //height = inH;
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


