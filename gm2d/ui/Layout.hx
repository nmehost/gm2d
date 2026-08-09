package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.Shape;
import nme.geom.Rectangle;

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

   public var borderLeft(default,null):Float;
   public var borderTop(default,null):Float;
   public var borderRight(default,null):Float;
   public var borderBottom(default,null):Float;

   public var minWidth:Float;
   public var minHeight:Float;
   //public var width:Float;
   //public var height:Float;

   public var name:String;

   public var mDebugCol:Int;

   public var mAlign:Int;

   public var lastRect:Rectangle;

   // Fired from setRect() with the inner/content rect (this layout's own borders already
   // subtracted) — never the rect actually passed to setRect().
   public var onInnerRect:Float->Float->Float->Float->Void;

   @:deprecated("Layout.onLayout has been renamed to onInnerRect - it always delivered the inner/content rect, never the rect passed to setRect(). See docs/Migration-v5.md#LAY-001.")
   public var onLayout(get,set):Float->Float->Float->Float->Void;
   inline function get_onLayout() return onInnerRect;
   inline function set_onLayout(f) return onInnerRect = f;

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
      borderLeft = borderRight = borderTop = borderBottom = 0;
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
      if (remove)
         cache = null;
      else
         cache.set(key,value);
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
   public function getBordersX() return borderLeft + borderRight;
   public function getBordersY() return borderTop + borderBottom;

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
      minWidth = inWidth + borderLeft + borderRight;
      minHeight = inHeight + borderTop + borderBottom;
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

   // Logical-unit sibling of setMinSize() - registers with widget.addScaleChanged so the min
   // size is re-resolved through skin.toPixels() on every rescale instead of being baked in at
   // construction. See docs/Migration-v5.md.
   public function setLogicalMinSize(widget:Widget, inWidth:Float, inHeight:Float) : Layout
   {
      widget.addScaleChanged(() ->
         setMinSize(widget.skin.toPixels(inWidth), widget.skin.toPixels(inHeight)) );
      return this;
   }

   // Layout
   public function getMinSize(?inWidth:Null<Float>) : Size
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
      setRect(inX-borderLeft, inY-borderTop, inW+borderLeft+borderRight, inH+borderTop+borderBottom);
   }
   public function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      if (debug)
      {
         trace('Layout setRect $onInnerRect, $name:$layoutId $inX,$inY ${inW}x$inH for min=${getMinSize()} best=${getBestSize()}');
         trace('  borders: $borderLeft,$borderTop,$borderRight,$borderBottom');
      }
      lastRect = new Rectangle(inX,inY,inW,inH);
      if (onInnerRect!=null)
         onInnerRect(inX+borderLeft,inY+borderTop,inW-borderLeft-borderRight,inH-borderTop-borderBottom);
   }
   public function getRect() return lastRect;
   public function relayout()
   {
      if (lastRect!=null)
         setRect(lastRect.x, lastRect.y, lastRect.width, lastRect.height );
   }
   public function setSpacing(inX:Float,inY:Float) : Layout { return this; }

   // Logical-unit sibling of setSpacing() - see setLogicalMinSize(). A no-op on plain Layout
   // (matching setSpacing() itself), but dispatches to the real override on GridLayout,
   // FlowLayout etc, since setSpacing() is called virtually from inside the closure.
   public function setLogicalSpacing(widget:Widget, inX:Float, inY:Float) : Layout
   {
      widget.addScaleChanged(() ->
         setSpacing(widget.skin.toPixels(inX), widget.skin.toPixels(inY)) );
      return this;
   }

   static public function setDebug(inObj:Shape)
   {
      mDebugObject = inObj;
      mDebug = mDebugObject==null ? null : mDebugObject.graphics;
   }

   public function setPadding(inX:Float, ?inY:Float) : Layout
   {
      borderLeft = inX;
      borderTop = inY==null ? inX : inY;
      borderRight = inX;
      borderBottom = inY==null ? inX : inY;
      return this;
   }

   // Logical-unit sibling of setPadding() - see setLogicalMinSize().
   public function setLogicalPadding(widget:Widget, inX:Float, ?inY:Float) : Layout
   {
      widget.addScaleChanged(() ->
         setPadding(widget.skin.toPixels(inX), inY==null ? null : widget.skin.toPixels(inY)) );
      return this;
   }
   public function setIndent(inL:Float) : Layout
   {
      borderLeft = inL;
      return this;
   }
   public function setBorders(inL:Float,inT:Float,inR:Float,inB:Float) : Layout
   {
      borderLeft = inL;
      borderTop = inT;
      borderRight = inR;
      borderBottom = inB;
      return this;
   }

   // Logical-unit sibling of setBorders() - see setLogicalMinSize().
   public function setLogicalBorders(widget:Widget, inL:Float, inT:Float, inR:Float, inB:Float) : Layout
   {
      widget.addScaleChanged(() ->
         setBorders(widget.skin.toPixels(inL), widget.skin.toPixels(inT),
                    widget.skin.toPixels(inR), widget.skin.toPixels(inB)) );
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
      borderLeft = inDX;
      borderRight = -inDX;
      borderTop = inDY;
      borderBottom = -inDY;
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

   // Logical-unit sibling of setBestSize() - see setLogicalMinSize().
   public function setLogicalBestSize(widget:Widget, inW:Float, inH:Float) : Layout
   {
      widget.addScaleChanged(() ->
         setBestSize(widget.skin.toPixels(inW), widget.skin.toPixels(inH)) );
      return this;
   }
   public function getColWidths() : Array<Float> { return [ getBestWidth() ]; }

   public function getBestWidth() : Float
   {
      return clampBestWidth(bestWidth!=null ? bestWidth : minWidth);
   }

   public function getBestHeight(?inWidth:Null<Float>) : Float
   {
      return clampBestHeight(bestHeight!=null ? bestHeight : minHeight, inWidth);
   }

   // best is a genuine preference and may be set explicitly larger (or smaller) than the
   // computed/explicit minimum - these ensure getBestWidth()/getBestHeight() never report a
   // value below getMinSize(), regardless of which branch produced the raw candidate.
   function clampBestWidth(inRaw:Float) : Float
   {
      var m = getMinSize().x;
      return inRaw<m ? m : inRaw;
   }
   function clampBestHeight(inRaw:Float, ?inWidth:Null<Float>) : Float
   {
      var m = getMinSize(inWidth).y;
      return inRaw<m ? m : inRaw;
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
      var min = child.getMinSize(w);
      if (debug)
         trace('  aligning($child:  $x,$y,$w,$h / $min), align=${child.mAlign}');

      //if (debug) trace('  $name : alignChild $x,$y ${w}x$h / $min');
      if (w<min.x)
         w = min.x;
      if (h<min.y)
         h = min.y;
      if (child.debug || debug)
      {
         trace('  $name : alignChild ${child.name} a=${child.mAlign} $x,$y ${inW}x$inH -> $w x $h / $min');
         //if (h>w)
         //   throw "debug";
      }
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
         trace("alignChild keepAspect: $child $cw x $ch -> $w x $h");
      }

      switch(child.mAlign & Layout.AlignMaskX)
      {
         case Layout.AlignRight:
            var bw = child.getBestWidth();
            if (debug) trace(' ${child.name} right:${w-bw}');
            if (bw>w) bw = w;
            x += w-bw;
            w = bw;
         case Layout.AlignCenterX:
            var bw = child.getBestWidth();
            if (debug) trace(' ${child.name} center:${w-bw}');
            if (bw>w) bw = w;
            x += (w-bw)/2;
            w = bw;
         case Layout.AlignLeft:
            var bw = child.getBestWidth();
            if (debug) trace(' ${child.name} left:${w-bw}');
            if (bw>w) bw = w;
            w = bw;
         default:
            if (debug) trace(' ${child.name} keepx:${x} / ${w}');
      }

      switch(child.mAlign & Layout.AlignMaskY)
      {
         case Layout.AlignBottom:
            var bh = child.getBestHeight(w);
            if (debug) trace(' ${child.name} bottom:${h-bh}');
            if (bh>h) bh = h;
            y += h - bh;
            h = bh;
         case Layout.AlignCenterY:
            var bh = child.getBestHeight(w);
            if (debug) trace(' ${child.name} centerY:$y $h / $bh');
            if (bh>h) bh = h;
            y += (h - bh)/2;
            h = bh;
            if (debug) trace(' -> $y $h');
         case Layout.AlignTop:
            var bh = child.getBestHeight(w);
            if (debug) trace(' ${child.name} top:${h-bh}');
            if (bh>h) bh = h;
            h = bh;
         default:
            if (debug) trace(' ${child.name} keepy:${y}/${h}');
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

      if (debug)
         trace(' $this -> ${child}.setRect($x,$y,$w,$h)');
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
     return new Rectangle( rect.x+borderLeft, rect.y+borderTop,
        rect.width - borderLeft-borderRight, rect.height-borderTop-borderBottom );
   }

   public function toString() return 'Layout($name)';
}

typedef LayoutList = Array<Layout>;
