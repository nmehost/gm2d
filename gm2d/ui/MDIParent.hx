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
import gm2d.Game;

class MDIChildFrame extends Sprite
{
   public var pane(default,null) : Pane;

   static var mNextChildPos = 0;
   var mMDI : MDIParent;
   var mHitBoxes:HitBoxes;
   var mClientWidth:Float;
   var mClientHeight:Float;
   var mClientOffset:Point;
   var mDragStage:gm2d.display.Stage;
	var mIsCurrent:Bool;

   public function new(inPane:Pane, inMDI:MDIParent, inIsCurrent:Bool )
   {
      super();
		mIsCurrent = inIsCurrent;
      pane = inPane;
      mHitBoxes = new HitBoxes(this, onHitBox);
      mMDI = inMDI;
      addChild(inPane.displayObject);

      var rect = inPane.gm2dMDIRect;
      if (rect==null)
      {
         mNextChildPos += 20;
         rect = new Rectangle(mNextChildPos,mNextChildPos, pane.bestWidth, pane.bestHeight );
         if (rect.bottom>mMDI.clientWidth && rect.right>mMDI.clientHeight)
         {
            mNextChildPos = 0;
            rect = new Rectangle(mNextChildPos,mNextChildPos, pane.bestWidth, pane.bestHeight );
         }
         inPane.gm2dMDIRect = rect;
      }
      mClientOffset = Skin.current.getFrameClientOffset();
      pane.displayObject.x = mClientOffset.x;
      pane.displayObject.y = mClientOffset.y;
      x = rect.x;
      y = rect.y;
      mClientWidth = Math.max(rect.width,Skin.current.getMinFrameWidth());

      mClientHeight = rect.height;
      Skin.current.renderFrame(this,inPane,mClientWidth,mClientHeight,mHitBoxes,mIsCurrent);
      addChild(pane.displayObject);
      pane.layout(mClientWidth,mClientHeight);
      inMDI.clientArea.addChild(this);
   }

	public function setCurrent(inIsCurrent:Bool)
	{
	   if (mIsCurrent!=inIsCurrent)
		{
		   mIsCurrent = inIsCurrent;
         Skin.current.renderFrame(this,pane,mClientWidth,mClientHeight,mHitBoxes,mIsCurrent);
		}
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
            else if (id==MiniButton.MAXIMIZE)
               mMDI.maximize(pane);
            redraw();
         case REDRAW:
            redraw();
         default:
      }
   }

   function saveRect()
   {
      pane.gm2dMDIRect = new Rectangle(x,y,mClientWidth,mClientHeight);
   }

   function redraw()
   {
      Skin.current.renderFrame(this,pane,mClientWidth,mClientHeight,mHitBoxes,mIsCurrent);
   }

   function onEndDrag(_)
   {
      mDragStage.removeEventListener(MouseEvent.MOUSE_UP,onEndDrag);
      stopDrag();
      saveRect();
   }

   public function setPosition(inX:Float, inY:Float)
   {
      x = inX;
      y = inY;
   }
}






class MDIParent extends Widget, implements IDock
{
   var mChildren:Array<MDIChildFrame>;
   var mPanes:Array<Pane>;
   public var clientArea(default,null):Sprite;
   public var clientWidth(default,null):Float;
   public var clientHeight(default,null):Float;
   var mTabHeight:Int;
   var mTabArea:Bitmap;
   var mHitBoxes:HitBoxes;
   var mMaximizedPane:Pane;

   public function new()
   {
      super();
      clientArea = new Sprite();
      mHitBoxes = new HitBoxes(this,onHitBox);
      addChild(clientArea);
      mTabArea = new Bitmap();
      addChild(mTabArea);
      mChildren = [];
      mPanes = [];
      mMaximizedPane = null;
      clientWidth = clientHeight = 100.0;
      mTabHeight = 20;
   }

   public function getCurrent() : Pane
   {
      if (mMaximizedPane!=null)
         return mMaximizedPane;
      if (mChildren.length==0)
         return null;
      var obj = clientArea.getChildAt( mChildren.length-1 );
      var child:MDIChildFrame = cast obj;
      if (child==null)
         return null;
      return child.pane;
   }
  
   public function maximize(inPane:Pane)
   {
      for(child in mChildren)
         child.destroy();
      mChildren = [];
      if (clientArea.numChildren==1)
         clientArea.removeChildAt(0);
      if (mMaximizedPane==null)
         clientArea.graphics.clear();
      mMaximizedPane = inPane;
      var d = inPane.displayObject;
      d.x = 0;
      d.y = 0;
      clientArea.addChild(d);
      inPane.layout(clientWidth,clientHeight);
      redrawTabs();
   }
   public function restore()
   {
      mHitBoxes.buttonState[MiniButton.RESTORE] = 0;
      if (mMaximizedPane!=null)
      {
         clientArea.removeChild(mMaximizedPane.displayObject);
         var max = mMaximizedPane;
         mMaximizedPane = null;
         for(pane in mPanes)
         {
            if (!pane.gm2dMinimized)
            {
               var frame = new MDIChildFrame(pane,this,pane==max);
               mChildren.push(frame);
            }
         }
         doLayout();
         max.raise();
      }
   }

   override public function layout(inW:Float,inH:Float):Void
   {
      // TODO: other tab layouts...
      mTabHeight = Skin.current.getTabHeight();
      clientWidth = inW;
      clientHeight = inH-mTabHeight;
      clientArea.y = mTabHeight;
      doLayout();
   }


   function doLayout()
   {
      if (clientHeight<1)
         clientArea.visible = false;
      else
      {
         clientArea.visible = true;
         clientArea.scrollRect = new Rectangle(0,0,clientWidth,clientHeight);
         if (mMaximizedPane!=null)
         {
            clientArea.graphics.clear();
            mMaximizedPane.layout(clientWidth,clientHeight);
         }
         else
            Skin.current.renderMDI(clientArea);
      }

      var bmp = new BitmapData(Std.int(clientWidth), mTabHeight, false);
      mTabArea.bitmapData = bmp;
      redrawTabs();
   }

   public function addPane(inPane:Pane)
   {
      inPane.gm2dSetDock(this);
      mPanes.push(inPane);
      if (mMaximizedPane==null)
      {
         inPane.gm2dMinimized = false;
         var child = new MDIChildFrame(inPane,this,true);
         mChildren.push(child);
         redrawTabs();
      }
      else
         maximize(inPane);
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
	   var current = getCurrent();
	   for(child in mChildren)
		   child.setCurrent(child.pane==current);
		  
      if (mTabArea.bitmapData!=null)
         Skin.current.renderTabs(mTabArea.bitmapData,mPanes,current,mHitBoxes, mMaximizedPane!=null);
   }

	function showPaneMenu()
	{
	   var menu = new MenuItem("Tabs");
		for(pane in mPanes)
		   menu.add( new MenuItem(pane.title, function(_)  pane.raise() ) );
		popup( new PopupMenu(menu), clientWidth-50,mTabHeight);
	}

   function onHitBox(inAction:HitAction)
   {
      switch(inAction)
      {
         case DRAG(pane):
            //trace("Drag:" + pane.title);
            //stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            //mDragStage = stage;
            //startDrag();
         case TITLE(pane):
            pane.raise();
         case BUTTON(pane,id):
            if (id==MiniButton.CLOSE)
               pane.close(false);
            else if (id==MiniButton.RESTORE)
               restore();
            else if (id==MiniButton.POPUP)
				{
			      if (mPanes.length>0)
			         showPaneMenu();
				}
            redrawTabs();
         case REDRAW:
            redrawTabs();
         default:
      }
   }

   // IDock interface
   public function raise(inPane:Pane):Void
   {
      if (mMaximizedPane!=null)
      {
         maximize(inPane);
      }
      else
      {
         var idx = findChildPane(inPane);
         if (idx>=0 && clientArea.getChildIndex(mChildren[idx])<mChildren.length-1)
         {
            clientArea.setChildIndex(mChildren[idx], mChildren.length-1);
            redrawTabs();
         }
      }
   }

    public function remove(inPane:Pane):Void
    {
        if (mMaximizedPane!=null)
        {
           if (mMaximizedPane==inPane)
           {
              if (mPanes.length==1)
                 mMaximizedPane = null;
              else if (mPanes[mPanes.length-1]==inPane)
                 maximize(mPanes[mPanes.length-2]);
              else
                 maximize(mPanes[mPanes.length-1]);
           }
        }
        else
        {
	   var idx = findChildPane(inPane);
	   if (idx>=0)
           {
	      clientArea.removeChild(mChildren[idx]);
	      mChildren.splice(idx,1);
	   }
        }

        var idx = findPaneIndex(inPane);
        mPanes.splice(idx,1);
        redrawTabs();
    }
}


