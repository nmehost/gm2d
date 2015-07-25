package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Shape;
import nme.display.Sprite;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.WidgetState;


class CheckButtons extends Button
{
   public function new(inValue:Bool, inCheck:Bool->Void,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
      super(null,function() inCheck(down),Widget.addLines(inLineage,["CheckButton"]),inAttribs);
      setChecked(inValue);
      build();
   }

   public function setChecked(inCheck:Bool)
      down = inCheck;
}

