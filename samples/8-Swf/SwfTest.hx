import gm2d.display.Sprite;
import gm2d.Game;
import gm2d.Screen;
import gm2d.reso.Resources;
import gm2d.swf.SWF;



class SwfTest extends Screen
{
   function new()
   {
      super();

      var test=[ "AdvancedLines", "Text", "GradientFillMotion", "ShapeMorph" ];
      var idx = 0;
      var gfx = graphics;
      gfx.lineStyle(1,0x000000);
      for(y in 0...2)
         for(x in 0...2)
         {
            gfx.drawRect(x*320+1, y*240+1, 318, 238 );
            var data = Resources.loadBytes("tests/" + test[idx++] + ".swf");
            var swf = new SWF(data);
            var obj = swf.createInstance();
            obj.cacheAsBitmap = true;
            obj.x = x*320;
            obj.y = y*240;
            obj.scaleX = 0.5;
            obj.scaleY = 0.5;
            addChild(obj);
         }
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
      new SwfTest();
   }
}

