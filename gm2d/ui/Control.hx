package gm2d.ui;


import nme.display.DisplayObjectContainer;
import nme.events.MouseEvent;
import gm2d.ui.Layout;
import gm2d.skin.Skin;

class Control extends Widget
{
   public function new(?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super(Widget.addLine(inLineage,"Control"),inAttribs);
   }
}


