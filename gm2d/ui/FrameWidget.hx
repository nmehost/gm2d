package gm2d.ui;

import nme.text.TextFormat;
import gm2d.ui.Layout;
import nme.filters.BitmapFilter;
import nme.filters.DropShadowFilter;
import gm2d.ui.HitBoxes;
import nme.geom.Rectangle;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;


class FrameWidget extends Widget
{
   var child:Widget;

   public function new(inChild:Widget, ?inLineage:Array<String>, ?inAttribs:{})
   {
      child = inChild;
      super(Widget.addLines(inLineage,["Frame"]), inAttribs);

      var titleLineage:Array<String> = attrib("titleLineage");
      if (titleLineage!=null)
      {
         var vlayout = new VerticalLayout();
         var title = new TextLabel(child.name, titleLineage);
         addChild(title);
         vlayout.add( title.getLayout() );
         addChild(child);
         vlayout.add( child.getLayout() );
         setItemLayout(vlayout);
      }
      else
      {
         addWidget(child);
      }
      build();
   }
}


