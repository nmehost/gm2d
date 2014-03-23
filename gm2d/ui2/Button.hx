package gm2d.ui2;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.text.TextField;
import nme.geom.Rectangle;
import gm2d.ui2.Layout;
import gm2d.ui2.SkinItem;




class Button extends Widget
{
   var isToggle:Bool;

   public function new( ?attribs : Dynamic, inContext="")
   {
      super(attribs, inContext);
      isToggle = skin.getBoolDefault("isToggle",false);
      addEventListener(MouseEvent.MOUSE_DOWN, onDown );
      addEventListener(MouseEvent.MOUSE_UP, onUp );
      addEventListener(MouseEvent.CLICK, onClick );
   }

   function onClick(e:MouseEvent)
   {
      if (!isToggle)
      {
         var callbackFunc = skin.getAttribute("callback");
         if (callbackFunc!=null)
            callbackFunc();
      }
   }
   function onDown(e:MouseEvent)
   {
      if (isToggle)
      {
         down = !down;
         var callbackFunc = skin.getAttribute("callback");
         if (callbackFunc!=null)
            callbackFunc();
      }
      else
         down = true;
   }
   function onUp(e:MouseEvent)
   {
      if (!isToggle)
         down = false;
   }


   override public function activate(inDirection:Int)
   {
      if (inDirection>=0)
      {
        if (isToggle)
           down = !down;
        var callbackFunc = skin.getAttribute("callback");
        if (callbackFunc!=null)
           callbackFunc();
      }
   }
 

   public static function BMPButton(inBitmapData:BitmapData,inX:Float=0, inY:Float=0,?inOnClick:Void->Void)
   {
      return new Button( {x:inX, y:inY, item:ITEM_BITMAPDATA(inBitmapData), callback:inOnClick } );
   }

   public static function BitmapButton(inBitmapData:BitmapData,?inOnClick:Void->Void)
   {
      return new Button( { item:ITEM_BITMAPDATA(inBitmapData), callback:inOnClick } );
   }

   public static function TextButton(inText:String,inOnClick:Void->Void)
   {
      return new Button( { text:inText, callback:inOnClick } );
   }

   public static function BMPTextButton(inBitmapData:BitmapData,inText:String, ?inOnClick:Void->Void)
   {
      return new Button( { text:inText, item:ITEM_BITMAPDATA(inBitmapData), callback:inOnClick } );
   }

}

#if 0
class BmpButton extends Button
{
   public var bitmap(default,null):Bitmap;
   public var normal:BitmapData;
   public var disabled:BitmapData;

   public function new(inBitmapData:BitmapData,?inOnClick:Void->Void)
   {
      normal = inBitmapData;
      bitmap = new Bitmap(normal);
      super(bitmap,inOnClick);
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

   public function enable(inEnable:Bool)
   {
      mouseEnabled = inEnable;
      if (inEnable)
         bitmap.bitmapData = normal;
      else
      {
         if (disabled==null)
            disabled = createDisabled(normal);
         bitmap.bitmapData = disabled;
      }
   }
}

#end
