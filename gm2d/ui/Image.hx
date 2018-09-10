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

   public function new(?inBmp:BitmapData, ?inLineage:Array<String>, ?inAttribs:{})
   {
      super(inLineage,inAttribs);
      var bmp = inBmp != null ? inBmp : getBitmap();
      if (bmp!=null)
      {
         bitmap = new Bitmap(bmp, nme.display.PixelSnapping.AUTO, attribBool("smooth", true));
         addChild(bitmap);
         setItemLayout( new DisplayLayout(bitmap) );
      }
      applyStyles();
   }

   public static function fromSvg(resoName:String, inScale = 1.0,?inLineage:Array<String>, ?inAttribs:{})
   {
      var svg = new SvgRenderer(gm2d.reso.Resources.loadSvg(resoName));

      var w = Skin.scale(svg.width*inScale);
      var h = Skin.scale(svg.height*inScale);
      var bmp = new BitmapData(w,h,true, gm2d.RGB.CLEAR );

      var shape = svg.createShape();
      var scaled = new Sprite();
      scaled.addChild(shape);
      shape.scaleX = w/svg.width;
      shape.scaleY = h/svg.height;
      bmp.draw(scaled);

      return new Image(bmp, inLineage, inAttribs);
   }

   function get_bitmapData() return bitmap==null ? null : bitmap.bitmapData;
   function set_bitmapData(inData:BitmapData) :BitmapData
   {
      if (bitmap!=null)
         bitmap.bitmapData = inData;
      return inData;
   }
}

