import gm2d.reso.Resources;
import nme.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.blit.Grid;
import gm2d.Game;
import gm2d.Screen;
import gm2d.ui.Button;
import nme.ui.Keyboard;
import nme.events.MouseEvent;
import gm2d.ui.BitmapFont;
import gm2d.ui.BitmapText;
import gm2d.ui.Slider;
import gm2d.skin.Skin;
import gm2d.skin.FrameRenderer;
import gm2d.svg.Svg;


class Dialog extends Screen
{
   function new()
   {
      super();

      Game.setCurrentScreen(this);

      var skin = Resources.loadSvg("skin.svg");
      Skin.fromSvg(skin);

      var panel = new gm2d.ui.Panel("Settings");
     

      panel.addLabel("Music Volume");
      panel.addUI(new Slider(0,100,50,OnMusic) );

      panel.addButton(Button.TextButton("Ok", function() { Game.closeDialog(); } ) );
      panel.addButton(Button.TextButton("Cancel", function() { Game.closeDialog(); } ) );

      var pane = panel.getPane();
      var settings = new gm2d.ui.Dialog(pane);
      Game.addDialog("Settings",settings);
      var dlg = Game.showDialog("Settings");


      var s = stage;
      s.addEventListener( MouseEvent.CLICK, function (e:MouseEvent)
      {
         var t : nme.display.DisplayObject = e.target;
         if (t==s)
            Game.showDialog("Settings");
      } );

   }

   function OnMusic(inVal) { trace(inVal); }

   override public function updateDelta(inDT:Float)
   {
   }


   static public function main()
   {
      //gm2d.Lib.debug = false;
      Game.showFPS = true;
      Game.fpsColor = 0x000000;
      new Dialog();
   }
}

