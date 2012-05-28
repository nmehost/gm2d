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
import gm2d.svg.SvgRenderer;
import gm2d.svg.Svg;


class FrameRenderer
{
   public function new() { }

   public dynamic function render(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void { }
   public dynamic function createLayout(inInteriorLayout:Layout):Layout { return inInteriorLayout; }


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
            renderer.render(gfx,matrix,null,scaleRect, inRect.width-(bounds.width-scaleRect.width), 
                                                    inRect.height-(bounds.height-scaleRect.height) );
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
}

