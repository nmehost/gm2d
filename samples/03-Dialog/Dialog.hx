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
import gm2d.svg.Svg;


class Dialog extends Screen
{
   function new()
   {
      super();

      Game.setCurrentScreen(this);

      skin.fromSvg(Resources.loadSvg("skin.svg"));

      var panel = new gm2d.ui.Panel("Settings");
      panel.addLabelUI("Music Volume", new Slider(0,100,50,OnMusic) );
      panel.addTextButton("Ok", function() { Game.closeDialog(); } );
      panel.addTextButton("Cancel");
      panel.showDialog();

      stage.addEventListener( MouseEvent.MOUSE_UP, function (e:MouseEvent) {
         if (e.target == stage)
            panel.showDialog();
      } );
   }

   function OnMusic(inVal) trace(inVal);
}


