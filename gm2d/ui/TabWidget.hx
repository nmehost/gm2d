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
   var currentWidget:Widget;
   var widgets:Array<Widget>;
   var tabBar:Widget;

   public function new(inWidgets:Array<Widget>, inCurrent:Widget, ?inLineage:Array<String>, ?inAttribs:{})
   {
      widgets = inWidgets.copy();

      super(Widget.addLines(inLineage,["Tabs"]), inAttribs);

      doSetCurrent(inCurrent);
      build();
   }

   public function setCurrent(inWidget:Widget)
   {
      if (inWidget!=currentWidget)
      {
         // TODO - just need to update button states
         doSetCurrent(inWidget);
      }
   }

   override public function addWidget(inWidget:Widget)
   {
      widgets.push(inWidget);
      doSetCurrent(inWidget);
      onChildLayoutChanged();
      return this;
   }

   function doSetCurrent(inWidget:Widget)
   {
      if (currentWidget!=null)
         removeChild(currentWidget);

      if (tabBar!=null)
         removeChild(tabBar);
      tabBar = new Widget(["TabBox"]);
      addChild(tabBar);

      currentWidget = inWidget;
      if (currentWidget!=null)
          addChild(currentWidget);

      var hlayout = new HorizontalLayout();
      var childButton:Widget = null;
      var allWidgets = new StackLayout();
      for(w in widgets)
      {
         var button = Button.TextButton(w.name,function() setCurrent(w) );
         if (w==currentWidget)
         {
            childButton = button;
            button.down = true;
         }
         else
            addChild(button);
         hlayout.add( button.getLayout() );
         allWidgets.add( w.getLayout() );
      }
      if (childButton!=null)
         addChild(childButton);
      tabBar.setItemLayout(hlayout);
      tabBar.build();

      var vlayout = new VerticalLayout();
      vlayout.add(tabBar.getLayout());

      if (currentWidget!=null)
         addChild(currentWidget);

      vlayout.add(allWidgets);
      setItemLayout(vlayout);
   }
}



