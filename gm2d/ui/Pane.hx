package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.DisplayObjectContainer;
import gm2d.geom.Rectangle;
import gm2d.geom.Point;
import gm2d.display.Sprite;
import gm2d.ui.IDockable;
import gm2d.skin.Skin;

class Pane implements IDockable
{
   public static var sPanes = new Array<Pane>();
   var        dock:IDock;
   public var title(default,null):String;
   public var shortTitle(default,null):String;
   public var displayObject(default,null):DisplayObject;
   public var bestWidth:Float;
   public var bestHeight:Float;
   public var gm2dMinimized:Bool;
   public var minSizeX:Float;
   public var minSizeY:Float;
   public var sizeX(default,null):Float;
   public var sizeY(default,null):Float;
   public var scrollX(default,null):Float;
   public var scrollY(default,null):Float;
   public var onLayout:Void->Void;
   public var onClose:Void->Void;
   public var itemLayout:Layout;
   public var bestSize:Array<Size>;
   public var properties:Dynamic;
   //public var bestPos:Array<Point>;
   var flags:Int;
   var posX:Float;
   var posY:Float;

   public function new(inObj:DisplayObject, inTitle:String, inFlags:Int, ?inShortTitle:String)
   {
      sPanes.push(this);
      scrollX = scrollY = 0.0;
      displayObject = inObj;
      title = inTitle;
      itemLayout = null;
      bestSize = [];
      //bestPos = [];
      properties = {};
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
      flags = inFlags;
      bestWidth = displayObject.width;
      bestHeight = displayObject.height;
      minSizeX = bestWidth;
      minSizeY = bestHeight;
      sizeX=sizeY=0.0;
      posX=posY=0.0;
      gm2dMinimized = false;
   }
   static public function allPanes() { return sPanes.copy(); }

   public function setMinSize(inX:Float, inY:Float)
   {
      minSizeX = inX;
      minSizeY = inY;
      if (bestWidth<inX)
         bestWidth = inX;
      if (bestHeight<inY)
         bestHeight = inY;
      for(s in bestSize)
         if (s!=null)
         {
            if (s.x<inX) s.x = inX;
            if (s.y<inY) s.y = inY;
         }
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

   public function toString() { return title; }

   public function raise()
   {
      //if (parentDock!=null) parentDock.raise(this);
   }

   // --- IDockable interface -------------------------------------------------
   public function closeRequest(inForce:Bool) : Void
   {
      Dock.remove(this);
      if ( (flags & Dock.DONT_DESTROY) ==0 )
      {
         sPanes.remove(this);
         onClose();
      }
   }
   public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void
   {
      dock = inDock;
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
   public function getTitle():String { return title; }
   public function getShortTitle():String { return shortTitle; }
   public function getFlags():Int { return flags; }
   public function setFlags(inFlags:Int) : Void { flags=inFlags; }
   public function getBestSize(inSlot):Size
   {
      if (bestSize[inSlot]==null)
      {
         if (itemLayout!=null)
         {
             bestSize[inSlot] = new Size( itemLayout.getBestWidth(), itemLayout.getBestHeight() );
             if (bestSize[inSlot].x < bestWidth)
                bestSize[inSlot].x = bestWidth;
             if (bestSize[inSlot].y < bestHeight)
                bestSize[inSlot].y = bestHeight;
             //trace("Item layout: " + bestSize[inSlot] );
         }
         else
            bestSize[inSlot] = new Size(bestWidth,bestHeight);
      }
      return bestSize[inSlot].clone();
   }
   public function onLayoutSwitch(inOldSlot:Int)
   {
      if (bestSize[inOldSlot]!=null)
      {
         if (inOldSlot==Dock.DOCK_SLOT_HORIZ)
            bestSize[Dock.DOCK_SLOT_VERT] = bestSize[inOldSlot].clone();
         else
            bestSize[Dock.DOCK_SLOT_HORIZ] = bestSize[inOldSlot].clone();
      }
   }
   public function getProperties() : Dynamic { return properties; }
   public function setBestSize(inW:Float,inH:Float)
   {
      bestWidth = inW;
      bestHeight = inH;
   }

   public function getMinSize():Size { return new Size(minSizeX,minSizeY); }
   public function getLayoutSize(w:Float,h:Float,inLimitX:Bool):Size
   {
      var min = getMinSize();
      return new Size(w<min.x ? min.x : w,h<min.y ? min.y : h);
   }

   public function isLocked():Bool { return false; }

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
      if (dock!=null)
      {
         var slot = dock.getSlot();
         bestSize[slot] = new Size(w,h);
         if (slot==Dock.DOCK_SLOT_FLOAT || slot==Dock.DOCK_SLOT_MDI)
             bestSize[Dock.DOCK_SLOT_FLOAT] = bestSize[Dock.DOCK_SLOT_MDI] = new Size(w,h);
         if (Dock.isToolbar(this))
         {
            if (slot==Dock.DOCK_SLOT_HORIZ)
            {
               h = getLayoutSize(w,h,true).y;
            }
            else if (slot==Dock.DOCK_SLOT_VERT)
            {
               w = getLayoutSize(w,h,false).x;
            }
         }
      }

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

   public function verify()
   {
   }

   
   public function getDockRect():gm2d.geom.Rectangle
   {
      return new Rectangle(posX, posY, sizeX, sizeY );
   }

   public function addDockZones(outZones:DockZones):Void
   {
      var rect = getDockRect();

      if (rect.contains(outZones.x,outZones.y))
      {
         var skin = Skin.current;
         var dock = getDock();
         skin.renderDropZone(rect,outZones,DOCK_LEFT,true,   function(d) dock.addSibling(this,d,DOCK_LEFT) );
         skin.renderDropZone(rect,outZones,DOCK_RIGHT,true,  function(d) dock.addSibling(this,d,DOCK_RIGHT));
         skin.renderDropZone(rect,outZones,DOCK_TOP,true,    function(d) dock.addSibling(this,d,DOCK_TOP) );
         skin.renderDropZone(rect,outZones,DOCK_BOTTOM,true, function(d) dock.addSibling(this,d,DOCK_BOTTOM) );
         skin.renderDropZone(rect,outZones,DOCK_OVER,true,   function(d) dock.addSibling(this,d,DOCK_OVER) );
      }
   }


   public function getLayoutInfo():Dynamic
   {
      return { type:"Pane", title:title,
          sizeX:sizeX,  sizeY:sizeY, scrollX:scrollX, scrollY:scrollY,
          bestSize:bestSize.copy(), properties:properties, flags:flags };

      return {};
   }

   public function loadLayout(inLayout:Dynamic):Void
   {
      var x = inLayout.mdiX;
      if (x!=null) properties.mdiX = x;
      var y = inLayout.mdiY;
      if (y!=null) properties.mdiY = y;

      var pos = inLayout.floatingfPos;
      if (pos!=null)
      {
         properties.floatingPos.x = pos.x;
         properties.floatingPos.y = pos.y;
      }
      var sizes:Array<Dynamic> = inLayout.bestSize;
      for(idx in 0...sizes.length)
      {
         var s = sizes[idx];
         if (s!=null)
            bestSize[idx] = new Size( s.x, s.y );
      }
   }



   public function renderChrome(inBackground:Sprite,outHitBoxes:HitBoxes):Void
   {
   }

   public function asPane() : Pane { return this; }


}

