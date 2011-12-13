package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.ui.DockPosition;


class TopLevelDock implements IDock
{
   var root:IDockable;
   var container:DisplayObjectContainer;
   var mdi:MDIParent;

   public function new(inContainer:DisplayObjectContainer,?inMDI:MDIParent)
   {
      mdi = inMDI;
      container = inContainer;
      if (inMDI!=null)
      {
         root = mdi;
         mdi.setDock(this);
         mdi.setContainer(container);
      }
   }

   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      if (root!=null)
         root.setRect(x,y,w,h);
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
         inChild.setContainer(container);
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
            side.setContainer(container);
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

}


