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
import gm2d.svg.SvgRenderer;
import gm2d.svg.Svg;


class FrameRenderer
{
   public function new() { titleHeight = 20; borders=5; }

   public dynamic function render(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void { }

   public var titleHeight:Float;
   public var borders:Float;

   public dynamic function createLayout(inInteriorLayout:Layout):Layout
   {
      var layout = new StackLayout();
      layout.add(inInteriorLayout);
      layout.setBorders(borders,borders+titleHeight,borders,borders);
      return layout;
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
}

