package gm2d.ui;

import gm2d.display.DisplayObject;

class ListControl extends Base
{
   var mItems:Array<DisplayObject>;
   var mItemHeight:Float;
   var mSelected :Int;
   var mWidth:Float;
   var mChildrenClean :Int;
  
   static var mSelectColour = 0xd0d0f0;
   static var mEvenColour = 0x0f0f0f0;
   static var mOddColour = 0xe0e0f0;

   public function new(inWidth = 100, inItemHeight:Float=0)
   {
       super();
       mItemHeight = inItemHeight;
       mWidth = inWidth;
       mItems = [];
       mChildrenClean = 0;
       mSelected = 0;
   }

   public function addItem(inItem:DisplayObject)
   {
      var h = inItem.height;
      if (h>mItemHeight)
      {
         mItemHeight = h;
         mChildrenClean = 0;
      }
      mItems.push(inItem);
      addChild(inItem);
      layout(mWidth);
   }

   override public function wantFocus() { return false; }


   public function drawBG()
   {
      var gfx = graphics;
      for(i in 0...mItems.length)
      {
         gfx.beginFill( (i==mSelected) ? mSelectColour : ( (i & 1) > 0 ? mOddColour: mEvenColour ) );
         gfx.drawRect(0,i*mItemHeight,mWidth,mItemHeight);
         trace("drawBG " + mItemHeight);
      }
   }

   public function layout(inWidth:Float)
   {
      for(i in mChildrenClean...mItems.length)
      {
         var o = mItems[i];
         var h = o.height;
         o.x = 2;
         trace(i + " = " + (mItemHeight-h)*0.5 );
         o.y = i*mItemHeight + (mItemHeight-h)*0.5;
      }
      mChildrenClean = mItems.length;

      mWidth = inWidth;
      drawBG();
   }

   
   
}


