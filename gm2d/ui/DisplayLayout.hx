package gm2d.ui;

import nme.display.DisplayObject;
import nme.geom.Point;

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

   // Refreshes the cached best-size read by getMinSize()/getBestWidth()/getBestHeight() - use
   // this after resizing the underlying DisplayObject outside the constructor (eg. Button's
   // objectSize handling on a live rescale), since mOWidth/mOHeight otherwise only ever reflect
   // whatever inObj.width/height happened to be when this Layout was constructed.
   public function setObjSize(inW:Float,inH:Float) : DisplayLayout
   {
      mOWidth = inW;
      mOHeight = inH;
      return this;
   }

   // DisplayLayout
   public override function getMinSize(?inWidth:Null<Float>) : Size
   {
      return bestDefault(new Size(minWidth>=0 ? minWidth : mOWidth + borderLeft + borderRight,
                                 minHeight>=0 ? minHeight : mOHeight + borderTop + borderBottom));
   }

   public override function setBestWidth(inW:Float)
   {
     mOWidth = inW - borderLeft - borderRight;
     return this;
   }

   public override function setBestHeight(inH:Float)
   {
     mOHeight = inH - borderTop - borderBottom;
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
      if (debug)
         trace('DisplayLayout $name setRect($inX,$inY,$inW,$inH) min=${getMinSize()}');

      var w = inW - borderLeft - borderRight;
      var x = mOX + inX + borderLeft;
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

      var h = inH - borderTop - borderBottom;
      var y = mOY + inY + borderTop;
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
      var w = bestWidth!=null ? bestWidth : mOWidth + borderLeft + borderRight;
      return clampBestWidth(w);
   }

   // DisplayLayout
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var h = bestHeight!=null ? bestHeight : mOHeight + borderTop + borderBottom;
      return clampBestHeight(h, inWidth);
   }

   override public function toString() return 'DisplayLayout($name : $mObj)';
}
