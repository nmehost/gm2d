import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldAutoSize;

// nme:lib=gm2d
import gm2d.ui2.Layout;
import gm2d.ui2.Button;
import gm2d.ui2.SkinItem;
import gm2d.ui2.SkinLabel;

import gm2d.ui2.BitmapFont;
import gm2d.ui2.BitmapText;
import gm2d.ui2.SkinTitle;
import gm2d.ui2.Pane;
import gm2d.app.Screen;
import gm2d.app.Game;
import gm2d.app.App;
import gm2d.ui2.Panel;
//import gm2d.ui2.Slider;


class NewUi extends App
{
   public function new()
   {
      super();

      var button = new Button( {
           //width:300,
           gap:20,
           item:ITEM_ICON(new gm2d.icons.Document(),0.5),
           titleStyle:TITLE_BOTTOM,
           title:"Click Me"
      } );
      // addChild(button);

      var panel = new Panel("MyStuff");

      panel.addUI(button);
      var dialog = new gm2d.ui2.Dialog(panel);

      Game.doShowDialog(dialog,true);


   }
}

