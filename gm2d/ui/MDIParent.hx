package gm2d.ui;

import gm2d.geom.Rectangle;
import gm2d.display.Sprite;
import gm2d.display.Shape;
import gm2d.display.Bitmap;
import gm2d.display.BitmapData;
import gm2d.text.TextField;
//import gm2d.ui.HitBoxes;
import gm2d.geom.Point;
import gm2d.events.MouseEvent;
import gm2d.ui.HitBoxes;

class MDIChildFrame extends Sprite
{
   public var pane(default,null) : Pane;

   var mMDI : MDIParent;
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
      pane = inPane;
      mHitBoxes = new HitBoxes();
      mMDI = inMDI;
      addChild(inPane.displayObject);
      mClientOffset = Skin.current.getFrameClientOffset();
      pane.displayObject.x = mClientOffset.x;
      pane.displayObject.y = mClientOffset.y;
      mClientWidth = pane.bestWidth;
      mClientHeight = pane.bestHeight;
      //pane.displayObject.scrollRect = new Rectangle(20,20,mClientWidth, mClientHeight);
      Skin.current.renderFrame(this,inPane,mClientWidth,mClientHeight,mHitBoxes);
      addChild(pane.displayObject);
      inMDI.clientArea.addChild(this);
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
			pane.raise();
         switch(mHitBoxes.onDown(event.localX, event.localY))
			{
			   case DRAG:
               stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
               mDragStage = stage;
               startDrag();
            case REDRAW:
               redraw();
				default:
			}
      }
   }


   function onMouseUp(event)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==this)
      {
         switch(mHitBoxes.onUp(event.localX, event.localY))
			{
			   case NONE:
			   case BUTTON(pane,id):
	             if (id==MiniButton.CLOSE)
		             pane.close(false);
               redraw();
				default:
               redraw();
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
      Skin.current.renderFrame(this,pane,mClientWidth,mClientHeight,mHitBoxes);
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

class MDIParent extends Widget, implements IDock
{
   var mNextChildPos:Int;
	var mChildren:Array<MDIChildFrame>;
	var mPanes:Array<Pane>;
	public var clientArea(default,null):Sprite;
	var mTabArea:Bitmap;

   public function new()
   {
      super();
		clientArea = new Sprite();
		addChild(clientArea);
		mTabArea = new Bitmap();
		addChild(mTabArea);
	   mNextChildPos = 0;
		mChildren = [];
		mPanes = [];
   }

	public function getCurrent() : Pane
	{
	   if (mChildren.length==0)
		   return null;
		var obj = clientArea.getChildAt( mChildren.length-1 );
		var child:MDIChildFrame = cast obj;
		if (child==null)
		   return null;
		return child.pane;
	}

   override public function layout(inW:Float,inH:Float):Void
   {
	   // TODO: other tab layouts...
		var tab_height = Skin.current.getTabHeight();
		if (inH<tab_height)
		   clientArea.visible = false;
	   else
		{
		   clientArea.visible = true;
			clientArea.y = tab_height;
         clientArea.scrollRect = new Rectangle(0,0,inW,inH-tab_height);
         Skin.current.renderMDI(clientArea);
		}

      var bmp = new BitmapData(Std.int(inW), tab_height, false);
		mTabArea.bitmapData = bmp;
		redrawTabs();
   }

   public function addPane(inPane:Pane)
   {
		inPane.gm2dSetDock(this);
      var child = new MDIChildFrame(inPane,this);
		mChildren.push(child);
		mPanes.push(inPane);
      child.setPosition(mNextChildPos,mNextChildPos);
		mNextChildPos += 10;
		redrawTabs();
   }

	function findPaneIndex(inPane:Pane)
	{
	   for(idx in 0...mPanes.length)
		   if (mPanes[idx]==inPane)
			   return idx;
		return -1;
	}


	function findChildPane(inPane:Pane)
	{
	   for(idx in 0...mChildren.length)
		   if (mChildren[idx].pane==inPane)
			   return idx;
		return -1;
	}

	function redrawTabs()
	{
	   if (mTabArea.bitmapData!=null)
         Skin.current.renderTabs(mTabArea.bitmapData,mPanes,getCurrent());
	}

   // IDock interface
	public function raise(inPane:Pane):Void
	{
	   var idx = findChildPane(inPane);
		if (idx>=0 && clientArea.getChildIndex(mChildren[idx])<mChildren.length-1)
		{
	      clientArea.setChildIndex(mChildren[idx], mChildren.length-1);
			redrawTabs();
		}
	}

	 public function remove(inPane:Pane):Void
	 {
	   var idx = findChildPane(inPane);
		if (idx>=0)
		{
	      clientArea.removeChild(mChildren[idx]);
		   mChildren.splice(idx,1);
		}
	   var idx = findPaneIndex(inPane);
		mPanes.splice(idx,1);
		redrawTabs();
	 }
}


