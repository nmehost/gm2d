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
   var mSize:Size;
   var mouseWatcher:MouseWatcher;
   var dragStage:nme.display.Stage;
   public var shouldConsumeEvent : MouseEvent -> Bool;

   public function new(inPane:Pane, ?inAttribs:Dynamic, ?inLineage:Array<String>)
   {
      super(Widget.addLines(inLineage,["DialogScreen"]), inAttribs);

      mPane = inPane;

      var vlayout = new VerticalLayout([0,1]);

      inPane.setDock(null,this);
      vlayout.add(inPane.itemLayout.stretch());
      setItemLayout(vlayout.stretch());
 
   }

   override public function closeIfDialog()
   {
      Game.popScreen();
   }


   public function closeFrame():Void Game.popScreen();
   public function asDialog():Dialog return null;
}

