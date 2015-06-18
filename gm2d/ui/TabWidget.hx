package gm2d.ui;

import nme.text.TextFormat;
import gm2d.ui.Layout;
import nme.filters.BitmapFilter;
import nme.filters.DropShadowFilter;
import gm2d.ui.HitBoxes;
import nme.geom.Rectangle;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;


class TabWidget extends Widget
{
   var child:Widget;
   var widgets:Array<Widget>;

   public function new(inWidgets:Array<Widget>, inCurrent:Widget, ?inLineage:Array<String>, ?inAttribs:{})
   {
      widgets = inWidgets.copy();
      child = inCurrent;

      super(Widget.addLines(inLineage,["Tabs"]), inAttribs);
      var vlayout = new VerticalLayout();
      var tabBar = new Widget(["TabBox"]);
      addChild(tabBar);

      var hlayout = new HorizontalLayout();
      var childButton:Widget = null;
      for(w in widgets)
      {
         var button = Button.TextButton(w.name,function() trace("Click") );
         trace(w.name);
         if (w==child)
         {
            childButton = button;
            button.down = true;
         }
         else
            addChild(button);
         hlayout.add( button.getLayout() );
      }
      if (childButton!=null)
         addChild(childButton);
      tabBar.setItemLayout(hlayout);
      tabBar.build();

      vlayout.add(tabBar.getLayout());

      addChild(child);
      vlayout.add( child.getLayout() );
      setItemLayout(vlayout);
      build();
   }
}



