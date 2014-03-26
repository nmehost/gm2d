package gm2d.ui;

import nme.geom.Rectangle;
import nme.display.Sprite;
import nme.geom.Point;
import nme.events.MouseEvent;
import gm2d.ui.HitBoxes;
import gm2d.ui.Dock;
import gm2d.ui.DockPosition;
import gm2d.skin.Skin;


// --- MDIChildFrame ----------------------------------------------------------------------



class MDIChildFrame extends Widget
{
   public var pane(default,null) : IDockable;

   static var mNextChildPos = 0;
   var mMDI : MDIParent;
   var mHitBoxes:HitBoxes;
   var mClientWidth:Int;
   var mClientHeight:Int;
   var mClientOffset:Point;
   var mDragStage:nme.display.Stage;
   var mPaneContainer:Sprite;
   var mResizeHandle:Sprite;
	var mIsCurrent:Bool;
   var mSizeX0:Int;
   var mSizeY0:Int;

   public function new(inPane:IDockable, inMDI:MDIParent, inIsCurrent:Bool )
   {
      super("MDIChildFrame");
      mIsCurrent = inIsCurrent;
      mMDI = inMDI;
      mPaneContainer = new Sprite();
      addChild(mPaneContainer);
 
      pane = inPane;
      pane.setDock(mMDI,mPaneContainer);
      mHitBoxes = new HitBoxes(this, onHitBox);

      var size = inPane.getBestSize( Dock.DOCK_SLOT_FLOAT );
      if (size.x<Skin.current.getMinFrameWidth())
         size = inPane.getLayoutSize(Skin.current.getMinFrameWidth(),size.y,true);

      var props:Dynamic = inPane.getProperties();
      var pos_x:Dynamic = props.mdiX;
      var pos_y:Dynamic = props.mdiY;
      if (pos_x==null || pos_y==null)
      {
         mNextChildPos += 20;
         x = props.mdiX = mNextChildPos;
         y = props.mdiY = mNextChildPos;
      }
      else
      {
         x = pos_x;
         y = pos_y;
      }

      if (x>mMDI.clientWidth-20 || y>mMDI.clientHeight-20)
      {
         mNextChildPos = 0;
         x = y = mNextChildPos;
         props.mdiX = props.mdiY = mNextChildPos;
      }

      mClientWidth = Std.int(Math.max(size.x,Skin.current.getMinFrameWidth())+0.99);
      mClientHeight = Std.int(size.y+0.99);
      setClientSize(mClientWidth,mClientHeight);

      mSizeX0 = mClientWidth;
      mSizeY0 = mClientHeight;

      pane.setRect(mClientOffset.x, mClientOffset.y, mClientWidth, mClientHeight);
   }

   public function loadLayout(inProperties:Dynamic)
   {
   }

   public function setClientSize(inW:Int, inH:Int)
   {
      var minW = Skin.current.getMinFrameWidth();
      mClientWidth = Std.int(Math.max(inW,minW));
      mClientHeight = Std.int(Math.max(inH,1));
      var size = pane.getLayoutSize(mClientWidth,mClientHeight,true);
      if (size.x<minW)
         size = pane.getLayoutSize(minW,mClientHeight,true);
      mClientWidth = Std.int(size.x);
      mClientHeight = Std.int(size.y);
      mClientOffset = Skin.current.getFrameClientOffset();
      pane.setRect(mClientOffset.x, mClientOffset.y, mClientWidth, mClientHeight);
      redraw();
   }

/*
	public function setCurrent(inIsCurrent:Bool)
	{
	   if (mIsCurrent!=inIsCurrent)
		{
		   mIsCurrent = inIsCurrent;
         redraw();
		}
	}
*/


   public function destroy()
   {
      pane.setDock(mMDI,null);
      parent.removeChild(this);
   }

   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
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
            else if (id==MiniButton.MAXIMIZE)
               mMDI.maximize(pane);
            redraw();
         case REDRAW:
            redraw();
         case RESIZE(_pane,_flags):
            stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,onUpdateSize);
            mDragStage = stage;
            mResizeHandle = new Sprite();
            mResizeHandle.name = "Resize handle";
            mSizeX0 = mClientWidth;
            mSizeY0 = mClientHeight;
            addChild(mResizeHandle);
            mResizeHandle.startDrag();
         default:
      }
   }

   function saveRect()
   {
      //pane.gm2dMDIRect = new Rectangle(x,y,mClientWidth,mClientHeight);
   }

   override public function redraw()
   {
      clearChrome();
      Skin.current.renderFrame(mChrome,pane,mClientWidth,mClientHeight,mHitBoxes,mIsCurrent);
   }

   function onEndDrag(_)
   {
      mDragStage.removeEventListener(MouseEvent.MOUSE_UP,onEndDrag);
      if (mResizeHandle!=null)
      {
         mDragStage.removeEventListener(MouseEvent.MOUSE_MOVE,onUpdateSize);
         removeChild(mResizeHandle);
         mResizeHandle.stopDrag();
         mResizeHandle = null;
      }
      else
         stopDrag();
      var props:Dynamic = pane.getProperties();
      props.mdiX = x;
      props.mdiY = y;
   }

   function onUpdateSize(_)
   {
      if (mResizeHandle!=null)
      {
         var cw = Std.int(mResizeHandle.x + mSizeX0 );
         var ch = Std.int(mResizeHandle.y + mSizeY0  );
         setClientSize(cw,ch);
      }
   }

   public function setPosition(inX:Float, inY:Float)
   {
      x = inX;
      y = inY;
   }
}



