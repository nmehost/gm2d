package gm2d.ui;

import nme.events.MouseEvent;
import nme.display.DisplayObjectContainer;
import nme.ui.Keyboard;

class Window extends Widget
{
   var focusWidget:Widget;
   var sleepingWidget:Widget;

   public function new(?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super(Widget.addLine(inLineage,"Window"), inAttribs);
      focusWidget = null;
      addEventListener(MouseEvent.MOUSE_MOVE, windowMouseMove);
      addEventListener(MouseEvent.MOUSE_DOWN, currentFromMouse);
   }

   public function destroy()
   {
      removeEventListener(MouseEvent.MOUSE_MOVE, windowMouseMove);
      removeEventListener(MouseEvent.MOUSE_DOWN, currentFromMouse);
   }

   public function getWidgetList(?base:DisplayObjectContainer) : Array<Widget>
   {
      var result = new Array<Widget>();
      Widget.getWidgetsRecurse(base==null ? this : base,result);
      return result;
   }

   public function setActive(inActive:Bool)
   {
       if (inActive)
       {
          if (focusWidget==null && sleepingWidget!=null)
             setCurrentItem(sleepingWidget);
          sleepingWidget = null;
       }
       else
       {
          sleepingWidget = focusWidget;
          setCurrentItem(null);
       }
   }

   function currentFromMouse(inEvent:MouseEvent)
   {
      checkCurrentMode(false);
      var target:nme.display.DisplayObject = inEvent.target;
      while(target!=null && target!=this)
      {
         if (Std.isOfType(target,Widget))
         {
             var widget:Widget = cast target;
             if (widget.wantsFocus())
                setCurrentItem(widget);
             return;
         }
         target = target.parent;
      }
   }

   function windowMouseMove(inEvent:MouseEvent)
   {
      if (!inEvent.buttonDown)
         currentFromMouse(inEvent);
   }


   public function setCurrentItem(inItem:gm2d.ui.Widget)
   {
      if (inItem!=focusWidget)
      {
         if (focusWidget!=null)
            focusWidget.isCurrent = false;
         focusWidget = inItem;
         if (focusWidget!=null)
            focusWidget.isCurrent = true;
        if (stage!=null)
           stage.invalidate();
        //if (focusWidget!=null)
        //  trace(this + " setCurrentItem -> " + focusWidget );
      }
   }

   public function checkCurrentMode(inKeys:Bool)
   {
      if (Widget.autoShowCurrent)
      {
         if (inKeys!=Widget.showCurrent)
         {
            Widget.showCurrent = inKeys;
            if (focusWidget!=null)
               focusWidget.rebuildState( );
         }
      }
   }


   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      if (focusWidget!=null)
      {
         var used =  focusWidget.onKeyDown(event);
         if (used)
            return true;
      }


      var code = event.keyCode;
      var dx = 0;
      var dy = 0;
      var dir:String = null;

      if (code == Keyboard.DOWN)
      {
         dy = 1;
         dir = "Down";
      }
      else if (code == Keyboard.UP)
      {
         dir = "Up";
         dy = -1;
      }
      else if (code == Keyboard.LEFT)
      {
         dir="Left";
         dx = -1;
      }
      else if (code == Keyboard.RIGHT)
      {
         dir = "Right";
         dx = 1;
      }

      if (dx!=0 || dy!=0)
      {
         checkCurrentMode(true);
         if (focusWidget==null || focusWidget.stage==null)
         {
            var items = getWidgetList();
            if (items.length>0)
            {
               setCurrentItem( items[0] );
            }
         }
         else
         {
            var nextCurrent:Widget = focusWidget.attrib("next"+dir);
            if (nextCurrent==null)
            {
               var p00 = new nme.geom.Point(0,0);
               var pos = focusWidget.localToGlobal(p00);

               var commonParent = focusWidget.parent;
               var closest = 0.0;

               while(commonParent != null)
               {
                  for(widget in getWidgetList(commonParent))
                  {
                     if (widget==focusWidget || !widget.wantsFocus())
                        continue;
                     var p = widget.localToGlobal(p00);
                     var dpx = p.x-pos.x;
                     var dpy = p.y-pos.y;

                     // Same Y and moving left/right...
                     if (dpy==0 && dy==0 )
                        dpx *= 0.01; 

                     // Same X and moving up/down
                     else if (dpx==0 && dx==0 )
                        dpy *= 0.01; 
   
                     if (dpx*dx>=0 && dpy*dy>=0 && ( dpx*dx>0 || dpy*dy>0 ) )
                     {
                        var dist = Math.sqrt(dpx*dpx*(Math.abs(dx)+0.5) +
                                             dpy*dpy*(Math.abs(dy)+0.5));
                        if (nextCurrent==null || dist<closest)
                        {
                           nextCurrent = widget;
                           closest = dist;
                        }
                     }
                  }

                  if (nextCurrent!=null)
                     break;
                  if (commonParent==this)
                     break;
                  commonParent = commonParent.parent;
               }
            }

            if (nextCurrent!=null)
               setCurrentItem(nextCurrent);
         }
         return true;
      }

      if (focusWidget!=null)
      {
          if (code==Keyboard.ENTER)
          {
             focusWidget.activate();
             return true;
          }
      }
      return true;
      //return false;
   }

   public function getWindowWidth() { return width; }
   public function getWindowHeight() { return height; }

   public function onKeyUp(event:nme.events.KeyboardEvent):Bool { return false; }
   public dynamic function onAdded() { }

   public function onMouseMove(inX:Float, inY:Float) { }
   public function onMouseDown(inX:Float, inY:Float) { }
   public function onMouseUp(inX:Float, inY:Float) { }
   public function onMouseClick(inX:Float, inY:Float) { }


}


