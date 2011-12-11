package gm2d.ui;

import gm2d.ui.IDockable;
import gm2d.ui.Pane;
import gm2d.display.DisplayObjectContainer;


class Dock
{
   var parentDock:Dock;


   public function new() { }

   public function getParentDock():Dock { return parentDock; }
   public function setParentDock(inDock:Dock):Void { parentDock=inDock; }
   public function rendersChrome():Bool { return false; }

   public function getParentContainer():DisplayObjectContainer
   {
      if (parentDock!=null)
         return parentDock.getParentContainer();
      return null;
   }

   public function add(child:IDockable,inPos:DockPosition,inSlot:Int):Dock
   {
      throw "Not implmented";
      return this;
   }
   public function remove(child:IDockable):Dock
   {
      throw "No children";
      return this;
   }
   public function raise(rase:IDockable)
   {
      throw "No children";
   }

   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      throw "Not implmented";
   }

   public function getSize(w:Float,h:Float):Size
   {
      return new Size(w,h);
   }
   function canAdd(inPos:DockPosition):Bool { return false; }


   public static function doRaise(inPane:IDockable)
   {
      var parent = inPane.getDock();
      if (parent!=null)
         parent.raise(inPane);
   }
}


class MDIDock extends Dock
{
   var clientArea:DisplayObjectContainer;
   var mdi:MDIParent;

   public function new(inParent:DisplayObjectContainer,inMDI:MDIParent)
   {
      super();
      parentDock = null;
      clientArea = inParent;
      mdi = inMDI;
   }
   override function canAdd(inPos:DockPosition):Bool { return inPos==DOCK_OVER; }

   public override function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      mdi.x = x;
      mdi.y = y;
      mdi.layout(w,h);
   }

   override public function getParentContainer():DisplayObjectContainer { return clientArea; }

   override public function rendersChrome():Bool { return true; }

   override public function add(inDockable:IDockable, inPos:DockPosition, inSlot:Int ) : Dock
   {
      if (inPos==DOCK_OVER)
      {
         mdi.addDockable(inDockable);
         return this;
      }

      throw("Bad dock position");
      return super.add(inDockable,inPos,inSlot);
   }

   override public function remove(child:IDockable):Dock
   {
      mdi.remove(child);
      return this;
   }
   override public function raise(child:IDockable)
   {
      mdi.raise(child);
   }

}
