package gm2d.ui;

import nme.text.TextField;
import nme.text.TextFormatAlign;
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
   public var onTextPhase:String->Int->Void;
   public var placeholder:String;
   public var placeholderField:TextField;

   var isEditing:Bool;

   public function new(inVal="", ?inOnText:String->Void, ?inOnTextPhase:String->Int->Void, ?inLineage:Array<String>,?inAttribs:Dynamic)
   {
       placeholder = null;
       onTextPhase = inOnTextPhase;
       super(inVal,Widget.addLine(inLineage,"TextInput"),inAttribs);
       placeholder = attribString("placeholder",null);
       wantFocus = true;
       onTextUpdate = inOnText;
       if (onTextUpdate==null)
          onTextUpdate = attribDynamic("onUpdate",null);
       onTextEnter = attribDynamic("onTextEnter",null);
       isEditing = false;

       if (placeholder!=null && mText.text=="")
          setText(inVal);

       mText.addEventListener(nme.events.Event.CHANGE, function(_) textUpdate(mText.text) );
       mText.addEventListener(KeyboardEvent.KEY_DOWN, keyDown );
       mText.addEventListener(MouseEvent.RIGHT_CLICK, onContextMenu );
   }

   function onContextMenu(e:MouseEvent)
   {
      var items = new MenuItem("Text");
      items.add( new MenuItem("Copy", _ -> mText.sendCopy()) );
      items.add( new MenuItem("Paste", _ -> mText.sendPaste()) );

      Game.popup( new PopupMenu(items), e.stageX, e.stageY );
   }

   function alwaysPlaceholder() return mText.text=="";

   function checkPlaceholder()
   {
      var want = false;
      var always = alwaysPlaceholder();
      if (placeholder!="" && placeholder!=null && (always || mText.text==""))
      {
         want = true;
         if (placeholderField==null)
         {
            placeholderField = new TextField();
            addChild(placeholderField);
            var attribs = mAttribs==null ? mAttribs : mAttribs.placeholderAttribs;
            if (attribs==null)
               attribs = mAttribs;
            var renderer = Skin.renderer( always ? ["TextPlaceholderAlways","TextPlaceholder", "TextLabel" ] :
                                            ["TextPlaceholder", "TextLabel"],0,attribs);
            renderer.renderLabel(placeholderField);
         }
/*
         if (always)
         {
            var fmt = placeholderField.defaultTextFormat;
            fmt.align = TextFormatAlign.RIGHT;
            placeholderField.defaultTextFormat = fmt;
         }
*/
         placeholderField.text = placeholder;
         placeholderField.x = mText.x;
         placeholderField.y = mText.y;
         placeholderField.width = mText.width;
         placeholderField.height = mText.height;
         placeholderField.mouseEnabled = false;
      }

      if (!want && placeholderField!=null)
      {
         if (placeholderField.parent!=null)
         {
            removeChild(placeholderField);
         }
         placeholderField = null;
      }
   }

   override public function setText(inText:String) : Void
   {
      mText.text = inText;
      checkPlaceholder();
   }

   override public function set(data:Dynamic)
   {
      if (Std.is(data,String) && data!="")
         setText(data);
   }


   override public function get(inValue:Dynamic) : Void
   {
      if (Reflect.hasField(inValue,name))
         Reflect.setField(inValue, name, getText() );
   }



   override public function redraw()
   {
      super.redraw();
      if (placeholderField!=null && placeholderField.parent!=null)
         placeholderField.parent.removeChild(placeholderField);
      placeholderField = null;
      checkPlaceholder();
   }


   function textUpdate(inValue:String)
   {
      checkPlaceholder();
      if (onTextUpdate!=null)
         onTextUpdate(inValue);

      var phase = Phase.UPDATE;
      if (!isEditing)
         phase |= Phase.BEGIN;
      isEditing = true;

      if (onTextPhase!=null)
         onTextPhase(mText.text, phase);
   }

   function keyDown(e:KeyboardEvent)
   {
      checkPlaceholder();
      if (e.charCode==13)
      {
         if (onTextEnter!=null)
            onTextEnter(mText.text);

         var phase = Phase.END | Phase.UPDATE;
         if (!isEditing)
            phase |= Phase.BEGIN;
         isEditing = false;

         if (onTextPhase!=null)
            onTextPhase(mText.text, phase);
      }
   }

   override public function set_isCurrent(inVal:Bool) : Bool
   {
      if (isEditing && !inVal)
      {
         isEditing = false;
         if (onTextPhase!=null)
            onTextPhase(mText.text, Phase.END );
         if (onTextEnter!=null)
            onTextEnter(mText.text);
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

