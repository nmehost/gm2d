package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;
import gm2d.skin.BitmapStyle;


class Image extends Widget
{
   public var bitmapData(get,set):BitmapData;
   var bitmap:Bitmap;
   // Set by fromStyle, so the bitmap can be re-rendered fresh on every rescale
   var source:BitmapStyle;
   var logicalSize:Int;

   public function new(?skin:Skin, ?inBmp:BitmapData, ?inLineage:Array<String>, ?inAttribs:Attribs)
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
         var itemLayout =  new DisplayLayout(bitmap,align);
         itemLayout.name = "Image Layout";
         setItemLayout(itemLayout);
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

   // Boot skin only matters for this first render - every later rescale runs through
   // onScaleChanged() below, which uses the widget's own `skin` field (kept correct by
   // setSkin()'s propagation), not this fallback.
   public static function fromStyle(inSource:BitmapStyle, inLogicalSize:Int=24, ?inLineage:Array<String>, ?inAttribs:Attribs, ?skin:Skin)
   {
      if (skin==null)
         skin = Skin.getSkin();
      var result = new Image(skin, skin.renderBitmapStyle(inSource,inLogicalSize), inLineage, inAttribs);
      result.source = inSource;
      result.logicalSize = inLogicalSize;
      return result;
   }

   override public function onScaleChanged()
   {
      super.onScaleChanged();
      if (source==null || bitmap==null)
         return;
      bitmapData = skin.renderBitmapStyle(source, logicalSize);
   }

   function get_bitmapData() return bitmap==null ? null : bitmap.bitmapData;
   function set_bitmapData(inData:BitmapData) :BitmapData
   {
      if (bitmap!=null)
      {
         bitmap.bitmapData = inData;
         // DisplayLayout's cached best-size is a one-time snapshot of bitmap.width/height taken
         // when it was constructed - refresh it here so a live bitmap swap (eg. a chrome button
         // redrawing its icon fresh at a new scale via BitmapFactory) is actually reflected in
         // this Image's reserved layout space, not just its pixel content.
         var layout = getItemLayout();
         if (Std.isOfType(layout,DisplayLayout))
            cast(layout,DisplayLayout).setObjSize(bitmap.width, bitmap.height);
      }
      return inData;
   }
}

