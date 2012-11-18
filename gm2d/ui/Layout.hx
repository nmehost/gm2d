package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.geom.Point;

// --- Layout -------------------------------------------

class Layout
{
   public static var AlignStretch  = 0x0000;
   public static var AlignLeft     = 0x0001;
   public static var AlignRight    = 0x0002;
   public static var AlignCenterX  = 0x0004;
   public static var AlignTop      = 0x0008;
   public static var AlignBottom   = 0x0010;
   public static var AlignCenterY  = 0x0020;
   public static var AlignMaskX    = AlignLeft | AlignRight | AlignCenterX;
   public static var AlignMaskY    = AlignTop | AlignBottom | AlignCenterY;
   public static var AlignCenter   = AlignCenterX | AlignCenterY;
   public static var AlignPixel    = 0x0100;
   public static var AlignHalfPixel= 0x0200;
   public static var AlignKeepAspect= 0x0400;

   public var mBLeft:Float;
   public var mBTop:Float;
   public var mBRight:Float;
   public var mBBottom:Float;

   public var minWidth:Float;
   public var minHeight:Float;
   public var width:Float;
   public var height:Float;

   public var mDebugCol:Int;

   public var mAlign:Int;

   public var onLayout:Float->Float->Float->Float->Void;

   static var mDebug:gm2d.display.Graphics;
   static var mDebugObject:gm2d.display.Shape;


   public function new()
   {
      width = height = 0.0;
      minWidth = minHeight = 0.0;
      mDebugCol = 0xff0000;
      mBLeft = mBRight = mBTop = mBBottom = 0;
      mAlign = AlignCenterX|AlignCenterY;
   }

   public function setAlignment(inAlign:Int)
   {
      mAlign = inAlign;
      return this;
   }

   public function pixelAlign()
   {
      mAlign |= Layout.AlignPixel;
      return this;
   }

   public function setMinSize(inWidth:Float,inHeight:Float) : Void
   {
      minWidth = inWidth;
      minHeight = inHeight;
   }

   public function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
      { throw "calcSize - not implemented"; }
   public function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
      { throw "setRect - not implemented"; }
   public function setSpacing(inX:Float,inY:Float) : Layout { return this; }

   static public function setDebug(inObj:gm2d.display.Shape)
   {
      mDebugObject = inObj;
      mDebug = mDebugObject==null ? null : mDebugObject.graphics;
   }

   public function setBorders(inL:Float,inT:Float,inR:Float,inB:Float) : Layout
   {
      mBLeft = inL;
      mBTop = inT;
      mBRight = inR;
      mBBottom = inB;
      return this;
   }
   public function add(inLayout:Layout) : Layout
   {
      throw "Can't add to this layout";
      return null;
   }
   public function setOffset(inDX:Float, inDY:Float)
   {
      mBLeft = inDX;
      mBRight = -inDX;
      mBTop = inDY;
      mBBottom = -inDY;
   }

   public function setBestSize(inW:Float, inH:Float) { }
   public function getColWidths() : Array<Float> { return [ getBestWidth() ]; }

   public function getBestWidth(?inHeight:Null<Float>) : Float { return 0.0; }
   public function getBestHeight(?inWidth:Null<Float>) : Float { return 0.0; }

   public function getBestSize() : Size
   {
      var w = getBestWidth();
      var h = getBestHeight(w);
      return new Size(w,h);
   }
}

typedef LayoutList = Array<Layout>;

// --- DisplayLayout ---------------------------------------------------

class DisplayLayout extends Layout
{
   var mObj:DisplayObject;
   var mOX:Float;
   var mOY:Float;
   var mOWidth:Float;
   var mOHeight:Float;

   public function new(inObj:DisplayObject,inAlign:Int = 0x24, // AlignCenterX|AlignCenterY
           ?inPrefWidth:Null<Float>,?inPrefHeight:Null<Float>)
   {
      super();
      mAlign = inAlign;
      mObj = inObj;
      mOWidth = inPrefWidth==null ? inObj.width : inPrefWidth;
      mOHeight =  inPrefHeight==null ? inObj.height : inPrefHeight;
      mOX = inObj.x;
      mOY = inObj.y;
      mBLeft = mBRight = mBTop = mBBottom = 0;
   }
   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
   }

   public function setOrigin(inX:Float,inY:Float) : DisplayLayout
   {
      mOX = inX;
      mOY = inY;
      return this;
   }
 
   public override function setBestSize(inW:Float,inH:Float)
   {
     mOWidth = inW;
     mOHeight = inH;
   }

   function setObjRect(x:Float,y:Float,w:Float,h:Float)
   {
      if (mAlign & Layout.AlignPixel > 0)
      {
         mObj.x = Std.int(x);
         mObj.y = Std.int(y);
      }
      else if (mAlign & Layout.AlignHalfPixel > 0)
      {
         mObj.x = Std.int(x) + 0.5;
         mObj.y = Std.int(y) + 0.5;
      }
      else
      {
         mObj.x = x;
         mObj.y = y;
      }
      if (Std.is(mObj,Widget))
      {
         var widget:Widget = cast mObj;
         widget.layout(w,h);
      }
      else if (mObj.scale9Grid != null)
      {
         mObj.width = w;
         mObj.height = h;
      }
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      var w = inW - mBLeft - mBRight;
      var x = mOX + inX + mBLeft;
      var ow = minWidth<mOWidth ? mOWidth : minWidth;
      var oh = minHeight<mOHeight ? mOHeight : minHeight;
      switch(mAlign & Layout.AlignMaskX)
      {
         case Layout.AlignLeft:
            w = ow;
         case Layout.AlignRight:
            x = x + w-ow;
            w = ow;
         case Layout.AlignCenterX:
            x = x + (w-ow)/2;
            w = ow;
      }

      var h = inH - mBTop - mBBottom;
      var y = mOY + inY + mBTop;
      switch(mAlign & Layout.AlignMaskY)
      {
         case Layout.AlignTop:
            h = oh;
         case Layout.AlignBottom:
            y = y + h - oh;
            h = oh;
         case Layout.AlignCenterY:
            y = y + (h - oh)/2;
            h = oh;
      }

       
      setObjRect(x,y,w,h);

      if (Layout.mDebug!=null && mObj!=null && mObj.parent!=null)
      {
         var pos = Layout.mDebugObject.globalToLocal( mObj.parent.localToGlobal( new Point(x,y) ) );
         renderDebug(pos,w,h);
      }

      if (onLayout!=null)
         onLayout(inX,inY,inW,inH);
   }

   public function renderDebug(pos:Point, w:Float, h:Float)
   {
     Layout.mDebug.lineStyle(2,mDebugCol);
     Layout.mDebug.drawRect(pos.x,pos.y,w,h);
   }

   public override function getBestWidth(?inHeight:Null<Float>) : Float
   {
      var w = mOWidth + mBLeft + mBRight;
      if (minWidth>w) return minWidth;
      return w;
   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var h = mOHeight + mBTop + mBBottom;
      if (minHeight>h) return minHeight;
      return h;
   }
}

class TextLayout extends DisplayLayout
{
   public function new(inObj:TextField,inAlign:Int = 0x24, // AlignCenterX|AlignCenterY
           ?inPrefWidth:Null<Float>,?inPrefHeight:Null<Float>)
   {
      super(inObj,inAlign);
      mOWidth = inPrefWidth==null ? inObj.textWidth : inPrefWidth;
      mOHeight =  inPrefHeight==null ? inObj.textHeight : inPrefHeight;
      mDebugCol = 0x00ff00;
   }

   override public function renderDebug(pos:Point, w:Float, h:Float)
   {
     var text:TextField = cast mObj;
     Layout.mDebug.lineStyle(2,mDebugCol);
     Layout.mDebug.drawRect(pos.x,pos.y,text.textWidth,text.textHeight);
   }


   override function setObjRect(x:Float,y:Float,w:Float,h:Float)
   {
      var text:TextField = cast mObj;
      text.x = x - 2;
      text.y = y - 2;
   }
}

// --- StackLayout ---------------------------------------------------------------------

class StackLayout extends Layout
{
   var mChildren:LayoutList;

   public function new()
   {
      mChildren = [];
      super();
   }

   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
      if (inWidth!=null)
         width = inWidth;
      else
         width = getBestWidth(inHeight);

      if (inHeight!=null)
         height = inHeight;
      else
         height = getBestHeight(width);
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      for(child in mChildren)
         child.setRect( inX+mBLeft, inY+mBTop, inW-mBLeft-mBRight, inH-mBTop-mBBottom );
      if (onLayout!=null)
         onLayout(inX,inY,inW,inH);
   }

   public override function add(inLayout:Layout) : Layout
   {
      mChildren.push(inLayout);
      return this;
   }


   public override function getBestWidth(?inHeight:Null<Float>) : Float
   {
      width = 0;
      for(child in mChildren)
      {
         var w = child.getBestWidth(inHeight);
         if (w>width) width=w;
      }
      width += mBLeft + mBRight;
      if (minWidth>width) width = minWidth;
      return width;

   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      height = 0;
      for(child in mChildren)
      {
         var h = child.getBestHeight(inWidth);
         if (h>height) height=h;
      }
      height += mBTop + mBBottom;
      if (minHeight>height) height = minHeight;
      return height;
   }



}

// In a child stack, the top item owns the others, so the offset
//  applies to this item only, and the others get it because they are
//  children
class ChildStackLayout extends StackLayout
{
   public function new()
   {
      super();
   }
   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      var new_w = inW-mBLeft-mBRight;
      var new_h = inH-mBTop-mBBottom;
      for(i in 0...mChildren.length)
      {
         var child = mChildren[i];
         if (i==0)
         {
            child.setRect( inX+mBLeft, inY+mBTop, new_w, new_h );
         }
         else
         {
            child.setRect(0,0,new_w,new_h);
         }
      }

      if (Layout.mDebug!=null)
      {
         Layout.mDebug.lineStyle(1,0xffff00);
         Layout.mDebug.drawRect(inX,inY,inW,inH);
      }

      if (onLayout!=null)
         onLayout(inX,inY,inW,inH);
   }
}

// --- GridLayout -------------------------------------------

class ColInfo
{
   public function new(inStretch:Float)
   {
      mMaxWidth = 0;
      mWidth = 0;
      mMinWidth = 0;
      mStretch = inStretch;
   }
   public var mMaxWidth:Float;
   public var mWidth:Float;
   public var mStretch:Float;
   public var mMinWidth:Float;
}

class RowInfo
{
   public function new(inStretch:Float)
   {
      mCols = [];
      mStretch = inStretch;
   }
   public var mCols:LayoutList;
   public var mStretch:Float;
   public var mHeight:Float;
}


class GridLayout extends Layout
{
   var mCols:Null<Int>;
   var mColInfo : Array<ColInfo>;
   var mRowInfo : Array<RowInfo>;
   var mSpaceX:Float;
   var mSpaceY:Float;
   var mDefaultStretch:Float;
   var mPos:Int;
   var mName:String;
   static var mID = 0;

   public function new(?inCols:Null<Int>,?inName:String,inDefaultStretch:Float=1.0)
   {
      super();
      mCols = inCols;
      mColInfo = [];
      mRowInfo = [];
      mDefaultStretch = inDefaultStretch;
      if (inCols!=null)
      {
         for(i in 0...inCols)
            mColInfo[i] = new ColInfo(mDefaultStretch);
      }
      else
      {
         mRowInfo[0] = new RowInfo(mDefaultStretch);
      }
      mName =  (inName==null) ? ("Layout:" + mID++) : inName;
      mPos = 0;
      mSpaceX = 10;
      mSpaceY = 10;
   }

   public static function createKeepAspect(inMinWidth:Float, inMinHeight:Float, inBase:Layout)
   {
      var result = new GridLayout(1,"KeepAspect");
      result.minWidth = inMinWidth;
      result.minHeight = inMinHeight;
      result.add(inBase);
      inBase.mAlign |= Layout.AlignKeepAspect;
      return result;
   }

   public override function add(inLayout:Layout) : Layout
   {
      var row = 0;
      if (mCols!=null && mCols>0)
      {
         row = Std.int(mPos / mCols);
         if (row>=mRowInfo.length)
            mRowInfo.push(new RowInfo(mDefaultStretch));
      }
      else
      {
         mColInfo.push(new ColInfo(mDefaultStretch));
      }
      if (mRowInfo[row]==null)
         mRowInfo[row]=new RowInfo(mDefaultStretch);
      mRowInfo[row].mCols.push(inLayout);
      mPos++;
      return this;
   }

   public override function setSpacing(inX:Float,inY:Float) : Layout
   {
      mSpaceX = inX; mSpaceY = inY;
      return this;
   }
   public function setRowStretch(inRow:Int,inStretch:Float)
   {
      if (mRowInfo[inRow]==null)
         mRowInfo[inRow] = new RowInfo(mDefaultStretch);
      mRowInfo[inRow].mStretch = inStretch;
      return this;
   }

   public function setColStretch(inCol:Int,inStretch:Float)
   {
      if (mColInfo[inCol]==null)
         mColInfo[inCol] = new ColInfo(mDefaultStretch);
      mColInfo[inCol].mStretch = inStretch;
      return this;
   }

   public function setMinColWidth(inCol:Int,inMin:Float)
   {
      if (mColInfo[inCol]==null)
         mColInfo[inCol] = new ColInfo(mDefaultStretch);
      mColInfo[inCol].mMinWidth = inMin;
      return this;
   }


   static var indent = "";

   function BestColWidths()
   {
      //trace(indent + "BestColWidths..." + mColInfo.length);
      //var oindent = indent;
      //indent += "  ";
      for(col in mColInfo)
         col.mWidth = col.mMinWidth;
      for(row in mRowInfo)
      {
         //trace(indent + " cols : "  + row.mCols.length);
         for(i in 0...row.mCols.length)
         {
            var col =  row.mCols[i];
            if (col!=null)
            {
               var w = col.getBestWidth();
               if (w>mColInfo[i].mWidth)
               {
                  mColInfo[i].mWidth = w;
                  //trace(indent + " -> [" + i + "] = " + w);
               }
            }
         }
      }
      //indent = oindent;
   }

   function BestRowHeights()
   {
      for(r in 0...mRowInfo.length)
      {
         var row = mRowInfo[r];
         row.mHeight = 0;
         for(i in 0...row.mCols.length)
         {
            var col =  row.mCols[i];
            if (col!=null)
            {
               var h = col.getBestHeight(mColInfo[i].mWidth);
               if (h>row.mHeight)
                  row.mHeight = h;
            }
         }
      }

   }

   override public function getColWidths() : Array<Float>
   {
      BestColWidths();
      var result = new Array<Float>();
      for(col in mColInfo)
         result.push(col.mWidth);
      return result;
   }


   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
     BestColWidths();

     width = 0;
     for(col in mColInfo)
        width+=col.mWidth;
     width += mBLeft + mBRight;
     if (mColInfo.length>0)
        width += (mColInfo.length -1)*mSpaceX;


     if (inWidth!=null)
     {
        var extra = inWidth - width;
        //trace("Extra spacing : " + inWidth + " - " + width + "(" + mBLeft + "+" + mBRight + ")");
        if (extra!=0)
        {
           var stretch = 0.0;
           for(col in mColInfo)
              stretch += col.mStretch;
           if (stretch!=0)
              for(col in mColInfo)
                 col.mWidth += col.mStretch * extra / stretch;
        }
        width = inWidth;
     }

     BestRowHeights();

     height = 0;
     for(row in mRowInfo)
        height+=row.mHeight;
     height += mBTop + mBBottom;
     if (mRowInfo.length>0)
        height += (mRowInfo.length -1)*mSpaceY;


     if (inHeight!=null)
     {
        var extra = inHeight-height;
        if (extra!=0)
        {
           var stretch = 0.0;
           for(row in mRowInfo)
              stretch += row.mStretch;
           if (stretch!=0)
                 for(row in mRowInfo)
                    row.mHeight += row.mStretch * extra / stretch;
        }

        height = inHeight;
     }
   }

   public override function getBestWidth(?inHeight:Null<Float>) : Float
   {
      BestColWidths();
      var w = mBLeft + mBRight;
      if (mColInfo.length>0)
         w+=(mColInfo.length-1)*mSpaceX;
      for(col in mColInfo)
         w+= col.mWidth;
      if (minWidth>w) return minWidth;
      return w;
   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      BestRowHeights();
      var h = mBTop + mBBottom;
      if (mRowInfo.length>0)
        h+= (mRowInfo.length-1)*mSpaceY;
      for(row in mRowInfo)
         h+= row.mHeight;
      if (minHeight>h) return minHeight;
      return h;
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      var oindent = indent;
      //trace(indent + "GridLayout::setRect " + inX + "," + inY + "   " +inW + "x"+inH);
      indent += "   ";
      calcSize(inW,inH);
      //for(col in mColInfo)
        //trace("Got col " + col.mWidth );
      indent = oindent;
      var y = inY + mBTop;
      for(row in mRowInfo)
      {
         var row_h = row.mHeight;
         var x = inX + mBLeft;
         for(c in 0...row.mCols.length)
         {
            var col_w = mColInfo[c].mWidth;
            var ox = x;
            var oy = y;
            var w = col_w;
            var h = row_h;

            var item = row.mCols[c];

            if (item!=null)
            {
               if ((item.mAlign & Layout.AlignMaskX)!=0)
                   w = item.getBestWidth();
               if ((item.mAlign & Layout.AlignMaskY)!=0)
                   h = item.getBestHeight();

               if ( (item.mAlign & Layout.AlignKeepAspect)>0 && item.minWidth>0 && item.minHeight>0 )
               {
                  var w0 = w - item.mBLeft - item.mBRight;
                  var h0 = h - item.mBTop - item.mBBottom;
                  
                  if (w0*item.minHeight > h0*item.minWidth)
                  {
                     var new_w = h0*item.minWidth/item.minHeight + item.mBLeft + item.mBRight;
                     ox += (w-new_w)*0.5;
                     w = new_w;
                  }
                  else
                  {
                     var new_h = w0*item.minHeight/item.minWidth + item.mBTop + item.mBBottom;
                     oy += (h-new_h)*0.5;
                     h = new_h;
                  }
               }

               switch(item.mAlign & Layout.AlignMaskX)
               {
                  case Layout.AlignRight:
                     ox += col_w - w;
                  case Layout.AlignCenterX:
                     ox += (col_w - w)/2;
               }
               //trace(indent + "Put " + w + " in " + col_w);


               switch(item.mAlign & Layout.AlignMaskY)
               {
                  case Layout.AlignBottom:
                     oy += row_h - h;
                  case Layout.AlignCenterY:
                     oy += (row_h - h)/2;
               }

               item.setRect(ox,oy,w,h);
            }

            x+=col_w + mSpaceX;
         }
         y+= row.mHeight + mSpaceY;
      }

      indent = oindent;

      if (Layout.mDebug!=null)
      {
         Layout.mDebug.lineStyle(1,0x0000ff);
         Layout.mDebug.drawRect(inX,inY,inW,inH);
      }

      if (onLayout!=null)
         onLayout(inX,inY,inW,inH);
   }
}
