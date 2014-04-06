package gm2d.skin;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.events.MouseEvent;
import nme.text.TextFormat;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;

import gm2d.ui.Widget;
import gm2d.ui.WidgetState;
import gm2d.ui.Size;
import gm2d.skin.Style;


class Renderer
{
   public var style:Style;
   public var textFormat:TextFormat;
   public var textColor:Int;
   public var offset:Point;
   public var minSize:Size;
   public var minSizeInner:Size;
   public var padding:Rectangle;
   public var paddingInner:Rectangle;


   public function new()
   {
      style = Style.StyleNone;
      textFormat = null;
      textColor = 0xffffff;
      offset = null;
   }

   public function clone() : Renderer
   {
      var result = new Renderer();
      result.copy(this);
      return result;
   }

   public function copy(inRenderer:Renderer)
   {
      style = inRenderer.style;
      textFormat = inRenderer.textFormat;
      textColor = inRenderer.textColor;
      offset = inRenderer.offset;
      minSize = inRenderer.minSize;
      minSizeInner = inRenderer.minSizeInner;
      padding = inRenderer.padding;
      paddingInner = inRenderer.paddingInner;
   }


   public function getDownOffset() : Point { return new Point(0,0); }

   public function renderWidget(inWidget:Widget)
   {
      var label = inWidget.getLabel();
      if (label!=null)
         renderLabel(label);

      switch(style)
      {
         case StyleNone:
         case StyleShape( fill, line, shape):
         case StyleCustom( render ):
            render(inWidget);
      }
   }
   public function renderLabel(label:TextField)
   {
      label.defaultTextFormat = textFormat;
      label.textColor = textColor;
      if (label.type != nme.text.TextFieldType.INPUT)
      {
         label.autoSize = TextFieldAutoSize.LEFT;
         label.selectable = false;
      }
   }

   public function layoutWidget(ioWidget:Widget)
   {
      var layout = ioWidget.getLayout();
      if (layout!=null)
      {
         if (minSize!=null)
            layout.setMinSize( minSize.x, minSize.y );
         if (padding!=null)
            layout.setBorders(padding.x, padding.y,
               padding.width-padding.x, padding.height-padding.y);
      }

      var layout = ioWidget.getItemLayout();
      if (layout!=null)
      {
         if (minSizeInner!=null)
            layout.setMinSize( minSizeInner.x, minSizeInner.y );
         if (paddingInner!=null)
            layout.setBorders(paddingInner.x, paddingInner.y,
               paddingInner.width-paddingInner.x, paddingInner.height-paddingInner.y);
      }

   }
}

