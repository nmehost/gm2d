package gm2d.ui;

import gm2d.ui.Pane;
import gm2d.display.DisplayObjectContainer;

enum DockPosition
{
   DOCK_OVER;
   DOCK_LEFT;
   DOCK_RIGHT;
   DOCK_TOP;
   DOCK_BOTTOM;
}

interface IDockable
{
   public function getDock():Dock;
   public function setDock(inDock:Dock):Void;
   public function setContainer(inParent:DisplayObjectContainer):Void;
   public function getTitle():String;
   public function getShortTitle():String;
   public function getFlags():Int;
   public function setFlags(inFlags:Int):Void;
   public function close(inForce:Bool):Bool;
   public function getBestSize(?inPos:DockPosition):Size;
   public function getMinSize():Size;
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size;
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void;
   public function buttonStates():Array<Int>;
   public function raise():Void;
}

