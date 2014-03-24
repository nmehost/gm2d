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


class ButtonRenderer extends Renderer
{
   public function new() { super(); downOffset = new Point(1,1);  }

   public var downOffset:Point;

   public override function styleLabel(ioLabel:TextField):Void { Skin.current.styleLabel(ioLabel); }

   public static function simple( )
   {
      var renderer = new ButtonRenderer();
      renderer.updateLayout=function(ioButton) ioButton.getInnerLayout().setBorders(2,2,2,2);
      renderer.downOffset = new Point(0,0);
      renderer.render = function(outChrome:Sprite, inRect:Rectangle, inState:ButtonState)
      {
         var gfx = outChrome.graphics;
         gfx.clear();
         if (inState!=BUTTON_UP)
         {
             gfx.beginFill(inState==BUTTON_DISABLE ? Skin.current.disableColor : Skin.current.guiMedium );
             gfx.lineStyle(1,Skin.current.controlBorder);
             gfx.drawRect(inRect.x+0.5,inRect.y+0.5,inRect.width-1,inRect.height-1);
         }
      }
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

      var result = new ButtonRenderer();

      result.render = function(outChrome:Sprite, inRect:Rectangle, inState:ButtonState)
      {
         outChrome.graphics.clear();
         renderer.renderRect0(outChrome.graphics,null,scaleRect,bounds,inRect);
      };
      result.updateLayout = function(ioButton:Widget)
      {
         //trace("Min Size:" + bounds.width + "x" + bounds.height);
         ioButton.getLayout().setMinSize(bounds.width, bounds.height);
         ioButton.getInnerLayout().setBorders(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.right-interior.right, bounds.bottom-interior.bottom);
      };
      result.styleLabel = LabelRenderer.fromSvg(inSvg, [inLayer, "dialog", null] ).styleLabel;


      return result;
   }
}


