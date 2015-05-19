package gm2d.ui;

import nme.events.MouseEvent;
import nme.ui.Keyboard;

class Window extends Widget
{
   var mCurrent:Widget;
   var mDeactive:Widget;

   public function new(?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super(Widget.addLine(inLineage,"Window"), inAttribs);
      mCurrent = null;
      addEventListener(MouseEvent.MOUSE_MOVE, windowMouseMove);
   }

   public function destroy()
   {
      removeEventListener(MouseEvent.MOUSE_MOVE, windowMouseMove);
   }

   public function getWidgetList(?base:Widget) : Array<Widget>
   {
      var result = new Array<Widget>();
      Widget.getWidgetsRecurse(base==null ? this : base,result);
      return result;
   }

   public function setActive(inActive:Bool)
   {
       if (inActive)
       {
          if (mCurrent==null && mDeactive!=null)
             setCurrentItem(mDeactive);
          mDeactive = null;
       }
       else
       {
          mDeactive = mCurrent;
          setCurrentItem(null);
       }
   }

   function windowMouseMove(inEvent:MouseEvent)
   {
      if (!inEvent.buttonDown)
      {
         var target:nme.display.DisplayObject = inEvent.target;
         while(target!=null && target!=this)
         {
            if (Std.is(target,Widget))
            {
                var widget:Widget = cast target;
                if (widget.wantsFocus())
                   setCurrentItem(widget);
                return;
            }
            target = target.parent;
         }
      }
   }


   public function setCurrentItem(inItem:gm2d.ui.Widget)
   {
      if (inItem!=mCurrent)
      {
         if (mCurrent!=null)
            mCurrent.isCurrent = false;
         mCurrent = inItem;
         if (mCurrent!=null)
            mCurrent.isCurrent = true;
      }
   }


   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      if (mCurrent!=null)
      {
         var used =  mCurrent.onKeyDown(event);
         if (used)
            return true;
      }


      var code = event.keyCode;
      var dx = 0;
      var dy = 0;

      if (code == Keyboard.DOWN)
         dy = 1;
      else if (code == Keyboard.UP)
         dy = -1;
      else if (code == Keyboard.LEFT)
         dx = -1;
      else if (code == Keyboard.RIGHT)
         dx = 1;

      if (dx!=0 || dy!=0)
      {
         if (mCurrent==null || mCurrent.stage==null)
         {
            var items = getWidgetList();
            if (items.length>0)
               setCurrentItem( items[0] );
         }
         else
         {
            var p00 = new nme.geom.Point(0,0);
            var pos = mCurrent.localToGlobal(p00);

            var bestSibling:Widget = null;
            var scoreSibling = 0.0;
            var best:Widget = null;
            var score = 0.0;

            for(widget in getWidgetList())
            {
               if (widget==mCurrent)
                  continue;
               var p = widget.localToGlobal(p00);
               var dpx = p.x-pos.x;
               var dpy = p.y-pos.y;
             
               if (dpx*dx>=0 && dpy*dy>=0 && ( dpx*dx>0 || dpy*dy>0 ) )
               {
                  // TODO - better sibling logic...
                  var dist = Math.sqrt(dpx*dpx*(Math.abs(dx)+0.01) + dpy*dpy*(Math.abs(dy)+0.1));
                  if (best==null || dist<score)
                  {
                     best = widget;
                     score = dist;
                  }
                  var sharesParent = false;
                  var p = widget.parent;
                  while(p!=this && p!=null && !sharesParent)
                  {
                     sharesParent = p==mCurrent.parent;
                     p = p.parent;
                  }
                  if (sharesParent && (bestSibling==null || dist<scoreSibling))
                  {
                     bestSibling = widget;
                     scoreSibling = dist;
                  }
               }
            }
            if (bestSibling!=null)
               setCurrentItem(bestSibling);
            else if (best!=null)
               setCurrentItem(best);
         }

      }

      if (mCurrent!=null)
      {
          if (code==Keyboard.ENTER)
          {
             mCurrent.activate(0);
             return true;
          }
      }
      return false;
   }

   public function getWindowWidth() { return width; }
   public function getWindowHeight() { return height; }

   public function onKeyUp(event:nme.events.KeyboardEvent):Bool { return false; }
   public dynamic function onAdded() { }

   public function onMouseMove(inX:Float, inY:Float) { }
   public function onMouseDown(inX:Float, inY:Float) { }
   public function onMouseUp(inX:Float, inY:Float) { }


}


