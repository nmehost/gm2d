package gm2d.ui;

import gm2d.ui.Layout;
import gm2d.text.TextField;
import gm2d.display.DisplayObjectContainer;

class StaticText
{
   public static function create(inText:String,?inParent:DisplayObjectContainer)
   {
      var label = new TextField();
      Skin.current.styleLabelText(label);
      if (inParent!=null)
         inParent.addChild(label);
      return label;
   }
   public static function createLayout(inText:String,?inParent:DisplayObjectContainer)
   {
      return new TextLayout(create(inText,inParent));
   }
}
