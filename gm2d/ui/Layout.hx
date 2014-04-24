package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.Graphics;
import nme.display.Shape;
import nme.text.TextField;
import nme.geom.Point;

// --- Layout -------------------------------------------

class Layout
{
   public static inline var AlignStretch  = 0x0000;
   public static inline var AlignLeft     = 0x0001;
   public static inline var AlignRight    = 0x0002;
   public static inline var AlignCenterX  = 0x0004;
   public static inline var AlignTop      = 0x0008;
   public static inline var AlignBottom   = 0x0010;
   public static inline var AlignCenterY  = 0x0020;
   public static var AlignMaskX    = AlignLeft | AlignRight | AlignCenterX;
   public static var AlignMaskY    = AlignTop | AlignBottom | AlignCenterY;
   public static var AlignCenter   = AlignCenterX | AlignCenterY;
   public static inline var AlignPixel    = 0x0100;
   public static inline var AlignHalfPixel= 0x0200;
   public static inline var AlignKeepAspect= 0x0400;

   public var mBLeft:Float;
   public var mBTop:Float;
   public var mBRight:Float;
   public var mBBottom:Float;

   public var minWidth:Float;
   public var minHeight:Float;
   public var width:Float;
   public var height:Float;

   public var name:String;

   public var mDebugCol:Int;

   public var mAlign:Int;

   public var onLayout:Float->Float->Float->Float->Void;

   static var mDebug:nme.display.Graphics;
   static var mDebugObject:Shape;


   public function new()
   {
      width = height = 0.0;
      minWidth = minHeight = 0.0;
      mDebugCol = 0xff0000;
      mBLeft = mBRight = mBTop = mBBottom = 0;
      mAlign = AlignCenterX|AlignCenterY;
   }

   public static function setDebugObject(inShape:Shape)
   {
     mDebugObject = inShape;
     mDebug = inShape.graphics;
   }

   public function setAlignment(inAlign:Int)
   {
      mAlign = inAlign;
      return this;
   }
   public function stretch()
   {
      mAlign = Layout.AlignStretch;
      return this;
   }

   public function pixelAlign()
   {
      mAlign |= Layout.AlignPixel;
      return this;
   }

   public function setMinSize(inWidth:Float,inHeight:Float) : Layout
   {
      minWidth = inWidth;
      minHeight = inHeight;
      return this;
   }

   public function setMinWidth(inWidth:Float) : Layout
   {
      minWidth = inWidth;
      return this;
   }

   public function setMinHeight(inHeight:Float) : Layout
   {
      minHeight = inHeight;
      return this;
   }


   public function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void { }
   public function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      fireLayout(inX, inY, inW, inH);
   }
   public function setSpacing(inX:Float,inY:Float) : Layout { return this; }

   static public function setDebug(inObj:Shape)
   {
      mDebugObject = inObj;
      mDebug = mDebugObject==null ? null : mDebugObject.graphics;
   }

   public function setPadding(inX:Float, inY:Float) : Layout
   {
      mBLeft = inX;
      mBTop = inY;
      mBRight = inX;
      mBBottom = inY;
      return this;
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

   public function clear()
   {
      throw "Can't clear this layout";
      return null;
   }

   public function insert(inPos:Int, inLayout:Layout) : Layout
   {
      throw "Can't insert in this layout";
      return null;
   }

   public function setOffset(inDX:Float, inDY:Float)
   {
      mBLeft = inDX;
      mBRight = -inDX;
      mBTop = inDY;
      mBBottom = -inDY;
   }

   public function setBestWidth(inW:Float) : Layout { return this; }
   public function setBestHeight(inH:Float) : Layout { return this; }
   public function setBestSize(inW:Float, inH:Float) : Layout
   {
      setBestWidth(inW);
      setBestHeight(inH);
      return this; 
   }
   public function getColWidths() : Array<Float> { return [ getBestWidth() ]; }

   public function getBestWidth(?inHeight:Null<Float>) : Float { return minWidth; }
   public function getBestHeight(?inWidth:Null<Float>) : Float { return minHeight; }

   public function getBestSize() : Size
   {
      var w = getBestWidth();
      var h = getBestHeight(w);
      return new Size(w,h);
   }

   public function align(x:Float, y:Float, w:Float, h:Float)
   {
      alignChild(this, x,y,w,h);
   }

   public function alignChild(child:Layout, x:Float, y:Float, w:Float, h:Float)
   {
      if ( (child.mAlign & Layout.AlignKeepAspect) > 0 )
      {
         if (w*child.minHeight > h*child.minWidth)
         {
             var nw = h*child.minWidth/child.minHeight;
             x+=(w-nw)*0.5;
             w = nw;
         }
         else
         {
             var nh = w*child.minHeight/child.minWidth;
             y+=(h-nh)*0.5;
             h = nh;
         }
      }

      switch(child.mAlign & Layout.AlignMaskX)
      {
         case Layout.AlignRight:
            var bw = child.getBestWidth(h);
            if (bw>w) bw = w;
            x += w-bw;
            w = bw;
         case Layout.AlignCenterX:
            var bw = child.getBestWidth(h);
            if (bw>w) bw = w;
            x += (w-bw)/2;
            w = bw;
         case Layout.AlignLeft:
            var bw = child.getBestWidth(h);
            if (bw>w) bw = w;
            w = bw;
         default:
      }

      switch(child.mAlign & Layout.AlignMaskY)
      {
         case Layout.AlignBottom:
            var bh = child.getBestHeight(w);
            if (bh>h) bh = h;
            y += h - bh;
            h = bh;
         case Layout.AlignCenterY:
            var bh = child.getBestHeight(w);
            if (bh>h) bh = h;
            y += (h - bh)/2;
            h = bh;
         case Layout.AlignTop:
            var bh = child.getBestHeight(w);
            if (bh>h) bh = h;
            h = bh;
      }
      child.setRect(x,y,w,h);

      /*
      if (Std.is(child,Widget))
      {
         var widget:Widget = cast child;
         widget.layout(w,h);
      }
      */
   }

   function fireLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      if (onLayout!=null)
         onLayout(inX+mBLeft,inY+mBTop,inW-mBLeft-mBRight,inH-mBTop-mBBottom);
   }
}

typedef LayoutList = Array<Layout>;

// --- BorderLayout ---------------------------------------------------

class BorderLayout extends Layout
{
   var mBase:Layout;
   var positionMask:Float;

   public function new(inBase:Layout, inParentHasOffset:Bool)
   {
      mBase = inBase;
      positionMask = inParentHasOffset? 0 : 1;
      super();
   }

   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
      return mBase.calcSize( inWidth==null  ? null : inWidth-mBLeft-mBRight,
                             inHeight==null ? null : inHeight-mBTop-mBBottom );
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      // trace('BorderLayout setRect $inX,$inY $inW,$inH $mBLeft $mBTop / $positionMask');
      alignChild(mBase, (inX+mBLeft)*positionMask, (inY+mBTop)*positionMask,
                         inW-mBLeft-mBRight, inH-mBTop-mBBottom );
      fireLayout(inX,inY,inW,inH);
   }

   public override function getBestWidth(?inHeight:Null<Float>) : Float
   {
      var w = mBase.getBestWidth(inHeight==null ? null : inHeight-mBTop-mBBottom) + mBLeft + mBRight;
      if (minWidth>w) return minWidth;
      return w;
   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var h = mBase.getBestHeight(inWidth==null ? null : inWidth-mBLeft-mBRight) + mBTop + mBBottom;
      if (minHeight>h) return minHeight;
      return h;
   }

   public override function setBestWidth(inW:Float) : Layout
   {
      mBase.setBestWidth(inW-mBLeft-mBRight);
      return this;
   }
   public override function setBestHeight(inH:Float) : Layout
   {
      mBase.setBestHeight(inH-mBTop-mBBottom);
      return this;
   }
}

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

      mDebugCol = 0xff00ff;
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
     return this;
   }

   public override function setBestWidth(inW:Float)
   {
     mOWidth = inW;
     return this;
   }
   public override function setBestHeight(inH:Float)
   {
     mOHeight = inH;
     return this;
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

      /*
      if (Std.is(mObj,Widget))
      {
         var widget:Widget = cast mObj;
         widget.layout(w,h);
      }
      else
      */
      
      if (mObj.scale9Grid != null)
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

       
      // trace(mObj.name + ' setRect $name: $inX, $inY, $inW, $inH -> $x,$y,$w,$y');
      setObjRect(x,y,w,h);

      if (Layout.mDebug!=null && mObj!=null && mObj.parent!=null)
      {
         var pos = Layout.mDebugObject.globalToLocal( mObj.parent.localToGlobal( new Point(x,y) ) );
         renderDebug(pos,w,h);
      }

      fireLayout(inX,inY,inW,inH);
   }

   public function renderDebug(pos:Point, w:Float, h:Float)
   {
     Layout.mDebug.lineStyle(1,mDebugCol);
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

      mOWidth = inPrefWidth==null ? inObj.width : inPrefWidth;
      if (inPrefHeight==null)
      {
         var fmt = inObj.defaultTextFormat;
         if (fmt!=null && fmt.size!=null)
            mOHeight = fmt.size * 1.5;
         else
            mOHeight = inObj.textHeight;
      }
      else
         mOHeight = inObj.textHeight;
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
      //trace('TextLayout setObjRect $x,$y, $w,$h  ' + text.text);

      text.x = x;// - 2;
      text.y = y;// - 2;
      text.width = w;
      text.height = h;
   }
}

// --- StackLayout ---------------------------------------------------------------------

class StackLayout extends Layout
{
   var offsetLeft:Float;
   var offsetRight:Float;
   var offsetTop:Float;
   var offsetBottom:Float;

   var mChildren:LayoutList;

   public function new()
   {
      mChildren = [];
      offsetLeft = offsetRight = offsetTop = offsetBottom = 0;
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
         alignChild(child,inX+mBLeft, inY+mBTop, inW-mBLeft-mBRight, inH-mBTop-mBBottom );

      fireLayout(inX,inY,inW,inH);
   }

   public override function add(inLayout:Layout) : Layout
   {
      mChildren.push(inLayout);
      return this;
   }

   override public function clear()
   {
      mChildren = [];
   }



   public override function getBestWidth(?inHeight:Null<Float>) : Float
   {
      var h:Null<Float> = inHeight==null ? null  : inHeight - mBTop - mBBottom;
      width = 0;
      var idx = 0;
      for(child in mChildren)
      {
         var w = child.getBestWidth(h);
         if (idx>0)
            w+=offsetLeft+offsetRight;
         if (w>width)
            width=w;
         idx++;
      }
      width += mBLeft + mBRight;
      if (minWidth>width) width = minWidth;
      return width;

   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var w:Null<Float> = inWidth==null ? null  : inWidth - mBLeft - mBRight;
      height = 0;
      var idx = 0;
      for(child in mChildren)
      {
         var h = child.getBestHeight(w);
         if (idx>0)
            h+=offsetTop+offsetBottom;
         if (h>height)
            height=h;
         idx++;
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
      if (Layout.mDebug!=null)
      {
         Layout.mDebug.lineStyle(1,0xffff00);
         Layout.mDebug.drawRect(inX,inY,inW,inH);
      }


      var new_w = inW-mBLeft-mBRight;
      var new_h = inH-mBTop-mBBottom;
      for(i in 0...mChildren.length)
      {
         var child = mChildren[i];
         if (i==0)
         {
            //trace("Set stack parent " +   (inX+mBLeft) + "," + (inY+mBTop) + ' $new_w x $new_h' );
            alignChild(child, inX+mBLeft, inY+mBTop, new_w, new_h );
            new_w -= offsetLeft + offsetRight;
            new_h -= offsetTop + offsetBottom;
         }
         else
         {
            //trace('Set stack child $offsetLeft,$offsetRight,$new_w,$new_h');
            alignChild(child,offsetLeft,offsetRight,new_w,new_h);
         }

     }

      fireLayout(inX,inY,inW,inH);
   }

   public function setChildPadding(left:Float, top:Float, right:Float, bottom:Float)
   {
      offsetLeft = left;
      offsetRight = right;
      offsetTop = top;
      offsetBottom = bottom;
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
   public var mDbgObj:DisplayObject;
   static var mID = 0;

   public function new(?inCols:Null<Int>,?inName:String,inDefaultStretch:Float=1.0)
   {
      super();
      mSpaceX = 10;
      mSpaceY = 10;
      mCols = inCols;
      mDefaultStretch = inDefaultStretch;
      if (mDefaultStretch>0)
         mAlign = Layout.AlignStretch;
      name =  (inName==null) ? ("Layout:" + mID++) : inName;
      clear();
   }

   override public function clear( )
   {
      mColInfo = [];
      mRowInfo = [];
      if (mCols!=null)
      {
         for(i in 0...mCols)
            mColInfo[i] = new ColInfo(mDefaultStretch);
      }
      else
      {
         mRowInfo[0] = new RowInfo(mDefaultStretch);
      }
      mPos = 0;
   }

   public function setDebugOwner(inObj:DisplayObject) : GridLayout
   {
      mDbgObj = inObj;
      return this;
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


   public override function insert(inPos:Int, inLayout:Layout) : Layout
   {
      if (inPos>=mPos)
         return add(inLayout);

      if (mCols==1)
      {
         mRowInfo.insert(inPos,new RowInfo(mDefaultStretch));
         mRowInfo[inPos].mCols.push(inLayout);
      }
      else if (mCols==null)
      {
         mRowInfo[inPos].mCols.insert(inPos,inLayout);
      }
      else // TODO:
         throw("Can only insert in 1xN or Nx1");

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


   public static var indent = "";

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
                   h = item.getBestHeight(col_w);

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
         var p = new Point(inX,inY);
         if (mDbgObj!=null)
            p = Layout.mDebugObject.globalToLocal( mDbgObj.localToGlobal(p) );
         Layout.mDebug.lineStyle(1,0x0000ff);
         Layout.mDebug.drawRect(p.x,p.y,inW,inH);
      }

      fireLayout(inX,inY,inW,inH);
   }
}

// --- FlowLayout --------------------------------

class FlowLayout extends Layout
{
   var mChildren:LayoutList;
   public var rowAlign:Int;
   var spaceX:Float;
   var spaceY:Float;

   public function new()
   {
      super();
      rowAlign = Layout.AlignLeft;
      mChildren = [];
      spaceX = spaceY = 0.0;
      setAlignment(Layout.AlignStretch);
   }

   public function setRowAlign(inAlign:Int)
   {
      rowAlign = inAlign;
      return this;
   }

   public override function setSpacing(inX:Float, inY:Float)
   {
      spaceX = inX;
      spaceY = inY;
      return this;
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

   function layoutRow(i0:Int, i1:Int, x0:Float, y0:Float, rowW:Float, rowH:Float, maxW:Float)
   {
      switch(rowAlign & Layout.AlignMaskX)
      {
         case Layout.AlignCenterX:
            x0 += (maxW-rowW)*0.5;
         case Layout.AlignRight:
            x0 += (maxW-rowW);
      }

      for(i in i0...i1)
      {
         var child = mChildren[i];
         var w = child.getBestWidth(null);
         if (w>rowW) w = rowW;
         var h = child.getBestHeight(w);

         var y = y0;
         var setH = rowH;

         switch(rowAlign & Layout.AlignMaskY)
         {
            case Layout.AlignCenterY:
               y += (rowH-h)*0.5;
               setH = h;
            case Layout.AlignBottom:
               y += (maxW-rowW);
               setH = h;
            case Layout.AlignTop:
               setH = h;
         }

         alignChild(child, x0, y, w, setH );

         x0 += w + spaceX;
      }
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      var y = mBTop + inY;
      var rowWidth = 0.0;
      var rowHeight = 0.0;
      var c0 = 0;
      var maxW = inW - mBLeft - mBRight;

      for(i in 0...mChildren.length)
      {
         var child = mChildren[i];

         var w = child.getBestWidth(null);
         var h = child.getBestHeight(w);
         if (rowWidth>0 && rowWidth+w > maxW)
         {
            layoutRow(c0,i,inX+mBLeft, y, rowWidth - spaceX,rowHeight, maxW);
            rowWidth = 0;
            c0 = i;
            y += rowHeight + spaceY;
            rowHeight = 0;
         }

         rowWidth += w + spaceX;
         if (h>rowHeight)
            rowHeight = h;
      }
      if (c0<mChildren.length)
      {
        layoutRow(c0,mChildren.length,inX+mBLeft, y, rowWidth - spaceX,rowHeight, maxW);
      }

      fireLayout(inX,inY,inW,inH);
   }

   public override function add(inLayout:Layout) : Layout
   {
      mChildren.push(inLayout);
      return this;
   }


   override public function clear()
   {
      mChildren = [];
   }


   public override function getBestWidth(?inHeight:Null<Float>) : Float
   {
      width = 0;
      for(child in mChildren)
      {
         if (width>0)
            width += spaceX;
         var w = child.getBestWidth(inHeight);
         width += w;
      }
      width += mBLeft + mBRight;
      if (minWidth>width) width = minWidth;
      return width;

   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      height = mBTop + mBBottom;
      var rowHeight = 0.0;
      var x = 0.0;
      var maxW = inWidth==null ? 0 : inWidth-mBLeft- mBRight;
      for(child in mChildren)
      {
         var w = child.getBestWidth(null);
         var checkW = x>0 ? w+spaceX : w;
         if (inWidth!=null && w>maxW)
            w = maxW;
         var h = child.getBestHeight(w);
         if (x>0 && inWidth!=null && x+checkW > maxW)
         {
            x = 0;
            if (height>0)
               height += spaceY;
            height += rowHeight;
            rowHeight = 0;
         }
         if (x>0)
            x+=spaceX;
         x+=w;
         if (h>rowHeight)
            rowHeight = h;
      }
      if (height>0) height+=spaceY;
      height += rowHeight;
      if (minHeight>height) height = minHeight;

      return height;
   }


}


