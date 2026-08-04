package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;

class BitmapButton extends Button
{
   public var bitmap(default,null):Bitmap;
   public var normal:BitmapData;
   public var disabledBmp:BitmapData;
   var wasEnabled = true;

   public function new(inBitmapData:BitmapData,?inOnClick:Void->Void,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
      normal = inBitmapData;
      //bitmap = new Bitmap(normal, nme.display.PixelSnapping.AUTO, smooth);
      bitmap = new Bitmap(normal);
      super(bitmap,inOnClick,Widget.addLine(inLineage,"BitmapButton"),inAttribs);
      bitmap.name="BitmapButton";
      bitmap.smoothing = attribBool("smooth",true);
   }

   public function createDisabled(inBmp:BitmapData)
   {
      var w = inBmp.width;
      var h = inBmp.height;
      var result = new BitmapData(w,h,true,gm2d.RGB.CLEAR);

      for(y in 0...h)
         for(x in 0...w)
         {
            var pix:Int = inBmp.getPixel32(x,y);
            var val:Int = (pix&0xff) + ( (pix>>8)&0xff ) + ( (pix>>16)&0xff );
            if (val<255) val=0;
            else if (val>512) val = 255;
            else val = 128;
            val = (val * 0x10101) | (pix&0xff000000);
            result.setPixel32(x,y,val);
         }

      return result;
   }

   override function rebuildState(?wasCurrent:Bool)
   {
      if (wasEnabled!=enabled)
      {
         wasEnabled = enabled;
         mouseEnabled = enabled;

         if (enabled)
            bitmap.bitmapData = normal;
         else
         {
            if (disabledBmp==null)
               disabledBmp = createDisabled(normal);
            bitmap.bitmapData = disabledBmp;
         }
      }
      super.rebuildState(wasCurrent);
   }

   public function enable(inEnable:Bool)
   {
      enabled = inEnable;
   }
}
