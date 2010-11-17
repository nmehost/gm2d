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
	//var mHitBoxes:HitBoxes;
	var mClientWidth:Float;
	var mClientHeight:Float;
	var mClientOffset:Point;
	var mDragStage:gm2d.display.Stage;
	var mButtonStates:Array<Int>;

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
		mButtonStates = [];
		mMDI = inMDI;
		addChild(inPane.displayObject);
		mClientOffset = Skin.current.getFrameClientOffset();
		mPane.displayObject.x = mClientOffset.x;
		mPane.displayObject.y = mClientOffset.y;
		mClientWidth = mPane.bestWidth;
		mClientHeight = mPane.bestHeight;
		//mPane.displayObject.scrollRect = new Rectangle(20,20,mClientWidth, mClientHeight);
		Skin.current.renderFrame(this,mClientWidth,mClientHeight);
		addChild(mPane.displayObject);
		inMDI.addChild(this);
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}

	function onMouseDown(event)
	{
	   var obj:gm2d.display.DisplayObject = event.target;
	   if (obj==this)
		{
	      stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
		   mDragStage = stage;
	      startDrag();
		}
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


