package gm2d.ui;

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.Stage;
import gm2d.ui.DockPosition;
import gm2d.ui.HitBoxes;
import gm2d.ui.MouseWatcher;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.geom.Point;
import gm2d.ui.DockZones;
import gm2d.skin.Skin;

class TopLevelDock implements IDock
{
   var root:IDockable;
   var container:Sprite;
   var backgroundContainer:Sprite;
   var overlayContainer:Sprite;
   var paneContainer:Sprite;
   var floatingContainer:Sprite;
   var floatingWins:Array<FloatingWin>;
   var docParent:DocumentParent;
   var hitBoxes:HitBoxes;
   var chromeDirty:Bool;
   var layoutDirty:Bool;
   public var skin:Skin;

   var size:Rectangle;
   var dockZones:DockZones;

   public function new(?inSkin:Skin, inContainer:Sprite,?inDocParent:DocumentParent)
   {
      skin = Skin.getSkin(inSkin);
      inContainer.name = "TopLevelDock.container";
      docParent = inDocParent;
      if (docParent!=null)
         docParent.setTopLevel(this);
      container = inContainer;
      backgroundContainer = new Sprite();
      container.addChild(backgroundContainer);
      backgroundContainer.name = "backgroundContainer";
      paneContainer = new Sprite();
      paneContainer.name = "paneContainer";
      container.addChild(paneContainer);
      floatingContainer = new Sprite();
      floatingContainer.name = "floatingContainer";
      container.addChild(floatingContainer);
      overlayContainer = new Sprite();
      overlayContainer.name = "overlayContainer";
      container.addChild(overlayContainer);
      floatingWins = [];

      chromeDirty = true;
      layoutDirty = true;
      hitBoxes = new HitBoxes(skin, backgroundContainer,onHitBox);
      new DockSizeHandler(container,overlayContainer,hitBoxes);

      if (inDocParent!=null)
      {
         root = docParent;
         docParent.setDock(this,paneContainer);
      }
      container.addEventListener(nme.events.Event.RENDER, updateLayout);
   }
   public static function findRoot(inDockable:IDockable):TopLevelDock
   {
      var topDock = inDockable.getDock();
      if (topDock==null)
         throw("No parent dock");

      while(true)
      {
         var dock = topDock.getDock();
         if (dock==null)
            break;
         topDock = dock;
      }
      if (!Std.isOfType(topDock, TopLevelDock))
      {
         throw('Not top level $topDock');
      }
      return cast topDock;
 
   }
   public static function dragTitle(inDockable:IDockable, inEvent:MouseEvent)
   {
      var tld = findRoot( inDockable );
      tld.floatWindow(inDockable,inEvent, inDockable.getProperties());
   }

   public function floatWindow(inDockable:IDockable, inEvent:MouseEvent, inProps:Dynamic)
   {
      var pane = inDockable.asPane();
      if (pane!=null)
      {
         var fx = inEvent==null ? 0 : inEvent.stageX;
         var fy = inEvent==null ? 0 : inEvent.stageY;
         var obj = pane.displayObject;
         if (obj!=null && obj.stage!=null)
         {
            var r = inDockable.getLayout().getRect();
            var stagePos = obj.parent.localToGlobal( new Point(r.x,r.y) );
            var best = inDockable.getLayout().getBestSize();
            fx = Math.max(stagePos.x,fx-best.x);
            fy = Math.max(stagePos.y,fy-best.y);
         }

         Dock.remove(inDockable);

         var floating:FloatingWin = null;
         if (inEvent!=null)
            floating = new FloatingWin(this,pane,fx,fy)
         else
         {
            pane.loadLayout(inProps);
            var pos = inProps.properties.floatingPos;
            if (pos==null)
               pos = { x:20, y:20 };
            floating = new FloatingWin(this,pane,pos.x, pos.y);
         }
         floatingWins.push(floating);
         floatingContainer.addChild(floating);
         if (inEvent!=null)
            floating.doStartDrag(inEvent);
      }
      else
      {
         Dock.remove(inDockable);
      }
   }

   public function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      //trace("onHitBox " + inAction);
      switch(inAction)
      {
         case DRAG(p):
            floatWindow(p,inEvent,null);
        case BUTTON(pane,but):
            if (but==MiniButton.EXPAND)
              Dock.raise(pane);
            else if (but==MiniButton.MINIMIZE)
              Dock.minimize(pane);
         case TITLE(pane):
            Dock.raise(pane);

         default:
      }
   }

   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      size = new Rectangle(x,y,w,h);
      if (root!=null)
         root.getLayout().setRect(x,y,w,h);
   }

   function forceLayout()
   {
      if (root!=null)
        root.getLayout().setRect(size.x, size.y, size.width, size.height );

      setDirty(false,true);
   }

   public function clearOverlay()
   {
      overlayContainer.graphics.clear();
      overlayContainer.x = 0;
      overlayContainer.y = 0;
      while(overlayContainer.numChildren>0)
         overlayContainer.removeChildAt(0);
      if (container.stage!=null)
         container.stage.invalidate();
      dockZones = null;
   }

   public function finishDockDragAt(inPane:Pane, x:Float, y:Float)
   {
      if (dockZones!=null)
      {
         var dropped = dockZones.test(x, y, inPane );
         //trace("Dropped : " + dropped );
      }
      clearOverlay();
   }


   public function finishDockDrag(inPane:Pane, inEvent:MouseEvent)
   {
      if (inEvent!=null)
         finishDockDragAt(inPane, inEvent.stageX, inEvent.stageY );
      clearOverlay();
   }

   public function showDockZonesAt(x:Float, y:Float)
   {
      clearOverlay();
      if (root!=null)
      {
         dockZones = new DockZones(x, y, overlayContainer);
         root.addDockZones(dockZones);
         skin.renderDropZone(size,dockZones,DOCK_LEFT, false,   function(d) addDockable(d,DOCK_LEFT,0) );
         skin.renderDropZone(size,dockZones,DOCK_RIGHT, false,  function(d) addDockable(d,DOCK_RIGHT,0));
         skin.renderDropZone(size,dockZones,DOCK_TOP, false,    function(d) addDockable(d,DOCK_TOP,0) );
         skin.renderDropZone(size,dockZones,DOCK_BOTTOM, false, function(d) addDockable(d,DOCK_BOTTOM,0) );
      }
   }
   public function showDockZones(inEvent:MouseEvent)
   {
      showDockZonesAt(inEvent.stageX, inEvent.stageY);
   }



   public function showPaneMenu(dockables:Array<IDockable>,inX:Float, inY:Float)
   {
      var menu = new MenuItem("Tabs");
      for(pane in dockables)
         menu.add( new MenuItem(pane.getShortTitle(), function(_)  Dock.raise(pane) ) );
      Game.popup( new PopupMenu(menu), inX, inY);
   }



   public function updateLayout(_)
   {
      if (layoutDirty)
      {
         //root.verify();
         layoutDirty = false;
         forceLayout();
      }
      if (chromeDirty)
      {
         chromeDirty = false;
         hitBoxes.clear();
         backgroundContainer.graphics.clear();
         while(backgroundContainer.numChildren>0)
            backgroundContainer.removeChildAt(0);
         if (root!=null)
            root.renderChrome(backgroundContainer,hitBoxes);
      }
   }

   public function getLayoutInfo():Dynamic
   {
      var floating = new Array<Dynamic>();
      for(idx in 0...floatingWins.length)
         floating[idx] = floatingWins[idx].pane.getLayoutInfo();

      return { floating:floating, root:root==null ? null : root.getLayoutInfo() }
   }

   public function setLayoutInfo(skin:Skin, inInfo:Dynamic)
   {
      var panes = Pane.allPanes();
      for(pane in panes)
         Dock.remove(pane);
      var floatings:Array<Dynamic> = inInfo.floating;
      for(floating in floatings)
      {
         var title = floating.title;
         for(pane in panes)
            if (pane.title==title)
            {
               panes.remove(pane);
               pane.loadLayout(floating);
               floatWindow(pane,null,floating);
               break;
            }
      }

      root = Dock.loadLayout(skin, inInfo.root,panes,docParent);
      if (root!=null)
        root.setDock(this,paneContainer);
   }



   // -- IDock -----------------------------------------------------------
   public function canAddDockable(inPos:DockPosition):Bool { return true; }
   public function addDockable(inChild:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      // trace("addDockable " + inChild + " x " + inPos + " " + inSlot );
      Dock.remove(inChild);
      if (docParent!=null && inPos==DOCK_OVER)
      {
          docParent.addDockable(inChild,inPos,inSlot);
      }
      else if (root==null)
      {
         root = inChild;
         root.setDock(this,paneContainer);
      }
      else
      {
         var dock:IDock = cast root;
         if (dock!=null && dock.canAddDockable(inPos))
         {
            dock.addDockable(inChild,inPos,inSlot);
         }
         else
         {
            var side = new SideDock(inPos);
            side.setDock(this,paneContainer);
            side.addDockable(root,inPos,0);
            side.addDockable(inChild,inPos,0);
            root = side;
         }
      }
      setDirty(true,true);
   }

   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition)
   {
      if (inReference!=root)
         throw "Bad docking reference";
      addDockable(inIncoming,inPos,0);
   }

   public function getDock():IDock { return null; }
   public function getSlot():Int { return Dock.DOCK_SLOT_FLOAT; }

   public function getDockablePosition(child:IDockable):Int
   {
      return child==root ? 0 : -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      if (Std.isOfType(child.getDock(), FloatingWin))
      {
         var win:FloatingWin = cast child.getDock();
         if (floatingWins.remove(win))
            win.destroy();
         return null;
      }

      if (child==root)
      {
         root=null;
         child.setDock(null,null);
      }
      else
      {
         var dock:IDock = cast root;
         root = dock.removeDockable(child);
         if (root!=null)
           root.setDock(this,paneContainer);
         //trace("post verify");
         //root.verify();
      }
      setDirty(true,true);
      return null;
   }
   public function raiseDockable(child:IDockable):Bool
   {
      var dock:IDock = cast root;
      if (dock!=null)
         dock.raiseDockable(child);
      return false;
   }
   public function minimizeDockable(child:IDockable):Bool
   {
      return false;
   }
   public function setLayoutDirty():Void
   {
      layoutDirty = true;
   }
   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      if (inLayout)
         layoutDirty = true;
      if (inChrome)
         chromeDirty = true;
      Game.invalidate();
   }
   public function addDockZones(outZones:DockZones):Void
   {
   }

}


