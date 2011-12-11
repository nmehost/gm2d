package gm2d.ui;

import gm2d.ui.Pane;
import gm2d.display.DisplayObjectContainer;


interface IDockable
{
   // Hierarchy
   public function getDock():IDock;
   public function setDock(inDock:IDock):Void;
   public function setContainer(inParent:DisplayObjectContainer):Void;
   public function closeRequest(inForce:Bool):Void;
   // Display
   public function getTitle():String;
   public function getShortTitle():String;
   public function buttonStates():Array<Int>;
   public function getFlags():Int;
   public function setFlags(inFlags:Int):Void;
   // Layout
   public function getBestSize(?inPos:DockPosition):Size;
   public function getMinSize():Size;
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size;
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void;
}

