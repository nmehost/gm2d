package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import gm2d.ui.Button;
import gm2d.ui.Layout;
import gm2d.skin.Skin;

class ChoiceButtons extends Control
{
   var group:RadioGroup<String>;
   var buttonLayout:GridLayout;

   public function new(inOnChoice:String->Void,?inItemsPerRow:Null<Int>)
   {
      super();
      group = new RadioGroup<String>(inOnChoice);
      buttonLayout = new GridLayout(inItemsPerRow,"button");
      buttonLayout.setSpacing(1,1);


      setItemLayout(buttonLayout);
      build();
   }

   public static function create(inOnIndex:Int->Void,inKeys:Array<Dynamic>, inBitmaps:haxe.ds.StringMap<BitmapData>, ?inItemsPerRow:Int )
   {
      var keys:Array<String> = inKeys.map( function(x) return Std.string(x) );

      var result = new ChoiceButtons( function(x) inOnIndex(Lambda.indexOf(keys,x)), inItemsPerRow );

      for(key in keys)
      {
         if (!inBitmaps.exists(key))
            throw "Missing bitmap " + key;
         var button = Button.BitmapButton(inBitmaps.get(key),null,["ChoiceButton","SimpleButton"]);
         result.add( button, key );
      }
      return result;
   }

   public function add(inButton:Button,inKey:String)
   {
      addChild(inButton);
      buttonLayout.add(inButton.getLayout().pixelAlign());
      group.add(inButton,inKey);
   }
   public function setValue(inKey:String)
   {
      group.setState(inKey);
   }

   public function setIndex(inIndex:Int)
   {
      group.setIndex(inIndex);
   }

}
