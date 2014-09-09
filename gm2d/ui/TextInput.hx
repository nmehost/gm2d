package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.Layout;

class TextInput extends TextLabel
{
   public var onTextUpdate:String->Void;
   public var onTextEnter:String->Void;
   public var textHandler(default,set):AdoHandler<String>;

   var isEditing:Bool;

   public function new(inVal="", ?inOnText:String->Void,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
       super(inVal,Widget.addLine(inLineage,"TextInput"),inAttribs);
       wantFocus = true;
       onTextUpdate = inOnText;
       isEditing = false;

       mText.addEventListener(nme.events.Event.CHANGE, function(_) textUpdate(mText.text) );
       mText.addEventListener(KeyboardEvent.KEY_DOWN, keyDown );
   }

   function set_textHandler(inHandler:AdoHandler<String>)
   {
      textHandler = inHandler;
      textHandler.updateGui = setText;
      return textHandler;
   }

   function textUpdate(inValue:String)
   {
      if (onTextUpdate!=null)
         onTextUpdate(inValue);
      if (textHandler!=null)
      {
         var phase = Phase.UPDATE;
         if (!isEditing)
            phase |= Phase.BEGIN;
         isEditing = true;
         textHandler.onValue(mText.text, phase);
      }
   }

   function keyDown(e:KeyboardEvent)
   {
      if (e.charCode==13)
      {
         if (onTextEnter!=null)
            onTextEnter(mText.text);

         if (textHandler!=null)
         {
            var phase = Phase.END | Phase.UPDATE;
            if (!isEditing)
               phase |= Phase.BEGIN;
            isEditing = false;
            textHandler.onValue(mText.text, phase);
         }
      }
   }

   override public function set_isCurrent(inVal:Bool) : Bool
   {
      if (isEditing && !inVal)
      {
         isEditing = false;
         textHandler.finishEdit();
      }
      return super.set_isCurrent(inVal);
   }


   public function setOnEnter(inOnEnter:String->Void)
   {
      onTextEnter = inOnEnter;
   }

   public function parseInt() : Int
   {
      return Std.parseInt( mText.text );
    }
}

