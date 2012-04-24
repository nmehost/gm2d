package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.ui.Skin;
import gm2d.ui.Layout;
import gm2d.display.Sprite;
import gm2d.geom.Point;
import gm2d.ui.HitBoxes;
import gm2d.events.MouseEvent;

class MiniWin extends Sprite
{
   public var pane(default,null) : Pane;

   var mScreen : Screen;
   var mHitBoxes:HitBoxes;
   var mClientWidth:Float;
   var mClientHeight:Float;
   var mClientOffset:Point;
   var mDragStage:gm2d.display.Stage;

   public function new(inPane:Pane, inScreen:Screen )
   {
      super();
      pane = inPane;
      mHitBoxes = new HitBoxes(this, onHitBox);
      mScreen = inScreen;
      addChild(inPane.displayObject);

      mClientOffset = Skin.current.getMiniWinClientOffset();
      pane.displayObject.x = mClientOffset.x;
      pane.displayObject.y = mClientOffset.y;
      x = 20;
      y = 100;
      alpha = 0.5;
      mClientWidth = 200;
      mClientHeight = 200;
      //pane.displayObject.scrollRect = new Rectangle(20,20,mClientWidth, mClientHeight);
      Skin.current.renderMiniWin(this,inPane,mClientWidth,mClientHeight,mHitBoxes);
      addChild(pane.displayObject);
      mScreen.addChild(this);
   }

   public function destroy()
   {
      parent.removeChild(this);
   }

   function onHitBox(inAction:HitAction)
   {
      switch(inAction)
      {
         case DRAG(pane):
            stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            mDragStage = stage;
            startDrag();
         case TITLE(pane):
            pane.raise();
         case BUTTON(pane,id):
            if (id==MiniButton.CLOSE)
               pane.close(false);
            redraw();
         case REDRAW:
            redraw();
         default:
      }
   }

   function saveRect()
   {
   }

   function redraw()
   {
      Skin.current.renderMiniWin(this,pane,mClientWidth,mClientHeight,mHitBoxes);
   }

   function onEndDrag(_)
   {
      mDragStage.removeEventListener(MouseEvent.MOUSE_UP,onEndDrag);
      stopDrag();
      saveRect();
   }


}


