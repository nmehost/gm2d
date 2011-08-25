package gm2d.ui;

import gm2d.text.TextField;
import gm2d.display.BitmapData;
import gm2d.events.MouseEvent;
import gm2d.ui.Button;


class TextInput extends Control
{
   public var text(getText,setText):String;
   var mText:TextField;
   var mWidth:Float;
   static var boxHeight = 22;

   public function new(inVal="", ?onUpdate:String->Void)
   {
       super();
       mText = new TextField();
       mText.defaultTextFormat = Panel.labelFormat;
       mText.text = inVal;
       mText.x = 0.5;
       mText.y = 0.5;
       mText.height = boxHeight-1;
       mText.type = gm2d.text.TextFieldType.INPUT;

       if (onUpdate!=null)
       {
          var t= mText;
          mText.addEventListener(gm2d.events.Event.CHANGE, function(_) onUpdate(t.text) );
       }
 
       addChild(mText);
   }

   public function setText(inText:String)
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
      stage.focus = inCurrent ? mText : null;
   }


   public override function onKeyDown(event:gm2d.events.KeyboardEvent ) : Bool
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


   public function getText() { return mText.text; }

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


