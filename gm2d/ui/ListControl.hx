package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.text.TextField;


class ListControl extends Control
{
   var mItems:Array<DisplayObject>;
   var mItemHeight:Float;
   var mSelected :Int;
   var mWidth:Float;
   var mChildrenClean :Int;
  
   static var mSelectColour = 0xd0d0f0;
   static var mEvenColour = 0xffffff;
   static var mOddColour = 0xf0f0ff;

   public function new(inWidth:Float = 100, inItemHeight:Float=0)
   {
       super();
       mItemHeight = inItemHeight;
       mWidth = inWidth;
       mItems = [];
       mChildrenClean = 0;
       mSelected = -1;
		 wantFocus = false;
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
      layout(mWidth,height);
   }

   public function addText(inString:String,inSelectable:Bool=true)
   {
      var t = new TextField();
      t.defaultTextFormat = Panel.labelFormat;
      t.text = inString;
      t.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      t.selectable = inSelectable;
      if (!inSelectable)
         t.mouseEnabled = false;
      t.height = 20;
      addItem(t);
   }

   public function select(inIndex:Int)
   {
      if (mSelected!=inIndex)
      {
         mSelected = inIndex;
         drawBG();
      }
   }

   public function selectByY(inY:Float):Int
   {
      if (inY>=0 && inY<mItemHeight*mItems.length)
      {
         var idx = Std.int(inY/mItemHeight);
         select(idx);
         return idx;
      }
      return -1;
   }


   public function drawBG()
   {
      var gfx = graphics;
      gfx.clear();
      for(i in 0...mItems.length)
      {
         gfx.beginFill( (i==mSelected) ? mSelectColour : ( (i & 1) > 0 ? mOddColour: mEvenColour ) );
         gfx.drawRect(0,i*mItemHeight,mWidth,mItemHeight);
      }
   }

   public override function layout(inWidth:Float,inHeight:Float)
   {
      for(i in mChildrenClean...mItems.length)
      {
         var o = mItems[i];
         var h = o.height;
         o.x = 2;
         o.y = i*mItemHeight + (mItemHeight-h)*0.5;
      }
      mChildrenClean = mItems.length;

      mWidth = inWidth;
      drawBG();
   }

   
   
}


