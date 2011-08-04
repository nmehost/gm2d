package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.geom.Point;


class Widget extends gm2d.display.Sprite
{
   public var wantFocus:Bool;
   //var highlightColour:Int;

   public function new()
   {
      super();
      name = "item";
		wantFocus = false;
      //highlightColour = 0x0000ff;
   }

   static public function getItemsRecurse(inParent:DisplayObjectContainer,outList : Array<Widget>)
   {
      if (!inParent.mouseEnabled || !inParent.visible) return;

      for(i in 0...inParent.numChildren)
      {
         var child = inParent.getChildAt(i);
         if (Std.is(child,Widget))
         {
            var child:Widget = cast child;
            if (child.wantFocus)
               outList.push(child);
         }
         if (Std.is(child,DisplayObjectContainer))
           getItemsRecurse(cast child, outList);
      }
   }

   public function onKeyDown(event:gm2d.events.KeyboardEvent ) : Bool { return false; }

   public function layout(inW:Float,inH:Float):Void { }

   public function activate(inDirection:Int) { }

   public function onCurrentChanged(inCurrent:Bool) { }

   public function popup(inPopup:Window,inX:Float,inY:Float,inShadow:Bool=true)
   {
	   var pos = localToGlobal( new Point(inX,inY) );
		gm2d.Game.popup(inPopup,pos.x,pos.y,inShadow);
   }

   public function clearCurrent()
   {
      var p = parent;
      while(p!=null)
      {
         if (Std.is(p,Window))
         {
            var window : Window = cast p;
            window.setCurrentItem(null);
            return;
         }
         p = p.parent;
      }
   }



   public function setCurrent()
   {
      var p = parent;
      while(p!=null)
      {
         //trace(p);
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


