package gm2d.ui;

import gm2d.events.MouseEvent;

class Phase
{
   public static inline var BEGIN  = 0x1;
   public static inline var UPDATE = 0x2;
   public static inline var END    = 0x4;
   public static inline var ALL    = 0x7;

   public static function fromMouseEvent(inEvent:MouseEvent) : Int
   {
      if (inEvent.type == MouseEvent.MOUSE_DOWN)
         return BEGIN;
      if (inEvent.type == MouseEvent.MOUSE_MOVE)
         return UPDATE;
      if (inEvent.type == MouseEvent.MOUSE_UP)
         return END;
      return ALL;
   }
}


