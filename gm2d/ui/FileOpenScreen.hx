package gm2d.ui;

import gm2d.Screen;
import gm2d.ui.Layout;
import gm2d.text.TextField;
import gm2d.ScreenScaleMode;
import gm2d.display.Sprite;


import gm2d.display.Graphics;
import gm2d.display.Bitmap;
import gm2d.geom.Matrix;

#if cpp
import cpp.FileSystem;
#elseif neko
import neko.FileSystem;
#end

class FileOpenScreen extends Screen
{
   var dirButtonContainer:Sprite;
   var dirButtons:Array<Button>;
   var screenLayout:Layout;
   var message:String;
   var filter:String;

   public function new(inMessage:String,inDir:String,inFilter:String)
   {
      super();
      message = inMessage;
      filter = inFilter;


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

      var files = new Array<String>();
      var dirs = new Array<String>();
      for(item in FileSystem.readDirectory(inDir))
      {
         if (item.substr(0,1)!=".")
         {
            if (FileSystem.isDirectory(inDir + "/" + item))
               dirs.push(item);
            else
               files.push(item);
         }
      }
      dirs.sort(function(a,b) { return a<b ? -1 : 1; } );
      files.sort(function(a,b) { return a<b ? -1 : 1; } );
      for(d in dirs)
         items.addText(d);
      for(f in files)
         items.addText(f);
      
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
      var screen = new FileOpenScreen(message,inLink,filter);
      Game.setCurrentScreen(screen);
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


