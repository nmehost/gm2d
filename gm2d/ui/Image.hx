package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;


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

   function get_bitmapData() return bitmap==null ? null : bitmap.bitmapData;
   function set_bitmapData(inData:BitmapData) :BitmapData
   {
      if (bitmap!=null)
         bitmap.bitmapData = inData;
      return inData;
   }
}

