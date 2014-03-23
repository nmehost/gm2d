package gm2d.ui;

import gm2d.ui.IDockable;
import gm2d.ui.Pane;
import nme.display.DisplayObjectContainer;


interface IDock
{
   public function getDock():IDock;
   public function canAddDockable(inPos:DockPosition):Bool;
   public function addDockable(child:IDockable,inPos:DockPosition,inSlot:Int):Void;
   public function getDockablePosition(child:IDockable):Int;
   public function removeDockable(child:IDockable):IDockable;
   public function raiseDockable(child:IDockable):Bool;
   public function minimizeDockable(child:IDockable):Bool;
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition):Void;
   public function getSlot():Int;
   public function setDirty(inLayout:Bool, inChrome:Bool):Void;
}

