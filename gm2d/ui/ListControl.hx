package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.text.TextField;
import nme.events.MouseEvent;
import nme.text.TextFieldAutoSize;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;
import gm2d.ui.Layout;

class ListControlRow
{
   public function new(inObjs:Array<DisplayObject>,inHeight:Float,inUserData:Dynamic,inIndent:Float)
   {
      objs = inObjs;
      height = inHeight;
      userData = inUserData;
      indent = inIndent;
   }
   public var objs:Array<DisplayObject>;
   public var height:Float;
   public var indent:Float;
   public var userData:Dynamic;
}

class ListControl extends ScrollWidget
{
   var mRows:Array<ListControlRow>;
   var mRowPos:Array<Float>;
   var mStretchCol:Null<Int>;
   var mOrigItemHeight:Float;
   var mItemHeight:Float;
   var mSelected :Int;
   var mListContents:Sprite;
   var mWidth:Float;
   var mMinWidth:Float;
   var mMinControlWidth:Float;
   var mHeight:Float;
   var mChildrenClean :Int;
   var mColWidths:Array<Float>;
   var mMinColWidths:Array<Float>;
   var mColPos:Array<Float>;
   var mColAlign:Array<Int>;
   var mMultiSelect:Array<Bool>;
   var mControlHeight:Float;
   var mHoldUpdates = 0;

   public var onSelect:Int->Void;
   public var onMultiSelect:Array<Bool>->Void;
   public var mXGap:Float;
   public var mTextSelectable:Bool;
  
   var    evenRenderer:Renderer;
   var    oddRenderer:Renderer;
   var    selectRenderer:Renderer;

   public var variableHeightRows = false;


   public function new(?inOnSelect:Int->Void, ?inLineage:Array<String>,?inAttribs:{})
   {
      super(Widget.addLine(inLineage,"List"), inAttribs);

      mMinControlWidth = mMinWidth = attribFloat("width",0);
      mWidth = mMinWidth;
      mOrigItemHeight = mHeight = attribFloat("itemHeight",0);
      mItemHeight = mOrigItemHeight;

      var rowLineage = attrib("rowLineage") ? [attrib("rowLineage"),"ListRow"] : ["ListRow"];
      var attribs = attrib("rowAttribs");
      if (hasAttrib("itemHeight"))
         Widget.addAttribs( attribs, {minSize: new Size(mMinWidth,mItemHeight) } );

      mXGap = attribFloat("xgap",Skin.scale(2.0));

      oddRenderer = Skin.renderer(rowLineage,   0, attribs);
      evenRenderer = Skin.renderer(rowLineage, Widget.ALTERNATE, attribs);
      selectRenderer = Skin.renderer(rowLineage, Widget.CURRENT, attribs);

      mStretchCol = null;
      onSelect = inOnSelect;

      mListContents = new Sprite();
      addChild(mListContents);
      scrollTarget = mListContents;
      scrollWheelStep = mOrigItemHeight;
      mControlHeight = 0.0;


      mRows = [];
      mColWidths = [];
      mMinColWidths = [];
      mColPos = [0.0];
      mRowPos = [0.0];
      mChildrenClean = 0;
      mSelected = -1;
      mTextSelectable = false;
      wantFocus = false;
      mColAlign = [];
      mMultiSelect = null;
      var internalLayout = new Layout().setMinSize(mMinWidth,mOrigItemHeight).stretch();
      internalLayout.onLayout = layoutList;
      setItemLayout(internalLayout);
      setScrollRange(mWidth,mWidth,mOrigItemHeight,mOrigItemHeight);
      applyStyles();
   }


   public function clear()
   {
      mRows = [];
      mColWidths = mMinColWidths.copy();
      mColPos = [0.0];
      mRowPos = [0.0];
      mChildrenClean = 0;
      mSelected = -1;
      mItemHeight = mOrigItemHeight;
      mWidth = mMinWidth;
      scrollWheelStep = mOrigItemHeight;
      graphics.clear();
      while(mListContents.numChildren>0)
         mListContents.removeChildAt(0);
      recalcPos();
   }

   public function setColAlign(inIdx:Int, inAlign:Int)
   {
      for (i in 0...inIdx)
         if (mColAlign.length==i)
            mColAlign.push(Layout.AlignCenterY | Layout.AlignLeft);
      mColAlign[inIdx] = inAlign;
   }

   public function setStretchCol(inCol:Null<Int>)
   {
      mStretchCol = inCol;
      recalcPos();
   }

   public function getRowCount() return mRows.length;

   public function deselect()
   {
      if (mSelected>=0 || mMultiSelect!=null)
      {
         mMultiSelect = null;
         mSelected = -1;
         if (mHoldUpdates==0)
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
      return mRows[inIdx].height;
   }



   public function getColPos(inIdx:Int) : Float
   {
      if (mColPos.length==0)
         return 0.0;
      if (inIdx>=mColPos.length)
         return mColPos[ mColPos.length-1 ];

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
         redraw();
      }
   }

   public function recalcPos()
   {
      mChildrenClean = 0;
      var pos = 0.0;
      mColPos=[];
      mMinControlWidth = 0.0;
      for(i in 0...mColWidths.length)
      {
         mColPos[i] = pos;
         #if neko if (mColWidths[i]==null) mColWidths[i] = 0; #end
         #if neko if (mMinColWidths[i]==null) mMinColWidths[i] = 0; #end
         pos += mColWidths[i];
         mMinControlWidth += mMinColWidths[i];
         if (i!=mColWidths.length-1)
         {
            mMinControlWidth += mXGap;
            pos+=mXGap;
         }
      }

      if (mMinControlWidth<mMinWidth)
         mMinControlWidth = mMinWidth;
      var w = Math.max(mMinControlWidth,mWidth);
      var col = mStretchCol!=null ? mStretchCol : mColWidths.length-1;

      if (col!=null && col<mColWidths.length && col>=0 && pos!=w)
      {
         var bump = w-pos;
         pos += bump;
         mColWidths[col] += bump;
         for(i in col+1...mColWidths.length)
            mColPos[i] += bump;
      }
      mColPos.push(pos);

      var pos = 0.0;
      for(i in 0...mRows.length)
      {
         mRowPos[i] = pos;
         pos += mRows[i].height;
      }
      mRowPos[mRows.length]=pos;
      updateHeight();
   }

   function updateHeight()
   {
      mControlHeight = mRowPos[mRows.length];
      getItemLayout().setMinSize( mMinControlWidth, mControlHeight );
      setScrollRange(mWidth,mWidth,mControlHeight,mHeight);
   }

   public function stringToItem(inString:String) : DisplayObject
   {
      var t = new TextField();
      mRenderer.renderLabel(t);
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

   public function addRow(inRow:Array<Dynamic>,?inHeight:Null<Float>,
                          ?inUserData:Dynamic,inIndent:Float=0.0)
   {
      var row = new Array<DisplayObject>();
      var rowHeight = 0.0;
      var needRecalcPos = false;
      for(i in 0...inRow.length)
      {
         if (i==mColAlign.length)
            mColAlign.push(Layout.AlignCenterY | Layout.AlignLeft);
         if (mColWidths.length<=i)
         {
            if (mMinColWidths.length<=i)
               mMinColWidths[i] = 0;
            mColWidths.push(mMinColWidths[i]);
         }
         var item:Dynamic = inRow[i];
         if (item!=null)
         {
            var obj:DisplayObject = null;
            var layout:Layout = null;
            if (Std.is(item,DisplayObject))
               obj = item;
            else if (Std.is(item,String))
               obj = stringToItem(item);
            else if (Std.is(item,BitmapData))
               obj = bitmapDataToItem(item);

            var h = obj.height;
            var w = obj.width;
            if (Std.is(obj,TextField))
            {
               var tf:TextField = cast obj;
               w = tf.textWidth;
               h = tf.textHeight;
            }
            else if (Std.is(obj,Widget))
            {
               var widget:Widget = cast obj;
               var size = widget.getLayout().getBestSize();
               w = size.x;
               h = size.y;
            }
            if (i==0)
               w += inIndent;

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
            mListContents.addChild(obj);
         }
         else
            row.push(null);
      }

      if (inHeight==null)
      {
         if (variableHeightRows)
         {
            if (rowHeight<mItemHeight)
               rowHeight = mItemHeight;
            if ( (rowHeight<scrollWheelStep||scrollWheelStep==0) && rowHeight>0)
                scrollWheelStep = rowHeight;
         }
         else if (rowHeight>mItemHeight)
         {
            mItemHeight = rowHeight;
            for(i in 0...mRows.length)
               mRows[i].height = mItemHeight;
            scrollWheelStep = rowHeight;
            needRecalcPos = true;
            mChildrenClean = 0;
         }
         else
           rowHeight = mItemHeight;
      }

      mRows.push( new ListControlRow(row,rowHeight,inUserData,inIndent) );
      if (mHoldUpdates==0)
      {
         if (needRecalcPos)
         {
            recalcPos();
         }
         else
         {
            var pos = mRowPos[mRowPos.length-1];
            mRowPos.push(pos+rowHeight);
            updateHeight();
         }
         redraw();
      }
      else
         needRecalcPos = true;
   }

   public function holdUpdates(inHold:Bool)
   {
      if (inHold)
         mHoldUpdates++;
      else
         mHoldUpdates--;
      if (mHoldUpdates==0)
      {
         recalcPos();
         redraw();
      }
   }

   public function addItem(inItem:Dynamic)
   {
      addRow([inItem]);
   }

   public function addItems(inItems:Array<Dynamic>)
   {
      holdUpdates(true);
      for(item in inItems)
      {
         if (Std.is(item,Array))
            addRow(item);
         else
            addRow([item]);
      }
      holdUpdates(false);
   }


   public function showItem(idx:Int)
   {
      if (idx>=0 && idx<mRows.length)
      {
         recalcPos();
         var top = mRowPos[idx];
         //trace("Show item " + idx + ":" + top + " / " + mScrollY + "/" + mHeight);
         // If above, put on top row ...
         if (top<=mScrollY)
            set_scrollY(top);

         // if below, raise to bottom line
         else if (mHeight>0 && top-mScrollY > mHeight-mRows[idx].height)
            set_scrollY(mRowPos[idx+1]-mHeight);
      }
      else
         set_scrollY(0);
   }

   public function showSelection()
   {
      showItem(mSelected);
   }


   public static inline var SELECT_RANGE       = 0x01;
   public static inline var SELECT_TOGGLE      = 0x02;
   public static inline var SELECT_NO_CALLBACK = 0x04;
   public static inline var SELECT_SHOW_ITEM   = 0x08;
   public static inline var SELECT_FROM_CLICK  = 0x10;

   public function select(inIndex:Int,inFlags:Int=0)
   {
      var i = inIndex < 0 ? 0 : inIndex>=mRows.length ? mRows.length-1 : inIndex;
      if (i>=0)
      {
         if (mSelected!=i || mMultiSelect!=null || ((inFlags & ~SELECT_NO_CALLBACK)!=0))
         {
            var toggle = (inFlags&SELECT_TOGGLE)!=0;
            var range = (inFlags&SELECT_RANGE)!=0;
            if (range)
            {
               if (mMultiSelect==null || !toggle)
                  mMultiSelect = new Array<Bool>();

               var s0 = mSelected<i ? mSelected : i;
               var s1 = mSelected<i ? i+1 : mSelected+1;
               for(s in s0...s1)
                  mMultiSelect[s] = toggle ? !mMultiSelect[s] : true;
               onMultiSelect(mMultiSelect);
            }
            else if (toggle)
            {
               if (mMultiSelect==null)
                  mMultiSelect = new Array<Bool>();
               mMultiSelect[i] = !mMultiSelect[i];
               mSelected = i;
               onMultiSelect(mMultiSelect);
            }
            else
            {
               mSelected = i;
               mMultiSelect = null;
               if (onSelect!=null && (inFlags&SELECT_NO_CALLBACK)==0)
                  onSelect(i);
            }

            if (mHoldUpdates==0)
            {
               drawBG();
            }
            if (mSelected>=0 && (inFlags&SELECT_SHOW_ITEM)!=0 )
               showItem(mSelected);
         }
      }
   }

   public function getLength() { return mRows.length; }

   public function getRow(inIdx:Int) : Array<DisplayObject>
   {
      return mRows[inIdx].objs;
   }

   public function getRowData(inIdx:Int) : Dynamic
   {
      return mRows[inIdx].userData;
   }

   public function getItem(inRow:Int,inCol:Int) : DisplayObject
   {
      if (inRow<0) return null;
      var row = mRows[inRow].objs;
      if (row==null)
         return null;
      return row[inCol];
   }


   public function findRow( inFunc: Array<DisplayObject> -> Bool ) : Int
   {
      for(idx in 0...mRows.length)
         if (inFunc(mRows[idx].objs))
            return idx;
      return -1;
   }

   public function indexFromMouse(ev:MouseEvent):Int
   {
      var local =  globalToLocal( new Point(ev.stageX,ev.stageY) );
      if (local.y<=0)
         return -1;

      for(idx in 0...mRows.length)
         if (mRowPos[idx+1]>=local.y)
             return idx;

      return -1;
   }

   public function rowFromMouse(ev:MouseEvent):Array<DisplayObject>
   {
      var idx = indexFromMouse(ev);
      if (idx<0)
         return null;
      return mRows[idx].objs;
   }


   public function itemFromY(inY:Float):Float
   {
      if (inY<=0)
         return 0.0;
      if (inY<mRowPos[mRowPos.length-1])
      {
         for(idx in 0...mRows.length)
            if (mRowPos[idx+1]>inY)
               return idx + (inY-mRowPos[idx])/mRows[idx].height;
      }
      return mRows.length;
   }

   public function selectByY(inY:Float,inFlags:Int=0):Int
   {
      var idx = Std.int(itemFromY(inY));
      if (idx<mRowPos.length)
         select(idx,inFlags);
      return -1;
   }

   override function doClick(inX:Float, inY:Float,ev:MouseEvent)
   {
      var flags = SELECT_FROM_CLICK;
      if (onMultiSelect!=null)
      {
         if (ev.ctrlKey)
           flags |= SELECT_TOGGLE;
         if (ev.shiftKey)
           flags |= SELECT_RANGE;
      }
      selectByY(inY,flags);
      super.doClick(inX,inY,ev);
   }

   public function getSelected() return mSelected;


   public function drawBG()
   {
      var gfx = mListContents.graphics;
      gfx.clear();

      for(i in 0...mRows.length)
      {
         var selected = mMultiSelect==null ?  i==mSelected : mMultiSelect[i];
         var renderer = selected ? selectRenderer : (i & 1) > 0 ? oddRenderer: evenRenderer;
         renderer.renderRect(null, gfx, new Rectangle(0,mRowPos[i],mWidth,mRows[i].height) );
      }

      if (mControlHeight<mHeight)
      {
         evenRenderer.renderRect(null, gfx, new Rectangle(0,mControlHeight,mWidth,mHeight-mControlHeight));
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

   public function layoutList(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      mListContents.x = inX;
      mListContents.y = inY;
      mWidth = inW;
      mHeight = inH;
      recalcPos();
      redraw();
   }

/*
   override public function onLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      recalcPos();
      super.onLayout(inX,inY,inW,inH);
   }
*/

   override public function redraw()
   {
      super.redraw();
      for(row_idx in mChildrenClean...mRows.length)
      {
         var row = mRows[row_idx];
         var indent = row.indent;
         for(i in 0...row.objs.length)
         {
            var item = row.objs[i];
            if (item!=null)
            {
               var w = item.width;
               var h = item.height;
               var x = mColPos[i] + indent;

               if (Std.is(item,Widget))
               {
                  var widget:Widget = cast item;
                  widget.align(x, mRowPos[row_idx],
                               mColWidths[i]-indent, mRows[row_idx].height );
               }
               else
               {
                  switch(mColAlign[i] & Layout.AlignMaskX)
                  {
                     case Layout.AlignRight:
                         item.x = mColPos[i] + (mColWidths[i]-w-indent) + indent;

                     case Layout.AlignCenterX:
                         item.x = mColPos[i] + (mColWidths[i]-w-indent)*0.5 + indent;

                     default:
                         item.x = x;
                  }
    

                  switch(mColAlign[i] & Layout.AlignMaskY)
                  {
                     case Layout.AlignTop:
                         item.y = mRowPos[row_idx];

                     case Layout.AlignBottom:
                         item.y = mRowPos[row_idx+1] - h;

                     default:
                         item.y = mRowPos[row_idx] + (mRows[row_idx].height-h)*0.5;
                  }
               }
            }
            indent = 0;
         }
      }
      mChildrenClean = mRows.length;

      drawBG();
   }

   public function getControlHeight()
   {
      return getLayout().getBestSize().y;
   }
   public function getControlWidth()
   {
      return getLayout().getBestSize().x;
   }
}



