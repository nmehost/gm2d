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
   public function add(inButton:Button,inKey:String)
   {
      addChild(inButton);
      buttonLayout.add(inButton.getLayout().pixelAlign());
      group.add(inButton,inKey);
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
