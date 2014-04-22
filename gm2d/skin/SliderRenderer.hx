package gm2d.skin;

import gm2d.ui.HitBoxes;
import nme.filters.BitmapFilter;
import nme.filters.BitmapFilterType;
import nme.filters.DropShadowFilter;
import nme.filters.GlowFilter;
import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Shape;
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;

import nme.display.SimpleButton;
import gm2d.ui.IDockable;
import gm2d.ui.Layout;
import gm2d.ui.Slider;
import gm2d.svg.SvgRenderer;
import gm2d.svg.Svg;


class SliderRenderer
{
   public function new() { }

   public dynamic function onCreate(inSlider:Slider):Void { }
   public dynamic function onRender(inSlider:Slider, inRect:Rectangle):Void { }
   public dynamic function onPosition(inSlider:Slider):Void
   {
      if (inSlider.mThumb!=null)
         inSlider.mThumb.x = inSlider.mX0 + (inSlider.mX1-inSlider.mX0) *
             (inSlider.mValue - inSlider.mMin) /
                    (inSlider.mMax-inSlider.mMin);
   }
 }


