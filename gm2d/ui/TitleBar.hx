package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.ui.Keyboard;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.Layout;

class TitleBar extends TextLabel
{
   public function new(inVal="",?inLineage:Array<String>, ?inAttribs:{} )
   {
       super(inVal,Widget.addLine(inLineage,"TitleBar"),inAttribs);
   }
}

