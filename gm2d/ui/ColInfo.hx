package gm2d.ui;

class ColInfo
{
   public function new(inStretch:Float)
   {
      mBestWidth = 0;
      mMinSpecWidth = 0;
      mMinWidth = 0;
      mStretch = inStretch;
   }
   public var mStretch:Float;
   public var mMinSpecWidth:Float;

   // Calculated from children
   public var mBestWidth:Float;
   public var mMinWidth:Float;

   public function toString() return 'ColInfo($mBestWidth,$mStretch)';
}
