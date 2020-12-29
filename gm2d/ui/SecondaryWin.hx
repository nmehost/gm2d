package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.skin.Skin;
import gm2d.ui.Layout;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import gm2d.ui.HitBoxes;
import nme.events.Event;
import nme.events.MouseEvent;

class SecondaryWin extends DocumentParent implements IDock
{
   var window:nme.app.Window;

   public function new(?pane:Pane,inW:Float, inH:Float)
   {
      super(true);

      var title = pane==null ? nme.Lib.title : pane.getTitle();
      var fps = 0.0;

      window = nme.Lib.createSecondaryWindow(
           Std.int(inW), Std.int(inH), title,
           nme.app.Application.HARDWARE | nme.app.Application.RESIZABLE,
           nme.Lib.nmeStage.opaqueBackground, fps, pane==null ? null : pane.getIcon() );
      var stage = window.stage;
      stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
      stage.addEventListener( Event.RESIZE, (_) -> {
         mLayout.setRect(0,0, stage.stageWidth, stage.stageHeight);
         trace("Layout..." + stage.stageWidth + "," + stage.stageHeight );
         });
      stage.onCloseRequest = onClose;
      stage.current.addChild(this);
      setClientSize(0,0,stage.stageWidth, stage.stageHeight);
   }

   public function onClose()
   {
      getCurrent().closeRequest(true);
   }

   function onDrag()
   {
      var mouse = window.globalMouseState;
      window.setPosition(mouse.x-20,mouse.y-4);
   }

   public function continueDrag(watcher:MouseWatcher)
   {
      onDrag();
      watcher.onDrag = (_) -> onDrag();
   }

   override public function removeDockable(inPane:IDockable):IDockable
   {
      super.removeDockable(inPane);
      if (mDockables.length==0)
         window.close();
      return this;
   }

}



