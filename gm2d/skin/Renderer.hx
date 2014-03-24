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

import nme.display.SimpleButton;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.ui.Layout;
import gm2d.ui.Button;
import gm2d.ui.Widget;


class Renderer
{
   public function new() {  }


   public dynamic function render(outChrome:Sprite, inRect:Rectangle, inState:ButtonState):Void { }
   public dynamic function updateLayout(ioWidget:Widget):Void { }
   public dynamic function styleLabel(ioLabel:TextField):Void { }
}
