import gm2d.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.blit.Grid;
import gm2d.Game;
import gm2d.Screen;
import gm2d.ui.Button;
import gm2d.ui.Keyboard;
import gm2d.events.MouseEvent;
import gm2d.ui.BitmapFont;
import gm2d.ui.BitmapText;
import gm2d.display.Bitmap;
import gm2d.display.BitmapData;
import gm2d.geom.Rectangle;
import gm2d.text.TextFieldType;


class BitmapFont extends Screen
{
   function new()
   {
      super();

      makeCurrent();

      var bmp:BitmapData = ApplicationMain.getAsset("Edmunds.png");
      var font = gm2d.ui.BitmapFont.createFromActiveRects(bmp,0x20);
      font.packing = -3;

      var text = new BitmapText(font,"Hello from the bitmap font");
      text.layout(200,font.height);
      text.x = 100;
      text.y = 100;
      text.type = TextFieldType.INPUT;
      addChild(text);

      var font = gm2d.ui.BitmapFont.create("edmunds", 48, 0xffffff);

      var text = new BitmapText(font,"Hello2");
      text.layout(400,font.height);
      text.x = 10;
      text.y = 200;
      text.type = TextFieldType.INPUT;
      addChild(text);
   }

   override public function updateDelta(inDT:Float)
   {
   }


   static public function main()
   {
      //Game.showFPS = true;
      Game.fpsColor = 0x000000;
      Game.backgroundColor = 0x400000;
      new BitmapFont();
   }
}

