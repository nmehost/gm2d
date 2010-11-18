package gm2d.ui;

import gm2d.geom.Rectangle;
import gm2d.geom.Point;
import gm2d.display.Bitmap;

class HitBox
{
   public function new(inRect:Rectangle, inAction:Int)
   {
      rect = inRect;
      action = inAction;
   }
   public var rect:Rectangle;
   public var action:Int;
}

class HitBoxes
{
   public static var ACT_NONE     = -1;
   public static var ACT_CLOSE    = 0;
   public static var ACT_MINIMIZE = 1;
   public static var ACT_MAXIMIZE = 2;
   public static var ACT_DRAG     = 3;
   public static var ACT_REDRAW   = 4;

   public static var ACT_RESIZE_E = 0x0010;
   public static var ACT_RESIZE_W = 0x0020;
   public static var ACT_RESIZE_N = 0x0040;
   public static var ACT_RESIZE_S = 0x0080;


   public static var BUT_CLOSE = 0;
   public static var BUT_MINIMIZE = 1;
   public static var BUT_MAXIMIZE = 2;
   public static var BUT_COUNT = 3;

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

   public function add(rect:Rectangle, action:Int)
   {
      rects.push( new HitBox(rect,action) );
   }

   public function onDown(inX:Float, inY:Float) : Int
   {
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            if (r.action>=0 && r.action<BUT_COUNT)
            {
               buttonState[r.action] = BUT_STATE_DOWN;
               return ACT_REDRAW;
            }

            return r.action;
         }

      return ACT_NONE;
   }


   public function onUp(inX:Float, inY:Float) : Int
   {
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            if (r.action>=0 && r.action<BUT_COUNT)
            {
               if (buttonState[r.action]==BUT_STATE_DOWN)
               {
                  buttonState[r.action]=BUT_STATE_OVER;
                  return r.action;
               }
               break;
            }
         }

      return ACT_NONE;
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




