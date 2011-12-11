package gm2d.ui;

import gm2d.ui.Pane;
import gm2d.display.DisplayObjectContainer;

class IDock
{
   var parentDock:IDock;

   public function new() { }

   public function getParentDock():IDock { return parentDock; }

   public function getParentContainer():DisplayObjectContainer
   {
      if (parentDock!=null)
         return parentDock.getParentContainer();
      return null;
   }

   public function add(child:IDock,inPos:Int,inSlot:Int):IDock
     { throw "Not implmented";return this;}
   public function remove(child:IDock):IDock { throw "No children"; return this; }
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void { throw "Not implmented"; }

   public function rendersChrome():Bool { return false; }

   public function setParentDock(inDock:IDock):Void { parentDock=inDock; }

   public function asPane() : Pane { return null; }
}

class MDIDock extends IDock
{
   var parent:DisplayObjectContainer;
   var mdi:MDIParent;

   public function new(inParent:DisplayObjectContainer,inMDI:MDIParent)
   {
      super();
      parentDock = null;
      parent = inParent;
      mdi = inMDI;
      parent.addChild(mdi);
   }

   public override function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      parent.x = x;
      parent.y = y;
      parent.layout(w,h);
   }

   override public function getParentDock():IDock { return parentDock; }

   override public function getParentContainer():DisplayObjectContainer { return parent; }

   override public function rendersChrome():Bool { return true; }

   override public function add(inPane:IDock, inPos:Int, inSlot:Int ) : IDock
   {
      if (inPos==Pane.POS_OVER)
      {
         mdi.addPane(inPane.asPane());
         return this;
      }

      mdi.addPane(inPane.asPane());
      return this;
   }

}
