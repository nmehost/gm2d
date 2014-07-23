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
   var layout:Layout;

   public function new(inOnChoice:String->Void,?inItemsPerRow:Null<Int>,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
      super(Widget.addLine(inLineage,"ChoiceButtons"), inAttribs);

      group = new RadioGroup<String>(inOnChoice);

      if (!mRenderer.getDefaultBool("overlapped", false ) )
      {
         var grid  = new GridLayout(inItemsPerRow,"button");
         grid.setSpacing(1,1);
         layout = grid;
      }
      else
      {
         var paged = new PagedLayout();
         group.onItem = function(p) {
            paged.setPage(p);
            if (inOnChoice!=null)
               inOnChoice( group.keys[p] );
         };
         layout = paged;
      }

      setItemLayout(layout);
      build();
   }

   public static function create(inOnIndex:Int->Void,inKeys:Array<Dynamic>, inBitmaps:Map<String,BitmapData>, ?inItemsPerRow:Int, ?inAttribs:Dynamic )
   {
      var keys:Array<String> = inKeys.map( function(x) return Std.string(x) );

      var result = new ChoiceButtons( function(x) inOnIndex(Lambda.indexOf(keys,x)), inItemsPerRow,null,inAttribs );

      for(key in keys)
      {
         if (!inBitmaps.exists(key))
            throw "ChoiceButtons : missing bitmap " + key;
         var button = Button.BitmapButton(inBitmaps.get(key),null,["ChoiceButton","SimpleButton"],inAttribs);
         result.add( button, key );
      }
      return result;
   }

   public function add(inButton:Button,?inKey:String)
   {
      addChild(inButton);
      layout.add(inButton.getLayout().pixelAlign());
      if (inKey==null)
         inKey = inButton.getId();
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
