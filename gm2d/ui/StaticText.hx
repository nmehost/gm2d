package gm2d.ui;

import gm2d.ui.Layout;
import gm2d.text.TextField;
import gm2d.display.DisplayObjectContainer;

class StaticText
{
   public static function create(inText:String,?inParent:DisplayObjectContainer)
   {
      var label = new TextField();
      label.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      // todo : skin
      label.defaultTextFormat = Panel.labelFormat;
      label.text = inText;
      label.setTextFormat(Panel.labelFormat);
      label.textColor = Panel.labelColor;
      label.selectable = false;
      if (inParent!=null)
         inParent.addChild(label);
      return label;
   }
   public static function createLayout(inText:String,?inParent:DisplayObjectContainer)
   {
      return new TextLayout(create(inText,inParent));
   }
}
