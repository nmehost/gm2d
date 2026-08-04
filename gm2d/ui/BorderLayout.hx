package gm2d.ui;

import nme.display.DisplayObject;

class BorderLayout extends Layout
{
   var mBase:Layout;
   // True when the owning Sprite already carries the absolute offset (via its own x/y),
   // so mBase must be aligned at the local origin instead of being offset again.
   var parentControlsOffset:Bool;

   public function new(inBase:Layout, inParentControlsOffset:Bool)
   {
      mBase = inBase;
      parentControlsOffset = inParentControlsOffset;
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
      return mBase.calcSize( inWidth==null  ? null : inWidth-borderLeft-borderRight,
                             inHeight==null ? null : inHeight-borderTop-borderBottom );
   }
   */

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      if (parentControlsOffset)
         alignChild(mBase, 0, 0, inW-borderLeft-borderRight, inH-borderTop-borderBottom );
      else
         alignChild(mBase, inX+borderLeft, inY+borderTop, inW-borderLeft-borderRight, inH-borderTop-borderBottom );
      super.setRect(inX, inY, inW, inH);
   }

   public override function getBestWidth() : Float
   {
      var w = mBase.getBestWidth() + borderLeft + borderRight;
      if (minWidth>w) return minWidth;
      return w;
   }
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      var h = mBase.getBestHeight(inWidth==null ? null : inWidth-borderLeft-borderRight) + borderTop + borderBottom;
      if (minHeight>h) return minHeight;
      return h;
   }

   public override function setBestWidth(inW:Float) : Layout
   {
      mBase.setBestWidth(inW-borderLeft-borderRight);
      return this;
   }
   public override function setBestHeight(inH:Float) : Layout
   {
      mBase.setBestHeight(inH-borderTop-borderBottom);
      return this;
   }

   // BorderLayout
   override public function setMinWidth(inWidth:Float) : Layout
   {
      super.setMinWidth(inWidth);
      mBase.setMinWidth(inWidth-borderLeft-borderRight);
      return this;
   }

   override public function setMinHeight(inHeight:Float) : Layout
   {
      super.setMinHeight(inHeight);
      mBase.setMinHeight(inHeight-borderTop-borderBottom);
      return this;
   }


   // BorderLayout
   public override function getMinSize(?inWidth:Null<Float>) : Size
   {
      var s = mBase.getMinSize(inWidth==null ? null : inWidth-borderLeft-borderRight);
      if ( (borderLeft+borderRight)==0 && (borderTop+borderBottom)==0 )
         return s;
      return new Size(s.x+borderLeft+borderRight, s.y+borderTop+borderBottom);
   }

   override public function toString() return 'BorderLayout($name : $mBase)';
}
