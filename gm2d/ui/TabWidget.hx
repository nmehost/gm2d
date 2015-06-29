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
         if (currentWidget!=null)
            removeChild(currentWidget);
         currentWidget = inWidget;
         if (currentWidget!=null)
            addChild(currentWidget);
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
      var lineage:Array<String> = attribDynamic("tabBoxLineage", ["TabBox"]);
      tabBar = new Widget(lineage);
      addChild(tabBar);

      currentWidget = inWidget;
      if (currentWidget!=null)
          addChild(currentWidget);

      var hlayout = new HorizontalLayout();
      var allWidgets = new StackLayout();
      var buttonLineage:Array<String> = attribDynamic("tabButtonLineage",["TabButton"]);
      var group = new RadioGroup<Widget>(setCurrent);
      for(w in widgets)
      {
         var ico = w.getBitmap();
         var button = new Button(buttonLineage, { text:w.name, bitmapData:ico, toggle:true } );
         group.add(button, w);
         addChild(button);
         hlayout.add( button.getLayout() );
         allWidgets.add( w.getLayout() );
      }
      tabBar.setItemLayout(hlayout);
      tabBar.build();

      var vlayout = new VerticalLayout();
      vlayout.add(tabBar.getLayout());

      group.setState(currentWidget);

      vlayout.add(allWidgets.stretch());
      setItemLayout(vlayout);
   }
}



