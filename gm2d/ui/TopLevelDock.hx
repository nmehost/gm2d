package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.display.Stage;
import gm2d.ui.DockPosition;
import gm2d.ui.HitBoxes;
import gm2d.ui.MouseWatcher;
import gm2d.events.MouseEvent;
import gm2d.geom.Rectangle;
import gm2d.ui.DockZones;


class TopLevelDock implements IDock
{
   var root:IDockable;
   var container:Sprite;
   var backgroundContainer:Sprite;
   var overlayContainer:Sprite;
   var paneContainer:Sprite;
   var floatingContainer:Sprite;
   var floatingWins:Array<FloatingWin>;
   var mdi:MDIParent;
   var hitBoxes:HitBoxes;
   var chromeDirty:Bool;
   var layoutDirty:Bool;

   var resizeBox:Rectangle;
   var resizeListen:Bool;
   var size:Rectangle;
   var dockZones:DockZones;

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
      floatingWins = [];

      resizeListen = false;
      chromeDirty = true;
      layoutDirty = true;
      hitBoxes = new HitBoxes(backgroundContainer,onHitBox);
      hitBoxes.onOverDockSize = onOverDockSize;
      hitBoxes.onDockSizeDown = onDockSizeDown;

      if (inMDI!=null)
      {
         root = mdi;
         mdi.setDock(this);
         mdi.setContainer(paneContainer);
      }
      container.addEventListener(gm2d.events.Event.RENDER, updateLayout);
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
               floatingWins.push(floating);
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

      setDirty(false,true);
   }

   function clearOverlay(?_:Dynamic)
   {
      overlayContainer.graphics.clear();
      overlayContainer.x = 0;
      overlayContainer.y = 0;
      while(overlayContainer.numChildren>0)
         overlayContainer.removeChildAt(0);
   }

   public function finishDockDrag(inPane:Pane, inEvent:MouseEvent)
   {
      clearOverlay();
      if (dockZones!=null)
      {
         var dropped = dockZones.test(inEvent.stageX, inEvent.stageY, inPane );
         //trace("Dropped : " + dropped );
      }
      dockZones = null;
   }

   public function showDockZones(inEvent:MouseEvent)
   {
      clearOverlay();
      dockZones = null;
      if (root!=null)
      {
         dockZones = new DockZones(inEvent.stageX, inEvent.stageY, overlayContainer);
         root.addDockZones(dockZones);
         var skin = Skin.current;
         skin.renderDropZone(size,dockZones,DOCK_LEFT, false,   function(d) addDockable(d,DOCK_LEFT,0) );
         skin.renderDropZone(size,dockZones,DOCK_RIGHT, false,  function(d) addDockable(d,DOCK_RIGHT,0));
         skin.renderDropZone(size,dockZones,DOCK_TOP, false,    function(d) addDockable(d,DOCK_TOP,0) );
         skin.renderDropZone(size,dockZones,DOCK_BOTTOM, false, function(d) addDockable(d,DOCK_BOTTOM,0) );
      }
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


   public function updateLayout(_)
   {
      if (layoutDirty)
      {
         //root.verify();
         layoutDirty = false;
         forceLayout();
      }
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
      // trace("addDockable " + inChild + " x " + inPos + " " + inSlot );
      Dock.remove(inChild);
      if (mdi!=null && inPos==DOCK_OVER)
      {
          mdi.addDockable(inChild,inPos,inSlot);
      }
      else if (root==null)
      {
         root = inChild;
         root.setDock(null);
         inChild.setDock(this);
         inChild.setContainer(paneContainer);
      }
      else
      {
         var dock:IDock = cast root;
         if (dock!=null && dock.canAddDockable(inPos))
         {
            dock.addDockable(inChild,inPos,inSlot);
         }
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
      setDirty(true,true);
   }

   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition)
   {
      if (inReference!=root)
         throw "Bad docking reference";
      addDockable(inIncoming,inPos,0);
   }

   public function getDock():IDock { return null; }
   public function getSlot():Int { return Dock.DOCK_SLOT_FLOAT; }

   public function getDockablePosition(child:IDockable):Int
   {
      return child==root ? 0 : -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      var win:FloatingWin = cast child.getDock();
      if (win!=null)
      {
         if (floatingWins.remove(win))
            win.destroy();
         return null;
      }

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
         //trace("post verify");
         //root.verify();
      }
      setDirty(true,true);
      return null;
   }
   public function raiseDockable(child:IDockable):Bool
   {
      var dock:IDock = cast root;
      if (dock!=null)
         dock.raiseDockable(child);
      return false;
   }
   public function setLayoutDirty():Void
   {
      layoutDirty = true;
      if (container.stage!=null)
         container.stage.invalidate();
   }
   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      if (inLayout)
         layoutDirty = true;
      if (inChrome)
         chromeDirty = true;

      if (container.stage!=null)
         container.stage.invalidate();
   }
   public function addDockZones(outZones:DockZones):Void
   {
   }

}


