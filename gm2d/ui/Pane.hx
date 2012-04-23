package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.DisplayObjectContainer;
import gm2d.geom.Rectangle;
import gm2d.display.Sprite;
import gm2d.ui.IDockable;


class Pane implements IDockable
{
   var        dock:IDock;
   public var title(default,null):String;
   public var shortTitle(default,null):String;
   public var displayObject(default,null):DisplayObject;
   public var bestWidth:Float;
   public var bestHeight:Float;
   public var buttonState(default,null):Array<Int>;
   public var gm2dMinimized:Bool;
   public var minSizeX:Float;
   public var minSizeY:Float;
   public var sizeX(default,null):Float;
   public var sizeY(default,null):Float;
   public var scrollX(default,null):Float;
   public var scrollY(default,null):Float;
   public var onLayout:Void->Void;
   public var itemLayout:Layout;
   public var bestSize:Array<Size>;
   var mFlags:Int;
   var posX:Float;
   var posY:Float;

   public function new(inObj:DisplayObject, inTitle:String, inFlags:Int, ?inShortTitle:String)
   {
      scrollX = scrollY = 0.0;
      displayObject = inObj;
      title = inTitle;
      itemLayout = null;
      bestSize = [];
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
      posX=posY=0.0;
      buttonState = [ 0,0,0 ];
      gm2dMinimized = false;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      if (child==this)
         return null;
      return this;
   }
   public function raiseDockable(child:IDockable):Bool
   {
      return child==this;
   }


   public function raise()
   {
      //if (parentDock!=null) parentDock.raise(this);
   }

   // --- IDockable interface -------------------------------------------------
   public function closeRequest(inForce:Bool) : Void
   {
      Dock.remove(this);
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


   public function getDock():IDock { return dock; }
   public function setDock(inDock:IDock):Void { dock=inDock; }
   public function getTitle():String { return title; }
   public function getShortTitle():String { return shortTitle; }
   public function getFlags():Int { return mFlags; }
   public function setFlags(inFlags:Int) : Void { mFlags=inFlags; }
   public function getBestSize(inSlot):Size
   {
      if (bestSize[inSlot]==null)
         return new Size(bestWidth,bestHeight);
      return bestSize[inSlot].clone();
   }
   public function getMinSize():Size { return new Size(minSizeX,minSizeY); }
   public function buttonStates():Array<Int> { return buttonState; }
   public function getLayoutSize(w:Float,h:Float,inLimitX:Bool):Size
   {
      var min = getMinSize();
      return new Size(w<min.x ? min.x : w,h<min.y ? min.y : h);
   }
   public function wantsResize(inHorizontal:Bool,inMove:Int):Bool
   {
      if ( Dock.isToolbar(this) )
      {
         return inMove>0;
      }
      if (inHorizontal)
      {
        if (inMove<0 && sizeX <= minSizeX)
           return false;
      }
      else
      {
        if (inMove<0 && sizeY <= minSizeY)
           return false;
      }
      return true;
   }
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      bestSize[ dock.getSlot() ] = new Size(w,h);

      posX = x;
      posY = y;
      sizeX = w;
      sizeY = h;
      if (displayObject!=null)
      {
         displayObject.x = x;
         displayObject.y = y;
         displayObject.scrollRect = new Rectangle(scrollX,scrollY,w,h);
         if (itemLayout!=null)
            itemLayout.setRect(0,0,w,h);
      }
      else if (itemLayout!=null)
         itemLayout.setRect(x,y,w,h);

      if (onLayout!=null)
         onLayout();
   }

   
   public function getRect():gm2d.geom.Rectangle
   {
      return new Rectangle(posX, posY, sizeX, sizeY );
   }

   public function renderChrome(inBackground:Sprite,outHitBoxes:HitBoxes):Void
   {
   }

   public function asPane() : Pane { return this; }


}

