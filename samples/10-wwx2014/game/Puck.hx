package game;

import nme.display.Shape;
import nme.display.DisplayObjectContainer;

class Puck
{
   var display:Shape;
   public var x:Float;
   public var y:Float;
   public var vx:Float;
   public var vy:Float;

   public function new(parent:DisplayObjectContainer)
   {
      display = new Shape();
      var gfx = display.graphics;
      gfx.beginFill(0x000000);
      gfx.drawCircle( 0, 0, Game.PUCK_RAD );
      parent.addChild(display);

   }

   public function init(inX,inY,inVx,inVy)
   {
      x = inX;
      y = inY;
      vx = inVx;
      vy = inVy;
      updateDisplay();
   }

   public function updateDisplay()
   {
      display.x = x;
      display.y = y;
   }
}
