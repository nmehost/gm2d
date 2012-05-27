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
   public dynamic function updateLayout(ioLayout:Layout):Void { }


   public static function fromSvg(inSvg:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSvg,inLayer);

      var interior = renderer.getMatchingRect(Skin.svgInterior);
      var bounds = renderer.getMatchingRect(Skin.svgBounds);
      if (bounds==null)
         bounds = renderer.getExtent(null, null);
      if (interior==null)
         interior = bounds;
      var scaleInfo = Skin.getScale9(renderer,bounds);

      var result = new FrameRenderer();
      result.render = function(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void
      {
         var gfx = outChrome.graphics;
         var matrix = new Matrix();
         matrix.tx = inRect.x-interior.x;
         matrix.ty = inRect.y-interior.y;
         renderer.render(gfx,matrix,null,scaleInfo.rect);
         if (gm2d.Lib.isOpenGL)
            outChrome.cacheAsBitmap = true;
      };
      result.updateLayout = function(ioLayout:Layout)
      {
         ioLayout.setBorders(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.right-interior.right, bounds.bottom-interior.bottom );
         // TODO - min/fixed size
      };

      return result;
   }
}

