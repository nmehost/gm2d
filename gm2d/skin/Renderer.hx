package gm2d.skin;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Graphics;
import nme.display.BitmapData;
import nme.display.CapsStyle;
import nme.display.GradientType;
import nme.display.JointStyle;
import nme.filters.BitmapFilter;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.events.MouseEvent;
import nme.text.TextFormat;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.Vector;

import gm2d.ui.Widget;
import gm2d.ui.WidgetState;
import gm2d.ui.Size;
import gm2d.ui.Button;
import gm2d.ui.Layout;
import gm2d.skin.Shape;
import gm2d.skin.BitmapStyle;


class Renderer
{
   public var shape:Shape;
   public var fillStyle:FillStyle;
   public var lineStyle:LineStyle;
   public var textFormat:TextFormat;
   public var offset:Point;
   public var minSize:Size;
   public var minItemSize:Size;
   public var align:Null<Int>;
   public var itemAlign:Null<Int>;
   public var padding:Rectangle;
   public var margin:Rectangle;
   public var filters:Array<BitmapFilter>;
   public var bitmapStyle:BitmapStyle;
   public var map:Map<String,Dynamic>;
   public var chromeButtons:Array<Button>;
   var skin:Skin;


   public function new(inSkin:Skin, ?inMap:Map<String,Dynamic>)
   {
      skin = inSkin;
      shape = Shape.ShapeNone;
      textFormat = skin.getTextFormat();
      offset = new Point(0,0);
      align = null;
      map = inMap;

      if (map!=null)
      {
         if (map.exists("offset"))
            offset = map.get("offset");
         if (map.exists("fill"))
            fillStyle = map.get("fill");
         if (map.exists("line"))
            lineStyle = map.get("line");
         if (map.exists("padding"))
         {
            var p = map.get("padding");
            if (p==null)
               padding = null;
            else if (Std.isOfType(p,Rectangle))
               padding = p;
            else
               padding = new Rectangle(p,p,p*2,p*2);
         }
         if (map.exists("margin"))
         {
            var m = map.get("margin");
            if (m==null)
               margin = null;
            else if (Std.isOfType(m,Rectangle))
               margin = m;
            else
               margin = new Rectangle(m,m,m*2,m*2);
         }
         if (map.exists("textFormat"))
            textFormat = map.get("textFormat");
         if (map.exists("minSize"))
            minSize = map.get("minSize");
         if (map.exists("minItemSize"))
            minItemSize = map.get("minItemSize");
         if (map.exists("align"))
            align = map.get("align");
         if (map.exists("itemAlign"))
            itemAlign = map.get("itemAlign");
         if (map.exists("font"))
            textFormat.font = map.get("font");
         if (map.exists("fontSize"))
            textFormat.size = map.get("fontSize");
         if (map.exists("textColor"))
            textFormat.color = map.get("textColor");
         if (map.exists("textAlign"))
            textFormat.align = map.get("textAlign");
         if (map.exists("bold"))
            textFormat.bold= map.get("bold");
         if (map.exists("shape"))
             shape = map.get("shape");
         if (map.exists("bitmap"))
             bitmapStyle = map.get("bitmap");
         if (map.exists("filters"))
             filters = map.get("filters");

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

         if (map.exists("chromeButtons"))
         {
            var data:Array<Dynamic> = map.get("chromeButtons");
            if (data!=null && data.length>0)
            {
               var pad = padding==null ? new Rectangle(0,0,0,0) : padding.clone();
               chromeButtons = null;
               for(box in data)
               {
                  var button = new Button(null, null, ["ChromeButton"], box );
                  button.applyStyles();
                  if (chromeButtons==null)
                     chromeButtons = [button];
                  else
                     chromeButtons.push(button);
                  var l = button.getLayout();
                  var s = l.getBestSize();
                  if ( (l.mAlign & Layout.AlignOverlap) == 0)
                  {
                     pad.width += s.x;
                     if ( (l.mAlign & Layout.AlignMaskX)==Layout.AlignLeft )
                        pad.x += s.x;
                  }
               }
               padding = pad;
            }
         }
      }
   }

   public function getDefaultFloat(inName:String, inDefault:Float):Float
   {
      if (map==null || !map.exists(inName))
         return inDefault;
      return map.get(inName);
   }

   public function getDefaultBool(inName:String, inDefault:Bool):Bool
   {
      if (map==null || !map.exists(inName))
         return inDefault;
      return map.get(inName);
   }


   public function getDynamic(inName:String, ?inDefault:Dynamic):Dynamic
   {
      if (map==null || !map.exists(inName))
         return inDefault;
      return map.get(inName);
   }


   public static function setFill(skin:Skin,inGraphics:Graphics,inFillStyle:FillStyle,widget:Widget):Bool
   {
      var filled = false;

      if (inFillStyle!=null)
      {
          filled = true;
          switch(inFillStyle)
          {
             case FillStyle.FillLight:
                inGraphics.beginFill(skin.guiLight);

             case FillStyle.FillMedium:
                inGraphics.beginFill(skin.guiMedium);

             case FillStyle.FillButton:
                inGraphics.beginFill(skin.guiButton);

             case FillStyle.FillDark:
                inGraphics.beginFill(skin.guiDark);

             case FillStyle.FillHighlight:
                inGraphics.beginFill(skin.guiHighlight);

             case FillStyle.FillDisabled:
                inGraphics.beginFill(skin.guiDisabled);

             case FillStyle.FillRowOdd:
                inGraphics.beginFill(skin.rowOddColour,((skin.rowOddColour>>24)&0xff)/255.0);

             case FillStyle.FillRowEven:
                inGraphics.beginFill(skin.rowEvenColour,((skin.rowEvenColour>>24)&0xff)/255.0);

             case FillStyle.FillRowSelect:
                inGraphics.beginFill(skin.rowSelectColour,((skin.rowSelectColour>>24)&0xff)/255.0);

             case FillStyle.FillSolid(rgb,a):
                inGraphics.beginFill(rgb,a);

             case FillStyle.FillTransparent:
                inGraphics.beginFill(0,0);

             case FillStyle.FillBitmap(bmp):
                inGraphics.beginBitmapFill(bmp);

             case FillStyle.FillGradV(rgb0,rgb1,a):
                if (widget==null)
                   inGraphics.beginFill(rgb0,a);
                else
                {
                   var mtx = new Matrix();
                   var w = widget.layoutWidth;
                   var h = widget.layoutHeight;
                   mtx.createGradientBox(w,h,Math.PI*0.5);
                   inGraphics.beginGradientFill(LINEAR, [rgb0,rgb1], [a,a], [0,255], mtx );
                }

             case FillStyle.FillGradH(rgb0,rgb1,a):
                if (widget==null)
                   inGraphics.beginFill(rgb0,a);
                else
                {
                   var mtx = new Matrix();
                   var w = widget.layoutWidth;
                   var h = widget.layoutHeight;
                   mtx.createGradientBox(w,h);
                   inGraphics.beginGradientFill(LINEAR, [rgb0,rgb1], [a,a], [0,255], mtx );
                }
             case FillNone:
                 filled = false;
          }
      }
      return filled;
   }

   public static function getLineWidth(inLineStyle:LineStyle):Float
   {
      if (inLineStyle!=null)
      {
         switch(inLineStyle)
         {
            case LineNone: return 0.0;
            case LineBorder, LineTrim, LineHighlight: return 1;
            case LineSolid( width, rgb, a ): return width==0 ? 1 : width;
         }
      }
      return 0.0;
   }

   public static function setLine(skin:Skin, inGraphics:Graphics,inLineStyle:LineStyle, square=false):Float
   {
      if (inLineStyle!=null)
      {
         var joint = square ? JointStyle.MITER : JointStyle.ROUND;
         joint = JointStyle.MITER;
         switch(inLineStyle)
         {
            case LineNone:
               return 0.0;

            case LineBorder:
               inGraphics.lineStyle(0, skin.guiBorder, joint);
               return 0.5;

            case LineTrim:
               inGraphics.lineStyle(0, skin.guiTrim, joint);
               return 0.5;

            case LineHighlight:
               inGraphics.lineStyle(0, skin.guiHighlight, joint);
               return 0.5;

            case LineSolid( width, rgb, a ):
               inGraphics.lineStyle(width, rgb,a, false, CapsStyle.SQUARE, joint);
               return width*0.5;

            default:
         }
      }
      return 0.0;
   }

   public function renderWidget(inWidget:Widget)
   {
      if (chromeButtons!=null)
      {
         var x0 = inWidget.mRect.x;
         var y0 = inWidget.mRect.y;
         var x1 = x0 + inWidget.mRect.width;
         var y1 = y0 + inWidget.mRect.height;
         for(box in chromeButtons)
         {
            var layout = box.getLayout();
            inWidget.mChrome.addChild(box);
            var id = box.name;
            box.mouseHandler = inWidget.onChromeMouse;
            var xPos = layout.mAlign & Layout.AlignMaskX;
            box.align(x0,y0,x1-x0,y1-y0);
            if ( (layout.mAlign & Layout.AlignOverlap) == 0)
            {
               var s = layout.getBestSize();
               if (xPos==Layout.AlignLeft)
                  x0+=s.x;
               else
                  x1 -= s.x;
            }
         }
      }

      var label = inWidget.getLabel();
      if (label!=null)
         renderLabel(label);
      inWidget.filters = filters;
      if (map!=null && map.exists("chromeFilters"))
          inWidget.mChrome.filters = map.get("chromeFilters");
      else
          inWidget.mChrome.filters = null;


      if (shape==ShapeNone)
         return;

      var gfx = inWidget.mChrome.graphics;
      var r = inWidget.mRect;
      renderRect(inWidget,gfx,r);
   }

   static var sIndices:Vector<Int>;
   static function getIndices()
   {
      if (sIndices==null)
      {
         sIndices = new Vector<Int>(9*2*3);
         var idx = 0;
         for(y in 0...3)
            for(x in 0...3)
            {
               sIndices[idx++] = y*4+x;
               sIndices[idx++] = y*4+x+1;
               sIndices[idx++] = y*4+x+4;

               sIndices[idx++] = y*4+x+1;
               sIndices[idx++] = y*4+x+5;
               sIndices[idx++] = y*4+x+4;
            }
      }
      return sIndices;
   }

   static function renderScale9(gfx:Graphics, r:Rectangle, bmp:BitmapData, inner:Rectangle, scale:Float)
   {
      var w = r.width;
      var h = r.height;
      var bmpW = bmp.width;
      var bmpH = bmp.height;

      if (w<(bmpW-inner.width)*scale && (bmpW>inner.width) )
         scale = w/(bmpW-inner.width);
      if (h<(bmpH-inner.height)*scale && (bmpH>inner.height) )
         scale = h/(bmpH-inner.height);

      var vertices = new Vector<Float>(32);
      var uvtData = new Vector<Float>(32);
      var xVals = [ 0.0, inner.left*scale, w-(bmpW-inner.right)*scale,  w];
      var yVals = [ 0.0, inner.top*scale,  h-(bmpH-inner.bottom)*scale, h];
      var uVals = [ 0.0, inner.left/bmpW,  inner.right/bmpW,            1.0];
      var vVals = [ 0.0, inner.top/bmpH,   inner.bottom/bmpH,           1.0];

      var vid = 0;
      for(y in yVals)
         for(x in xVals)
         {
            vertices[vid++] = x + r.left;
            vertices[vid++] = y + r.top;
         }
      var vid = 0;
      for(v in vVals)
         for(u in uVals)
         {
            uvtData[vid++] = u;
            uvtData[vid++] = v;
         }
      gfx.beginBitmapFill(bmp);
      gfx.drawTriangles(vertices, getIndices(), uvtData);
   }


   public function isRectRender()
   {
      return shape!=null && switch(shape)
      {
         case ShapeRect, ShapeRoundRect, ShapeRoundRectRad(_) : true;
         default: false;
      }
   }

   public function renderRect(widget:Widget, gfx:Graphics, r:Rectangle)
   {
      if (shape==null)
         return;

      var lineOffset = 0.0;
      var filled = false;

      switch(shape)
      {
         case ShapeNone:
         case ShapeRect:
            lineOffset = setLine(skin, gfx,lineStyle,true);
            filled = setFill(skin, gfx,fillStyle,widget);
            if (lineOffset>0 || filled)
               gfx.drawRect(r.x-lineOffset, r.y-lineOffset, r.width+lineOffset*2, r.height+lineOffset*2);

         case ShapeRoundRect:
            lineOffset = setLine(skin, gfx,lineStyle);
            filled = setFill(skin, gfx,fillStyle,widget);
            if (lineOffset>0 || filled)
            {
               gfx.drawRoundRect(r.x-lineOffset, r.y-lineOffset, r.width+lineOffset*2, r.height+lineOffset*2,
                   skin.roundRectRad*2,skin.roundRectRad*2);
            }

         case ShapeUnderlineRect:
            if (setFill(skin, gfx,fillStyle,widget))
            {
               gfx.drawRect(r.x, r.y, r.width, r.height);
               gfx.endFill();
            }
            lineOffset = setLine(skin, gfx,lineStyle,true);
            if (lineOffset>0)
            {
               gfx.moveTo(r.x+lineOffset, r.y+r.height-lineOffset);
               gfx.lineTo(r.x+r.width-lineOffset, r.y+r.height-lineOffset);
            }

         case ShapeRoundRectRad(rad):
            lineOffset = setLine(skin, gfx,lineStyle);
            filled = setFill(skin, gfx,fillStyle,widget);
            if (lineOffset>0 || filled)
               gfx.drawRoundRect(r.x-lineOffset, r.y-lineOffset, r.width+lineOffset*2, r.height+lineOffset*2, rad*2,rad*2);

         case ShapeCustom( render ):
            lineOffset = setLine(skin, gfx,lineStyle);
            filled = setFill(skin, gfx,fillStyle,widget);
            if (widget==null)
               throw "Invalid custom renderer on non-widget";
            render(widget);
            filled = true;

         case ShapeScale9(bmp, inner, scale ):
            renderScale9(gfx, r, bmp, inner, scale);
            filled = true;

         case ShapeShadowRect(depth,flags):
            var shadow = ShadowCache.create(skin, lineStyle, fillStyle, depth, flags, 0.0 );
            if (shadow!=null)
            {
               renderScale9(gfx, r, shadow.bmp, shadow.inner, 1.0);
               filled = true;
            }

         case ShapeRectFlags(flags):
            var shadow = ShadowCache.create(skin, lineStyle, fillStyle, 0, flags | EdgeFlags.Rect, 0.0 );
            if (shadow!=null)
            {
               renderScale9(gfx, r, shadow.bmp, shadow.inner, 1.0);
               filled = true;
            }

         case ShapeRoundRectFlags(flags,rad):
            var shadow = ShadowCache.create(skin, lineStyle, fillStyle, 0, flags | EdgeFlags.Rect, rad );
            if (shadow!=null)
            {
               renderScale9(gfx, r, shadow.bmp, shadow.inner, 1.0);
               filled = true;
            }

      }

      if (lineOffset>0.0 || filled)
      {
         gfx.endFill();
         gfx.lineStyle();
      }
   }

   public function getBitmap(inId:String, inState:Int) : BitmapData
   {
      var icon:BitmapData = getDynamic("icon");
      if (icon!=null)
         return icon;
      if (bitmapStyle==null || inId=="" || inId==null)
         return null;

      switch(bitmapStyle)
      {
         case BitmapBitmap(bmBitmapData):
            // TODO - disable
            return bmBitmapData;
         case BitmapFactory(factory):
            return factory(inId,inState);
         case BitmapAndDisable(bmp,bmpDisabled):
            return ( (inState&Widget.DISABLED>0) ? bmpDisabled : bmp );
      }
   }

   public function renderLabel(label:TextField)
   {
      label.defaultTextFormat = textFormat;
      label.setTextFormat(textFormat);
      if (map.exists("textRotation"))
         label.rotation = map.get("textRotation");
      if (label.type != nme.text.TextFieldType.INPUT)
      {
         //label.autoSize = TextFieldAutoSize.LEFT;
         label.autoSize = TextFieldAutoSize.NONE;
         if (map.exists("selectable"))
            label.selectable = map.get("selectable");
         else
            label.selectable = false;

      }
   }

   public function layoutWidget(ioWidget:Widget)
   {
      var layout = ioWidget.getLayout();
      if (layout!=null)
      {
         if (layout.name==null)
            layout.name = ioWidget.name;
         var lineWidth = isRectRender() ? Std.int(getLineWidth(lineStyle)) : 0;

         if (margin!=null)
         {
            layout.setBorders(margin.x+lineWidth, margin.y+lineWidth,
               margin.width-margin.x + lineWidth, margin.height-margin.y + lineWidth);
         }
         else if (lineWidth>0)
         {
            layout.setBorders(lineWidth, lineWidth, lineWidth, lineWidth);
         }

         if (minSize!=null)
            layout.setMinSize( minSize.x, minSize.y );

         if (align!=null)
            layout.setAlignment(align);
      }

      var layout = ioWidget.getItemLayout();
      if (layout!=null)
      {
         if (layout.name==null)
            layout.name = ioWidget.name+":inner";

         if (padding!=null)
         {
            layout.setBorders(padding.x, padding.y,
               padding.width-padding.x, padding.height-padding.y);
         }

         if (minItemSize!=null)
            layout.setMinSize( minItemSize.x, minItemSize.y );

         if (itemAlign!=null)
            layout.setAlignment(itemAlign);
      }

   }
}

