package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.geom.Rectangle;


class Pane
{
   public static var POS_OVER = 0;

   public static var RESIZABLE     = 0x0001;
   public static var TOOLBAR       = 0x0002;

   public var title(default,null):String;
   public var shortTitle(default,null):String;
   public var displayObject(default,null):DisplayObject;
   public var bestWidth:Float;
   public var bestHeight:Float;
   public var buttonState(default,null):Array<Int>;
   public var gm2dMinimized:Bool;
   public var gm2dMDIRect:Rectangle;
   var mFlags:Int;
   var mMinSizeX:Float;
   var mMinSizeY:Float;
   var dock:IDock;

   public function new(inObj:DisplayObject, inTitle:String, inFlags:Int, ?inShortTitle:String)
   {
      displayObject = inObj;
      title = inTitle;
      if (inShortTitle==null)
      {
         var lastPart = inTitle.lastIndexOf("/");
         lastPart = Std.int(Math.max(inTitle.lastIndexOf("\\",lastPart),lastPart));
         shortTitle = title.substr(lastPart+1);
         /*
         var dot = shortTitle.lastIndexOf(".");
         if (dot>0)
            shortTitle = shortTitle.substr(0,dot);
         */
      }
      mFlags = inFlags;
      bestWidth = displayObject.width;
      bestHeight = displayObject.height;
      mMinSizeX = 0;
      mMinSizeY = 0;
      dock = null;
      buttonState = [ 0,0,0 ];
      gm2dMinimized = false;
   }

   public function isToolbar() { return (mFlags & TOOLBAR) > 0; }

   public function resizeable()
   {
      return (mFlags & RESIZABLE) > 0;
   }

   public function raise()
   {
      // TODO: broadcast event
      if (dock!=null)
         dock.raise(this);
   }

   public function layout(inW:Float, inH:Float)
   {
      if (displayObject!=null)
      {
         displayObject.scrollRect = new Rectangle(0,0,inW,inH);
      }
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

