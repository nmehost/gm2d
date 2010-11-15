package gm2d.ui;


import gm2d.display.DisplayObjectContainer;
import gm2d.events.MouseEvent;
import gm2d.ui.Layout;


class Control extends Widget
{
   public function new()
   {
      super();
      name = "control";
   }

   override public function wantFocus() { return true; }

   override public function onCurrentChanged(inCurrent:Bool)
   {
	   if (inCurrent)
		   Skin.current.renderCurrent(this);
		else
		   Skin.current.clearCurrent(this);
   }

}


