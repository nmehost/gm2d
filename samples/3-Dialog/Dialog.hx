import gm2d.reso.Resources;
import gm2d.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.blit.Grid;
import gm2d.Game;
import gm2d.Screen;
import gm2d.svg.SVG2Gfx;
import gm2d.ui.Button;
import gm2d.ui.Keyboard;
import gm2d.events.MouseEvent;
import gm2d.ui.BitmapFont;
import gm2d.ui.BitmapText;


class Dialog extends Screen
{
   function new()
   {
      super();

      Game.setCurrentScreen(this);


      var panel = new gm2d.ui.Panel("Settings");

      var bg:SVG2Gfx = Resources.loadSvg("bg.svg");
      panel.addLabel("Music Volume");
      var sl:SVG2Gfx =  Resources.loadSvg("slider.svg");
      panel.addUI(gm2d.ui.Slider.SkinnedSlider(sl,null,0,100,50,OnMusic) );

      var but = Button.TextButton("Ok", function() { Game.closeDialog(); } );
      but.setBackground(bg,100,40);
      panel.addButton(but);

      var but = Button.TextButton("Cancel", function() { Game.closeDialog(); } );
      but.setBackground(bg,100,40);
      panel.addButton(but);

      var pane = panel.getPane();
      pane.setMinSize(300,200);
      var settings = new gm2d.ui.Dialog(pane);
      //settings.SetSVGBackground( bg );


      Game.addDialog("Settings",settings);
      var dlg = Game.showDialog("Settings");

      var s = stage;
      s.addEventListener( MouseEvent.CLICK, function (e:MouseEvent)
      {
         var t : gm2d.display.DisplayObject = e.target;
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

