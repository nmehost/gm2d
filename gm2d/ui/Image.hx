package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;


class Image extends Control
{

   public function new(?inBmp:BitmapData, ?inLineage:Array<String>, ?inAttribs:{})
   {
      super(inLineage,inAttribs);
      var bmp = inBmp != null ? inBmp : getBitmap();
      if (bmp!=null)
      {
         var bitmap = new Bitmap(bmp, nme.display.PixelSnapping.AUTO, attribBool("smooth", true));
         addChild(bitmap);
         setItemLayout( new DisplayLayout(bitmap) );
      }
      build();
   }
}

