package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.ui.DockPosition;
import gm2d.ui.HitBoxes;


class TopLevelDock implements IDock
{
   var root:IDockable;
   var container:Sprite;
   var backgroundContainer:Sprite;
   var overlayContainer:Sprite;
   var paneContainer:Sprite;
   var mdi:MDIParent;
   var hitBoxes:HitBoxes;
   var chromeDirty:Bool;

   public function new(inContainer:Sprite,?inMDI:MDIParent)
   {
      mdi = inMDI;
      container = inContainer;
      backgroundContainer = new Sprite();
      container.addChild(backgroundContainer);
      overlayContainer = new Sprite();
      container.addChild(overlayContainer);
      paneContainer = new Sprite();
      container.addChild(paneContainer);

      chromeDirty = true;
      hitBoxes = new HitBoxes(backgroundContainer,onHitBox);
      if (inMDI!=null)
      {
         root = mdi;
         mdi.setDock(this);
         mdi.setContainer(paneContainer);
      }
      container.addEventListener(gm2d.events.Event.RENDER, updateChrome);
   }

   public function onHitBox(inAction:HitAction)
   {
   }

   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      if (root!=null)
         root.setRect(x,y,w,h);
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


