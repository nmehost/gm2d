package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.ui.Keyboard;
import gm2d.ui.Button;
import gm2d.skin.Skin;

class TextInput extends Control
{
   public var text(get_text,set_text):String;
   var mText:TextField;
   var mWidth:Float;
   static var boxHeight = 22;

   public function new(inVal="", ?onUpdate:String->Void)
   {
       super();
       mText = new TextField();
       mText.defaultTextFormat = Skin.current.textFormat;
       mText.text = inVal;
       mText.x = 0.5;
       mText.y = 0.5;
       mText.height = boxHeight-1;
       mText.type = nme.text.TextFieldType.INPUT;

       if (onUpdate!=null)
       {
          var t= mText;
          mText.addEventListener(nme.events.Event.CHANGE, function(_) onUpdate(t.text) );
       }
 
       addChild(mText);
   }

   public function setTextWidth(inW:Float)
   {
      mText.width = inW;
   }

   public function set_text(inText:String)
   {
       mText.text = inText;
       return inText;
   }
   public function parseInt() : Int
   {
      return Std.parseInt( mText.text );
    }

   override public function onCurrentChanged(inCurrent:Bool)
   {
      super.onCurrentChanged(inCurrent);
      if (stage!=null)
         stage.focus = inCurrent ? mText : null;
   }


   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      #if flash
      var code:UInt = event.keyCode;
      #else
      var code:Int = event.keyCode;
      #end

      // Let these ones thought to the keeper...
      if (code==Keyboard.DOWN || code==Keyboard.UP || code==Keyboard.TAB)
         return false;
      return true;
   }


   public function get_text() { return mText.text; }

   public override function layout(inW:Float, inH:Float)
   {
       var gfx = graphics;
       gfx.clear();
       gfx.lineStyle(1,0x808080);
       gfx.beginFill(0xf0f0ff);
       gfx.drawRect(0.5,0.5,inW-1,23);
       gfx.lineStyle();
       mText.width = inW - 2;
       mText.y =  (boxHeight - 2 - mText.textHeight)/2;
       mText.height =  boxHeight-mText.y;
   }

}


