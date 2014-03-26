package gm2d.ui;

import nme.geom.Rectangle;
import nme.display.Sprite;
import nme.display.Shape;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
//import gm2d.ui.HitBoxes;
import nme.geom.Point;
import nme.events.MouseEvent;
import gm2d.ui.HitBoxes;
import gm2d.ui.Dock;
import gm2d.ui.DockPosition;
import gm2d.Game;
import gm2d.skin.Skin;
import gm2d.ui.WidgetState;


class MDIParent extends Widget implements IDock implements IDockable
{
   var parentDock:IDock;
   var mChildren:Array<MDIChildFrame>;
   var mDockables:Array<IDockable>;
   public var clientArea(default,null):Sprite;
   public var clientWidth(default,null):Float;
   public var clientHeight(default,null):Float;
   var mTabContainer:Sprite;
   var mTopLevel:TopLevelDock;
   var mHitBoxes:HitBoxes;
   var mMaximizedPane:IDockable;
   var current:IDockable;
   var properties:Dynamic;
   var flags:Int;
   var sizeX:Float;
   var sizeY:Float;

   public function new()
   {
      super();
      mTabContainer = new Sprite();
      mTabContainer.name = "Tabs";
      addChild(mTabContainer);
      clientArea = new Sprite();
      clientArea.name = "Client area";
      clientWidth = 100;
      clientHeight = 100;
      properties = {};
      mHitBoxes = new HitBoxes(this,onHitBox);
      addChild(clientArea);
      mChildren = [];
      mDockables = [];
      mMaximizedPane = null;
      clientWidth = clientHeight = 100.0;
      sizeX = sizeY = 0;
      current = null;
      flags = 0;
   }

   public function setTopLevel(inTopLevel:TopLevelDock)
   {
      mTopLevel = inTopLevel;
   }

   // --- IDock --------------------------------------------------------------

   public function canAddDockable(inPos:DockPosition):Bool { return inPos==DOCK_OVER; }
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPosition:DockPosition)
   {
      throw "Bad dock position";
   }

   public function addDockable(inChild:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      if (inPos!=DOCK_OVER)
         throw "Bad dock position";
      Dock.remove(inChild);
      mDockables.push(inChild);
      if (mMaximizedPane==null)
      {
         var child = new MDIChildFrame(inChild,this,true);
         mChildren.push(child);
         clientArea.addChild(child);
         current = inChild;
         redrawTabs();
      }
      else
      {
         inChild.setDock(this,clientArea);
         maximize(inChild);
      }
   }
   public function getDockablePosition(child:IDockable):Int
   {
      for(i in 0...mDockables.length)
         if (mDockables[i]==child)
           return i;
      return -1;
   }


   public function removeDockable(inPane:IDockable):IDockable
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
       if (inPane==current)
       {
          current = mDockables.length>0 ? mDockables[0] : null;
       }
 
       redrawTabs();
       return this;
   }

   public function getSlot():Int { return mMaximizedPane==null ? Dock.DOCK_SLOT_MDI : Dock.DOCK_SLOT_MDIMAX; }

   public function raiseDockable(child:IDockable):Bool
   {
      if (mMaximizedPane!=null)
      {
         maximize(child);
         if (mMaximizedPane!=child)
           return false;
      }
      else
      {
         var idx = findChildPane(child);
         if (idx<0)
            return false;
         current = child;
         current.raiseDockable(current);
         if (idx>=0 && clientArea.getChildIndex(mChildren[idx])<mChildren.length-1)
         {
            clientArea.setChildIndex(mChildren[idx], mChildren.length-1);
            redrawTabs();
            for(child in mChildren)
              child.setState(child.pane==current ? WidgetCurrent : WidgetNormal );
         }
      }
      return true;
   }

   public function minimizeDockable(child:IDockable):Bool
   {
      // todo
      return false;
   }






   // --- IDockable --------------------------------------------------------------

   // Hierarchy
   public function getDock():IDock { return parentDock; }
   public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void
   {
      parentDock = inDock;
      if (inParent!=parent)
         if (inParent!=null)
            inParent.addChild(this);
         else
            parent.removeChild(this);
   }
   public function closeRequest(inForce:Bool):Void {  }
   // Display
   public function getTitle():String { return ""; }
   public function getShortTitle():String { return ""; }
   public function getIcon():nme.display.BitmapData { return null; }
   public function getFlags():Int { return flags; }
   public function setFlags(inFlags:Int):Void { flags = inFlags; }
   // Layout
   public function getBestSize(inPos:Int):Size
   {
      var chrome = Skin.current.getMDIClientChrome();
      return new Size(clientWidth+chrome.width,clientHeight+chrome.height);
   }
   public function getProperties() : Dynamic { return properties; }
   public function getMinSize():Size { return new Size(1,1); }
   public function getLayoutSize(w:Float,h:Float,inLimitX:Bool):Size
   {
      var min = getMinSize();
      return new Size(w<min.x ? min.x : w,h<min.y ? min.y : h);
   }

   public function isLocked():Bool { return false; }



   override public function setRect(inX:Float,inY:Float,w:Float,h:Float):Void
   {
      x = inX;
      y = inY;
      super.setRect(inX,inY,w,h);
   }
   public function getDockRect():Rectangle
   {
      return new Rectangle(x, y, sizeX, sizeY );
   }

   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      // Do nothing for now...
   }

   public function renderChrome(inBackground:Sprite,outHitBoxes:HitBoxes):Void
   {
   }

   public function asPane() : Pane { return null; }


   public function addDockZones(outZones:DockZones):Void
   {
      var rect = new Rectangle(x,y,clientWidth, clientHeight);

      if (rect.contains(outZones.x,outZones.y))
      {
         var skin = Skin.current;
         var dock = getDock();
         skin.renderDropZone(rect,outZones,DOCK_LEFT,true,   function(d) dock.addSibling(this,d,DOCK_LEFT) );
         skin.renderDropZone(rect,outZones,DOCK_RIGHT,true,  function(d) dock.addSibling(this,d,DOCK_RIGHT));
         skin.renderDropZone(rect,outZones,DOCK_TOP,true,    function(d) dock.addSibling(this,d,DOCK_TOP) );
         skin.renderDropZone(rect,outZones,DOCK_BOTTOM,true, function(d) dock.addSibling(this,d,DOCK_BOTTOM) );
         skin.renderDropZone(rect,outZones,DOCK_OVER,true,   function(d) addDockable(d,DOCK_OVER,0) );
      }
   }


   public function getLayoutInfo():Dynamic
   {
      var dockables = new Array<Dynamic>();
      for(i in 0...mDockables.length)
         dockables[i] = mDockables[i].getLayoutInfo();

      return { type:"MDIParent",
          sizeX:sizeX,  sizeY:sizeY,
          dockables:dockables, properties:properties, flags:flags,
          current:current==null ? null : current.getTitle() };
   }

   public function loadLayout(inLayout:Dynamic):Void
   {
      sizeX = inLayout.sizeX==null ? sizeX : inLayout.sizeX;
      sizeY = inLayout.sizeY==null ? sizeY : inLayout.sizeY;
   }


   // ---------------------------------------------------------------------------

   public function getCurrent() : IDockable
   {
      return current;
   }
  
   public function maximize(inPane:IDockable)
   {
      if (inPane==mMaximizedPane)
         return;

      if (mMaximizedPane!=null)
         mMaximizedPane.setDock(this,null);

      current = inPane;
      for(child in mChildren)
         child.destroy();
      mChildren = [];
      if (clientArea.numChildren==1)
         clientArea.removeChildAt(0);

      mMaximizedPane = inPane;
      if (mMaximizedPane!=null)
      {
         mMaximizedPane.raiseDockable(mMaximizedPane);
         clientArea.graphics.clear();
      }

      for(child in mChildren)
         child.setState(child.pane==current ? WidgetCurrent : WidgetNormal);

      inPane.setDock(this,clientArea);
      inPane.setRect(0,0,clientWidth,clientHeight);
      redrawTabs();
   }
   public function restore()
   {
      if (mMaximizedPane!=null)
      {
         current = mMaximizedPane;
         mMaximizedPane.setDock(this,null);
         mMaximizedPane = null;
         for(pane in mDockables)
         {
            //if ((pane.getFlags()&Dock.MINIMIZED)==0)
            {
               var frame = new MDIChildFrame(pane,this,pane==current);
               mChildren.push(frame);
               clientArea.addChild(frame);
            }
         }
         redraw();
         raiseDockable(current);
      }
   }

   public function verify() { }


   override public function redraw()
   {
      // TODO: other tab layouts...
      var chrome = Skin.current.getMDIClientChrome();
      sizeX = mRect.width;
      sizeY = mRect.height;
      clientWidth = sizeX-chrome.width;
      clientHeight = sizeY-chrome.height;
      clientArea.x = chrome.x;
      clientArea.y = chrome.y;

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

      redrawTabs();
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
      while(mTabContainer.numChildren>0)
         mTabContainer.removeChildAt(0);
       mHitBoxes.clear();

      Skin.current.renderTabs(mTabContainer,new Rectangle(0,0,sizeX,sizeY) ,mDockables, getCurrent(),mHitBoxes, mMaximizedPane!=null);
   }

	function showPaneMenu(inX:Float, inY:Float)
	{
	   var menu = new MenuItem("Tabs");
		for(pane in mDockables)
		   menu.add( new MenuItem(pane.getShortTitle(), function(_)  Dock.raise(pane) ) );
		popup( new PopupMenu(menu), inX, inY);
	}

   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         case DRAG(p):
            mTopLevel.floatWindow(p,inEvent,null);
         case TITLE(pane):
            Dock.raise(pane);
         case BUTTON(pane,id):
            if (id==MiniButton.CLOSE)
               pane.closeRequest(false);
            else if (id==MiniButton.RESTORE)
               restore();
            else if (id==MiniButton.POPUP)
				{
			      if (mDockables.length>0)
			         showPaneMenu(inEvent.localX, inEvent.localY);
				}
            redrawTabs();
         case REDRAW:
            redrawTabs();
         default:
      }
   }
}




