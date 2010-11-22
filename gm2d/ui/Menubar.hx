package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import gm2d.display.BitmapData;
import gm2d.display.Graphics;
import gm2d.display.Sprite;
import gm2d.display.DisplayObjectContainer;
import gm2d.text.TextField;
import gm2d.events.MouseEvent;
import gm2d.text.TextFieldAutoSize;


class Menubar extends Sprite
{
   var mWidth:Float;
   var mHeight:Float;
   var mNextX:Float;
   var mCurrentItem:Int;
	var mNormalParent:DisplayObjectContainer;

   var mItems:Array<MenuItem>;
   var mButtons:Array<Button>;

   public function new()
   {
      super();
      mItems = [];
      mButtons = [];
      mNextX = 2;
      mCurrentItem = -1;
		mNormalParent = null;
   }

   public function add(inItem:MenuItem)
   {
      var pos = mItems.length;
      mItems.push(inItem);
      
      var me = this;
      var nx = mNextX;
      var but = Button.TextButton(inItem.gmText,function(){me.popup(pos);});
      mButtons.push(but);
		Skin.current.styleMenu(but);
      but.addEventListener(MouseEvent.MOUSE_OVER, function(_) me.onMouseItem(pos) );

      but.x = mNextX;
      mNextX += but.width + 10;
      addChild(but);
   }

   function onMouseItem(inPos:Int)
   {
      if (mCurrentItem>=0  && mCurrentItem!=inPos)
         popup(inPos);
   }

   public function popup(inPos:Int)
   {
      Game.closePopup();
      mCurrentItem = inPos;
      mButtons[mCurrentItem].getLabel().background = true;
      mButtons[mCurrentItem].getLabel().textColor = 0xffffff;
		if (mNormalParent==null)
		{
		   mNormalParent = parent;
			Game.moveToPopupLayer(this);
		}
      Game.popup( new PopupMenu(mItems[inPos],this), mButtons[inPos].x, mHeight );
   }

   public function closeMenu(inItem:MenuItem)
   {
	   if (mNormalParent!=null)
		{
		   mNormalParent.addChildAt(this,0);
			mNormalParent = null;
		}
      if (mCurrentItem>=0 && mItems[mCurrentItem]==inItem)
      {
         mButtons[mCurrentItem].getLabel().background = false;
         mButtons[mCurrentItem].getLabel().textColor = 0x000000;
         mCurrentItem = -1;
      }
   }

   public function layout(inWidth:Float, inHeight:Float)
   {
       mWidth = inWidth;
       mHeight = inHeight;
       Skin.current.renderMenubar(this,mWidth,mHeight);
       for(but in mButtons)
          but.y = (mHeight-but.height)/2;
   }
}


