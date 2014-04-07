package gm2d.skin;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Graphics;
import nme.text.TextField;
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


class ButtonRenderer
{
   public static function simple( )
   {
      var renderer = new Renderer();
      renderer.padding = new Rectangle(2,2,4,4);
      renderer.offset = new Point(0,0);
      renderer.style = Style.StyleCustom(function(inWidget:Widget)
      {
         var gfx = inWidget.mChrome.graphics;
         gfx.clear();
         if ( (inWidget.state & (Widget.DOWN | Widget.DISABLED)) > 0 )
         {
             gfx.beginFill(inWidget.disabled ? Skin.disableColor : Skin.guiMedium );
             gfx.lineStyle(1,Skin.controlBorder);
             var r = inWidget.mRect;
             gfx.drawRect(r.x+0.5,r.y+0.5,r.width-1,r.height-1);
         }
      });
      return renderer;
   }


   public static function fromSvg( inSvg:Svg,?inLayer:String)
   {
      var renderer = new SvgRenderer(inSvg,inLayer);

      var interior = renderer.getMatchingRect(Skin.svgInterior);
      var bounds = renderer.getMatchingRect(Skin.svgBounds);
      if (bounds==null)
         bounds = renderer.getExtent(null, null);
      if (interior==null)
         interior = bounds;
      var scaleRect = Skin.getScaleRect(renderer,bounds);

      var result = new Renderer();
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
      result.textFormat = LabelRenderer.fromSvg(inSvg, [inLayer, "dialog", null] );


      return result;
   }
}


