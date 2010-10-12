package gm2d.ui;

import gm2d.events.MouseEvent;

class Window extends Base
{
   var mCurrent:Base;
   var mDeactive:Base;

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

   public function getItemList() : Array<Base>
   {
      var result = new Array<Base>();

      Base.getItemsRecurse(this,result);
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
      var target:gm2d.display.DisplayObject = inEvent.target;
      while(target!=null && target!=this)
      {
         if (Std.is(target,Base))
         {
             var base:Base = cast target;
             if (base.wantFocus())
                setCurrentItem(base);
             return;
         }
         target = target.parent;
      }
   }


   override public function wantFocus() { return false; }

   public function setCurrentItem(inItem:gm2d.ui.Base)
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


   public function onKeyDown(event:gm2d.events.KeyboardEvent ) : Bool
   {
      //if (mCurrent!=null)
      //{
         //return mCurrent.onKeyDown(event);
      //}


      var code = event.keyCode;
      var dir = 0;
      if (code == Keyboard.DOWN || code==Keyboard.RIGHT || (code==Keyboard.TAB && !event.shiftKey) )
         dir = 1;
      else if (code==Keyboard.UP || code==Keyboard.LEFT || code==Keyboard.TAB)
         dir = -1;

      if (dir!=0)
      {
         var items = getItemList();
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
}


