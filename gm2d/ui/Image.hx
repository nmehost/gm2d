package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Sprite;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;
import gm2d.svg.SvgRenderer;


class Image extends Widget
{
   public var bitmapData(get,set):BitmapData;
   var bitmap:Bitmap;

   public function new(?skin:Skin, ?inBmp:BitmapData, ?inLineage:Array<String>, ?inAttribs:{})
   {
      super(skin,Widget.addLine(inLineage,"Image"),inAttribs);
      var bmp = inBmp != null ? inBmp : getBitmap();
      if (bmp!=null)
      {
         bitmap = new Bitmap(bmp, nme.display.PixelSnapping.AUTO, attribBool("smooth", true));
         addChild(bitmap);
         var bmpScale = attribFloat("bmpScale",1.0);
         if (bmpScale!=1.0)
            bitmap.scaleX = bitmap.scaleY = bmpScale;
         var align = attribInt("alignBitmap", Layout.AlignGraphcsRect|Layout.AlignKeepAspect );
         setItemLayout( new DisplayLayout(bitmap,align) );
      }
      applyStyles();
   }

/*
   override public function onWidgetDrawn() {
      if (bitmap!=null)
      {
         bitmap.width = mRect.width;
         bitmap.height = mRect.height;
      }
   }
   */

   public static function fromSvg(?skin:Skin,resoName:String, inScale = 1.0,?inLineage:Array<String>, ?inAttribs:{})
   {
      if (skin==null)
         skin = Skin.getSkin();
      var svg = new SvgRenderer(gm2d.reso.Resources.loadSvg(resoName));

      var w = skin.scale(svg.width*inScale);
      var h = skin.scale(svg.height*inScale);
      var bmp = new BitmapData(w,h,true, gm2d.RGB.CLEAR );

      var shape = svg.createShape();
      var scaled = new Sprite();
      scaled.addChild(shape);
      shape.scaleX = w/svg.width;
      shape.scaleY = h/svg.height;
      bmp.draw(scaled);

      return new Image(skin, bmp, inLineage, inAttribs);
   }

   function get_bitmapData() return bitmap==null ? null : bitmap.bitmapData;
   function set_bitmapData(inData:BitmapData) :BitmapData
   {
      if (bitmap!=null)
         bitmap.bitmapData = inData;
      return inData;
   }
}

