package gm2d.skin;

import gm2d.ui.HitBoxes;
import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.display.Shape;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.text.TextFieldAutoSize;
import gm2d.events.MouseEvent;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import gm2d.geom.Matrix;

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


   public static function fromSvg(inSvg:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSvg,inLayer);

      var interior = renderer.getMatchingRect(Skin.svgInterior);
      var bounds = renderer.getMatchingRect(Skin.svgBounds);
      var active = renderer.getMatchingRect(Skin.svgActive);
      if (bounds==null)
         bounds = renderer.getExtent(null, null);
      if (interior==null)
         interior = bounds;
      if (active==null)
         active = bounds;
      var scaleRect = Skin.getScaleRect(renderer,bounds);

      var thumb = renderer.hasGroup(".thumb");

      var result = new SliderRenderer();

      result.onCreate = function(inSlider:Slider):Void
      {
         var layout = inSlider.getLayout();
         layout.setMinSize(bounds.width,bounds.height);

         if (thumb)
         {
            inSlider.mThumb = new Sprite();
            var mtx = new Matrix();
            mtx.tx = -bounds.x;
            mtx.ty = -bounds.y;
            renderer.render(inSlider.mThumb.graphics,mtx, function(_,groups) return groups[1]==".thumb" );
         }

         layout.onLayout = function(inX:Float,inY:Float,inW:Float,inH:Float)
         {
            result.onRender( inSlider, new Rectangle(inX,inY,inW,inH) );
            result.onPosition(inSlider);
         };
         if (gm2d.Lib.isOpenGL)
             inSlider.cacheAsBitmap = true;
      };

      result.onRender = function(inSlider:Slider, inRect:Rectangle):Void
      {
         inSlider.mX0 = interior.x - bounds.x;
         inSlider.mX1 = inSlider.mX0 + interior.width + inRect.width-bounds.width;

         var gfx = inSlider.mTrack.graphics;

         renderer.renderRect0(gfx,null,scaleRect,bounds,inRect);
      };

      return result;
   }
}


