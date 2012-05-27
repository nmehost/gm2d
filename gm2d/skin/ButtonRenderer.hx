package gm2d.skin;

import gm2d.display.Bitmap;
import gm2d.display.Sprite;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.text.TextFieldAutoSize;
import gm2d.events.MouseEvent;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import gm2d.geom.Matrix;

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.ui.Layout;


class ButtonRenderer
{
   public function new() { }

   public dynamic function render(outChrome:Sprite, inRect:Rectangle, inState:ButtonState):Void { }
   public dynamic function updateLayout(ioLayout:Layout):Void { }
   public dynamic function getDownOffset():Point { return new Point(1,1); }
   public dynamic function styleLabel(ioLabel:TextField):Void {  }
}


