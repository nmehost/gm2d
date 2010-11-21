package gm2d.ui;

import gm2d.geom.Rectangle;
import gm2d.geom.Point;
import gm2d.display.Bitmap;

class ResizeFlag
{
   public static inline var E = 0x0010;
   public static inline var W = 0x0020;
   public static inline var N = 0x0040;
   public static inline var S = 0x0080;
}

class MiniButton
{
   public static inline var CLOSE    = 0;
   public static inline var MINIMIZE = 1;
   public static inline var MAXIMIZE = 2;

   public static inline var COUNT = 3;
}

enum HitAction
{
   NONE;
   DRAG;
   REDRAW;
   BUTTON(pane:Pane,button:Int);
}

class HitBox
{
   public function new(inRect:Rectangle, inAction:HitAction)
   {
      rect = inRect;
      action = inAction;
   }
   public var rect:Rectangle;
   public var action:HitAction;
}

class HitBoxes
{
   public static var BUT_STATE_UP = 0;
   public static var BUT_STATE_OVER = 1;
   public static var BUT_STATE_DOWN = 2;

   public var buttonState:Array<Int>;
   public var bitmaps:Array<Bitmap>;

   var rects:Array<HitBox>;


   public function new()
   {
      rects = [];
      buttonState = [0,0,0];
      bitmaps = [];
   }
   public function clear() { rects = []; }

   public function add(rect:Rectangle, action:HitAction)
   {
      rects.push( new HitBox(rect,action) );
   }

	function buttonID(inAction:HitAction) : Int
	{
	   switch(inAction)
		{
			case BUTTON(_,id): return id;
			default:
		}
		return -1;
	}

   public function onDown(inX:Float, inY:Float) : HitAction
   {
      for(r in rects)
         if (r.rect.contains(inX,inY))
			   switch(r.action)
				{
				   case BUTTON(pane,id) :
                  buttonState[id] = BUT_STATE_DOWN;
                  return HitAction.REDRAW;
					default:
                  return r.action;
            }

      return HitAction.NONE;
   }


   public function onUp(inX:Float, inY:Float) : HitAction
   {
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
			   switch(r.action)
				{
				   case BUTTON(pane,id):
                  if (buttonState[id]==BUT_STATE_DOWN)
                  {
                     buttonState[id]=BUT_STATE_OVER;
                     return r.action;
                  }
				   default:
            }
         }
      return HitAction.NONE;
   }


   public function onMove(inX:Float, inY:Float) : Bool
   {
      var result = false;
      var on = -1;

      for(i in 0...rects.length)
         if (rects[i].rect.contains(inX,inY))
         {
            on = i;
            if (buttonState[i]==BUT_STATE_UP)
            {
                buttonState[i] = BUT_STATE_OVER;
                result = true;
            }
            break;
         }
      for(i in 0...buttonState.length)
      {
         if (i!=on)
            if (buttonState[i]!=BUT_STATE_UP)
            {
               buttonState[i] = BUT_STATE_UP;
               result = true;
            }
      }

      return result;
   }


}




