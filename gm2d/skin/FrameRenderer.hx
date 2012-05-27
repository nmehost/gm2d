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
import gm2d.svg.SvgRenderer;
import gm2d.svg.Svg;


class FrameRenderer
{
   public function new() { }

   public dynamic function render(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void { }
   public dynamic function getRect(ioRect:Rectangle):Void { }

   public static function fromSVG(inSVG:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSVG,inLayer);

      var all  = renderer.getExtent(null, null);
      var scale9 = renderer.getExtent(null, function(_,groups) { return groups[1]==".scale9"; } );
      var interior = renderer.getExtent(null, function(_,groups) { return groups[1]==".interior"; } );
      var size = renderer.getExtent(null, function(_,groups) { return groups[1]==".size"; } );

      var result = new FrameRenderer();
      result.render = function(outChrome:Sprite, inPane:IDockable, inRect:Rectangle, outHitBoxes:HitBoxes):Void
      {
         var gfx = outChrome.graphics;
         var matrix = new Matrix();
         matrix.tx = inRect.x;
         matrix.ty = inRect.y;
         if (scale9==null)
         {
            var rect = interior==null ? all : interior;
            matrix.a = inRect.width/rect.width;
            matrix.d = inRect.height/rect.height;
         }
         renderer.render(gfx,matrix,null,scale9);
         if (gm2d.Lib.isOpenGL)
            outChrome.cacheAsBitmap = true;
      };
      if (scale9!=null)
        result.getRect = function(ioRect:Rectangle)
        {
           ioRect.x -= all.x;
           ioRect.y -= all.y;
           ioRect.width += all.width;
           ioRect.height += all.height;
        }
      else if (size!=null)
        result.getRect = function(ioRect:Rectangle)
        {
           ioRect.x = size.x;
           ioRect.y = size.y;
           ioRect.width = size.width;
           ioRect.height = size.height;
        }
      return result;
   }
}

