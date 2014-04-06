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
import gm2d.ui.WidgetState;


class ButtonRenderer extends Renderer
{
   public dynamic function updateLayout(ioWidget:Widget):Void { }
   public dynamic function styleLabel(ioLabel:TextField):Void { Skin.current.styleLabel(ioLabel); }
   public var downOffset:Point;


   public function new() { super(); downOffset = new Point(1,1);  }

   override public function clone() : Renderer
   {
      var result = new ButtonRenderer();
      result.copyButton(this);
      return result;
   }

   public function copyButton(inRenderer:ButtonRenderer)
   {
      copy(inRenderer);
      downOffset = inRenderer.downOffset.clone();
      updateLayout = inRenderer.updateLayout;
      styleLabel = inRenderer.styleLabel;
   }


   override public function getDownOffset() : Point { return downOffset; }

/*
   override public function renderWidget(inWidget:Widget)
   {
      var tf = inWidget.getLabel();
      if (tf!=null)
         renderLabel(tf);
      render(inWidget);
   }
*/
   override public function layoutWidget(ioWidget:Widget)
   {
      updateLayout(ioWidget);
   }

   override public function renderLabel(ioTextField:TextField) { styleLabel(ioTextField); }


   public static function simple( )
   {
      var renderer = new ButtonRenderer();
      renderer.updateLayout=function(ioButton) ioButton.getLayout().setBorders(2,2,2,2);
      renderer.downOffset = new Point(0,0);
      renderer.style = Style.StyleCustom(function(inWidget:Widget)
      {
         var gfx = inWidget.mChrome.graphics;
         gfx.clear();
         if (inWidget.mState!=WidgetNormal)
         {
             gfx.beginFill(inWidget.mState==WidgetDisabled ? Skin.current.disableColor : Skin.current.guiMedium );
             gfx.lineStyle(1,Skin.current.controlBorder);
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

      var result = new ButtonRenderer();

      result.style = Style.StyleCustom(function(inWidget:Widget)
      {
         inWidget.mChrome.graphics.clear();
         renderer.renderRect0(inWidget.mChrome.graphics,null,scaleRect,bounds,inWidget.mRect);
      });
      result.updateLayout = function(ioButton:Widget)
      {
         //trace("Min Size:" + bounds.width + "x" + bounds.height);
         ioButton.getLayout().setMinSize(bounds.width, bounds.height);
         var inner = ioButton.getItemLayout();
         if (inner!=null)
            inner.setBorders(interior.x-bounds.x, interior.y-bounds.y,
                             bounds.right-interior.right, bounds.bottom-interior.bottom);
      };
      result.styleLabel = LabelRenderer.fromSvg(inSvg, [inLayer, "dialog", null] ).styleLabel;


      return result;
   }
}


