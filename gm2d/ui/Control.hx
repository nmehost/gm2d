package gm2d.ui;


import nme.display.DisplayObjectContainer;
import nme.events.MouseEvent;
import gm2d.ui.Layout;
import gm2d.skin.Skin;

class Control extends Widget
{
   public function new(?inSkin:Skin,?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super(skin,Widget.addLine(inLineage,"Control"),inAttribs);
   }
}


