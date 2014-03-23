package gm2d.ui2;
import gm2d.skin.Skin;


class ProgressBar extends Widget
{
   var mMax:Float;
   var mWidth:Float;
   var mHeight:Float;
   var mFraction:Float;

   public function new(inMax:Float)
   {
      super();
      mMax = inMax;
      mWidth = 100;
      mHeight = 20;
      mFraction = 0.0;
      getLayout().setBestSize(mWidth,mHeight);
   }

   public function update(inValue:Float)
   {
      mFraction = inValue / mMax;
      if (mFraction>1) mFraction = 1;
      if (mFraction<0) mFraction = 0;
      render();
   }

   function render()
   {
      Skin.current.renderProgressBar(graphics,mWidth,mHeight,mFraction);
   }

   override public function layout(inW:Float,inH:Float):Void
   {
      mWidth = inW;
      mHeight = inH;
      render();
   }

}

