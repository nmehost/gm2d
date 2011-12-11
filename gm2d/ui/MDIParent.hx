package gm2d.ui;

import gm2d.geom.Rectangle;
import gm2d.display.Sprite;
import gm2d.display.Shape;
import gm2d.display.Bitmap;
import gm2d.display.BitmapData;
import gm2d.display.DisplayObjectContainer;
import gm2d.text.TextField;
//import gm2d.ui.HitBoxes;
import gm2d.geom.Point;
import gm2d.events.MouseEvent;
import gm2d.ui.HitBoxes;
import gm2d.ui.Dock;
import gm2d.Game;

class MDIChildFrame extends Sprite
{
   public var pane(default,null) : IDockable;

   static var mNextChildPos = 0;
   var mMDI : MDIParent;
   var mHitBoxes:HitBoxes;
   var mClientWidth:Int;
   var mClientHeight:Int;
   var mClientOffset:Point;
   var mDragStage:gm2d.display.Stage;
   var mResizeHandle:Sprite;
	var mIsCurrent:Bool;
   var mSizeX0:Int;
   var mSizeY0:Int;

   public function new(inPane:IDockable, inMDI:MDIParent, inIsCurrent:Bool )
   {
      super();
		mIsCurrent = inIsCurrent;
      pane = inPane;
      pane.setContainer(this);
      mHitBoxes = new HitBoxes(this, onHitBox);
      mMDI = inMDI;

      var size = inPane.getBestSize(DOCK_OVER);
      if (size.x<Skin.current.getMinFrameWidth())
         size = inPane.getLayoutSize(Skin.current.getMinFrameWidth(),size.y,true);

      mNextChildPos += 20;
      if (mNextChildPos+size.x>mMDI.clientWidth || mNextChildPos+size.y>mMDI.clientHeight)
         mNextChildPos = 0;
      x = mNextChildPos;
      y = mNextChildPos;

      mClientWidth = Std.int(Math.max(size.x,Skin.current.getMinFrameWidth())+0.99);
      mClientHeight = Std.int(size.y+0.99);
      setClientSize(mClientWidth,mClientHeight);

      mSizeX0 = mClientWidth;
      mSizeY0 = mClientHeight;

      pane.setRect(mClientOffset.x, mClientOffset.y, mClientWidth, mClientHeight);
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
      Skin.current.renderFrame(this,pane,mClientWidth,mClientHeight,mHitBoxes,mIsCurrent);
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
      pane.setContainer(null);
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
         case RESIZE(pane,flags):
            stage.addEventListener(MouseEvent.MOUSE_UP,onEndDrag);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,onUpdateSize);
            mDragStage = stage;
            mResizeHandle = new Sprite();
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

   function redraw()
   {
      Skin.current.renderFrame(this,pane,mClientWidth,mClientHeight,mHitBoxes,mIsCurrent);
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
      saveRect();
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




class MDIParent extends Widget
{
   var mChildren:Array<MDIChildFrame>;
   var mDockables:Array<IDockable>;
   public var clientArea(default,null):Sprite;
   public var clientWidth(default,null):Float;
   public var clientHeight(default,null):Float;
   public var dock(default,null):MDIDock;
   var mTabHeight:Int;
   var mTabArea:Bitmap;
   var mHitBoxes:HitBoxes;
   var mMaximizedPane:IDockable;
   var current:IDockable;

   public function new(inParent:DisplayObjectContainer)
   {
      super();
      clientArea = new Sprite();
      mHitBoxes = new HitBoxes(this,onHitBox);
      addChild(clientArea);
      mTabArea = new Bitmap();
      addChild(mTabArea);
      mChildren = [];
      mDockables = [];
      mMaximizedPane = null;
      clientWidth = clientHeight = 100.0;
      mTabHeight = 20;
      dock = new MDIDock(clientArea,this);
      inParent.addChild(this);
      current = null;
   }

   public function getCurrent() : IDockable
   {
      return current;
   }
  
   public function maximize(inPane:IDockable)
   {
      current = inPane;
      for(child in mChildren)
         child.destroy();
      mChildren = [];
      if (clientArea.numChildren==1)
         clientArea.removeChildAt(0);
      if (mMaximizedPane==null)
         clientArea.graphics.clear();
      mMaximizedPane = inPane;
      inPane.setContainer(clientArea);
      inPane.setRect(0,0,clientWidth,clientHeight);
      redrawTabs();
   }
   public function restore()
   {
      mHitBoxes.buttonState[MiniButton.RESTORE] = 0;
      if (mMaximizedPane!=null)
      {
         current = mMaximizedPane;
         mMaximizedPane.setContainer(null);
         mMaximizedPane = null;
         for(pane in mDockables)
         {
            //if ((pane.getFlags()&DockFlags.MINIMIZED)==0)
            {
               var frame = new MDIChildFrame(pane,this,pane==current);
               mChildren.push(frame);
               clientArea.addChild(frame);
            }
         }
         doLayout();
         current.raise();
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
            mMaximizedPane.setRect(0,0,clientWidth,clientHeight);
         }
         else
            Skin.current.renderMDI(clientArea);
      }

      var bmp = new BitmapData(Std.int(clientWidth), mTabHeight, false);
      mTabArea.bitmapData = bmp;
      redrawTabs();
   }

   public function addDockable(inPane:IDockable)
   {
      inPane.setDock(dock);
      mDockables.push(inPane);
      if (mMaximizedPane==null)
      {
         DockFlags.setMinimized(inPane,false);
         var child = new MDIChildFrame(inPane,this,true);
         mChildren.push(child);
         clientArea.addChild(child);
         current = inPane;
         redrawTabs();
      }
      else
         maximize(inPane);
   }

   function findPaneIndex(inPane:IDockable)
   {
      for(idx in 0...mDockables.length)
         if (mDockables[idx]==inPane)
            return idx;
      return -1;
   }


   function findChildPane(inPane:IDockable)
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
         Skin.current.renderTabs(mTabArea.bitmapData,mDockables,current,mHitBoxes, mMaximizedPane!=null);
   }

	function showPaneMenu()
	{
	   var menu = new MenuItem("Tabs");
		for(pane in mDockables)
		   menu.add( new MenuItem(pane.getShortTitle(), function(_)  pane.raise() ) );
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
			      if (mDockables.length>0)
			         showPaneMenu();
				}
            redrawTabs();
         case REDRAW:
            redrawTabs();
         default:
      }
   }

   public function raise(inPane:IDockable):Void
   {
      if (mMaximizedPane!=null)
      {
         maximize(inPane);
      }
      else
      {
         var idx = findChildPane(inPane);
         current = inPane;
         if (idx>=0 && clientArea.getChildIndex(mChildren[idx])<mChildren.length-1)
         {
            clientArea.setChildIndex(mChildren[idx], mChildren.length-1);
            redrawTabs();
         }
      }
   }

    public function remove(inPane:IDockable):Void
    {
        if (mMaximizedPane!=null)
        {
           if (mMaximizedPane==inPane)
           {
              if (mDockables.length==1)
                 mMaximizedPane = null;
              else if (mDockables[mDockables.length-1]==inPane)
                 maximize(mDockables[mDockables.length-2]);
              else
                 maximize(mDockables[mDockables.length-1]);
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
        mDockables.splice(idx,1);
        redrawTabs();
    }
}


