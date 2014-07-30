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
      var bmp = inBmp;
      if (bmp==null && hasAttrib("bitmap") )
         bmp = attrib("bitmap");
      if (bmp==null && hasAttrib("resource") )
         bmp = nme.Assets.getBitmapData(attrib("resource"));

      if (bmp!=null)
      {
         var bitmap = new Bitmap(bmp, attribBool("smooth", true));
         addChild(bitmap);
         setItemLayout( new DisplayLayout(bitmap) );
      }
      build();
   }
}

