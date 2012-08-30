package gm2d.ui;

import gm2d.ui.Menubar;
import gm2d.display.DisplayObjectContainer;
import gm2d.ui.DockPosition;


class SlideBar extends SpriteMenubar, implements IDock
{
   var align:Int;

   public function new(inParent:DisplayObjectContainer,inAlign:Int)
   {
      super(inParent);
      align = inAlign;
   }

   // IDock....
   public function getDock():IDock { return this; }
   public function canAddDockable(inPos:DockPosition):Bool { return inPos==DOCK_OVER; }
   public function addDockable(child:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
   }
   public function getDockablePosition(child:IDockable):Int
   {
      return -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      return null;
   }
   public function raiseDockable(child:IDockable):Bool
   {
      return false;
   }
   public function minimizeDockable(child:IDockable):Bool
   {
      return false;
   }
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition):Void
   {
   }
   public function getSlot():Int
   {
      return -1;
   }
   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
   }
}



