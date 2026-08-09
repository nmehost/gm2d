package gm2d.ui;

import gm2d.ui.Layout;
import gm2d.skin.Skin;
import nme.display.BitmapData;
import nme.text.TextField;


class GroupBox extends Widget
{
   var icon:BitmapData;
   var title:TextLabel;

   public function new(inTitle:String, inIcon:BitmapData, inLayout:Layout,
     ?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super(Widget.addLine(inLineage,"GroupBox"), inAttribs);
      icon = inIcon;
      name = inTitle;

      wantFocus = false;

      cacheAsBitmap = true;

      if (inTitle!="")
      {
         title = new TextLabel(inTitle,["GroupBoxTitle"]);
         title.x = 2;
         title.y = 0;
         addChild(title);
      }

      setItemLayout(inLayout);
      build();
   }
   override public function onLayout(x,y,w,h)
   {
      super.onLayout(x,y,w,h);
      var margin = mRenderer.margin;
      if (title!=null && margin!=null)
      {
         title.y = -margin.y;
         title.x = margin.x;
      }
   }

}

