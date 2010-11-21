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
      mHitBoxes = new HitBoxes(this, onHitBox);
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
   var mClientWidth:Float;
   var mClientHeight:Float;
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
      mNextChildPos = 0;
      mChildren = [];
      mPanes = [];
      mMaximizedPane = null;
      mClientWidth = mClientHeight = 100.0;
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
      inPane.layout(mClientWidth,mClientHeight);
      redrawTabs();
   }

   override public function layout(inW:Float,inH:Float):Void
   {
      // TODO: other tab layouts...
      var tab_height = Skin.current.getTabHeight();
      if (inH<tab_height)
         clientArea.visible = false;
      else
      {
         mClientWidth = inW;
         mClientHeight = inH-tab_height;
         clientArea.visible = true;
         clientArea.y = tab_height;
         clientArea.scrollRect = new Rectangle(0,0,mClientWidth,mClientHeight);
         if (mMaximizedPane!=null)
         {
            clientArea.graphics.clear();
            mMaximizedPane.layout(mClientWidth,mClientHeight);
         }
         else
            Skin.current.renderMDI(clientArea);
      }

      var bmp = new BitmapData(Std.int(inW), tab_height, false);
      mTabArea.bitmapData = bmp;
      redrawTabs();
   }

   public function addPane(inPane:Pane)
   {
      inPane.gm2dSetDock(this);
      mPanes.push(inPane);
      if (mMaximizedPane==null)
      {
         var child = new MDIChildFrame(inPane,this);
         mChildren.push(child);
         child.setPosition(mNextChildPos,mNextChildPos);
         mNextChildPos += 10;
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
      if (mTabArea.bitmapData!=null)
         Skin.current.renderTabs(mTabArea.bitmapData,mPanes,getCurrent(),mHitBoxes);
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


