package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.DisplayObjectContainer;
import gm2d.geom.Rectangle;
import gm2d.ui.IDockable;


class Pane implements IDockable
{
   var        dock:Dock;
   public var title(default,null):String;
   public var shortTitle(default,null):String;
   public var displayObject(default,null):DisplayObject;
   public var bestWidth:Float;
   public var bestHeight:Float;
   public var buttonState(default,null):Array<Int>;
   public var gm2dMinimized:Bool;
   public var gm2dMDIRect:Rectangle;
   var mFlags:Int;
   var minSizeX:Float;
   var minSizeY:Float;
   public var sizeX(default,null):Float;
   public var sizeY(default,null):Float;

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
      minSizeX = bestWidth;
      minSizeY = bestHeight;
      sizeX=sizeY=0.0;
      buttonState = [ 0,0,0 ];
      gm2dMinimized = false;
   }

   public function isToolbar() { return (mFlags & DockFlags.TOOLBAR) > 0; }

   public function resizeable()
   {
      return (mFlags & DockFlags.RESIZABLE) > 0;
   }

   public function raise()
   {
      if (dock!=null)
         dock.raise(this);
   }

   // --- IDockable interface -------------------------------------------------
   public function close(inForce:Bool) : Bool
   {
      if (dock!=null)
         dock.remove(this);
      return true;
   }
   public function setContainer(inParent:DisplayObjectContainer):Void
   {
      if (displayObject!=null)
      {
         var p = displayObject.parent;
         if (p!=inParent)
         {
            if (inParent==null)
               p.removeChild(displayObject);
            else
              inParent.addChild(displayObject);
         }
      }
   }


   public function getDock():Dock { return dock; }
   public function setDock(inDock:Dock):Void { dock=inDock; }
   public function getTitle():String { return title; }
   public function getShortTitle():String { return shortTitle; }
   public function getFlags():Int { return mFlags; }
   public function setFlags(inFlags:Int) : Void { mFlags=inFlags; }
   public function getBestSize(?inPos:DockPosition):Size
   {
      return new Size(100,100);
   }
   public function getMinSize():Size { return new Size(minSizeX,minSizeY); }
   public function buttonStates():Array<Int> { return buttonState; }
   public function getLayoutSize(w:Float,h:Float,inLimitX:Bool):Size
   {
      return new Size(w,h);
   }
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      sizeX = w;
      sizeY = w;
      if (displayObject!=null)
      {
         displayObject.x = x;
         displayObject.y = y;
         displayObject.scrollRect = new Rectangle(0,0,w,h);
      }
   }
}

