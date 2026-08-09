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
import gm2d.ui.Layout;
import gm2d.skin.Shape;
import gm2d.skin.BitmapStyle;


class Renderer
{
   // skin/map are the only real state - everything below is a read-only property resolved
   // from them on demand, not cached, since each is read at most a handful of times per
   // widget redraw/layout pass (see individual getters for the one or two spots - textFormat,
   // minSize's fillStyle dependency - that aren't a plain map lookup).
   public var shape(get,never):Shape;
   public var fillStyle(get,never):FillStyle;
   public var lineStyle(get,never):LineStyle;
   public var textFormat(get,never):TextFormat;
   public var offset(get,never):Point;
   public var minSize(get,never):Size;
   public var minItemSize(get,never):Size;
   public var bestWidth(get,never):Null<Float>;
   public var bestHeight(get,never):Null<Float>;
   public var align(get,never):Null<Int>;
   public var itemAlign(get,never):Null<Int>;
   public var textBorder(get,never):Null<Int>;
   public var padding(get,never):Rectangle;
   public var margin(get,never):Rectangle;
   public var filters(get,never):Array<BitmapFilter>;
   public var bitmapStyle(get,never):BitmapStyle;
   public var map:Map<String,Dynamic>;
   var skin:Skin;


   public function new(inSkin:Skin, ?inMap:Map<String,Dynamic>)
   {
      skin = inSkin;
      map = inMap;
   }

   function get_shape():Shape
   {
      if (map!=null && map.exists("shape"))
         return map.get("shape");
      return Shape.ShapeNone;
   }

   function get_fillStyle():FillStyle
   {
      return (map!=null && map.exists("fill")) ? map.get("fill") : null;
   }

   function get_lineStyle():LineStyle
   {
      return (map!=null && map.exists("line")) ? map.get("line") : null;
   }

   // font/fontSize come from the "*" attribSet lineage entry (always present, so
   // map.exists("font")/("fontSize") is guaranteed in practice) - only the colour needs a
   // base here. A "textFormat" override is layered under font/fontSize/textColor/textAlign/bold,
   // so those still apply on top of a supplied override, same as before this was a getter.
   function get_textFormat():TextFormat
   {
      var result = new TextFormat();
      result.color = skin.getTextColour(TextColNormal);
      if (map!=null)
      {
         if (map.exists("textFormat"))
            result = map.get("textFormat");
         if (map.exists("font"))
            result.font = map.get("font");
         if (map.exists("fontSize"))
            result.size = skin.toPixels(map.get("fontSize"));
         if (map.exists("textColor"))
            result.color = skin.getTextColour(map.get("textColor"));
         if (map.exists("textAlign"))
            result.align = map.get("textAlign");
         if (map.exists("bold"))
            result.bold = map.get("bold");
      }
      return result;
   }

   function get_offset():Point
   {
      if (map!=null && map.exists("offset"))
      {
         var o:Point = map.get("offset");
         return o==null ? null : new Point(skin.toPixels(o.x), skin.toPixels(o.y));
      }
      return new Point(0,0);
   }

   // Bumped to at least the fill bitmap's own size when fillStyle is FillBitmap, same as
   // the one-shot check this replaced.
   function get_minSize():Size
   {
      var result:Size = null;
      if (map!=null && map.exists("minSize"))
      {
         var s:Size = map.get("minSize");
         result = s==null ? null : new Size(skin.toPixels(s.x), skin.toPixels(s.y));
      }
      var fs = fillStyle;
      if (fs!=null)
      {
         switch(fs)
         {
            case FillStyle.FillBitmap(bmp):
               var w = bmp.width;
               var h = bmp.height;
               result = result==null ? new Size(w,h) : new Size(w>result.x ? w : result.x, h>result.y ? h : result.y);
            default:
         }
      }
      return result;
   }

   function get_minItemSize():Size
   {
      if (map==null || !map.exists("minItemSize"))
         return null;
      var s:Size = map.get("minItemSize");
      return s==null ? null : new Size(skin.toPixels(s.x), skin.toPixels(s.y));
   }

   function get_bestWidth():Null<Float>
   {
      return (map!=null && map.exists("bestWidth")) ? map.get("bestWidth") : null;
   }

   function get_bestHeight():Null<Float>
   {
      return (map!=null && map.exists("bestHeight")) ? map.get("bestHeight") : null;
   }

   function get_align():Null<Int>
   {
      return (map!=null && map.exists("align")) ? map.get("align") : null;
   }

   function get_itemAlign():Null<Int>
   {
      return (map!=null && map.exists("itemAlign")) ? map.get("itemAlign") : null;
   }

   function get_textBorder():Null<Int>
   {
      return (map!=null && map.exists("textBorder")) ? map.get("textBorder") : null;
   }

   function get_padding():Rectangle
   {
      if (map==null || !map.exists("padding"))
         return null;
      var p = map.get("padding");
      if (p==null)
         return null;
      if (Std.isOfType(p,Rectangle))
      {
         var r:Rectangle = p;
         return new Rectangle(skin.toPixels(r.x), skin.toPixels(r.y), skin.toPixels(r.width), skin.toPixels(r.height));
      }
      var sp = skin.toPixels(p);
      return new Rectangle(sp,sp,sp*2,sp*2);
   }

   function get_margin():Rectangle
   {
      if (map==null || !map.exists("margin"))
         return null;
      var m = map.get("margin");
      if (m==null)
         return null;
      if (Std.isOfType(m,Rectangle))
      {
         var r:Rectangle = m;
         return new Rectangle(skin.toPixels(r.x), skin.toPixels(r.y), skin.toPixels(r.width), skin.toPixels(r.height));
      }
      var sm = skin.toPixels(m);
      return new Rectangle(sm,sm,sm*2,sm*2);
   }

   function get_filters():Array<BitmapFilter>
   {
      if (map==null || !map.exists("filters"))
         return null;
      var fs:FilterSet = map.get("filters");
      return fs==null ? null : skin.getFilterSet(fs);
   }

   function get_bitmapStyle():BitmapStyle
   {
      return (map!=null && map.exists("bitmap")) ? map.get("bitmap") : null;
   }

   public function getDefaultFloat(inName:String, inDefault:Float):Float
   {
      if (map==null || !map.exists(inName))
         return inDefault;
      return map.get(inName);
   }

   // Like getDefaultFloat, but for a logical-unit attrib not extracted by the constructor above -
   // scales the result (map value or default, either way) once, here, at the point of use.
   public function getDefaultScaled(inName:String, inDefault:Float):Float
   {
      return skin.toPixels(getDefaultFloat(inName, inDefault));
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


   public static function setFill(skin:Skin,inGraphics:Graphics,inFillStyle:FillStyle, w:Float, h:Float, x=0.0, y=0.0):Bool
   {
      var filled = false;

      if (inFillStyle!=null)
      {
          filled = true;
          switch(inFillStyle)
          {
             case FillStyle.FillRowOdd:
                var v = skin.getColour("FillRowOdd");
                inGraphics.beginFill(v,((v>>24)&0xff)/255.0);

             case FillStyle.FillRowEven:
                var v = skin.getColour("FillRowEven");
                inGraphics.beginFill(v,((v>>24)&0xff)/255.0);

             case FillStyle.FillRowSelect:
                var v = skin.getColour("FillRowSelect");
                inGraphics.beginFill(v,((v>>24)&0xff)/255.0);

             case FillStyle.FillSolid(rgb,a):
                inGraphics.beginFill(rgb,a);

             case FillStyle.FillTransparent:
                inGraphics.beginFill(0,0);

             case FillStyle.FillBitmap(bmp):
                inGraphics.beginBitmapFill(bmp);

             case FillStyle.FillBitmapStretch(bmp):
                var mtx = new Matrix();
                mtx.createBox(w/bmp.width, h/bmp.height);
                inGraphics.beginBitmapFill(bmp, mtx);

             case FillStyle.FillGradV(rgb0,rgb1,a):
                if (h==0)
                   inGraphics.beginFill(rgb0,a);
                else
                {
                   var mtx = new Matrix();
                   mtx.createGradientBox(w,h,Math.PI*0.5);
                   inGraphics.beginGradientFill(LINEAR, [rgb0,rgb1], [a,a], [0,255], mtx );
                }

             case FillStyle.FillGradH(rgb0,rgb1,a):
                if (w==0)
                   inGraphics.beginFill(rgb0,a);
                else
                {
                   var mtx = new Matrix();
                   mtx.createGradientBox(w,h);
                   inGraphics.beginGradientFill(LINEAR, [rgb0,rgb1], [a,a], [0,255], mtx );
                }
             case FillNone:
                 filled = false;

             default:
                inGraphics.beginFill(skin.getFillColour(inFillStyle));
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
            case LineSolid( width, rgb, a ): return width==0 ? 1 : width;
            case LineSolidFill( width, fill, a ): return width==0 ? 1 : width;
            default: return 1;
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

            case LineSolid( width, rgb, a ):
               inGraphics.lineStyle(width, rgb,a, false, CapsStyle.SQUARE, joint);
               return width*0.5;

            case LineSolidFill( width, fill, a ):
               inGraphics.lineStyle(width, skin.getFillColour(fill), a, false, CapsStyle.SQUARE, joint);
               return width*0.5;

            default:
               inGraphics.lineStyle(0, skin.getLineColour(inLineStyle), joint);
               return 0.5;
         }
      }
      return 0.0;
   }

   public function renderWidget(inWidget:Widget)
   {
      var label = inWidget.getLabel();
      if (label!=null)
      {
         renderLabel(label);
         // TextLayout.getBestWidth()/getMinSize() read a cached measurement (mOWidth/mOHeight)
         // taken once at construction, not the TextField live - renderLabel() may just have
         // changed the font/size (eg. a skin change), so the cache needs refreshing here or
         // every text label silently keeps its construction-time best/min size forever.
         inWidget.getItemLayout()?.findTextLayout()?.updateSizeFromText();
      }
      inWidget.filters = filters;
      if (map!=null && map.exists("chromeFilters"))
      {
         var fs:FilterSet = map.get("chromeFilters");
         inWidget.mChrome.filters = fs==null ? null : skin.getFilterSet(fs);
      }
      else
          inWidget.mChrome.filters = null;


      var s = shape;
      if (s==ShapeNone)
         return;

      var gfx = inWidget.mChrome.graphics;
      var r = s==ShapeItemRect ? inWidget.getItemRect() : inWidget.mRect;
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
      gfx.beginBitmapFill(bmp, null, false, true);
      gfx.drawTriangles(vertices, getIndices(), uvtData);
   }


   public function isRectRender()
   {
      var s = shape;
      return s!=null && switch(s)
      {
         case ShapeRect, ShapeRoundRect, ShapeRoundRectRad(_) : true;
         default: false;
      }
   }

   public function renderRect(widget:Widget, gfx:Graphics, r:Rectangle)
   {
      var s = shape;
      if (s==null)
         return;

      var lineOffset = 0.0;
      var filled = false;
      var w = widget==null ? r.width : widget.layoutWidth;
      var h = widget==null ? r.height : widget.layoutHeight;

      switch(s)
      {
         case ShapeNone:
         case ShapeRect, ShapeItemRect:
            lineOffset = setLine(skin, gfx,lineStyle,true);
            filled = setFill(skin, gfx,fillStyle,w,h,r.x,r.y);
            if (lineOffset>0 || filled)
               gfx.drawRect(r.x+lineOffset, r.y+lineOffset, r.width-lineOffset*2, r.height-lineOffset*2);

         case ShapeRoundRect:
            lineOffset = setLine(skin, gfx,lineStyle);
            filled = setFill(skin, gfx,fillStyle,w,h,r.x,r.y);
            if (lineOffset>0 || filled)
            {
               gfx.drawRoundRect(r.x+lineOffset, r.y+lineOffset, r.width-lineOffset*2, r.height-lineOffset*2,
                   skin.roundRectRad*2,skin.roundRectRad*2);
            }

         case ShapeUnderlineRect:
            if (setFill(skin, gfx,fillStyle,w,h,r.x,r.y))
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
            filled = setFill(skin, gfx,fillStyle,w,h,r.x,r.y);
            if (lineOffset>0 || filled)
            {
               var radPx = skin.toPixels(rad);
               gfx.drawRoundRect(r.x+lineOffset, r.y+lineOffset, r.width-lineOffset*2, r.height-lineOffset*2, radPx*2,radPx*2);
            }

         case ShapeCustom( render ):
            lineOffset = setLine(skin, gfx,lineStyle);
            filled = setFill(skin, gfx,fillStyle, w,h, r.x,r.y);
            if (widget==null)
               throw "Invalid custom renderer on non-widget";
            render(widget);
            filled = true;

         case ShapeScale9(bmp, inner, scale ):
            renderScale9(gfx, r, bmp, inner, scale);
            filled = true;

         case ShapeShadowRect(depth,flags):
            var shadow = skin.shadowCache.create(skin, lineStyle, fillStyle, depth, flags, 0.0 );
            if (shadow!=null)
            {
               renderScale9(gfx, r, shadow.bmp, shadow.inner, 1.0);
               filled = true;
            }

         case ShapeRectFlags(flags):
            var shadow = skin.shadowCache.create(skin, lineStyle, fillStyle, 0, flags | EdgeFlags.Rect, 0.0 );
            if (shadow!=null)
            {
               renderScale9(gfx, r, shadow.bmp, shadow.inner, 1.0);
               filled = true;
            }

         case ShapeRoundRectFlags(flags,rad):
            var shadow = skin.shadowCache.create(skin, lineStyle, fillStyle, 0, flags | EdgeFlags.Rect, rad );
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
      var bs = bitmapStyle;
      if (bs==null || inId=="" || inId==null)
         return null;

      switch(bs)
      {
         case BitmapBitmap(bmBitmapData):
            // TODO - disable
            return bmBitmapData;
         case BitmapFactory(factory):
            return factory(skin,inId,inState);
         case BitmapAndDisable(bmp,bmpDisabled):
            return ( (inState&Widget.DISABLED>0) ? bmpDisabled : bmp );
         default:
            // BitmapResource/BitmapRender are size-keyed (resolved via skin.renderBitmapStyle
            // through the "bitmapStyle" attrib, not "bitmap") - not valid here.
            return null;
      }
   }

   public function renderLabel(label:TextField)
   {
      var fmt = textFormat;
      label.defaultTextFormat = fmt;
      label.setTextFormat(fmt);
      var tb = textBorder;
      if (tb!=null)
      {
         label.border = true;
         label.borderColor = tb;
      }
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

         var m = margin;
         if (m!=null)
         {
            layout.setBorders(m.x, m.y, m.width-m.x, m.height-m.y);
         }

         var ms = minSize;
         if (ms!=null)
            layout.setMinSize( ms.x, ms.y );

         var bw = bestWidth;
         if (bw!=null)
            layout.setBestWidth(bw);

         var bh = bestHeight;
         if (bh!=null)
            layout.setBestHeight(bh);

         var a = align;
         if (a!=null)
            layout.setAlignment(a);
      }

      var layout = ioWidget.getItemLayout();
      if (layout!=null)
      {
         if (layout.name==null)
            layout.name = ioWidget.name+":inner";

         var p = padding;
         if (p!=null)
         {
            layout.setBorders(p.x, p.y, p.width-p.x, p.height-p.y);
         }

         var mis = minItemSize;
         if (mis!=null)
            layout.setMinSize( mis.x, mis.y );


         var ia = itemAlign;
         if (ia!=null)
            layout.setAlignment(ia);
         else
            layout.stretch();
      }

   }
}

