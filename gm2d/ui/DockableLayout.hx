package gm2d.ui;

import gm2d.ui.Pane;
import nme.display.DisplayObjectContainer;
import nme.display.BitmapData;
import nme.display.Sprite;


class DockableLayout extends Layout
{
   var dockable:IDockable;

   public function new(inDockable:IDockable)
   {
      super();
      dockable = inDockable;
   }

   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      dockable.setRect(
   }
}

