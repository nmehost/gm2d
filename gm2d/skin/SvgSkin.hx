package gm2d.skin;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldAutoSize;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.ui.Layout;
import gm2d.ui.Button;
import gm2d.ui.Widget;
import gm2d.ui.Size;
import gm2d.ui.WidgetState;
import gm2d.ui.Slider;


class SvgSkin
{
   public static var svgInterior = ~/\.interior/;
   public static var svgScaleX = ~/\.scaleX/;
   public static var svgScaleY = ~/\.scaleY/;
   public static var svgBounds = ~/\.bounds/;
   public static var svgActive = ~/\.active/;
   public static var svgThumb = ".thumb";


   public static function createButtonRenderer( inSvg:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSvg,inLayer);

      var result:Dynamic = {};

      var interior = renderer.getMatchingRect(svgInterior);
      var bounds = renderer.getMatchingRect(svgBounds);
      if (bounds==null)
         bounds = renderer.getExtent(null, null);
      if (interior==null)
         interior = bounds;
      var scaleRect = getScaleRect(renderer,bounds);

      result.offset = new Point(1,1);

      result.style = Style.StyleCustom(function(inWidget:Widget)
      {
         inWidget.mChrome.graphics.clear();
         renderer.renderRect0(inWidget.mChrome.graphics,null,scaleRect,bounds,inWidget.mRect);
      });
      result.minSize = new Size(bounds.width, bounds.height);
      result.padding = new Rectangle(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.width-interior.width,
                             bounds.height-interior.height);
      result.textFormat = createLabelRenderer(inSvg, [inLayer, "dialog", null] );

      return result;
   }


   public static function createFrameRenderer(inSvg:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSvg,inLayer);

      var interior = renderer.getMatchingRect(svgInterior);
      var bounds = renderer.getMatchingRect(svgBounds);
      if (bounds==null)
         bounds = renderer.getExtent(null, null);
      if (interior==null)
         interior = bounds;
      var scaleRect = getScaleRect(renderer,bounds);

      var result = Skin.renderer(["Frame","Widget"], 0, {
         style: Style.StyleCustom(function(widget:Widget) {
            var gfx = widget.mChrome.graphics;
            var matrix = new Matrix();
            matrix.tx = widget.mRect.x-(bounds.x);
            matrix.ty = widget.mRect.y-(bounds.y);
            if (scaleRect!=null)
            {
               var rect = widget.mRect;
               var extraX = rect.width-(bounds.width-scaleRect.width);
               var extraY = rect.height-(bounds.height-scaleRect.height);
               //trace("Add " + extraX + "x" + extraY );
               renderer.render(gfx,matrix,null,scaleRect, extraX, extraY );
            }
            else
               renderer.render(gfx,matrix);

            if (gm2d.Lib.isOpenGL)
               widget.mChrome.cacheAsBitmap = true;
         }),
         minItemSize: new Size(bounds.width, bounds.height),
         padding: new Rectangle(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.width-interior.width, bounds.height-interior.height )
      } );

      return result;
   }

   public static function createSliderRenderer(inSvg:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSvg,inLayer);

      var interior = renderer.getMatchingRect(svgInterior);
      var bounds = renderer.getMatchingRect(svgBounds);
      var active = renderer.getMatchingRect(svgActive);
      if (bounds==null)
         bounds = renderer.getExtent(null, null);
      if (interior==null)
         interior = bounds;
      if (active==null)
         active = bounds;
      var scaleRect = getScaleRect(renderer,bounds);

      var thumb = renderer.hasGroup(".thumb");

      var result = new SliderRenderer();

      result.onCreate = function(inSlider:Slider):Void
      {
         var layout = inSlider.getItemLayout();
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

   public static function createLabelRenderer(inSvg:Svg, inSearch:Array<String>)
   {
      for(layer in inSearch)
      {
         if (layer==null || inSvg.findGroup(layer)!=null)
         {
            var renderer = new SvgRenderer(inSvg,layer);
            if (renderer.hasGroup(".font"))
            {
               var text = renderer.findText( function(_,groups) { /*trace(groups);*/return groups[1]==".font"; } );
               if (text!=null)
               {
                  var fmt = new TextFormat();
                  fmt.size = text.font_size;
                  fmt.font = text.font_family;
                  switch(text.fill)
                  {
                     case FillSolid(c) : fmt.color = c;
                     default:
                  }
                  return fmt;
               }
            }
         }
      }
      return Skin.textFormat;
   }



   public static function getScaleRect(inRenderer:SvgRenderer, inBounds:Rectangle) : Rectangle
   {
      var scaleX = inRenderer.getMatchingRect(svgScaleX);
      var scaleY = inRenderer.getMatchingRect(svgScaleY);
      if (scaleX==null && scaleY==null)
         return null;
      return  new Rectangle(scaleX==null ? inBounds.x - 1000 : scaleX.x,
                            scaleY==null ? inBounds.y - 1000 : scaleY.y,
                            scaleX==null ? inBounds.width + 2000 : scaleX.width,
                            scaleY==null ? inBounds.height + 2000 : scaleY.height );
   }

}


