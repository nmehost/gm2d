import gm2d.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.blit.Grid;
import gm2d.Game;
import gm2d.Screen;

import gm2d.ui.Keyboard;


class Svg extends Screen
{
   var mResources:Hash<Dynamic>;

   function new()
   {
      super();
      var loader = new gm2d.reso.Loader();
      loader.loadSVG("tiger.svg","svg");
      loader.Process(onLoaded);
		cacheAsBitmap = true;
   }

   function onLoaded(inResources:Hash<Dynamic>)
   {
      mResources = inResources;
      var svg:gm2d.svg.SVG2Gfx = mResources.get("svg");

		var shape = svg.CreateShape();
		//shape.cacheAsBitmap = true;
		addChild(shape);

      makeCurrent();
   }

   override public function updateDelta(inDT:Float)
   {
   }


   static public function main()
   {
      Game.showFPS = true;
      Game.fpsColor = 0xffffff;
      new Svg();
   }
}

