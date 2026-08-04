package gm2d.ui;

import nme.text.TextField;
import gm2d.skin.Skin;

class TextButton extends Button
{
   public function new(?inSkin:Skin, inText:String, inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:Attribs)
   {
      var skin = Skin.getSkin(inSkin);
      var renderer = skin.renderer(Widget.addLines(inLineage,["ButtonText","Button","StaticText","Text"]),0,inAttribs);
      var label = new TextField();
      label.text = inText;
      renderer.renderLabel(label);
      label.selectable = false;
      super(label, inOnClick, Widget.addLine(inLineage,"TextButton"), inAttribs);
   }
}
