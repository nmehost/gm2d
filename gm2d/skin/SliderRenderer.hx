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

   public dynamic function onCreate(inSlider:Slider):Void
   {
      var layout = inSlider.getLayout();
      layout.setMinSize(120,20);

      inSlider.mThumb = new Sprite();
      var gfx = inSlider.mThumb.graphics;
      gfx.beginFill(Skin.current.controlColor);
      gfx.lineStyle(1,Skin.current.controlBorder);
      gfx.drawRect(-10,0,20,20);

      layout.onLayout = function(inX:Float,inY:Float,inW:Float,inH:Float)
      {
          this.onRender( inSlider, new Rectangle(inX,inY,inW,inH) );
          this.onPosition(inSlider);
      };
   }

   public dynamic function onRender(inSlider:Slider, inRect:Rectangle):Void
   {
      inSlider.mX0 = 10;
      inSlider.mX1 = inRect.width-10;

      var gfx = inSlider.mTrack.graphics;
      gfx.beginFill(Skin.current.disableColor);
      gfx.lineStyle(1,Skin.current.controlBorder);
      gfx.drawRect(10,0,inRect.width-20,inRect.height);

   }
   public dynamic function onPosition(inSlider:Slider):Void
   {
      inSlider.mThumb.x = inSlider.mX0 + (inSlider.mX1-inSlider.mX0) *
             (inSlider.mValue - inSlider.mMin) /
                    (inSlider.mMax-inSlider.mMin);
   }


/*
   public static function fromSvg(inSvg:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSvg,inLayer);

      var interior = renderer.getMatchingRect(Skin.svgInterior);
      var bounds = renderer.getMatchingRect(Skin.svgBounds);
      if (bounds==null)
         bounds = renderer.getExtent(null, null);
      if (interior==null)
         interior = bounds;
      var scaleRect = Skin.getScaleRect(renderer,bounds);

      var result = new FrameRenderer();
      result.render = function(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void
      {
         //trace("Rect: " + inRect);
         //trace("bounds: " + bounds);
         //trace("interior: " + interior);
         //trace("scale: " + scaleRect);
         var gfx = outChrome.graphics;
         var matrix = new Matrix();
         matrix.tx = inRect.x-(bounds.x);
         matrix.ty = inRect.y-(bounds.y);
         if (scaleRect!=null)
         {
            var extraX = inRect.width-(bounds.width-scaleRect.width);
            var extraY = inRect.height-(bounds.height-scaleRect.height);
            //trace("Add " + extraX + "x" + extraY );
            renderer.render(gfx,matrix,null,scaleRect, extraX, extraY );
         }
         else
            renderer.render(gfx,matrix);

         if (gm2d.Lib.isOpenGL)
            outChrome.cacheAsBitmap = true;
      };
      result.createLayout = function(inInteriorLayout:Layout)
      {
         var layout = new StackLayout();
         layout.setBorders(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.right-interior.right, bounds.bottom-interior.bottom );
         layout.minWidth = bounds.width;
         layout.minHeight = bounds.height;
         layout.add(inInteriorLayout);
         return layout;
      };

      return result;
   }
*/
}


