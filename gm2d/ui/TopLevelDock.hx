package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.display.Stage;
import gm2d.ui.DockPosition;
import gm2d.ui.HitBoxes;
import gm2d.ui.MouseWatcher;
import gm2d.events.MouseEvent;
import gm2d.geom.Rectangle;


class TopLevelDock implements IDock
{
   var root:IDockable;
   var container:Sprite;
   var backgroundContainer:Sprite;
   var overlayContainer:Sprite;
   var paneContainer:Sprite;
   var floatingContainer:Sprite;
   var mdi:MDIParent;
   var hitBoxes:HitBoxes;
   var chromeDirty:Bool;

   var resizeBox:Rectangle;
   var resizeListen:Bool;
   var size:Rectangle;

   public function new(inContainer:Sprite,?inMDI:MDIParent)
   {
      mdi = inMDI;
      container = inContainer;
      backgroundContainer = new Sprite();
      container.addChild(backgroundContainer);
      paneContainer = new Sprite();
      container.addChild(paneContainer);
      floatingContainer = new Sprite();
      container.addChild(floatingContainer);
      overlayContainer = new Sprite();
      container.addChild(overlayContainer);

      resizeListen = false;
      chromeDirty = true;
      hitBoxes = new HitBoxes(backgroundContainer,onHitBox);
      hitBoxes.onOverDockSize = onOverDockSize;
      hitBoxes.onDockSizeDown = onDockSizeDown;

      if (inMDI!=null)
      {
         root = mdi;
         mdi.setDock(this);
         mdi.setContainer(paneContainer);
      }
      container.addEventListener(gm2d.events.Event.RENDER, updateChrome);
   }

   public function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         case DRAG(p):
            Dock.remove(p);
            var pane = p.asPane();
            if (pane!=null)
            {
               var floating = new FloatingWin(this,pane,hitBoxes.downX, hitBoxes.downY);
               floatingContainer.addChild(floating);
               floating.doStartDrag(inEvent);
            }
         default:
      }
   }

   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      size = new Rectangle(x,y,w,h);
      if (root!=null)
         root.setRect(x,y,w,h);
   }

   public function checkResizeDock(inMouse:MouseEvent)
   {
      if (resizeBox!=null)
      {
         if (!resizeBox.contains(inMouse.localX,inMouse.localY))
         {
            resizeBox = null;
            container.removeEventListener(MouseEvent.MOUSE_MOVE,checkResizeDock);
            resizeListen = false;
            var gfx = overlayContainer.graphics;
            gfx.clear();
         }
      }
   }

   function forceLayout()
   {
      if (root!=null)
        root.setRect(size.x, size.y, size.width, size.height );

      setChromeDirty();
   }

   function clearOverlay(?_:Dynamic)
   {
      overlayContainer.graphics.clear();
   }

   function showResizeHint(inX:Float, inY:Float, inHorizontal:Bool)
   {
      overlayContainer.x = inX-16;
      overlayContainer.y = inY-16;
      overlayContainer.cacheAsBitmap = true;
      overlayContainer.mouseEnabled = false;
      var gfx = overlayContainer.graphics;
      gfx.clear();
      if (inHorizontal)
         new gm2d.icons.EastWest().render(gfx);
      else
         new gm2d.icons.NorthSouth().render(gfx);
   }

   public function onOverDockSize(inDock:SideDock, inIndex:Int, inX:Float, inY:Float, inRect:Rectangle )
   {
      showResizeHint(inX,inY,inDock.isHorizontal());

      resizeBox = inRect;
      if (!resizeListen)
      {
         container.addEventListener(MouseEvent.MOUSE_MOVE,checkResizeDock);
         resizeListen = true;
      }
   }

   public function onDockSizeDown(inDock:SideDock, inIndex:Int, inX:Float, inY:Float, inRect:Rectangle )
   {
      //trace("Drag dock " + inX + "," + inY);
      resizeBox = null;
      container.removeEventListener(MouseEvent.MOUSE_MOVE,checkResizeDock);
      resizeListen = false;

      MouseWatcher.watchDrag(container,inX,inY,
          function(_) onDockSize(inDock,inIndex,_) , clearOverlay );
   }

   function onDockSize(inDock:SideDock, inIndex:Int, inEvent:MouseEvent)
   {
      showResizeHint(inEvent.stageX,inEvent.stageY,inDock.isHorizontal());
      inDock.tryResize(inIndex, inDock.isHorizontal() ? inEvent.stageX : inEvent.stageY );
      //trace(inEvent);
   }


   public function updateChrome(_)
   {
      if (chromeDirty)
      {
         chromeDirty = false;
         hitBoxes.clear();
         backgroundContainer.graphics.clear();
         while(backgroundContainer.numChildren>0)
            backgroundContainer.removeChildAt(0);
         root.renderChrome(backgroundContainer,hitBoxes);
      }
   }



   // -- IDock -----------------------------------------------------------
   public function canAddDockable(inPos:DockPosition):Bool { return true; }
   public function addDockable(inChild:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      if (mdi!=null && inPos==DOCK_OVER)
      {
          mdi.addDockable(inChild,inPos,inSlot);
      }
      else if (root==null)
      {
         root = inChild;
         inChild.setDock(this);
         inChild.setContainer(paneContainer);
      }
      else
      {
         var dock:IDock = cast root;
         if (dock!=null && dock.canAddDockable(inPos))
            dock.addDockable(inChild,inPos,inSlot);
         else
         {
            var side = new SideDock(inPos);
            side.setDock(this);
            side.setContainer(paneContainer);
            side.addDockable(root,inPos,0);
            side.addDockable(inChild,inPos,0);
            root = side;
         }
      }
   }
   public function getDock():IDock { return null; }
   public function getSlot():Int { return Dock.DOCK_SLOT_FLOAT; }

   public function getDockablePosition(child:IDockable):Int
   {
      return child==root ? 0 : -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      if (child==root)
      {
         root=null;
         child.setDock(null);
         child.setContainer(null);
      }
      else
      {
         var dock:IDock = cast root;
         root = dock.removeDockable(child);
      }
      forceLayout();
      return null;
   }
   public function raiseDockable(child:IDockable):Bool
   {
      var dock:IDock = cast root;
      if (dock!=null)
         dock.raiseDockable(child);
      return false;
   }
   public function setChromeDirty():Void
   {
      chromeDirty = true;
      if (container.stage!=null)
         container.stage.invalidate();
   }

}


