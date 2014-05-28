package gm2d.ui;

import gm2d.ui.Layout;
import nme.text.TextField;
import nme.display.DisplayObjectContainer;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;

class StaticText
{
   public static function create(inText:String,?inParent:DisplayObjectContainer)
   {
      var label = new TextField();
      label.text = inText;
      var renderer = Skin.renderer(["StaticText","Text"]);
      renderer.renderLabel(label);
      label.autoSize = nme.text.TextFieldAutoSize.LEFT;
      if (inParent!=null)
         inParent.addChild(label);
      return label;
   }
   public static function createLayout(inText:String,?inParent:DisplayObjectContainer)
   {
      return new TextLayout(create(inText,inParent));
   }
}
