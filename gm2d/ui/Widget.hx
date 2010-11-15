package gm2d.ui;

import gm2d.display.DisplayObjectContainer;


class Widget extends gm2d.display.Sprite
{
   //var highlightColour:Int;

   public function new()
   {
      super();
      name = "item";
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
            if (child.wantFocus())
               outList.push(child);
         }
         if (Std.is(child,DisplayObjectContainer))
           getItemsRecurse(cast child, outList);
      }
   }

   public function wantFocus() { return false; }

   public function onKeyDown(event:gm2d.events.KeyboardEvent ) : Bool { return false; }

   public function layout(inW:Float,inH:Float):Void { }

   public function activate(inDirection:Int) { }

   public function onCurrentChanged(inCurrent:Bool) { }


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


