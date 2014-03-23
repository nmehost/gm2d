package gm2d.ui2;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.skin.Skin;
import gm2d.ui2.Layout;
import gm2d.ui2.HitBoxes;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.events.MouseEvent;

class MiniWin extends Sprite
{
   public var pane(default,null) : Pane;

   var mScreen : Screen;
   var mHitBoxes:HitBoxes;
   var mClientWidth:Float;
   var mClientHeight:Float;
   var mClientOffset:Point;
   var mDragStage:nme.display.Stage;

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
      Skin.current.renderMiniWin(this,pane,new Rectangle(0,0,mClientWidth,mClientHeight),mHitBoxes,true);
      addChild(pane.displayObject);
      mScreen.addChild(this);
   }

   public function destroy()
   {
      parent.removeChild(this);
   }

   function onHitBox(inAction:HitAction, e)
   {
      switch(inAction)
      {
         case DRAG(_pane):
            stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            mDragStage = stage;
            startDrag();
         case TITLE(pane):
            Dock.raise(pane);
         case BUTTON(pane,id):
            if (id==MiniButton.CLOSE)
               pane.closeRequest(false);
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
      Skin.current.renderMiniWin(this,pane,new Rectangle(0,0,mClientWidth,mClientHeight),mHitBoxes,true);
   }

   function onEndDrag(_)
   {
      mDragStage.removeEventListener(MouseEvent.MOUSE_UP,onEndDrag);
      stopDrag();
      saveRect();
   }


}


