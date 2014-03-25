package gm2d.skin;

import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.geom.Matrix;

import gm2d.ui.Widget;
import gm2d.ui.WidgetState;


class Renderer
{
   public function new() {  }

   public function getDownOffset() : Point { return new Point(0,0); }
   public function renderWidget(inWidget:Widget) { }
   public function layoutWidget(ioWidget:Widget) { }

 
}
