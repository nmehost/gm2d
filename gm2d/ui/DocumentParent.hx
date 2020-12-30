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
import gm2d.skin.FillStyle;
import gm2d.skin.Skin;
import gm2d.ui.WidgetState;
import gm2d.ui.Layout;


class DocumentParent extends Sprite implements IDock implements IDockable
{
   static var allParents:Array<DocumentParent>;
   var parentDock:IDock;
   var mChildren:Array<DockFrame>;
   var mDockables:Array<IDockable>;
   public var clientArea(default,null):Sprite;
   public var clientLayout : Layout;
   public var clientWidth(default,null):Float;
   public var clientHeight(default,null):Float;
   var tabBar:TabBar;
   var mTopLevel:TopLevelDock;
   var mMaximizedPane:IDockable;
   var mLayout:Layout;
   var singleDocument:Bool;
   var current:IDockable;
   var properties:Dynamic;
   var flags:Int;
   var sizeX:Float;
   var sizeY:Float;
   var dockX:Float;
   var dockY:Float;

   public function new(inSingleDocument:Bool)
   {
      //super(["DocumentParent", "Dock", "Widget"] );
      super();

      if (allParents==null)
         allParents = [this];
      else
         allParents.push(this);

      singleDocument = inSingleDocument;

      clientArea = new Sprite();
      clientArea.name = "Client area";
      properties = {};
      addChild(clientArea);

      mDockables = [];
      if (!singleDocument)
      {
         tabBar = new TabBar(mDockables,onHitBox,true);
         tabBar.applyStyles();
         addChild(tabBar);
      }

      mChildren = [];
      mMaximizedPane = null;
      clientWidth = clientHeight = 100.0;
      dockX = dockY = 0;
      sizeX = sizeY = 0;
      current = null;
      flags = Dock.RESIZABLE;

      clientLayout = new DisplayLayout(clientArea, Layout.AlignStretch, clientWidth, clientHeight);
      clientLayout.setAlignment(Layout.AlignStretch);
      clientLayout.onLayout = setClientSize;

      if (singleDocument)
      {
         mLayout =  clientLayout;
      }
      else
      {
         mLayout = new VerticalLayout([0,1],"MDI");
         mLayout.setAlignment(Layout.AlignStretch);
         mLayout.add(tabBar.getLayout());
         mLayout.add( clientLayout );
         //mLayout.setRowStretch(0,0);
      }
      mLayout.setMinSize( Skin.scale(50), Skin.scale(50) );
   }

   function unregister()
   {
      allParents.remove(this);
   }

   public static function showGlobalDockZones(gx:Int, gy:Int, ignoreDock:DocumentParent)
   {
      var found = false;
      for(dock in allParents)
      {
         if (dock.mTopLevel==null)
            continue;
         if (dock==ignoreDock || found)
            dock.mTopLevel.clearOverlay();
         else
         {
            var s = dock.stage;
            var win = s.window;
            var wx = win.x;
            var w =  s.stageWidth;
            var wy = win.y;
            var h =  s.stageHeight;

            if (gx>=wx && gx<wx+w && gy>wy && gy<wy+h)
            {
               dock.mTopLevel.showDockZonesAt(gx-wx, gy-wy);
               found = true;
            }
            else
               dock.mTopLevel.clearOverlay();
         }
      }
   }

   public static function dropGlobalDockZones(pane:Pane,gx:Int, gy:Int, ignoreDock:DocumentParent)
   {
      for(dock in allParents)
      {
         if (dock.mTopLevel!=null && dock!=ignoreDock)
         {
            var s = dock.stage;
            var win = s.window;
            var wx = win.x;
            var w =  s.stageWidth;
            var wy = win.y;
            var h =  s.stageHeight;

            if (gx>=wx && gx<wx+w && gy>wy && gy<wy+h)
            {
               dock.mTopLevel.finishDockDragAt(pane,gx-wx, gy-wy);
               break;
            }
         }
      }
   }


   public static function hideGlobalDropZones()
   {
      for(d in allParents)
      {
         if (d.mTopLevel==null)
            continue;
         d.mTopLevel.clearOverlay();
      }
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

   function addFrame(pane:Pane)
   {
      var child = new DockFrame(pane,this, {
           onPaneMaximize : function() maximize(pane)
         });
      mChildren.push(child);
      clientArea.addChild(child);
   }

   public function hasBestSize() return false;

   public function addDockable(inChild:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      if (inPos!=DOCK_OVER)
         throw "Bad dock position";
      Dock.remove(inChild);
      if (singleDocument && mDockables.length>0)
         throw "Too many documents";
      mDockables.push(inChild);
      if ( (mMaximizedPane==null && inChild.asPane()!=null) || singleDocument)
      {
         var pane = inChild.asPane();
         addFrame(pane);
         current = inChild;
         maximize(inChild);
      }
      else
      {
         inChild.setDock(this,null);
         redrawTabs();
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

   public function getSlot():Int { return mMaximizedPane==null ? Dock.DOCK_SLOT_DOC : Dock.DOCK_SLOT_DOCMAX; }

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
              child.isCurrent = child.pane==current;
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
   public function getLayout() return mLayout;
   public function getBestSize(inPos:Int):Size
   {
      var chrome = Skin.getMDIClientChrome();
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


/*
   public function setRect(inX:Float,inY:Float,w:Float,h:Float):Void
   {
      dockX = inX;
      dockY = inY;
      sizeX = w;
      sizeY = h;
      trace('-----> $dockX,$dockY,$sizeX,$sizeY');
      mLayout.setRect(inX,inY,w,h);
   }
   */
   public function getDockRect():Rectangle
   {
      return new Rectangle(dockX, dockY, sizeX, sizeY );
   }

   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      redrawTabs();
      if (mMaximizedPane==null)
         for(child in mChildren)
            child.checkDirty();
   }

   public function renderChrome(inBackground:Sprite,outHitBoxes:HitBoxes):Void
   {
      //trace("renderChrome");
   }

   public function asPane() : Pane { return null; }


   public function addDockZones(outZones:DockZones):Void
   {
      //var rect = new Rectangle(dockX,dockY,sizeX,sizeY);
      var rect = mLayout.getRect();

      if (rect.contains(outZones.x,outZones.y))
      {
         var dock = getDock();
         Skin.renderDropZone(rect,outZones,DOCK_LEFT,true,   function(d) dock.addSibling(this,d,DOCK_LEFT) );
         Skin.renderDropZone(rect,outZones,DOCK_RIGHT,true,  function(d) dock.addSibling(this,d,DOCK_RIGHT));
         Skin.renderDropZone(rect,outZones,DOCK_TOP,true,    function(d) dock.addSibling(this,d,DOCK_TOP) );
         Skin.renderDropZone(rect,outZones,DOCK_BOTTOM,true, function(d) dock.addSibling(this,d,DOCK_BOTTOM) );
         Skin.renderDropZone(rect,outZones,DOCK_OVER,true,   function(d) addDockable(d,DOCK_OVER,0) );
      }
   }


   public function getLayoutInfo():Dynamic
   {
      var dockables = new Array<Dynamic>();
      for(i in 0...mDockables.length)
         dockables[i] = mDockables[i].getLayoutInfo();

      return { type:"DocumentParent",
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
      {
         child.pane.setDock(this,null);
         clientArea.removeChild(child);
      }
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
         child.isCurrent = child.pane==current;

      inPane.setDock(this,clientArea);
      inPane.getLayout().setRect(0,0,clientWidth,clientHeight);
      redraw();
   }
   public function restore()
   {
      if (mMaximizedPane!=null)
      {
         current = mMaximizedPane;
         mMaximizedPane.setDock(this,null);
         mMaximizedPane = null;
         for(pane in mDockables)
            addFrame(pane.asPane());
         redraw();
         raiseDockable(current);
      }
   }

   public function verify() { }

   function setClientSize(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      clientWidth = inW;
      clientHeight = inH;

      if (clientHeight<1)
         clientArea.visible = false;
      else
      {
         clientArea.visible = true;
         clientArea.scrollRect = new Rectangle(0,0,clientWidth,clientHeight);
         if (mMaximizedPane!=null)
            mMaximizedPane.getLayout().setRect(0,0,clientWidth,clientHeight);
      }
      redraw();
   }

   public function redraw()
   {
      var gfx = clientArea.graphics;
      gfx.clear();

      if (mMaximizedPane!=null)
      {
         var fill:FillStyle = null;
         var asPane = mMaximizedPane.asPane();
         if (asPane!=null)
         {
            fill = Reflect.field(asPane.frameAttribs,"fill");
            if (fill==null)
            {
               gfx.beginFill(Skin.guiLight);
               gfx.drawRect(0,0,clientWidth,clientHeight);
            }
            else if (fill!=FillNone)
            {
               if (gm2d.skin.Renderer.setFill(gfx,fill,null))
                  gfx.drawRect(0,0,clientWidth,clientHeight);
            }
         }

         mMaximizedPane.getLayout().setRect(0,0,clientWidth,clientHeight);
      }
      else
      {
         gfx.beginFill(Skin.mdiBGColor);
         gfx.drawRect(0,0,clientWidth,clientHeight);
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
      if (tabBar!=null)
         tabBar.setTop(current, mMaximizedPane!=null);
   }

	function showPaneMenu(inX:Float, inY:Float)
	{
	   var menu = new MenuItem("Tabs");
		for(pane in mDockables)
		   menu.add( new MenuItem(pane.getShortTitle(), function(_)  Dock.raise(pane) ) );
      var pos = localToGlobal( new Point(inX,inY) );
		Game.popup( new PopupMenu(menu), pos.x, pos.y);
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
                  mTopLevel.showPaneMenu(mDockables, inEvent.stageX, inEvent.stageY);
            }
            redrawTabs();
         case REDRAW:
            redrawTabs();
         default:
      }
   }
}




