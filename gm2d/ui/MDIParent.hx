package gm2d.ui;

import gm2d.geom.Rectangle;
import gm2d.display.Sprite;
import gm2d.text.TextField;
//import gm2d.ui.HitBoxes;
import gm2d.geom.Point;
import gm2d.events.MouseEvent;

class MDIChildFrame extends Sprite
{
   var mMDI : MDIParent;
   var mPane : Pane;
   var mTitle : TextField;
   var mHitBoxes:HitBoxes;
   var mClientWidth:Float;
   var mClientHeight:Float;
   var mClientOffset:Point;
   var mDragStage:gm2d.display.Stage;

   public function new(inPane:Pane, inMDI:MDIParent )
   {
      super();
      mTitle = new TextField();
      addChild(mTitle);
      Skin.current.styleLabelText(mTitle);
      mTitle.text = inPane.title;
      mTitle.y = 2;
      mTitle.x = 2;
      mPane = inPane;
      mHitBoxes = new HitBoxes();
      mMDI = inMDI;
      addChild(inPane.displayObject);
      mClientOffset = Skin.current.getFrameClientOffset();
      mPane.displayObject.x = mClientOffset.x;
      mPane.displayObject.y = mClientOffset.y;
      mClientWidth = mPane.bestWidth;
      mClientHeight = mPane.bestHeight;
      //mPane.displayObject.scrollRect = new Rectangle(20,20,mClientWidth, mClientHeight);
      Skin.current.renderFrame(this,mClientWidth,mClientHeight,mHitBoxes);
      addChild(mPane.displayObject);
      inMDI.addChild(this);
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
   }

   function onMouseDown(event)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==this)
      {
         var action = mHitBoxes.onDown(event.localX, event.localY);
         if (action == HitBoxes.ACT_DRAG)
         {
            stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            mDragStage = stage;
            startDrag();
         }
         else if (action == HitBoxes.ACT_REDRAW)
            redraw();
      }
   }


   function onMouseUp(event)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==this)
      {
         var action = mHitBoxes.onUp(event.localX, event.localY);
         if (action != HitBoxes.ACT_NONE)
         {
            redraw();
            trace(action);
         }
      }
   }



   function onMouseMove(event)
   {
      if (mHitBoxes.onMove(event.localX, event.localY))
         redraw();
   }


   function onMouseOut(event)
   {
      if (mHitBoxes.onMove(-100,-100))
         redraw();
   }


   function redraw()
   {
      Skin.current.renderFrame(this,mClientWidth,mClientHeight,mHitBoxes);
   }

   function onEndDrag(_)
   {
      mDragStage.removeEventListener(MouseEvent.MOUSE_UP,onEndDrag);
      stopDrag();
   }


   public function setPosition(inX:Float, inY:Float)
   {
      x = inX;
      y = inY;
   }

}

class MDIParent extends Widget
{
   public function new()
   {
      super();
   }

   override public function layout(inW:Float,inH:Float):Void
   {
      scrollRect = new Rectangle(0,0,inW,inH);
      Skin.current.renderMDI(this);
   }

   public function addPane(inPane:Pane)
   {
      var child = new MDIChildFrame(inPane,this);
      child.setPosition(10,10);
   }
}


