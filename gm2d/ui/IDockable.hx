package gm2d.ui;

import gm2d.ui.Pane;
import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;


interface IDockable
{
   // Hierarchy
   public function getDock():IDock;
   public function setDock(inDock:IDock):Void;
   public function setContainer(inParent:DisplayObjectContainer):Void;
   public function closeRequest(inForce:Bool):Void;
   // If it is a container...
   public function removeDockable(child:IDockable):IDockable;
   public function raiseDockable(child:IDockable):Bool;

   public function asPane():Pane;
   public function renderChrome(inBackground:Sprite,outHitBoxes:HitBoxes):Void;
   public function addDockZones(outZones:DockZones):Void;


   // Display
   public function getTitle():String;
   public function getShortTitle():String;
   public function buttonStates():Array<Int>;
   public function getFlags():Int;
   public function setFlags(inFlags:Int):Void;
   // Layout
   public function getBestSize(inSlot:Int):Size;
   public function getMinSize():Size;
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size;
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void;
   public function getDockRect():gm2d.geom.Rectangle;
}

