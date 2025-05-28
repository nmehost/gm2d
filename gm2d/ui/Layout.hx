package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.Graphics;
import nme.display.Shape;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.geom.Rectangle;
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
   public static inline var AlignEqual    = 0x0040;
   public static inline var AlignGraphcsRect = 0x0080;
   public static var AlignMaskX    = AlignLeft | AlignRight | AlignCenterX;
   public static var AlignMaskY    = AlignTop | AlignBottom | AlignCenterY;
   public static var AlignCenter   = AlignCenterX | AlignCenterY;

   // Default to pixel alignment...
   public static inline var AlignPixel    = 0x0000;
   public static inline var AlignSubPixel = 0x0100;

   public static inline var AlignHalfPixel= 0x0200;

   public static inline var AlignKeepAspect= 0x0400;
   public static inline var AlignOverlap   = 0x0800;

   static var layoutIdAlloc = 0;

   public var bestWidth(default,null):Null<Float>;
   public var bestHeight(default,null):Null<Float>;

   public var mBLeft:Float;
   public var mBTop:Float;
   public var mBRight:Float;
   public var mBBottom:Float;

   public var minWidth:Float;
   public var minHeight:Float;
   //public var width:Float;
   //public var height:Float;

   public var name:String;

   public var mDebugCol:Int;

   public var mAlign:Int;

   public var lastRect:Rectangle;

   public var onLayout:Float->Float->Float->Float->Void;

   public var layoutId:Int;
   public var debug(default,set):Bool;
   static var cache:Map<String,Dynamic>;

   static var mDebug:nme.display.Graphics;
   static var mDebugObject:Shape;



   public function new()
   {
      layoutId = layoutIdAlloc++;
      name = "layout" + layoutId;
      //width = height = 0.0;
      minWidth = minHeight = -1;
      mDebugCol = 0xff0000;
      mBLeft = mBRight = mBTop = mBBottom = 0;
      mAlign = AlignCenterX|AlignCenterY;
   }

   public static function sBeginCache()
   {
      if (cache!=null)
         return false;
      cache = new Map();
      return true;
   }

   inline function endCache(remove:Bool) sEndCache(remove);
   public static function sEndCache(remove:Bool)
   {
      if (remove && cache!=null)
         cache = null;
   }

   static function sSetCache(key:String, value:Dynamic, remove:Bool)
   {
      cache.set(key,value);
      if (remove)
         cache = null;
   }

   inline public function isCached(key:String): Bool
       return Layout.cache!=null && Layout.cache.exists(key);
   inline public function getCached(key:String): Dynamic
       return Layout.cache.get(key);

   inline public function beginCache()
   {
      // if (Layout.cache==null) trace(" new cache:" + this);
      return sBeginCache();
   }
   inline public function setCache(key:String, value:Dynamic, remove:Bool) : Dynamic
      { sSetCache(key,value,remove); return value; }

   function set_debug(inDebug:Bool)
   {
      debug = inDebug;
      return debug;
   }
   public function getBordersX() return mBLeft + mBRight;
   public function getBordersY() return mBTop + mBBottom;

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
   public function setVerticalAlignment(inAlign:Int)
   {
      mAlign = (mAlign & ~AlignMaskY) | (inAlign & AlignMaskY);
      return this;
   }
   public function setHorizontalAlignment(inAlign:Int)
   {
      mAlign = (mAlign & ~AlignMaskX) | (inAlign & AlignMaskX);
      return this;
   }

   function bestDefault(ioSize:Size) : Size
   {
      if (ioSize.x<0)
         ioSize.x = bestWidth!=null ? bestWidth : 0;
      if (ioSize.y<0)
         ioSize.y = bestHeight!=null ? bestHeight : 0;
      return ioSize;
   }


   public function stretch()
   {
      mAlign = Layout.AlignStretch;
      return this;
   }

   public function pixelAlign()
   {
      mAlign &= ~(Layout.AlignSubPixel | Layout.AlignHalfPixel);
      return this;
   }

   public function visitChildren(onChild:Layout->Dynamic,inRecurse=true) : Dynamic
   {
      return null;
   }
   static function visitChildList(inChildren:Array<Layout>, onChild:Layout->Dynamic,inRecurse:Bool)
   {
      for(child in inChildren)
      {
         if (child!=null)
         {
            var result = onChild(child);
            if (result!=null)
               return result;
            if (inRecurse)
            {
               var result = child.visitChildren(onChild,true);
               if (result!=null)
                  return result;
            }
         }
      }
      return null;
   }



   public function subPixelAlign()
   {
      mAlign = (mAlign & ~Layout.AlignHalfPixel) | Layout.AlignSubPixel;
      return this;
   }

   public function halfPixelAlign()
   {
      mAlign = (mAlign & ~Layout.AlignSubPixel) | Layout.AlignHalfPixel;
      return this;
   }


   public function setMinItemSize(inWidth:Float,inHeight:Float) : Layout
   {
      minWidth = inWidth + mBLeft + mBRight;
      minHeight = inHeight + mBTop + mBBottom;
      return this;
   }


   // Layout
   public function setMinSize(inWidth:Float,inHeight:Float) : Layout
   {
      setMinWidth(inWidth);
      setMinHeight(inHeight);
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

   // Layout
   public function getMinSize()
   {
      return bestDefault(new Size(minWidth, minHeight) );
   }

   public function findTextLayout() : TextLayout  { return null; }
   public static function findTextLayoutInList(inLayouts:LayoutList) : TextLayout
   {
      for(layout in inLayouts)
      {
        if (layout!=null)
        {
           var result = layout.findTextLayout();
           if (result!=null)
              return result;
        }
      }
      return null;
   }
   public function getDisplayObject() : DisplayObject { return null; }

   public function setName(inName:String):Layout
   {
      name = inName;
      return this;
   }


   //public function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void { }

   public function setBorderRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      if (debug)
         Sys.println('setRect munus borders ... $name $inX,$inY ${inW}x$inH');
      setRect(inX-mBLeft, inY-mBTop, inW+mBLeft+mBRight, inH+mBTop+mBBottom);
   }
   public function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      if (debug)
      {
         Sys.println('setRect $name:$layoutId $inX,$inY ${inW}x$inH for min=${getMinSize()} best=${getBestSize()}');
      }
      lastRect = new Rectangle(inX,inY,inW,inH);
      if (onLayout!=null)
         onLayout(inX+mBLeft,inY+mBTop,inW-mBLeft-mBRight,inH-mBTop-mBBottom);
   }
   public function getRect() return lastRect;
   public function relayout()
   {
      if (lastRect!=null)
         setRect(lastRect.x, lastRect.y, lastRect.width, lastRect.height );
   }
   public function setSpacing(inX:Float,inY:Float) : Layout { return this; }

   static public function setDebug(inObj:Shape)
   {
      mDebugObject = inObj;
      mDebug = mDebugObject==null ? null : mDebugObject.graphics;
   }

   public function setPadding(inX:Float, ?inY:Float) : Layout
   {
      mBLeft = inX;
      mBTop = inY==null ? inX : inY;
      mBRight = inX;
      mBBottom = inY==null ? inX : inY;
      return this;
   }
   public function setIndent(inL:Float) : Layout
   {
      mBLeft = inL;
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

   public function setBestWidth(inW:Float) : Layout
   {
      bestWidth = inW;
      return this;
   }
   public function setBestHeight(inH:Float) : Layout
   {
      bestHeight = inH;
      return this;
   }
   public function setBestSize(inW:Float, inH:Float) : Layout
   {
      setBestWidth(inW);
      setBestHeight(inH);
      return this; 
   }
   public function getColWidths() : Array<Float> { return [ getBestWidth() ]; }

   public function getBestWidth() : Float
   {
      return bestWidth!=null ? bestWidth : minWidth;
   }

   public function getBestHeight(?inWidth:Null<Float>) : Float
   {
      return bestHeight!=null ? bestHeight : minHeight;
   }

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
      var inW = w;
      var inH = h;

      var min = child.getMinSize();
      //if (debug) Sys.println('  $name : alignChild $x,$y ${w}x$h / $min');
      if (w<min.x)
         w = min.x;
      if (h<min.y)
         h = min.y;
      if ( (child.mAlign & Layout.AlignKeepAspect) > 0 )
      {
         var cw = child.getBestWidth();
         var ch = child.getBestHeight();
         if (w*ch > h*cw)
         {
             var nw = h*cw/ch;
             x+=(w-nw)*0.5;
             w = nw;
         }
         else
         {
             var nh = w*ch/cw;
             y+=(h-nh)*0.5;
             h = nh;
         }
      }

      switch(child.mAlign & Layout.AlignMaskX)
      {
         case Layout.AlignRight:
            var bw = child.getBestWidth();
            if (bw>w) bw = w;
            x += w-bw;
            w = bw;
         case Layout.AlignCenterX:
            var bw = child.getBestWidth();
            if (bw>w) bw = w;
            x += (w-bw)/2;
            w = bw;
         case Layout.AlignLeft:
            var bw = child.getBestWidth();
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

      if (child.mAlign & Layout.AlignHalfPixel > 0)
      {
         var right = Std.int(x+w+0.5) + 0.5;
         var bottom = Std.int(y+h+0.5) + 0.5;
         x = Std.int(x+0.5) + 0.5;
         y = Std.int(y+0.5) + 0.5;
         w = right - x;
         h = bottom - y;
      }
      else if (child.mAlign & Layout.AlignSubPixel == 0)
      {
         var right = Std.int(x+w+0.5);
         var bottom = Std.int(y+h+0.5);
         x = Std.int(x+0.5);
         y = Std.int(y+0.5);
         w = right - x;
         h = bottom - y;
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

   public function getInnerRect(rect:Rectangle) : Rectangle
   {
     return new Rectangle( rect.x+mBLeft, rect.y+mBTop,
        rect.width - mBLeft-mBRight, rect.height-mBTop-mBBottom );
   }

   public function toString() return 'Layout($name)';
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

   
   public override function add(inLayout:Layout) : Layout
   {
      if (mBase!=null)
         super.add(inLayout);
      else
      {
         mBase = inLayout;
      }
      return this;
   }

   override public function findTextLayout() : TextLayout  { return mBase.findTextLayout(); }

   public function setItemLayout(inItemLayout:Layout)
   {
      mBase = inItemLayout;
      return this;
   }

   override public function getDisplayObject() : DisplayObject { return mBase.getDisplayObject(); }

/*
   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
      return mBase.calcSize( inWidth==null  ? null : inWidth-mBLeft-mBRight,
                             inHeight==null ? null : inHeight-mBTop-mBBottom );
   }
   */

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      alignChild(mBase, (inX+mBLeft)*positionMask, (inY+mBTop)*positionMask,
                         inW-mBLeft-mBRight, inH-mBTop-mBBottom );
      super.setRect(inX, inY, inW, inH);
   }

   public override function getBestWidth() : Float
   {
      var w = mBase.getBestWidth() + mBLeft + mBRight;
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

   // BorderLayout
   override public function setMinWidth(inWidth:Float) : Layout
   {
      super.setMinWidth(inWidth);
      mBase.setMinWidth(inWidth-mBLeft-mBRight);
      return this;
   }

   override public function setMinHeight(inHeight:Float) : Layout
   {
      super.setMinHeight(inHeight);
      mBase.setMinHeight(inHeight-mBTop-mBBottom);
      return this;
   }


   // BorderLayout
   public override function getMinSize() : Size
   {
      var s = mBase.getMinSize();
      s.x += mBLeft + mBRight;
      s.y += mBTop + mBBottom;
      //if (debug || mBase.debug)
      //   Sys.println(' border min $mBase ->' + s);
      return s;
   }

   override public function toString() return 'BorderLayout($name : $mBase)';
}

// --- DisplayLayout ---------------------------------------------------

class DisplayLayout extends Layout
{
   var mObj:DisplayObject;
   var mOX:Float;
   var mOY:Float;
   var mOWidth:Float;
   var mOHeight:Float;
   var mGfxRect:Bool;

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

      mGfxRect = ( inAlign & Layout.AlignGraphcsRect ) > 0;

      mDebugCol = 0xff00ff;
   }

   /*
   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
   }
   */

   override public function getDisplayObject() : DisplayObject
   {
      return mObj;
   }

   public function setOrigin(inX:Float,inY:Float) : DisplayLayout
   {
      mOX = inX;
      mOY = inY;
      return this;
   }
 
   // DisplayLayout
   public override function getMinSize() : Size
   {
      return bestDefault(new Size(minWidth>=0 ? minWidth : mOWidth,
                                 minHeight>=0 ? minHeight : mOHeight ));
   }

   public override function setBestWidth(inW:Float)
   {
     mOWidth = inW - mBLeft - mBRight;
     return this;
   }

   public override function setBestHeight(inH:Float)
   {
     mOHeight = inH - mBTop - mBBottom;
     return this;
   }


   function setObjRect(x:Float,y:Float,w:Float,h:Float)
   {
      mObj.x = x;
      mObj.y = y;

      if (mObj.scale9Grid != null || mGfxRect )
      {
         mObj.width = w;
         mObj.height = h;
      }
   }

   public function getBaseWidth() return mOWidth;
   public function getBaseHeight() return mOHeight;

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      var w = inW - mBLeft - mBRight;
      var x = mOX + inX + mBLeft;
      var ow = getBaseWidth();
      var oh = getBaseHeight();

      if ( mGfxRect )
      {
         ow = minWidth<ow ? ow : minWidth;
         oh = minHeight<oh ? oh : minHeight;
      }

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

      if (mAlign & Layout.AlignHalfPixel > 0)
      {
         var right = Std.int(x+w+0.5) + 0.5;
         var bottom = Std.int(y+h+0.5) + 0.5;
         x = Std.int(x+0.5) + 0.5;
         y = Std.int(y+0.5) + 0.5;
         w = right - x;
         h = bottom - y;
      }
      else if (mAlign & Layout.AlignSubPixel == 0)
      {
         var right = Std.int(x+w+0.5);
         var bottom = Std.int(y+h+0.5);
         x = Std.int(x+0.5);
         y = Std.int(y+0.5);
         w = right - x;
         h = bottom - y;
      }

      setObjRect(x,y,w,h);

      if (Layout.mDebug!=null && mObj!=null && mObj.parent!=null)
      {
         var pos = Layout.mDebugObject.globalToLocal( mObj.parent.localToGlobal( new Point(x,y) ) );
         renderDebug(pos,w,h);
      }

      super.setRect(inX, inY, inW, inH);
   }

   public function renderDebug(pos:Point, w:Float, h:Float)
   {
     Layout.mDebug.lineStyle(1,mDebugCol);
     Layout.mDebug.drawRect(pos.x,pos.y,w,h);
   }

   // DisplayLayout
   public override function getBestWidth() : Float
   {
      if (bestWidth!=null)
         return bestWidth;
      var w = mOWidth + mBLeft + mBRight;
      if (minWidth>w) return minWidth;
      return w;
   }

   // DisplayLayout
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      if (bestHeight!=null)
         return bestHeight;
      var h = mOHeight + mBTop + mBBottom;
      if (minHeight>h) return minHeight;
      return h;
   }

   override public function toString() return 'DisplayLayout($name : $mObj)';
}


class TextLayout extends DisplayLayout
{
   public function new(inObj:TextField,inAlign:Int = 0x24, // AlignCenterX|AlignCenterY
           ?inPrefWidth:Null<Float>,?inPrefHeight:Null<Float>)
   {
      super(inObj,inAlign);

      var w = inObj.width;
      var h = inObj.height;
      if (inObj.rotation==90 || inObj.rotation==270)
      {
         var t = w; w = h; h = t;
      }
      var fmt = inObj.defaultTextFormat;
      if (fmt!=null && fmt.size!=null)
      {
         //trace("  fmt size: " + fmt.size + " lines:" + inObj.numLines );
         if (inObj.rotation==90 || inObj.rotation==270)
            w = fmt.size * 1.5 * inObj.numLines;
         else
            h = fmt.size * 1.5 * inObj.numLines;
      }

      mOWidth = inPrefWidth==null ? w: inPrefWidth;
      mOHeight = inPrefHeight==null ? h: inPrefHeight;

      mDebugCol = 0x00ff00;
   }

   public function updateSizeFromText()
   {
      var w = mObj.width;
      var h = mObj.height;
      if (mObj.rotation==90 || mObj.rotation==270)
      {
         var t = w; w = h; h = t;
      }
      mOWidth = w;
      mOHeight = h;
   }

   override public function findTextLayout() : TextLayout  { return this; }

   override public function renderDebug(pos:Point, w:Float, h:Float)
   {
     var text:TextField = cast mObj;
     Layout.mDebug.lineStyle(2,mDebugCol);
     Layout.mDebug.drawRect(pos.x,pos.y,text.textWidth,text.textHeight);
   }

   
   override public function getBaseWidth()
   {
      var text:TextField = cast mObj;
      if (text.rotation==90 || text.rotation==270)
          return text.height;
      return text.width;
   }
   override public function getBaseHeight()
   {
      var text:TextField = cast mObj;
      if (text.rotation==90 || text.rotation==270)
          return text.width;
      return text.height;
   }

   override function setObjRect(x:Float,y:Float,w:Float,h:Float)
   {
      var text:TextField = cast mObj;
      text.x = x;
      text.y = y;
      if (text.rotation==90 || text.rotation==270)
      {
         text.width = h;
         text.height = w;
         if (text.rotation==270)
            text.y = y+h;
         else
         {
            text.x = x+w;
         }
      }
      else
      {
         text.width = w;
         text.height = h;
      }
   }


   // TextLayout
   public override function getBestWidth() : Float
   {
      if (bestWidth!=null)
         return bestWidth;
      var w = mOWidth + mBLeft + mBRight;
      if (minWidth>w) return minWidth;
      return w;
   }


   // TextLayout
   public override function getMinSize() : Size
   {
      var textF:TextField = cast mObj;
      if (minHeight<0 && textF.multiline && (mObj.rotation==0 || mObj.rotation==180))
      {
         var h = -1.0;
         var fmt = textF.defaultTextFormat;
         if (fmt!=null && fmt.size!=null)
            h = fmt.size * 1.5 + mBTop + mBBottom;

         return bestDefault(new Size(minWidth>=0? minWidth : mOWidth, h) );
      }

      return super.getMinSize();

      //return bestDefault(new Size(mOWidth>minWidth ? mOWidth:minWidth, mOHeight>minHeight ? mOHeight:minHeight ));
   }

   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      if (bestHeight!=null)
         return bestHeight;
      var textF:TextField = cast mObj;
      if (textF.multiline && inWidth!=null && (mObj.rotation==0 || mObj.rotation==180))
      {
         textF.autoSize = TextFieldAutoSize.LEFT;
         textF.width=inWidth - mBLeft - mBRight;
         var h = textF.height + mBTop + mBBottom;
         textF.autoSize = TextFieldAutoSize.NONE;
         //trace(textF.text + "@" + inWidth + " -> " + textF.autoSize + " " + h + "/" + minHeight);
         if (minHeight>h)
            return minHeight;
         return h;
      }
      return super.getBestHeight(inWidth);
   }

   override public function toString()
   {
      var textF:TextField = cast mObj;
      var text =  textF.text;
      if (text.length>10)
         text = text.substr(0,7) + "...";

      return 'TextLayout($name : $text)';
   }
}

class AutoTextLayout extends TextLayout
{
   public function new(inObj:TextField,inAlign:Int = 0x24, // AlignCenterX|AlignCenterY
           ?inPrefWidth:Null<Float>,?inPrefHeight:Null<Float>)
   {
      inObj.autoSize = TextFieldAutoSize.LEFT;
      //trace(" " + inObj.text + " autos " + inObj.autoSize);
      super(inObj,inAlign,inPrefWidth,inPrefHeight);
      inObj.autoSize = TextFieldAutoSize.NONE;
   }

   override public function updateSizeFromText()
   {
      var tf:TextField = cast mObj;
      if (tf!=null)
      {
         var as = tf.autoSize;
         tf.autoSize = TextFieldAutoSize.LEFT;
         super.updateSizeFromText();
         tf.autoSize = as;
      }
      else
      {
         super.updateSizeFromText();
      }
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

   override public function findTextLayout() : TextLayout
   {
      return Layout.findTextLayoutInList(mChildren);
   }
   override public function visitChildren(onChild:Layout->Dynamic,inRecurse=true) : Dynamic
      return Layout.visitChildList(mChildren, onChild,inRecurse);


/*
   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
      if (inWidth!=null)
         width = inWidth;
      else
         width = getBestWidth();

      height = getBestHeight();
   }
*/

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      for(child in mChildren)
         alignChild(child,inX+mBLeft, inY+mBTop, inW-mBLeft-mBRight, inH-mBTop-mBBottom );

      super.setRect(inX, inY, inW, inH);
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


   // StackLayout
   public override function getMinSize() : Size
   {
      var w:Float = minWidth;
      var h:Float = minHeight;
      for(c in mChildren)
      {
         var s = c.getMinSize();
         if (s.x>w)
            w = s.x;
         if (s.y>h)
            h = s.y;
      }
      return bestDefault(new Size( w, h ));
   }


   public override function getBestWidth() : Float
   {
      var width = 0.0;
      var idx = 0;
      for(child in mChildren)
      {
         var w = child.getBestWidth();
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
      var height = 0.0;
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

   override public function toString() return 'StackLayout($name)';
}

class PagedLayout extends StackLayout
{
   public function new()
   {
      super();
   }

   public override function add(inLayout:Layout) : Layout
   {
      var result = super.add(inLayout);
      var display = inLayout.getDisplayObject();
      if (display!=null)
         display.visible = mChildren.length == 1;
      return result;
   }

   public function setPage(inIndex:Int) : Void
   {
      for(c in 0...mChildren.length)
      {
         var display = mChildren[c].getDisplayObject();
         if (display!=null)
            display.visible = inIndex==c;
      }
   }
   override public function toString() return 'PagedLayout($name)';
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

      super.setRect(inX, inY, inW, inH);
   }

   public function setChildPadding(left:Float, top:Float, right:Float, bottom:Float)
   {
      offsetLeft = left;
      offsetRight = right;
      offsetTop = top;
      offsetBottom = bottom;
   }
   override public function toString() return 'ChildStackLayout($name)';
}

// --- GridLayout -------------------------------------------

class ColInfo
{
   public function new(inStretch:Float)
   {
      mBestWidth = 0;
      mMinSpecWidth = 0;
      mMinWidth = 0;
      mStretch = inStretch;
      mStretchSet = false;
   }
   public var mStretch:Float;
   public var mMinSpecWidth:Float;
   public var mStretchSet:Bool;

   // Calculated from children
   public var mBestWidth:Float;
   public var mMinWidth:Float;

   public function toString() return 'ColInfo($mBestWidth,$mStretch)';
}

class RowInfo
{
   public function new(inStretch:Float)
   {
      mCols = [];
      mStretch = inStretch;
      //mShrink = 0.0;
      mMinHeight = 0.0;
      mStretchSet = false;
      mShrinkOnly = false;
   }

   public var mCols:LayoutList;
   public var mShrinkOnly:Bool;
   public var mStretch:Float;
   //public var mHeight:Float;
   //public var mShrink:Float;
   public var mStretchSet:Bool;

   // Calculated from children
   public var mMinHeight:Float;
}


class GridLayout extends Layout
{
   var mCols:Null<Int>;
   var mColInfo : Array<ColInfo>;
   var mRowInfo : Array<RowInfo>;
   var mSpaceX:Float;
   var mSpaceY:Float;
   var mPos:Int;
   var autoAlign:Bool;
   public var mDbgObj:DisplayObject;

   public function new(?inCols:Null<Int>,?inName:String)
   {
      super();
      mSpaceX = 0;
      mSpaceY = 0;
      mCols = inCols;
      autoAlign = true;
      if (inName!=null)
          name = inName;
      clear();
   }

   override public function clear( )
   {
      mColInfo = [];
      mRowInfo = [];
      if (mCols!=null)
      {
         for(i in 0...mCols)
            mColInfo[i] = new ColInfo(0);
      }
      else
      {
         mRowInfo[0] = new RowInfo(0);
      }
      mPos = 0;
   }

   public function setDebugOwner(inObj:DisplayObject) : GridLayout
   {
      mDbgObj = inObj;
      return this;
   }


   /*
   public static function createKeepAspect(inMinWidth:Float, inMinHeight:Float, inBase:Layout)
   {
      var result = new GridLayout(1,"KeepAspect");
      result.minWidth = inMinWidth;
      result.minHeight = inMinHeight;
      result.add(inBase);
      inBase.mAlign |= Layout.AlignKeepAspect;
      return result;
   }
   */

   public override function add(inLayout:Layout) : Layout
   {
      var row = 0;
      if (mCols!=null && mCols>0)
      {
         row = Std.int(mPos / mCols);
         if (row>=mRowInfo.length)
            mRowInfo.push(new RowInfo(0));
      }
      else
      {
         while(mColInfo.length<=mPos)
            mColInfo.push(new ColInfo(0));
      }
      if (mRowInfo[row]==null)
         mRowInfo[row]=new RowInfo(0);
      var col = mRowInfo[row].mCols.length;

      mRowInfo[row].mCols.push(inLayout);
      // todo auto-stretch
      if (inLayout!=null)
      {
         if (!mRowInfo[row].mStretchSet && (inLayout.mAlign & Layout.AlignMaskY) == Layout.AlignStretch)
         {
            if (mRowInfo[row].mStretch<1)
               mRowInfo[row].mStretch = 1;
            if (autoAlign)
               mAlign &= ~Layout.AlignMaskY;
         }

         if (!mColInfo[col].mStretchSet &&  (inLayout.mAlign & Layout.AlignMaskX) == Layout.AlignStretch)
         {
            if (mColInfo[col].mStretch<1)
               mColInfo[col].mStretch = 1;
            if (autoAlign)
               mAlign &= ~Layout.AlignMaskX;
         }
      }
      mPos++;
      return this;
   }

   override public function setAlignment(inAlign:Int)
   {
      super.setAlignment(inAlign);
      autoAlign = false;
      return this;
   }

   public override function insert(inPos:Int, inLayout:Layout) : Layout
   {
      if (inPos>=mPos)
         return add(inLayout);

      if (mCols==1)
      {
         var stretch = inLayout==null ? 0 :
             (inLayout.mAlign & Layout.AlignMaskY)==Layout.AlignStretch ? 1: 0;
         mRowInfo.insert(inPos,new RowInfo(stretch));
         mRowInfo[inPos].mCols.push(inLayout);
      }
      else if (mCols==null)
      {
         var stretch = inLayout==null ? 0 :
             (inLayout.mAlign & Layout.AlignMaskX)==Layout.AlignStretch ? 1: 0;
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


   public function rowStretch(inValues:Array<Float>)
   {
      for(i in 0...inValues.length)
         setRowStretch(i,inValues[i]);
      return this;
   }


   public function setRowStretch(inRow:Int,inStretch:Float,inShrinkOnly=false)
   {
      if (mRowInfo[inRow]==null)
         mRowInfo[inRow] = new RowInfo(inStretch);
      mRowInfo[inRow].mStretch = inStretch;
      mRowInfo[inRow].mShrinkOnly = inShrinkOnly;
      mRowInfo[inRow].mStretchSet = true;
      return this;
   }

   public function colStretch(inValues:Array<Float>)
   {
      for(i in 0...inValues.length)
         setColStretch(i,inValues[i]);
      return this;
   }

   public function setColStretch(inCol:Int,inStretch:Float)
   {
      if (mColInfo[inCol]==null)
         mColInfo[inCol] = new ColInfo(inStretch);
      mColInfo[inCol].mStretch = inStretch;
      mColInfo[inCol].mStretchSet = true;
      return this;
   }

   public function setMinColWidth(inCol:Int,inMin:Float)
   {
      if (mColInfo[inCol]==null)
         mColInfo[inCol] = new ColInfo(0);
      mColInfo[inCol].mMinSpecWidth = inMin;
      return this;
   }


   public static var indent = "";

   // Updates col.mBestWidth, col.mMinWidth, row.mMinHeight
   function calcWidthsMinAndBest()
   {
       var key = "cw:" + layoutId;
       if (isCached(key))
          return;
      //trace(indent + "calcWidthsMinAndBest..." + mColInfo.length);
      //var oindent = indent;
      //indent += "  ";
      for(col in mColInfo)
      {
         col.mBestWidth = col.mMinWidth = col.mMinSpecWidth;
         if (debug)
            trace(' $key col ' + col.mMinWidth );
      }
      var thickest = 0.0;
      for(row in mRowInfo)
      {
         row.mMinHeight = 0;
         //trace(indent + " cols : "  + row.mCols.length);
         for(i in 0...row.mCols.length)
         {
            var col =  row.mCols[i];
            if (col!=null)
            {
               var w = col.getBestWidth();
               if (w>mColInfo[i].mBestWidth)
               {
                  mColInfo[i].mBestWidth = w;
                  if (w>thickest)
                     thickest = w;
                  //trace(indent + " -> [" + i + "] = " + w);
               }
               var s = col.getMinSize();
               if (s.x>mColInfo[i].mMinWidth)
               {
                  mColInfo[i].mMinWidth = s.x;
                  if (debug)
                     trace(' $i] -> ${s.x}');
               }
               if (s.y>row.mMinHeight)
                  row.mMinHeight = s.y;
            }
         }
      }
      if ( (mAlign & Layout.AlignEqual)!=0 )
         for(c in mColInfo)
            c.mBestWidth = thickest;
      setCache(key,true,false);
      //indent = oindent;
   }

   /*
   function calcRowMinBest()
   {
       var key = "minBest:" + layoutId + ":" + inWidth;
       if (Layout.cache.exists(key) )
          return;

      var tallest = 0.0;
      for(r in 0...mRowInfo.length)
      {
         var row = mRowInfo[r];
         row.mHeight = 0;
         var minHeight = 0.0;
         for(i in 0...row.mCols.length)
         {
            var col =  row.mCols[i];
            if (col!=null)
            {
               var h = col.getBestHeight();
               if (h>row.mHeight)
                  row.mHeight = h;
               if (h>tallest)
                  tallest = h;
               var minH = col.getMinSize().y;
               if (minH>minHeight)
                  minHeight = minH;
            }
         }

         row.mMinHeight = minHeight;
         //if (debug)
         //   Sys.println('   $name $r] h=$minHeight');
         if (row.mHeight>minHeight)
            row.mShrink = row.mHeight-minHeight;
         else
            row.mShrink = 0.0;
      }
      if ( (mAlign & Layout.AlignEqual)!=0 )
         for(r in mRowInfo)
            r.mHeight = tallest;
      Layout.cache.set(key,true);
   }
   */

   function distribute(width:Float, dmin:Array<Float>, dbest:Array<Float>, dstretch:Array<Float> )
   {
      var min = 0.0;
      var best = 0.0;
      var totalStretch = 0.0;
      var n = dmin.length;
      for(c in 0...n)
      {
         min += dmin[c];
         best += dbest[c];
         totalStretch += dstretch[c];
      }
      if (width>=best)
      {
         var size = [ ];
         var extra = width-best;
         for(c in 0...n)
         {
            var w = dbest[c];
            if (dstretch[c]>0)
            {
               var e = Std.int(extra * dstretch[c]/totalStretch + 0.5);
               w += e;
               extra -= e;
               totalStretch -= dstretch[c];
            }
            size.push(w);
         }
         return size;
      }

      var size = dbest;
      var missing = best-width;
      for(pass in 0...10)
      {
         for(cid in 0...n)
         {
            if (dstretch[cid]>0 && size[cid]>dmin[cid])
            {
               var e = missing * dstretch[cid]/totalStretch;
               if (size[cid]-e < dmin[cid])
                  e = size[cid] - dmin[cid];
               size[cid] -= e;
               missing -= e;
               totalStretch -= dstretch[cid];
            }
         }
         if (missing<0.5)
           break;

         totalStretch = 0.0;
         for(cid in 0...n)
         {
            if ( size[cid]>dmin[cid] && dstretch[cid] > 0 )
                 totalStretch += dstretch[cid];
         }
      }
      return size;
   }

   function distributeWidth(width:Float)
   {
      var min = [for(c in mColInfo) c.mMinWidth ];
      var best = [for(c in mColInfo) c.mBestWidth ];
      var stretch = [for(c in mColInfo) c.mStretch ];

      width -= mBLeft + mBRight;
      if (min.length>1)
         width -= (min.length-1) * mSpaceX;

      return distribute(width, min, best, stretch);
   }


   override public function getColWidths() : Array<Float>
   {
      return calcColWidths(null);
   }

   // GridLayout
   function calcColWidths(inWidth:Null<Float>) : Array<Float>
   {
      var key = "ccw:" + layoutId + ":" + inWidth;
      if (isCached(key))
         return getCached(key);

      var destroyCache = beginCache();
      calcWidthsMinAndBest();
      var result:Array<Float> = null;
      if (inWidth==null)
      {
         result = [for(c in mColInfo) c.mBestWidth ];
      }
      else
         result = distributeWidth(inWidth);

      return setCache(key,result,destroyCache);
   }

/*
            [for(c in mColInfo) c.mBestWidth ] :
            distributeWidth(inWidth);

     calcRowHeights(width);

     var height = 0.0;
     for(row in mRowInfo)
        height+=row.mHeight;
     //if (debug)
     //   Sys.println("  row heights: " + [ for(row in mRowInfo) row.mHeight ] );
     height += mBTop + mBBottom;
     if (mRowInfo.length>0)
        height += (mRowInfo.length -1)*mSpaceY;

     //if (debug)
     //   Sys.println(' Layout H $name: $height / $inHeight $mAlign');

     if (inHeight!=null)
     {
        var extra = inHeight-height;
        if (extra!=0)
        {
           var stretch = 0.0;
           var stretches = new Array<Float>();
           for(row in mRowInfo)
           {
              if (extra<0 || !row.mShrinkOnly)
              {
                 stretches.push(row.mStretch);
                 stretch += row.mStretch;
              }
              else
                 stretches.push(0.0);
           }

           var remaining = extra;
           while(stretch>0 && Math.abs(extra)>=1 )
           {
              var clamped = false;
              for(rid in 0...mRowInfo.length)
              {
                 if (stretches[rid]!=0)
                 {
                    var row = mRowInfo[rid];
                    var delta = Std.int(stretches[rid] * extra / stretch + 0.5);
                    if (row.mHeight+delta < row.mMinHeight)
                    {
                       delta = Std.int(row.mMinHeight-row.mHeight);
                       row.mHeight = row.mMinHeight;
                       stretches[rid] = 0.0;
                       clamped = true;
                    }
                    else
                    {
                       row.mHeight += delta;
                    }
                    remaining -= delta;
                 }
              }

              if (!clamped)
                 break;
              stretch = 0;
              for(s in stretches)
                 stretch+=s;
              extra = remaining;
           }

           if (remaining<0)
           {
              remaining = -remaining;
              var total = 0.0;
              for(row in mRowInfo)
                 total += row.mShrink;

              if (total>0)
              {
                 for(row in mRowInfo)
                 {
                    var delta = row.mShrink * remaining/total;
                    row.mHeight = Std.int(row.mHeight - delta + 0.5);
                 }
              }
           }
        }

        height = inHeight;
     }
     Layout.endCache(destroyCache);
   }
*/

   override public function findTextLayout() : TextLayout
   {
      for(row in mRowInfo)
      {
         if (row==null)
             continue;
         var result = Layout.findTextLayoutInList(row.mCols);
         if (result!=null)
            return result;
      }
      return null;
   }
   override public function visitChildren(onChild:Layout->Dynamic,inRecurse=true) : Dynamic
   {
      for(row in mRowInfo)
      {
         if (row==null)
             continue;
         var result = Layout.visitChildList(row.mCols,onChild,inRecurse);
         if (result!=null)
            return result;
      }
      return null;
   }


   // Grid
   public override function getBestWidth() : Float
   {
      if (bestWidth!=null)
         return bestWidth;

      var key = 'gbw:$layoutId';
      if (isCached(key))
         return getCached(key);

      var destroyCache = beginCache();

      calcWidthsMinAndBest();
      if (debug)
      {
         trace('$this best col width:' + [for(c in mColInfo) c.mBestWidth]);
         trace('$this min col width:' + [for(c in mColInfo) c.mMinWidth]);
      }
      var w = mBLeft + mBRight;
      if (mColInfo.length>0)
         w+=(mColInfo.length-1)*mSpaceX;
      for(col in mColInfo)
         w+= col.mBestWidth;
      if (minWidth>w)
         w = minWidth;

      return setCache(key,w,destroyCache);
   }

   function calcBestHeights(widths:Array<Float>) : Array<Float>
   {
      var key = 'cbh:$layoutId:$widths';
      if (isCached(key))
         return getCached(key);

      var result = new Array<Float>();
      for(r in mRowInfo)
      {
         var h = 0.0;
         for(cid in 0...r.mCols.length)
         {
            var c = r.mCols[cid];
            if (c!=null)
            {
               var ch = c.getBestHeight(widths[cid]);
               if (ch>h)
                  h = ch;
            }
         }
         result.push(h);
      }

      return setCache(key, result, false);
   }


   // Grid
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      if (bestHeight!=null)
         return bestHeight;

      var key = "gbh:" + layoutId + ":" + inWidth;
      if (isCached(key))
         return getCached(key);

      var remove = beginCache();

      var colWidths = calcColWidths(inWidth);
      var rowHeights = calcBestHeights(colWidths);

      var h = mBTop + mBBottom;
      if (rowHeights.length>0)
         h+= (rowHeights.length-1)*mSpaceY;
      for(r in rowHeights)
         h+=r;
      if (minHeight>h)
         h = minHeight;

      return setCache(key, h, remove);
   }

   // GridLayout
   public override function getMinSize() : Size
   {
      var key = 'gmh:$layoutId';
      if (isCached(key))
         return getCached(key);


      var remove = beginCache();

      calcWidthsMinAndBest();


      var sx = (mColInfo.length-1)*mSpaceX + mBLeft + mBRight;
      for(c in mColInfo)
         sx+= c.mMinWidth;
      if (sx<minWidth)
         sx = minWidth;

      var sy = (mRowInfo.length-1)*mSpaceY + mBTop + mBBottom;
      for(r in mRowInfo)
         sy+= r.mMinHeight;
      if (sy<minHeight)
         sy = minHeight;

      var result = bestDefault(new Size( sx, sy ));

      if (debug) trace('dbg: $this  getMinSize ->' + result);
      return setCache(key,result,remove);
   }


   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      var destroyCache = beginCache();

      var oindent = indent;
      indent += "   ";

      var widths = calcColWidths(inW);
      var bestHeights = calcBestHeights(widths);
      var minHeights = [for(r in mRowInfo) r.mMinHeight];
      var stretches = [for(r in mRowInfo) r.mStretch ];

      var h = inH - mBTop - mBBottom;
      if (mRowInfo.length>1)
         h -= (mRowInfo.length-1)*mSpaceY;
      var heights = distribute(h, minHeights, bestHeights, stretches );

      // distributeWidth
      // distributeHeight

      //for(col in mColInfo)
        //trace("Got col " + col.mBestWidth );
      indent = oindent;
      var y = inY + mBTop;
      for(rid in 0...mRowInfo.length)
      {
         var row = mRowInfo[rid];
         var row_h = heights[rid];
         var x = inX + mBLeft;
         for(c in 0...row.mCols.length)
         {
            var col_w = widths[c];

            var item = row.mCols[c];

            if (item!=null)
               alignChild(item, x, y, col_w, row_h );

            x+=col_w + mSpaceX;
         }
         y+= row_h + mSpaceY;
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

      super.setRect(inX, inY, inW, inH);
      endCache(destroyCache);
   }
   override public function toString() return 'GridLayout($name)';
}

class VerticalLayout extends GridLayout
{
   public function new(?inRowStretch:Array<Float>,inColStretch = 1.0,inName="VLayout")
   {
      super(1,inName);
      if (inRowStretch!=null)
         rowStretch(inRowStretch);
      setColStretch(0,inColStretch);
   }


   public override function add(inLayout:Layout) : Layout
   {
      if (mRowInfo!=null &&  mRowInfo[mPos]!=null)
         if (mRowInfo[mPos].mStretch>0)
            inLayout.stretch();

      return super.add(inLayout);
   }
   override public function toString() return 'VerticalLayout($name)';
}


class HorizontalLayout extends GridLayout
{
   public function new(?inColStretch:Array<Float>,inRowStretch=1.0,inName="HLayout")
   {
      super(null,inName);
      if (inColStretch!=null)
         colStretch(inColStretch);
      setRowStretch(0,inRowStretch);
   }

   public override function add(inLayout:Layout) : Layout
   {
      if (mColInfo!=null &&  mColInfo[mPos]!=null)
         if (mColInfo[mPos].mStretch>0)
            inLayout.stretch();

      return super.add(inLayout);
   }
   override public function toString() return 'HorizontalLayout($name)';
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

   override public function findTextLayout() : TextLayout
   {
      return Layout.findTextLayoutInList(mChildren);
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

/*
   public override function calcSize(inWidth:Null<Float>,inHeight:Null<Float>) : Void
   {
      if (inWidth!=null)
         width = inWidth;
      else
         width = getBestWidth();

      if (inHeight!=null)
         height = inHeight;
      else
         height = getBestHeight(width);
   }
   */

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
         var w = child.getBestWidth();
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

         var w = child.getBestWidth();
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

      super.setRect(inX, inY, inW, inH);
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


   public override function getBestWidth() : Float
   {
      var width = 0.0;
      for(child in mChildren)
      {
         if (width>0)
            width += spaceX;
         var w = child.getBestWidth();
         width += w;
      }
      width += mBLeft + mBRight;
      if (minWidth>width) width = minWidth;
      return width;

   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var height = mBTop + mBBottom;
      var rowHeight = 0.0;
      var x = 0.0;
      var maxW = inWidth==null ? 0 : inWidth-mBLeft- mBRight;
      for(child in mChildren)
      {
         var w = child.getBestWidth();
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


   override public function toString() return 'FlowLayout($name)';
}


