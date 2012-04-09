package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.geom.Rectangle;
import gm2d.text.TextField;


class ListControl extends ScrollWidget
{
   var mRows:Array<Array<DisplayObject>>;
   var mOrigItemHeight:Float;
   var mItemHeight:Float;
   var mSelected :Int;
   var mWidth:Float;
   var mHeight:Float;
   var mChildrenClean :Int;
   var mColWidths:Array<Float>;
   var mColPos:Array<Float>;
   var mControlHeight:Float;
   public var onSelect:Int->Void;
   public var mXGap:Float;
   public var mTextSelectable:Bool;
  
   static var mSelectColour = 0xd0d0f0;
   static var mEvenColour = 0xffffff;
   static var mOddColour = 0xf0f0ff;

   public function new(inWidth:Float = 100, inItemHeight:Float=0)
   {
       super();
       mOrigItemHeight = inItemHeight;
       mItemHeight = mOrigItemHeight;
       mControlHeight = 0.0;
       mWidth = inWidth;
       mHeight = inItemHeight;
       mRows = [];
       mColWidths = [];
       mColPos = [];
       mChildrenClean = 0;
       mSelected = -1;
       mXGap = 2.0;
       mTextSelectable = false;
		 wantFocus = false;
       onSelect = null;
       setScrollRange(inWidth,inWidth,inItemHeight,inItemHeight);
   }

   public function clear()
   {
      mRows = [];
      mColWidths = [];
      mColPos = [];
      mChildrenClean = 0;
      mSelected = -1;
      mItemHeight = mOrigItemHeight;
      graphics.clear();
      while(numChildren>0)
         removeChildAt(0);
   }

   public function recalcPos()
   {
      mChildrenClean = 0;
      var pos = mXGap;
      for(i in 0...mColWidths.length)
      {
         mColPos[i] = pos;
         pos += mColWidths[i] + mXGap;
      }
   }

   public function stringToItem(inString:String) : DisplayObject
   {
      var t = new TextField();
      t.defaultTextFormat = Panel.labelFormat;
      t.text = inString;
      t.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      t.selectable = mTextSelectable;
      if (!mTextSelectable)
         t.mouseEnabled = false;
      t.height = 20;
      return t;
   }
   public function bitmapDataToItem(inData:BitmapData) : DisplayObject
   {
      return new Bitmap(inData);
   }

   public function addRow(inRow:Array<Dynamic>)
   {
      var row = new Array<DisplayObject>();
      for(i in 0...inRow.length)
      {
         var item:Dynamic = inRow[i];
         if (item!=null)
         {
            var obj:DisplayObject = null;
            if (Std.is(item,DisplayObject))
               obj = item;
            else if (Std.is(item,String))
               obj = stringToItem(item);
            else if (Std.is(item,BitmapData))
               obj = bitmapDataToItem(item);

            var h = obj.height;
            if (h>mItemHeight)
            {
               mItemHeight = h;
               mChildrenClean = 0;
            }
            var w = obj.width;
            if (mColWidths.length<=i || mColWidths[i]<w)
            {
               mColWidths[i] = w;
               recalcPos();
            }
            row.push(obj);
            addChild(obj);
         }
         else
         {
            mColWidths.push(0);
            row.push(null);
         }
      }
      mRows.push(row);
      layout(mWidth,height);
   }
   public function addItem(inItem:Dynamic)
   {
      addRow([inItem]);
   }


   public function select(inIndex:Int)
   {
      if (mSelected!=inIndex)
      {
         mSelected = inIndex;
         drawBG();
         if (onSelect!=null)
            onSelect(inIndex);
      }
   }

   public function selectByY(inY:Float):Int
   {
      if (inY>=0 && inY<mItemHeight*mRows.length)
      {
         var idx = Std.int(inY/mItemHeight);
         select(idx);
         return idx;
      }
      return -1;
   }

   override function onClick(inX:Float, inY:Float)
   {
      selectByY(inY);
   }



   public function drawBG()
   {
      var gfx = graphics;
      gfx.clear();
      for(i in 0...mRows.length)
      {
         gfx.beginFill( (i==mSelected) ? mSelectColour : ( (i & 1) > 0 ? mOddColour: mEvenColour ) );
         gfx.drawRect(0,i*mItemHeight,mWidth,mItemHeight);
      }
      if (mControlHeight<mHeight)
      {
         gfx.beginFill( mEvenColour );
         gfx.drawRect(0,mControlHeight,mWidth,mHeight-mControlHeight);
      }
   }

   public override function layout(inWidth:Float,inHeight:Float)
   {
      for(row_idx in mChildrenClean...mRows.length)
      {
         var row = mRows[row_idx];
         for(i in 0...row.length)
         {
            var item = row[i];
            if (item!=null)
            {
               var h = item.height;
               item.x = mColPos[i];
               item.y = row_idx*mItemHeight + (mItemHeight-h)*0.5;
            }
         }
      }
      mChildrenClean = mRows.length;

      mControlHeight = mItemHeight*mRows.length;
      mWidth = inWidth;
      mHeight = inHeight;
      drawBG();
      setScrollRange(mWidth,mWidth,mControlHeight,mHeight);
   }
}



