package gm2d.ui;

import gm2d.ui.Pane;
import nme.display.DisplayObjectContainer;
import nme.display.BitmapData;
import nme.display.Sprite;


interface IDockable
{
   // Hierarchy
   public function getDock():IDock;
   public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void;
   public function closeRequest(inForce:Bool):Void;
   // If it is a container...
   public function removeDockable(child:IDockable):IDockable;
   public function raiseDockable(child:IDockable):Bool;

   public function asPane():Pane;
   public function addDockZones(outZones:DockZones):Void;


   // Display
   public function getTitle():String;
   public function getShortTitle():String;
   public function getIcon():BitmapData;
   public function getFlags():Int;
   public function setFlags(inFlags:Int):Void;
   // Layout
   public function getBestSize(inSlot:Int):Size;
   public function getMinSize():Size;
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size;
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void;
   public function getDockRect():nme.geom.Rectangle;
   public function getLayoutInfo():Dynamic;
   public function loadLayout(inLayout:Dynamic):Void;
   public function isLocked():Bool;

   // generic
   public function getProperties():Dynamic;
   // Debug
   public function verify():Void;
}

