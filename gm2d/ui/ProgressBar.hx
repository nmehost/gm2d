package gm2d.ui;
import gm2d.skin.Skin;
import gm2d.skin.ProgressStyle;


class ProgressBar extends Widget
{
   var mMax:Float;
   var mFraction:Float;

   public function new(?inSkin:Skin, inMax:Float,?inLineage:Array<String>,?inAttribs:{})
   {
      super(Widget.addLine(inLineage,"ProgressBar"),inAttribs);
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
      var gfx = graphics;

      gfx.clear();
      var stype:ProgressStyle = attribDynamic("progressStyle",null);
      if (stype==null)
         return;
      switch(stype)
      {
        case ProgressRoundRect(outline, fill, empty, lineWidth, rad):
           var w = mRect.width;
           var h = mRect.height;

           var off = (Std.int(lineWidth) & 1) > 0 ? 0.5 : 0.0;
           gfx.beginFill(empty);
           gfx.drawRoundRect(off,off,w,h,rad,rad);
           gfx.lineStyle();
           gfx.beginFill(fill);
           gfx.drawRoundRect(off,off,w*mFraction,h,rad,rad);
           gfx.endFill();
           gfx.lineStyle(lineWidth,outline);
           gfx.drawRoundRect(off,off,w,h,rad,rad);
      }

   }

}

