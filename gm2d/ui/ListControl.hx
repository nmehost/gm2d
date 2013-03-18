package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.geom.Rectangle;
import gm2d.text.TextField;
import gm2d.text.TextFieldAutoSize;
import gm2d.skin.Skin;

class ListControl extends ScrollWidget
{
   var mRows:Array<Array<DisplayObject>>;
   var mRowHeights:Array<Float>;
   var mRowPos:Array<Float>;
   var mOrigItemHeight:Float;
   var mItemHeight:Float;
   var mSelected :Int;
   var mWidth:Float;
   var mHeight:Float;
   var mChildrenClean :Int;
   var mColWidths:Array<Float>;
   var mMinColWidths:Array<Float>;
   var mColPos:Array<Float>;
   var mColAlign:Array<Int>;
   var mMultiSelect:Array<Bool>;
   var mControlHeight:Float;
   public var onSelect:Int->Void;
   public var mXGap:Float;
   public var mTextSelectable:Bool;
  
   public var selectColour:Int;
   public var selectAlpha:Float;
   public var evenColour:Int;
   public var evenAlpha:Float;
   public var oddColour:Int;
   public var oddAlpha:Float;

   public function new(inWidth:Float = 100, inItemHeight:Float=0)
   {
      super();
      selectAlpha = 1.0;
      evenAlpha = 1.0;
      oddAlpha = 1.0;
      selectColour = 0xd0d0f0;
      evenColour = 0xffffff;
      oddColour = 0xf0f0ff;

      mOrigItemHeight = inItemHeight;
      mItemHeight = mOrigItemHeight;
      scrollWheelStep = mOrigItemHeight;
      mControlHeight = 0.0;
      mWidth = inWidth;
      mHeight = inItemHeight;
      mRows = [];
      mColWidths = [];
      mMinColWidths = [];
      mColPos = [0.0];
      mRowHeights = [];
      mRowPos = [0.0];
      mChildrenClean = 0;
      mSelected = -1;
      mXGap = 2.0;
      mTextSelectable = false;
      wantFocus = false;
      onSelect = null;
      mColAlign = [];
      mMultiSelect = null;
      setScrollRange(inWidth,inWidth,inItemHeight,inItemHeight);
   }

   public function clear()
   {
      mRows = [];
      mColWidths = mMinColWidths.copy();
      mColPos = [0.0];
      mRowHeights = [];
      mRowPos = [0.0];
      mChildrenClean = 0;
      mSelected = -1;
      mItemHeight = mOrigItemHeight;
      scrollWheelStep = mOrigItemHeight;
      graphics.clear();
      while(numChildren>0)
         removeChildAt(0);
      recalcPos();
   }

   public function setColAlign(inIdx:Int, inAlign:Int)
   {
      for (i in 0...inIdx)
         if (mColAlign.length==i)
            mColAlign.push(Layout.AlignCenterY | Layout.AlignLeft);
      mColAlign[inIdx] = inAlign;
   }

   public function deselect()
   {
      if (mSelected>=0 || mMultiSelect!=null)
      {
         mMultiSelect = null;
         mSelected = -1;
         drawBG();
      }
   }

   public function getRowPos(inIdx:Int)
   {
      if (inIdx>mRowPos.length)
         inIdx = mRowPos.length - 1;
      if (inIdx<0)
        inIdx = 0;
      return mRowPos[inIdx];
   }

   public function getRowHeight(inIdx:Int)
   {
      return mRowHeights[inIdx];
   }



   public function getColPos(inIdx:Int)
   {
      return mColPos[inIdx];
   }

   public function getColWidth(inIdx:Int)
   {
      return mColWidths[inIdx];
   }

   public function setMinColWidth(inCol:Int, inWidth:Float)
   {
      mMinColWidths[inCol] = inWidth;
      if (mColWidths[inCol]<inWidth)
      {
         mColWidths[inCol] = inWidth;
         recalcPos();
         layout(mWidth,mHeight);
      }
   }

   public function recalcPos()
   {
      mChildrenClean = 0;
      var pos = 0.0;
      for(i in 0...mColWidths.length)
      {
         mColPos[i] = pos;
         #if neko if (mColWidths[i]==null) mColWidths[i] = 0; #end
         pos += mColWidths[i] + mXGap;
      }
      mColPos.push(pos);

      var pos = 0.0;
      for(i in 0...mRowHeights.length)
      {
         mRowPos[i] = pos;
         pos += mRowHeights[i];
      }
      mRowPos[mRowHeights.length]=pos;

   }

   public function stringToItem(inString:String) : DisplayObject
   {
      var t = new TextField();
      Skin.current.labelRenderer.styleLabel(t);
      t.text = inString;
      t.autoSize = TextFieldAutoSize.LEFT;
      t.selectable = mTextSelectable;
      //t.border = true; t.borderColor = 0;
      if (!mTextSelectable)
         t.mouseEnabled = false;
      t.height = 20;
      return t;
   }
   public function bitmapDataToItem(inData:BitmapData) : DisplayObject
   {
      return new Bitmap(inData);
   }

   public function addRow(inRow:Array<Dynamic>,?inHeight:Null<Float>)
   {
      var row = new Array<DisplayObject>();
      var rowHeight = 0.0;
      var needRecalcPos = false;
      for(i in 0...inRow.length)
      {
         if (i==mColAlign.length)
            mColAlign.push(Layout.AlignCenterY | Layout.AlignLeft);
         if (mColWidths.length<=i)
            mColWidths.push(mMinColWidths[i]);
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
            var w = obj.width;
            if (Std.is(item,TextField))
            {
               var tf:TextField = cast item;
               w = tf.textWidth;
               h = tf.textHeight;
            }
            h = Std.int(h+0.99);

            if (inHeight!=null)
               h = inHeight;
            if (h>rowHeight)
               rowHeight = h;

            if (w>mColWidths[i])
            {
               mColWidths[i] = w;
               needRecalcPos = true;
            }
            row.push(obj);
            addChild(obj);
         }
         else
            row.push(null);
      }

      if (inHeight==null)
      {
         if (rowHeight>mItemHeight)
         {
            for(i in 0...mRowHeights.length)
               mRowHeights[i] = mItemHeight;
            mItemHeight = rowHeight;
            scrollWheelStep = rowHeight;
            needRecalcPos = true;
            mChildrenClean = 0;
         }
         else
           rowHeight = mItemHeight;
      }

      mRowHeights.push(rowHeight);
      if (needRecalcPos)
      {
         recalcPos();
      }
      else
      {
         var pos = mRowPos[mRowPos.length-1];
         mRowPos.push(pos+rowHeight);
      }
      mRows.push(row);
      layout(mWidth,mHeight);
   }
   public function addItem(inItem:Dynamic)
   {
      addRow([inItem]);
   }

   public function showItem(idx:Int)
   {
      if (idx>=0)
      {
         var top = mRowPos[idx];
         // If above, put on top row ...
         if (top<mScrollY)
            set_scrollY(top);

         // if below, raise to bottom line
         else if (top-mScrollY > mHeight-mRowHeights[idx])
            set_scrollY(mRowPos[idx+1]-mHeight);
      }
   }

   public function showSelection()
   {
      showItem(mSelected);
   }


   public function select(inIndex:Int)
   {
      if (mSelected!=inIndex || mMultiSelect!=null)
      {
         mSelected = inIndex;
         mMultiSelect = null;
         drawBG();
         if (onSelect!=null)
            onSelect(inIndex);
      }
      showItem(inIndex);
   }

   public function itemFromY(inY:Float):Float
   {
      if (inY<=0)
         return 0.0;
      if (inY<mRowPos[mRowPos.length-1])
      {
         for(idx in 0...mRowHeights.length)
            if (mRowPos[idx+1]>inY)
               return idx + (inY-mRowPos[idx])/mRowHeights[idx];
      }
      return mRowHeights.length;
   }

   public function selectByY(inY:Float):Int
   {
      var idx = Std.int(itemFromY(inY));
      if (idx<mRowPos.length)
         select(idx);
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
         var selected = i==mSelected || (mMultiSelect!=null && mMultiSelect[i]);
         gfx.beginFill( selected ? selectColour : ( (i & 1) > 0 ? oddColour: evenColour ),
                        selected ? selectAlpha  : ( (i & 1) > 0 ? oddAlpha : evenAlpha  ) );
         gfx.drawRect(0,mRowPos[i],mWidth,mRowHeights[i]);
      }

      if (mControlHeight<mHeight)
      {
         gfx.beginFill( evenColour, evenAlpha );
         gfx.drawRect(0,mControlHeight,mWidth,mHeight-mControlHeight);
      }
   }

   public function setMultiSelect(inSelection:Array<Bool>, inClearCurrent:Bool)
   {
      if (mMultiSelect!=null || inSelection!=null || (inClearCurrent && mSelected!=-1))
      {
         mMultiSelect = inSelection;
         if (inClearCurrent)
            mSelected = -1;
         drawBG();
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
                var w = item.width;
                /*
                if (Std.is(item,TextField))
                {
                   var tf:TextField = cast item;
                   w = tf.textWidth;
                   h = tf.textHeight;
                }
                */

               switch(mColAlign[i] & Layout.AlignMaskX)
               {
                  case Layout.AlignRight:
                      item.x = mColPos[i] + (mColWidths[i]-w);

                  case Layout.AlignCenterX:
                      item.x = mColPos[i] + (mColWidths[i]-w)*0.5;

                  default:
                      item.x = mColPos[i];
               }
 

               switch(mColAlign[i] & Layout.AlignMaskY)
               {
                  case Layout.AlignTop:
                      item.y = mRowPos[row_idx];

                  case Layout.AlignBottom:
                      item.y = mRowPos[row_idx+1] - h;

                  default:
                      item.y = mRowPos[row_idx] + (mRowHeights[row_idx]-h)*0.5;
               }
            }
         }
      }
      mChildrenClean = mRows.length;

      mControlHeight = mRowPos[mRowHeights.length];
      mWidth = inWidth;
      mHeight = inHeight;
      drawBG();
      setScrollRange(mWidth,mWidth,mControlHeight,mHeight);
   }
}



