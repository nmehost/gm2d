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
   public var fillStyle:FillStyle;
   public var lineStyle:LineStyle;
   public var textFormat:TextFormat;
   public var offset:Point;
   public var minSize:Size;
   public var minItemSize:Size;
   public var align:Null<Int>;
   public var padding:Rectangle;
   public var margin:Rectangle;


   public function new(?map:Map<String,Dynamic>)
   {
      style = Style.StyleNone;
      textFormat = Skin.textFormat;
      offset = new Point(0,0);
      align = null;

      if (map!=null)
      {
         if (map.exists("offset"))
            offset = map.get("offset");
         if (map.exists("fill"))
            fillStyle = map.get("fill");
         if (map.exists("line"))
            lineStyle = map.get("line");
         if (map.exists("padding"))
            padding = map.get("padding");
         if (map.exists("margin"))
            margin = map.get("margin");
         if (map.exists("textFormat"))
            textFormat = map.get("textFormat");
         if (map.exists("minSize"))
            minSize = map.get("minSize");
         if (map.exists("minItemSize"))
            minSize = map.get("minItemSize");
         if (map.exists("align"))
            align = map.get("align");

         if (map.exists("render"))
             style = Style.StyleCustom(map.get("render"));
         else if (map.exists("style"))
             style = map.get("style");

         if (fillStyle!=null)
         {
            switch(fillStyle)
            {
               case FillStyle.FillBitmap(bmp):
                  var w = bmp.width;
                  var h = bmp.height;
                  if (minSize==null)
                     minSize = new Size(w,h);
                  else
                     minSize = new Size(w>minSize.x ? w : minSize.x ,h>minSize.y ? h : minSize.y);
               default:
            }
         }
      }
   }



   function setFill(inGraphics:Graphics,rect:Rectangle):Bool
   {
      var filled = false;

      if (fillStyle!=null)
      {
          filled = true;
          switch(fillStyle)
          {
             case FillStyle.FillLight:
                inGraphics.beginFill(Skin.guiLight);

             case FillStyle.FillMedium:
                inGraphics.beginFill(Skin.guiMedium);

             case FillStyle.FillDark:
                inGraphics.beginFill(Skin.guiDark);

             case FillStyle.FillDisabled:
                inGraphics.beginFill(Skin.guiDisabled);

             case FillStyle.FillSolid(rgb,a):
                inGraphics.beginFill(rgb,a);

             case FillStyle.FillBitmap(bmp):
                inGraphics.beginBitmapFill(bmp);

             default:
                 filled = false;
          }
      }
      return filled;
   }

   function setLine(inGraphics:Graphics,rect:Rectangle):Bool
   {
      var lined = false;
      if (lineStyle!=null)
      {
         lined = true;
         switch(lineStyle)
         {
            case LineBorder:
               inGraphics.lineStyle(0, Skin.guiBorder);

            case LineSolid( width, rgb, a ):
               inGraphics.lineStyle(width, rgb,a);

            default:
               lined=false;
         }
      }
      return lined;
   }


   public function renderWidget(inWidget:Widget)
   {
      var label = inWidget.getLabel();
      if (label!=null)
         renderLabel(label);

      if (style==StyleNone)
         return;

      var gfx = inWidget.mChrome.graphics;
      var r = inWidget.mRect;
      var lined = setLine(gfx,r);
      var filled = setFill(gfx,r);

      var offset = lined ? 0.5 : 0;

      switch(style)
      {
         case StyleNone:
         case StyleRect:
            if (lined || filled)
               gfx.drawRect(r.x, r.y, r.width, r.height);

         case StyleRoundRect:
            if (lined || filled)
               gfx.drawRoundRect(r.x+offset, r.y+offset, r.width, r.height,
                   Skin.roundRectRad,Skin.roundRectRad);

         case StyleRoundRectRad(rad):
            if (lined || filled)
               gfx.drawRoundRect(r.x+offset, r.y+offset, r.width, r.height, rad,rad);

         case StyleCustom( render ):
            render(inWidget);
            filled = true;
      }

      if (lined || filled)
      {
         gfx.endFill();
         gfx.lineStyle();
      }
   }

   public function renderLabel(label:TextField)
   {
      label.defaultTextFormat = textFormat;
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
         if (margin!=null)
            layout.setBorders(margin.x, margin.y,
               margin.width-margin.x, margin.height-margin.y);
         if (align!=null)
            layout.setAlignment(align);
      }

      var layout = ioWidget.getItemLayout();
      if (layout!=null)
      {
         if (minItemSize!=null)
            layout.setMinSize( minItemSize.x, minItemSize.y );
         if (padding!=null)
            layout.setBorders(padding.x, padding.y,
               padding.width-padding.x, padding.height-padding.y);
      }

   }
}

