package gm2d.skin;

import gm2d.ui.HitBoxes;
import nme.filters.BitmapFilter;
import nme.filters.BitmapFilterType;
import nme.filters.DropShadowFilter;
import nme.filters.GlowFilter;
import nme.display.Sprite;
import nme.display.DisplayObject;
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
import gm2d.ui.Widget;
import gm2d.svg.SvgRenderer;
import gm2d.svg.Svg;


class FrameRenderer extends ButtonRenderer
{
   public function new() { super(); titleHeight = 20; borders=5; }


   public dynamic function renderFrame(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void { }
   public var titleHeight:Float;
   public var borders:Float;

   override public function clone()
   {
      var result = new FrameRenderer();
      result.copyButton(this);
      result.renderFrame = renderFrame;
      result.titleHeight = titleHeight;
      result.borders = borders;
      return result;
   }


   override public dynamic function updateLayout(widget:Widget)
   {
      widget.getItemLayout().setBorders(borders,borders+titleHeight,borders,borders);
   }

   override public function renderWidget(inWidget:Widget)
   {
      renderFrame(inWidget.mChrome, inWidget.getPane(), inWidget.mRect, inWidget.getHitBoxes() );
   }
   override public function layoutWidget(ioWidget:Widget)
   {
      updateLayout(ioWidget);
   }


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
      result.renderFrame = function(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void
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
      result.updateLayout = function(widget:Widget)
      {
         var layout = widget.getItemLayout();
         layout.setBorders(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.right-interior.right, bounds.bottom-interior.bottom );
         layout.minWidth = bounds.width;
         layout.minHeight = bounds.height;
      };

      return result;
   }
}

