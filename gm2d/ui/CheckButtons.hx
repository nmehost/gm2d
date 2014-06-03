package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Shape;
import nme.display.Sprite;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.WidgetState;


class CheckButtons extends ChoiceButtons
{
   var onCheck:Bool->Void;
   public function new(inValue:Bool, inCheck:Bool->Void, ?inAttribs:Dynamic)
   {
      onCheck = inCheck;
      super(onButton,null, inAttribs);
      add(new Button(null,null,["ToggleButton","SimpleButton"],{id:"#checked"}) );
      add(new Button(null,null,["ToggleButton","SimpleButton"], { id:"#unchecked"} ) );

      setChecked(inValue);
      build();
   }
   function onButton(inKey:String) { if (onCheck!=null) onCheck(inKey=="#checked"); }

   public function setChecked(inCheck:Bool)
   {
      setValue(inCheck?"#checked":"#unchecked");
   }
}

