package gm2d.ui;

import gm2d.display.DisplayObject;


class Pane
{
   public static var POS_OVER = 0;

   public static var RESIZABLE = 0x0001;

   public var title(default,null):String;
   public var displayObject(default,null):DisplayObject;
   public var bestWidth:Float;
   public var bestHeight:Float;
   var mFlags:Int;
   var mMinSizeX:Float;
   var mMinSizeY:Float;
	var dock:IDock;

   public function new(inObj:DisplayObject, inTitle:String, inFlags:Int)
   {
      displayObject = inObj;
      title = inTitle;
      mFlags = inFlags;
      bestWidth = displayObject.width;
      bestHeight = displayObject.height;
      mMinSizeX = 0;
      mMinSizeY = 0;
		dock = null;
   }

	public function raise()
	{
	   // TODO: broadcast event
	   if (dock!=null)
		   dock.raise(this);
	}


	public function close(inForce:Bool = false)
	{
	   gm2dSetDock(null);
	}

	public function gm2dSetDock(inDock:IDock)
	{
	   if (dock!=null && dock!=inDock)
		   dock.remove(this);
		dock = inDock;
	}


}

