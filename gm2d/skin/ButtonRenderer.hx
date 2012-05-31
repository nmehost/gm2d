package gm2d.skin;

import gm2d.display.Bitmap;
import gm2d.display.Sprite;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.text.TextFieldAutoSize;
import gm2d.events.MouseEvent;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import gm2d.geom.Matrix;

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.ui.Layout;
import gm2d.ui.Button;


class ButtonRenderer
{
   public function new() { downOffset=new Point(1,1); }

   public var downOffset:Point;

   public dynamic function render(outChrome:Sprite, inRect:Rectangle, inState:ButtonState):Void { }
   public dynamic function updateLayout(ioButton:Button):Void { }
   public dynamic function styleLabel(ioLabel:TextField):Void { Skin.current.styleLabel(ioLabel); }


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
      result.updateLayout = function(ioButton:Button)
      {
         //trace("Min Size:" + bounds.width + "x" + bounds.height);
         ioButton.getLayout().setMinSize(bounds.width, bounds.height);
         ioButton.getItemLayout().setBorders(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.right-interior.right, bounds.bottom-interior.bottom);
      };
      result.styleLabel = function(ioTextField:TextField)
      {
         //trace("Style : " + ioTextField);
         Skin.current.styleLabel(ioTextField);
      };


      return result;
   }
}


