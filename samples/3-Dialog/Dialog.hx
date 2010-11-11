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

      var loader = new gm2d.reso.Loader();
      loader.loadSVG("bg.svg","background");
      loader.loadSVG("slider.svg","slider");
      loader.Process(onLoaded);
      makeCurrent();
		var s = stage;
		s.addEventListener( MouseEvent.CLICK, function (e)
		{
		   var t : gm2d.display.DisplayObject = e.target;
		   if ( t==s)
            Game.showDialog("Settings");
		} );
   }

   function onLoaded(inResources:Hash<Dynamic>)
   {
      var settings = new gm2d.ui.Dialog(300,200);
      var bg:SVG2Gfx = inResources.get("background");
      settings.SetSVGBackground( bg );

      var panel =settings.panel;

      panel.addLabel("Music Volume");
      var sl:SVG2Gfx = inResources.get("slider");
      panel.addUI(gm2d.ui.Slider.SkinnedSlider(sl,null,0,100,50,OnMusic) );

      var but = Button.TextButton("Ok", function() { Game.closeDialog(); } );
      but.setBackground(bg,100,40);
      panel.addButton(but);

      var but = Button.TextButton("Cancel", function() { Game.closeDialog(); } );
      but.setBackground(bg,100,40);
      panel.addButton(but);

      Game.addDialog("Settings",settings);
      var dlg = Game.showDialog("Settings");
   }

   function OnMusic(inVal) { trace(inVal); }

   override public function updateDelta(inDT:Float)
   {
   }


   static public function main()
   {
      gm2d.Lib.debug = false;
      Game.useHardware = true;
      Game.title = "Dialog";
      Game.showFPS = true;
      Game.fpsColor = 0x000000;
      Game.backgroundColor = 0xa0a0ff;
      Game.iPhoneOrientation = 90;
      Game.create(function() new Dialog());
   }
}

