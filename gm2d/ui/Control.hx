package gm2d.ui;


import nme.display.DisplayObjectContainer;
import nme.events.MouseEvent;
import gm2d.ui.Layout;
import gm2d.skin.Skin;

class Control extends Widget
{
   public function new()
   {
      super();
		wantFocus = true;
   }

   override public function onCurrentChanged(inCurrent:Bool)
   {
	   if (inCurrent)
		   Skin.current.renderCurrent(this);
		else
		   Skin.current.clearCurrent(this);
   }

}


