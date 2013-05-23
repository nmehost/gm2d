package gm2d.ui;

import gm2d.text.TextField;
import gm2d.display.BitmapData;
import gm2d.events.MouseEvent;
import gm2d.ui.Button;
import gm2d.ui.Layout;
import gm2d.skin.Skin;

class ChoiceButtons extends Control
{
   var group:RadioGroup<String>;
   var buttonLayout:GridLayout;

   public function new(inOnChoice:String->Void)
   {
      super();
      group = new RadioGroup<String>(inOnChoice);
      buttonLayout = new GridLayout(null,"button");
      buttonLayout.setSpacing(1,1);
   }

   public static function create(inOnIndex:Int->Void,inKeys:Array<Dynamic>, inBitmaps:haxe.ds.StringMap<BitmapData> )
   {
      var keys:Array<String> = inKeys.map( function(x) return Std.string(x) );

      var result = new ChoiceButtons( function(x) inOnIndex(Lambda.indexOf(keys,x)) );
      var renderer = gm2d.skin.ButtonRenderer.simple();
      for(key in keys)
      {
         if (!inBitmaps.exists(key))
            throw "Missing bitmap " + key;
         var button = Button.BitmapButton(inBitmaps.get(key),null, renderer);
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
   public function setState(inKey:String)
   {
      group.setState(inKey);
   }

   public function setIndex(inIndex:Int)
   {
      group.setIndex(inIndex);
   }


   override public function createLayout() : Layout
   {
      var layout = new ChildStackLayout( );
      layout.setBorders(0,0,0,0);
      var meLayout = new DisplayLayout(this).setOrigin(0,0);
      meLayout.mAlign = Layout.AlignLeft | Layout.AlignTop | Layout.AlignPixel;
      layout.add( meLayout );
      layout.add(buttonLayout);
      return layout;
   }


}
