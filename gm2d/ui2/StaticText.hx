package gm2d.ui;

import gm2d.ui.Layout;
import nme.text.TextField;
import nme.display.DisplayObjectContainer;
import gm2d.skin.Skin;
import gm2d.skin.LabelRenderer;

class StaticText
{
   public static function create(inText:String,?inParent:DisplayObjectContainer,?inLabelRenderer:LabelRenderer)
   {
      var label = new TextField();
      var renderer = inLabelRenderer==null ? Skin.current.labelRenderer : inLabelRenderer;
      renderer.styleLabel(label);
      if (inParent!=null)
         inParent.addChild(label);
      return label;
   }
   public static function createLayout(inText:String,?inParent:DisplayObjectContainer)
   {
      return new TextLayout(create(inText,inParent));
   }
}
