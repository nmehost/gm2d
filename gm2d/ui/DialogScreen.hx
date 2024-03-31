package gm2d.ui;

import nme.events.MouseEvent;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;
import gm2d.ui.Layout;
import nme.filters.BitmapFilter;
import nme.filters.DropShadowFilter;
import gm2d.ui.HitBoxes;
import nme.geom.Rectangle;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;
import gm2d.Game;
import gm2d.Screen;


class DialogScreen extends Screen implements IDialog
{
   var mPane:Pane;
   public var shouldConsumeEvent : MouseEvent -> Bool;

   public function new(inPane:Pane, ?inLineage:Array<String>, ?inAttribs:{} )
   {
      super(Widget.addLines(inLineage,["DialogScreen","Dialog"]), inAttribs);

      mPane = inPane;

      var obj = mPane.displayObject;
      if (obj!=null)
         addChild(obj);
      //mPane.setDock(this);

      setItemLayout(inPane.itemLayout.stretch());

/*
      var vlayout = new VerticalLayout([0,1]);
      inPane.setDock(null,this);
      vlayout.add(inPane.itemLayout.stretch());
      setItemLayout(vlayout.stretch());
*/
   }

   override public function relayout()
   {
      trace("relayout!");
      super.relayout();
   }

   override public function closeIfDialog()
   {
      Game.popScreen();
   }

   public function closeFrame():Void Game.popScreen();

   public function asDialog():Dialog return null;
   public function asScreen():DialogScreen return this;
}

