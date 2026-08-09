package gm2d.ui;

import nme.text.TextField;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.ui.Keyboard;
import gm2d.ui.Button;
import gm2d.skin.Skin;
import gm2d.ui.Layout;

typedef TitleBarButton = { id:String, onClick:Void->Void }

class TitleBar extends TextLabel
{
   var buttons:Array<TitleBarButton>;

   public function new(inVal="",?inLineage:Array<String>, ?inAttribs:Attribs, ?inButtons:Array<TitleBarButton> )
   {
       buttons = inButtons;
       super(inVal,Widget.addLine(inLineage,"TitleBar"),inAttribs);
   }

   override public function createExtraWidgetLayout() : Layout
   {
      if (buttons==null || buttons.length==0)
         return null;

      var layouts = [ for(b in buttons)
      {
         var button = new Button(null, b.onClick, ["ChromeButton"], { id:b.id } );
         addChild(button);
         button.getLayout();
      } ];

      if (layouts.length==1)
         return layouts[0];

      var h = new HorizontalLayout();
      for(l in layouts)
         h.add(l);
      return h;
   }
}

