package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.ui.Keyboard;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.Layout;

class TextInput extends TextLabel
{
   public function new(inVal="", ?onUpdate:String->Void,?inLineage:Array<String>)
   {
       super(inVal,Widget.addLine(inLineage,"TextInput"));

       if (onUpdate!=null)
       {
          var t= mText;
          mText.addEventListener(nme.events.Event.CHANGE, function(_) onUpdate(t.text) );
       }
   }

   override public function isInput() : Bool { return true;  }

   public function parseInt() : Int
   {
      return Std.parseInt( mText.text );
    }
}

