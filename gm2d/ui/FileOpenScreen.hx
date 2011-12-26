package gm2d.ui;

import gm2d.Screen;
import gm2d.ui.Layout;
import gm2d.ScreenScaleMode;
import gm2d.display.Sprite;


class FileOpenScreen extends Screen
{
   var dirButtonContainer:Sprite;
   var dirButtons:Array<Button>;
   var screenLayout:Layout;

   public function new(inMessage:String,inDir:String,inFilter:String)
   {
      super();

      screenLayout = new GridLayout(1,"vlayout");
      var button_layout = new GridLayout(null,"dir button",0);
      button_layout.setSpacing(2,10);
         
      inDir = inDir.split("\\").join("/");
      var parts = inDir.split("/");
      var soFar : Array<String> = [];
      for(part in parts)
      {
         if (part!="" || soFar.length<2)
            soFar.push(part);
         if (part!="")
         {
            var link = soFar.join("/");
            var button = Button.TextButton(part, function() setDir(link), true );
            addChild(button);
            button_layout.add(button.getLayout());
         }
      }
      screenLayout.add(button_layout);
   }

   override public function getScaleMode() : ScreenScaleMode
      { return ScreenScaleMode.TOPLEFT_UNSCALED; }


   public function setDir(inLink:String)
   {
   }

   override public function scaleScreen(inScale:Float)
   {
      screenLayout.setRect(0,0, stage.stageWidth, stage.stageHeight);
   }

}


