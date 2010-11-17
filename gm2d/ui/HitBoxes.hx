package gm2d.ui;

import gm2d.geom.Rectangle;

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
   public static var ACT_NONE = 0;
   public static var ACT_CLOSE = 1;
   public static var ACT_MINIMIZE = 2;
   public static var ACT_MAXIMIZE = 3;

   public static var ACT_RESIZE_E = 0x0010;
   public static var ACT_RESIZE_W = 0x0020;
   public static var ACT_RESIZE_N = 0x0040;
   public static var ACT_RESIZE_S = 0x0080;


   public static var BUT_CLOSE = 1;
   public static var BUT_MINIMIZE = 2;
   public static var BUT_MAXIMIZE = 3;

   public static var BUT_STATE_UP = 0;
   public static var BUT_STATE_OVER = 1;
   public static var BUT_STATE_DOWN = 2;

   var rects:Array<HitBox>;

   public function new()
	{
	   rects = [];
	}
	public function clear() { rects = []; }

	public function add(rect:Rectangle, action:Int)
	{
	   rects.push( new HitBox(rect,action) );
	}

	public function action(inPos:Point) : Int
	{
	   for(r in rects)
		   if (r.rect.contains(inPos))
			   return r.action;

		return ACT_NONE;
	}

}
