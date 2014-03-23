package gm2d.ui2;

import nme.events.MouseEvent;
import nme.display.Sprite;
import nme.ui.Keyboard;

class Window extends Sprite
{
   var mCurrent:IWidget;
   var mDeactive:IWidget;

   public function new()
   {
      super();
      mCurrent = null;
      name = "Window";
      addEventListener(MouseEvent.MOUSE_MOVE, windowMouseMove);
   }

   public function destroy()
   {
      removeEventListener(MouseEvent.MOUSE_MOVE, windowMouseMove);
   }

   public function getIWidgetList() : Array<IWidget>
   {
      var result = new Array<IWidget>();
      Widget.getIWidgetsRecurse(this,result);
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
            if (Std.is(target,IWidget))
            {
                var widget:IWidget = cast target;
                if (widget.wantsFocus())
                   setCurrentItem(widget);
                return;
            }
            target = target.parent;
         }
      }
   }


   public function setCurrentItem(inItem:gm2d.ui2.IWidget)
   {
      if (inItem!=mCurrent)
      {
         if (mCurrent!=null)
            mCurrent.onCurrentChanged(false);
         mCurrent = inItem;
         if (mCurrent!=null)
            mCurrent.onCurrentChanged(true);
      }
   }


   public function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      if (mCurrent!=null)
      {
         var used =  mCurrent.onKeyDown(event);
         if (used)
            return true;
      }


      var code = event.keyCode;
      var dir = 0;
      if (code == Keyboard.DOWN || code==Keyboard.RIGHT || (code==Keyboard.TAB && !event.shiftKey) )
         dir = 1;
      else if (code==Keyboard.UP || code==Keyboard.LEFT || code==Keyboard.TAB)
         dir = -1;

      if (dir!=0)
      {
         var items = getIWidgetList();
         var l = items.length;
         if (l>0)
         {
            var index = 0;
            for(i in 0...l)
               if (mCurrent==items[i])
                  index = i;
            setCurrentItem( items[ (index+dir+l ) % l ] );
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


