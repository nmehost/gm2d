package gm2d.ui;

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.Stage;
import gm2d.ui.DockPosition;
import gm2d.ui.HitBoxes;
import gm2d.ui.MouseWatcher;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import gm2d.ui.DockZones;
import gm2d.skin.Skin;

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

   var size:Rectangle;
   var dockZones:DockZones;

   public function new(inContainer:Sprite,?inMDI:MDIParent)
   {
      mdi = inMDI;
      if (mdi!=null)
         mdi.setTopLevel(this);
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

      chromeDirty = true;
      layoutDirty = true;
      hitBoxes = new HitBoxes(backgroundContainer,onHitBox);
      new DockSizeHandler(container,overlayContainer,hitBoxes);

      if (inMDI!=null)
      {
         root = mdi;
         mdi.setDock(this,paneContainer);
      }
      container.addEventListener(nme.events.Event.RENDER, updateLayout);
   }

   public function floatWindow(inDockable:IDockable, inEvent:MouseEvent, inProps:Dynamic)
   {
      Dock.remove(inDockable);
      var pane = inDockable.asPane();
      if (pane!=null)
      {
         var floating:FloatingWin = null;
         if (inEvent!=null)
            floating = new FloatingWin(this,pane,inEvent.stageX, inEvent.stageY)
         else
         {
            pane.loadLayout(inProps);
            var pos = inProps.properties.floatingPos;
            if (pos==null)
               pos = { x:20, y:20 };
            floating = new FloatingWin(this,pane,pos.x, pos.y);
         }
         floatingWins.push(floating);
         floatingContainer.addChild(floating);
         if (inEvent!=null)
            floating.doStartDrag(inEvent);
      }
   }

   public function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         case DRAG(p):
            floatWindow(p,inEvent,null);
        case BUTTON(pane,but):
            if (but==MiniButton.EXPAND)
              Dock.raise(pane);
            else if (but==MiniButton.MINIMIZE)
              Dock.minimize(pane);
         case TITLE(pane):
            Dock.raise(pane);

         default:
      }
   }

   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      size = new Rectangle(x,y,w,h);
      if (root!=null)
         root.setRect(x,y,w,h);
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
         Skin.renderDropZone(size,dockZones,DOCK_LEFT, false,   function(d) addDockable(d,DOCK_LEFT,0) );
         Skin.renderDropZone(size,dockZones,DOCK_RIGHT, false,  function(d) addDockable(d,DOCK_RIGHT,0));
         Skin.renderDropZone(size,dockZones,DOCK_TOP, false,    function(d) addDockable(d,DOCK_TOP,0) );
         Skin.renderDropZone(size,dockZones,DOCK_BOTTOM, false, function(d) addDockable(d,DOCK_BOTTOM,0) );
      }
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
         if (root!=null)
            root.renderChrome(backgroundContainer,hitBoxes);
      }
   }

   public function getLayoutInfo():Dynamic
   {
      var floating = new Array<Dynamic>();
      for(idx in 0...floatingWins.length)
         floating[idx] = floatingWins[idx].pane.getLayoutInfo();

      return { floating:floating, root:root==null ? null : root.getLayoutInfo() }
   }

   public function setLayoutInfo(inInfo:Dynamic)
   {
      var panes = Pane.allPanes();
      for(pane in panes)
         Dock.remove(pane);
      var floatings:Array<Dynamic> = inInfo.floating;
      for(floating in floatings)
      {
         var title = floating.title;
         for(pane in panes)
            if (pane.title==title)
            {
               panes.remove(pane);
               pane.loadLayout(floating);
               floatWindow(pane,null,floating);
               break;
            }
      }

      root = Dock.loadLayout(inInfo.root,panes,mdi);
      if (root!=null)
        root.setDock(this,paneContainer);
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
         root.setDock(this,paneContainer);
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
            side.setDock(this,paneContainer);
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
      if (Std.is(child.getDock(), FloatingWin))
      {
         var win:FloatingWin = cast child.getDock();
         if (floatingWins.remove(win))
            win.destroy();
         return null;
      }

      if (child==root)
      {
         root=null;
         child.setDock(null,null);
      }
      else
      {
         var dock:IDock = cast root;
         root = dock.removeDockable(child);
         if (root!=null)
           root.setDock(this,paneContainer);
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
   public function minimizeDockable(child:IDockable):Bool
   {
      return false;
   }
   public function setLayoutDirty():Void
   {
      layoutDirty = true;
   }
   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      if (inLayout)
         layoutDirty = true;
      if (inChrome)
         chromeDirty = true;
      Game.invalidate();
   }
   public function addDockZones(outZones:DockZones):Void
   {
   }

}


