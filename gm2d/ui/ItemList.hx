package gm2d.ui;

import gm2d.display.Sprite;
import gm2d.events.MouseEvent;
import gm2d.ui.Keyboard;


class ItemList
{
   var mParent:Sprite;
   var mItems:Array<gm2d.ui.Base>;
   var mCurrent:gm2d.ui.Base;

   public function new(inParent:Sprite)
   {
      mParent = inParent;
      mCurrent = null;
      mItems = [];
   }

   public function setCurrent(inItem:gm2d.ui.Base)
   {
      if (inItem!=mCurrent)
      {
         if (mCurrent!=null)
            mCurrent.setCurrent(false);
         mCurrent = inItem;
         if (mCurrent!=null)
            mCurrent.setCurrent(true);
      }
   }

   public function addUI(inItem:gm2d.ui.Base)
   {
      mItems.push(inItem);
      if (mItems.length==1)
      {
         mCurrent = inItem;
         mCurrent.setCurrent(true);
      }
      var me = this;
      inItem.addEventListener( MouseEvent.MOUSE_OVER, function (_) { me.setCurrent(inItem); });

      mParent.addChild(inItem);
   }


   public function onKeyDown(event:gm2d.events.KeyboardEvent ) : Bool
   {
      var code = event.keyCode;
      if (mItems.length>1)
      {
         var dir = 0;
         if (code == Keyboard.DOWN || code==Keyboard.RIGHT || (code==Keyboard.TAB && !event.shiftKey) )
            dir = 1;
         else if (code==Keyboard.UP || code==Keyboard.LEFT || code==Keyboard.TAB)
            dir = -1;
         if (dir!=0)
         {
            for(i in 0...mItems.length)
            {
               if (mItems[i]==mCurrent)
               {
                  setCurrent(mItems[ (i+dir+mItems.length) % mItems.length ]);
                  return true;
               }
            }
         }
      }
      if (mCurrent!=null)
      {
          if (code==Keyboard.ENTER)
          {
             mCurrent.activate(0);
             return true;
          }
          /*
          else if (code==Keyboard.RIGHT)
          {
             mCurrent.activate(1);
             return true;
          }
          else if (code==Keyboard.LEFT)
          {
             mCurrent.activate(2);
             return true;
          }
          */
      }
      return false;
   }


}
