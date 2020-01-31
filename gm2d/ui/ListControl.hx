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
import gm2d.ui.IListDrag;

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
   var mTitleRow:Array<Widget>;
   var mTitleHeight:Float;
   var mRows:Array<ListControlRow>;
   var mRowPos:Array<Float>;
   var mStretchCol:Null<Int>;
   var mOrigItemHeight:Float;
   var mItemHeight:Float;
   var mSelected :Int;
   var mWidth:Float;
   var mMinWidth:Float;
   var mMinControlWidth:Float;
   var mHeight:Float;
   var mListHeight:Float;
   var mChildrenClean :Int;
   var mColWidths:Array<Float>;
   var mBestColWidths:Array<Float>;
   var mMinColWidths:Array<Float>;
   var mColPos:Array<Float>;
   var mColAlign:Array<Int>;
   var mMultiSelect:Array<Bool>;
   var mControlHeight:Float;
   var mHoldUpdates = 0;
   var dragHandler:IListDrag;
   var overlay:nme.display.Shape;
   var draggingIndex:Int;

   public var onSelect:Int->Void;
   public var onSelectPhase:Int->Int->Void;
   public var onMultiSelect:Array<Bool>->Void;
   public var mXGap:Float;
   public var mTextSelectable:Bool;
   public var firstSelect = true;
  
   var    evenRenderer:Renderer;
   var    oddRenderer:Renderer;
   var    selectRenderer:Renderer;

   public var variableHeightRows = false;


   public function new(?inOnSelect:Int->Void, ?inLineage:Array<String>,?inAttribs:{})
   {
      super(Widget.addLine(inLineage,"List"), inAttribs);

      mMinControlWidth = mMinWidth = attribFloat("width",0);
      mWidth = mMinWidth;
      mOrigItemHeight = mHeight = mListHeight = attribFloat("itemHeight",0);
      mItemHeight = mOrigItemHeight;
      draggingIndex = -1;

      var rowLineage = hasAttrib("rowLineage") ? [Std.string(attrib("rowLineage")),"ListRow"] : ["ListRow"];
      var attribs = attrib("rowAttribs");
      if (hasAttrib("itemHeight"))
         Widget.addAttribs( attribs, {minSize: new Size(mMinWidth,mItemHeight) } );

      mXGap = attribFloat("xgap",Skin.scale(2.0));

      oddRenderer = Skin.renderer(rowLineage,   0, attribs);
      evenRenderer = Skin.renderer(rowLineage, Widget.ALTERNATE, attribs);
      selectRenderer = Skin.renderer(rowLineage, Widget.CURRENT, attribs);

      mStretchCol = null;
      onSelect = inOnSelect;

      makeContentContainer();

      scrollWheelStep = mOrigItemHeight;
      mControlHeight = 0.0;
      mTitleHeight = 0.0;


      mRows = [];
      mColWidths = [];
      mBestColWidths = [];
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
      mBestColWidths = mMinColWidths.copy();
      mColPos = [0.0];
      mRowPos = [0.0];
      mChildrenClean = 0;
      mSelected = -1;
      mItemHeight = mOrigItemHeight;
      //mWidth = mMinWidth;
      scrollWheelStep = mOrigItemHeight;
      graphics.clear();
      while(contents.numChildren>0)
         contents.removeChildAt(0);
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

   public function onListDrag(ev:MouseEvent)
   {
      var idx = indexFromMouse(ev);
      var gfx = overlay.graphics;
      gfx.clear();
      if (idx>=0 && idx!=draggingIndex)
      {
         var y0 = mRowPos[idx];
         var y1 = mRowPos[idx+1];
         var dy = y1-y0;
         var my = contents.globalToLocal( new Point(ev.stageX, ev.stageY) ).y - y0;
         var pos = PosOver;
         var by = y0-mScrollY;

         if (my<dy*0.25)
         {
            pos = PosAbove;
            dy *= 0.25;
         }
         else if (my>dy*0.75)
         {
            pos = PosBelow;
            by += dy*0.75;
            dy *= 0.25;
         }
         else
         {
            by += dy*0.2;
            dy *= 0.6;
         }

         if ( dragHandler.listCanDrop(draggingIndex, idx, pos, ev))
         {
            gfx.beginFill(0xff0000,0.3);
            gfx.lineStyle(0,0xff0000);
            gfx.drawRect(0,by,mWidth,dy);
         }
      }
      // TODO
   }
   public function onDragFinish(watch:MouseWatcher, ev:MouseEvent)
   {
      overlay.visible = false;
      overlay.graphics.clear();
      if (!watch.wasDragged)
      {
         draggingIndex = -1;
         var local = scrollTarget.globalToLocal(watch.downPos);
         doClick(local.x,local.y,ev);
      }
      else
      {
         var idx = indexFromMouse(ev);
         if (idx>=0 && idx!=draggingIndex)
         {
            var y0 = mRowPos[idx];
            var y1 = mRowPos[idx+1];
            var dy = y1-y0;
            var my = contents.globalToLocal( new Point(ev.stageX, ev.stageY) ).y - y0;
            var pos = PosOver;
            if (my<dy*0.25)
               pos = PosAbove;
            else if (my>dy*0.75)
               pos = PosBelow;

            if (dragHandler.listCanDrop(draggingIndex, idx, pos, ev))
               dragHandler.listDoDrop(draggingIndex, idx, pos, ev);
         }
         draggingIndex = -1;
      }

   }


   public function setDragHandler(handler:IListDrag)
   {
      dragHandler = handler;
      if (overlay==null)
      {
         overlay = new nme.display.Shape();
         addChild(overlay);
      }

      shouldBeginScroll = function(ev:MouseEvent) {
         var idx = indexFromMouse(ev);
         var drag = idx>=0 && dragHandler.listShouldDrag(idx,ev);
         if (!drag)
            return true;
         draggingIndex = idx;
         var mw:MouseWatcher = null;
         mw = MouseWatcher.watchDrag(this, ev.stageX,ev.stageY, onListDrag, e -> onDragFinish(mw,e) );
         mw.minDragDistance = mItemHeight*0.5;
         overlay.visible = true;
         return false;
      }
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
      if (mBestColWidths[inCol]<inWidth)
      {
         mBestColWidths[inCol] = inWidth;
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
      var bestWidth = getLayout().getBordersX();
      for(i in 0...mColWidths.length)
      {
         mColPos[i] = pos;
         #if neko if (mColWidths[i]==null) mColWidths[i] = 0; #end
         #if neko if (mBestColWidths[i]==null) mBestColWidths[i] = 0; #end
         #if neko if (mMinColWidths[i]==null) mMinColWidths[i] = 0; #end
         mColWidths[i] = mBestColWidths[i];
         pos += mColWidths[i];
         mMinControlWidth += mMinColWidths[i];
         bestWidth += mBestColWidths[i];
         if (i!=mColWidths.length-1)
         {
            mMinControlWidth += mXGap;
            pos+=mXGap;
            bestWidth+=mXGap;
         }
      }

      if (mMinControlWidth<mMinWidth)
         mMinControlWidth = mMinWidth;

      if (mMinControlWidth<bestWidth)
         mMinControlWidth = bestWidth;

      var w = Math.max(mMinControlWidth, mWidth );
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
      contents.y = mTitleHeight;
      var h = mRowPos[mRows.length];
      mControlHeight = h + mTitleHeight;
      getItemLayout().setMinSize( mMinControlWidth, mControlHeight );
      setScrollRange(mWidth,mWidth,h,mListHeight);
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

   public function setTitleRow(inTitle:Array<Widget>)
   {
      if (mTitleRow!=null)
         for(t in mTitleRow)
            if (t!=null)
               removeChild(t);
      mTitleRow = inTitle;
      mTitleHeight = 0;
      if (mTitleRow!=null)
         for(i in 0...mTitleRow.length)
         {
            var w = mTitleRow[i];
            if (w!=null)
            {
               var l = w.getLayout();
               var width = l.getBestWidth();
               if (mBestColWidths[i]<width)
                   mBestColWidths[i] = width;
               var height = l.getBestHeight( mBestColWidths[i]);
               if (height>mTitleHeight)
                  mTitleHeight = height;
               addChild(w);
            }
         }
      mListHeight = mHeight - mTitleHeight;

      if (mHoldUpdates==0)
      {
         recalcPos();
         redraw();
      }
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
         if (mBestColWidths.length<=i)
         {
            if (mMinColWidths.length<=i)
               mMinColWidths[i] = 0;
            mColWidths.push(mMinColWidths[i]);
            mBestColWidths.push(mMinColWidths[i]);
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

            if (w>mBestColWidths[i])
            {
               mBestColWidths[i] = w;
               needRecalcPos = true;
            }

            row.push(obj);
            contents.addChild(obj);
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
         //trace("Show item " + idx + ":" + top + " / " + mScrollY + "/" + mListHeight);
         // If above, put on top row ...
         if (top<=mScrollY)
            set_scrollY(top);

         // if below, raise to bottom line
         else if (mListHeight>0 && top-mScrollY > mListHeight-mRows[idx].height)
            set_scrollY(mRowPos[idx+1]-mListHeight);
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
               if (onMultiSelect!=null && (inFlags&SELECT_NO_CALLBACK)==0)
               {
                  var sel = new Array<Bool>();
                  sel[i] = true;
                  onMultiSelect(sel);
               }
               if (onSelectPhase!=null && (inFlags&SELECT_NO_CALLBACK)==0 )
               {
                  var phase = (inFlags&SELECT_FROM_CLICK)>0 ? Phase.END : firstSelect ? Phase.BEGIN : Phase.UPDATE;
                  if (firstSelect && phase==Phase.END)
                     phase = Phase.ALL;
                  firstSelect = false;
                  onSelectPhase(i,phase);
                  if ((inFlags&SELECT_FROM_CLICK)>0)
                     firstSelect = true;
               }
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
      var local =  scrollTarget.globalToLocal( new Point(ev.stageX,ev.stageY) );
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

   public function toLocal(stageX:Float, stageY:Float)
   {
      return scrollTarget.globalToLocal( new Point(stageX,stageY) );
   }

   public function selectByMousePos(inX:Float, inY:Float,ev:MouseEvent)
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
   }

   override function doClick(inX:Float, inY:Float,ev:MouseEvent)
   {
      if (onClick!=null)
         onClick(ev);
      else
         selectByMousePos(inX,inY,ev);
   }

   public function getSelected() return mSelected;


   public function drawBG()
   {
      var gfx = contents.graphics;
      gfx.clear();

      for(i in 0...mRows.length)
      {
         var selected = mMultiSelect==null ?  i==mSelected : mMultiSelect[i];
         var renderer = selected ? selectRenderer : (i & 1) > 0 ? oddRenderer: evenRenderer;
         renderer.renderRect(null, gfx, new Rectangle(0,mRowPos[i],mWidth,mRows[i].height) );
      }

      var boxHeight = mControlHeight - mTitleHeight;
      if (boxHeight<mHeight)
      {
         evenRenderer.renderRect(null, gfx, new Rectangle(0,boxHeight,mWidth,mHeight-boxHeight));
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
      contents.x = inX;
      contents.y = inY;
      mWidth = inW;
      mHeight = inH;
      mListHeight = mHeight - mTitleHeight;
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
      if (mTitleRow!=null)
      {
         for(row_idx in 0...mTitleRow.length)
         {
            var widget = mTitleRow[row_idx];
            if (widget!=null)
               widget.align(mColPos[row_idx], 0, mColWidths[row_idx], mTitleHeight );
         }
      }

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


   override public function get(data:Dynamic)
   {
      var me:Array<Dynamic> = Reflect.field(data, name);
      if (!Std.is(me,Array))
         Reflect.setField(data,name,me=new Array<Dynamic>());

      for(i in 0...mRows.length)
      {
         var row = mRows[i];
         if (me[i]!=null)
            for(o in 0...row.objs.length)
            {
               var obj = row.objs[o];
               if (obj!=null && Std.is(obj,Widget))
               {
                  var widget:Widget = cast obj;
                  widget.get(data);
               }
            }
      }
      if (me.length>mRows.length)
         me.splice(mRows.length, me.length);
   }

   override public function set(data:Dynamic)
   {
      var me:Array<Dynamic> = data;
      if (me!=null)
      {
         for(i in 0...mRows.length)
         {
            var row = mRows[i];
            if (me[i]!=null)
               for(o in 0...row.objs.length)
               {
                  var obj = row.objs[o];
                  if (obj!=null && Std.is(obj,Widget))
                  {
                     var widget:Widget = cast obj;
                     if (Reflect.hasField(me[i],widget.name))
                         widget.set( Reflect.field(me[i],widget.name) );
                  }
               }
         }
      }
   }

   override public function setList(id:String, values:Array<String>, display:Array<Dynamic>)
   {
      for(row in mRows)
         for(obj in row.objs)
         {
            if (obj!=null && Std.is(obj,Widget))
            {
               var widget:Widget = cast obj;
               widget.setList(id, values, display);
            }
         }
   }


}



