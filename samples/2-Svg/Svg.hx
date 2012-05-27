import gm2d.display.Sprite;
import gm2d.Game;
import gm2d.Screen;
import gm2d.reso.Resources;
import gm2d.svg.SvgRenderer;

import gm2d.ui.Keyboard;


class Svg extends Screen
{
   var mResources:Hash<Dynamic>;

   function new()
   {
      super();

      var svg = new SvgRenderer(Resources.loadSvg("tiger.svg"));
      var shape = svg.createShape();
      shape.scaleX = shape.scaleY = 0.5;
      shape.cacheAsBitmap = true;
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

