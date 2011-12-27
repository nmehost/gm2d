package gm2d.ui;

import gm2d.Screen;
import gm2d.ui.Layout;
import gm2d.text.TextField;
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


      var top = new GridLayout(1,"vlayout",0);
      top.add(StaticText.createLayout(inMessage,this));
      top.setColStretch(0,1);

      var dir_buttons = new GridLayout(null,"dir button",0).setAlignment(Layout.AlignLeft);
      dir_buttons.setSpacing(2,10);

      inDir = inDir.split("\\").join("/");
      var parts = inDir.split("/");
      var soFar : Array<String> = [];
      for(part in parts)
      {
         if (part!="" || soFar.length<2)
            soFar.push(part);
         if (part!="")
         {
            var spacer = StaticText.createLayout("/",this);
            dir_buttons.add(spacer);
            var link = soFar.join("/");
            var button = Button.TextButton(part, function() setDir(link), true );
            addChild(button);
            dir_buttons.add(button.getLayout());
         }
      }
      top.add(dir_buttons);
      var items = new ListControl();
      addChild(items);
      for(item in ["One", "Two", "Three", "Four"] )
         items.addText(item);
      var layout = items.getLayout();
      layout.mAlign = Layout.AlignStretch;
      top.add(layout);
      top.setRowStretch(2,1);

      var buttons = new GridLayout(null,"buttons",1);
      buttons.setSpacing(10,0);

      var button = Button.TextButton("Ok", null, true );
      addChild(button);
      buttons.add(button.getLayout());

      var button = Button.TextButton("Cancel", null, true );
      addChild(button);
      buttons.add(button.getLayout());

      top.add(buttons);

      screenLayout = top;
   }

   override public function getScaleMode() : ScreenScaleMode
      { return ScreenScaleMode.TOPLEFT_UNSCALED; }


   public function setDir(inLink:String)
   {
   }

   override public function scaleScreen(inScale:Float)
   {
      var gfx = graphics;
      gfx.clear();
      gfx.beginFill(Panel.panelColor);
      gfx.drawRect(0,0, stage.stageWidth, stage.stageHeight);
      screenLayout.setRect(0,0, stage.stageWidth, stage.stageHeight);
   }

}


