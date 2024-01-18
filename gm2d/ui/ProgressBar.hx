package gm2d.ui;
import gm2d.skin.Skin;


class ProgressBar extends Widget
{
   var mMax:Float;
   var mFraction:Float;

   public function new(?inSkin:Skin, inMax:Float, ?inAttribs:{})
   {
      super(["ProgressBar"], inAttribs);
      mMax = inMax;
      mFraction = 0.0;
      //build();
   }

   public function update(inValue:Float)
   {
      mFraction = inValue / mMax;
      if (mFraction>1) mFraction = 1;
      if (mFraction<0) mFraction = 0;
      redraw();
   }

   override public function redraw()
   {
      skin.renderProgressBar(graphics,mRect.width,mRect.height,mFraction);
   }

}

