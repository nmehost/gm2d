package gm2d.blit;

import gm2d.display.Sprite;
import gm2d.geom.Rectangle;

class Viewport extends Sprite
{
	var mRect:Rectangle;

   public function new(inRect:Rectangle,inClear:Bool=true,inBackground:Int=0xffffff)
	{
	   mRect = inRect.clone();
      #if !flash
		scrollRect = inRect;
	   #end
	}

}

