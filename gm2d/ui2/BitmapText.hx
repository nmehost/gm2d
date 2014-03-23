package gm2d.ui2;

import nme.text.TextField;
import nme.text.TextFieldType;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.events.MouseEvent;
import gm2d.ui2.Button;
import gm2d.blit.Viewport;
import gm2d.blit.Layer;
import gm2d.blit.Tile;
import gm2d.ui2.SkinItem;
import nme.ui.Keyboard;
import haxe.Timer;


class BitmapText extends Widget
{
   public var bitmapTextField:BitmapTextField;
   public var text(get,set):String;

   public function new(inFont:BitmapFont, inVal="", ?onUpdate:String->Void)
   {
      bitmapTextField = new BitmapTextField(inFont, inVal, onUpdate);
      super( { item:ITEM_OBJECT(bitmapTextField) } );
      wantFocus = bitmapTextField.wantsFocus();
   }


   override function onCurrentChanged(inCurrent:Bool)
   {
      super.onCurrentChanged(inCurrent);
      bitmapTextField.setCurrent(inCurrent);
   }

   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      return bitmapTextField.onKeyDown(event);
   }

   public function get_text() { return bitmapTextField.text; }
   public function set_text(inText:String) { return bitmapTextField.text=inText; }

   override public function onLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      super.onLayout(inX, inY, inW, inH);
      bitmapTextField.setSize(inW,inH);
   }
}


