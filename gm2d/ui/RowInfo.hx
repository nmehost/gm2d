package gm2d.ui;

import gm2d.ui.Layout.LayoutList;

class RowInfo
{
   public function new(inStretch:Float)
   {
      mCols = [];
      mStretch = inStretch;
      //mShrink = 0.0;
      mMinHeight = 0.0;
      mShrinkOnly = false;
   }

   public var mCols:LayoutList;
   public var mShrinkOnly:Bool;
   public var mStretch:Float;
   //public var mHeight:Float;
   //public var mShrink:Float;

   // Calculated from children
   public var mMinHeight:Float;
}
