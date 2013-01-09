package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.geom.Rectangle;
import gm2d.text.TextField;
import gm2d.skin.Skin;

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
   var mColAlign:Array<Int>;
   var mControlHeight:Float;
   public var onSelect:Int->Void;
   public var mXGap:Float;
   public var mTextSelectable:Bool;
  
   public var autoItemHeight:Bool;
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
       autoItemHeight = true;

       mOrigItemHeight = inItemHeight;
       mItemHeight = mOrigItemHeight;
       scrollWheelStep = mOrigItemHeight;
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
       mColAlign = [];
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
      scrollWheelStep = mOrigItemHeight;
      graphics.clear();
      while(numChildren>0)
         removeChildAt(0);
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
      if (mSelected>=0)
      {
         mSelected = -1;
         drawBG();
      }
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
         pos += mColWidths[i] + mXGap;
      }
      mColPos.push(pos);
   }

   public function stringToItem(inString:String) : DisplayObject
   {
      var t = new TextField();
      Skin.current.labelRenderer.styleLabel(t);
      t.text = inString;
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
         if (i==mColAlign.length)
            mColAlign.push(Layout.AlignCenterY | Layout.AlignLeft);
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

            if (h>mItemHeight && autoItemHeight)
            {
               mItemHeight = h;
               scrollWheelStep = h;
               mChildrenClean = 0;
            }
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
         var top = idx*mItemHeight;
         // If above, put on top row ...
         if (top<mScrollY)
            setScrollY(top);
    
         // if below, raise to bottom line
         else if (top-mScrollY > mHeight-mItemHeight)
            setScrollY(top+mItemHeight-mHeight);
      }
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
      showItem(inIndex);
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
         gfx.beginFill( (i==mSelected) ? selectColour : ( (i & 1) > 0 ? oddColour: evenColour ),
                        (i==mSelected) ? selectAlpha  : ( (i & 1) > 0 ? oddAlpha : evenAlpha  ) );
         gfx.drawRect(0,i*mItemHeight,mWidth,mItemHeight);
      }
      if (mControlHeight<mHeight)
      {
         gfx.beginFill( evenColour, evenAlpha );
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
               var w = item.width;
               switch(mColAlign[i] & Layout.AlignMaskX)
               {
                  case Layout.AlignRight:
                      item.x = mColPos[i] + (mColWidths[i]-w);

                  case Layout.AlignCenterX:
                      item.x = mColPos[i] + (mColWidths[i]-w)*0.5;

                  default:
                      item.x = mColPos[i];
               }
 

               var h = item.height;
               switch(mColAlign[i] & Layout.AlignMaskY)
               {
                  case Layout.AlignTop:
                      item.y = row_idx*mItemHeight;

                  case Layout.AlignBottom:
                      item.y = row_idx*mItemHeight + (mItemHeight-h);

                  default:
                      item.y = row_idx*mItemHeight + (mItemHeight-h)*0.5;
               }
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



