import nme.display.Sprite;
import gm2d.Game;
import gm2d.Screen;
import gm2d.reso.Resources;
import gm2d.svg.SvgRenderer;

import nme.ui.Keyboard;


class Svg extends Screen
{
   var mResources:Hash<Dynamic>;

   function new()
   {
      super();

      var svg = new SvgRenderer(Resources.loadSvg("test.svg"));
      //var shape = svg.createShape();
      var shape = svg.createDisplayTree();
      shape.scaleX = shape.scaleY = 0.25;
      //shape.cacheAsBitmap = true;
      addChild(shape);
      makeCurrent();
   }

   override public function getScaleMode() { return gm2d.ScreenScaleMode.TOPLEFT_SCALED; }

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

