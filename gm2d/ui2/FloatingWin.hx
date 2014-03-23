package gm2d.ui2;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.ui2.Layout;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import gm2d.ui2.SkinItem;
import nme.events.MouseEvent;

class FloatingWin extends Widget implements IDock
{
   public var pane: Pane;

   var mTopLevel:TopLevelDock;
   var mFull:Bool=true;
   var mouseWatcher:MouseWatcher;
   var origRect:Rectangle;

   public function new(inTopLevel:TopLevelDock,inPane:Pane,inX:Float, inY:Float)
   {
      pane = inPane;
      mTopLevel = inTopLevel;
      var size = pane.getBestSize( Dock.DOCK_SLOT_FLOAT );

      origRect = null;
      pane.setDock(this,this);
      pane.properties.floatingPos = { x:inX, y:inY };

      super({ x:inX, y:inY, title:pane.title, itemWidth:size.x, itemHeight:size.y,
                 item:ITEM_LAYOUT(new DockableLayout(inPane,Dock.DOCK_SLOT_FLOAT))},
                 "pane:" + pane.shortTitle );

      addEventListener(MouseEvent.ROLL_OVER,function(_) setFull(true));
      addEventListener(MouseEvent.ROLL_OUT,function(_) setFull(false));
      //pane.displayObject.scrollRect = new Rectangle(20,20,mClientWidth, mClientHeight);
   }

   override public function getClass() { return "FloatingFrame"; }

   // TODO: skin this -
   public function setFull(inFull:Bool)
   {
      mFull = inFull;
      render();
   }

/*
   public function setClientSize(inW:Float, inH:Float)
   {
      var minW = Skin.current.getMinFrameWidth();
      mClientWidth = Std.int(Math.max(inW,minW));
      mClientHeight = Std.int(Math.max(inH,1));
      var size = pane.getLayoutSize(mClientWidth,mClientHeight,true);
      if (size.x<minW)
         size = pane.getLayoutSize(minW,mClientHeight,true);
      mClientWidth = Std.int(size.x);
      mClientHeight = Std.int(size.y);
      var rect = pane.getDockRect();
      pane.setRect(rect.x, rect.y, mClientWidth, mClientHeight);
      redraw();
   }
*/

   public function destroy()
   {
      if (pane!=null)
      {
         pane.setDock(null,null);
      }
      parent.removeChild(this);
   }

/*
   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         case DRAG(_pane):
            doStartDrag(inEvent);
         case TITLE(_):
            Dock.raise(pane);
         case BUTTON(_,id):
            if (id==MiniButton.CLOSE)
               pane.closeRequest(false);
            redraw();
         case REDRAW:
            redraw();
         default:
      }
   }
   */

   public function doStartDrag(inEvent:MouseEvent)
   {
      //trace("start " + inEvent.stageX + "," +  inEvent.stageY );
      mouseWatcher = MouseWatcher.watchDrag(this, inEvent.stageX, inEvent.stageY, onDrag, onEndDrag);
      origRect = pane.getDockRect();
   }

/*
   function redraw()
   {
      var solid = (mFull || (mouseWatcher!=null));
      alpha = solid ? 1.0 : 0.5;
      var rect = pane.getDockRect();
      Skin.current.renderMiniWin(chrome,pane,rect,mHitBoxes,solid);
   }
*/

   function onDrag(inEvent:MouseEvent)
   {
      mTopLevel.showDockZones(inEvent);
      //trace(" Dragged : " + mouseWatcher.draggedX() + "," + mouseWatcher.draggedY() );
      var tx = origRect.x+mouseWatcher.draggedX();
      var ty = origRect.y+mouseWatcher.draggedY();
      pane.setRect( tx, ty, origRect.width, origRect.height );
      pane.properties.floatingPos = { x:tx, y:ty };
      //redraw();
   }

   function onEndDrag(inEvent:MouseEvent)
   {
      //trace(" -- end -- ");
      mouseWatcher = null;
      mTopLevel.finishDockDrag(pane,inEvent);
   }
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition)
   {
      throw "Bad docking reference";
   }

   public function getDock():IDock { return mTopLevel; }
   public function canAddDockable(inPos:DockPosition):Bool { return false; }
   public function addDockable(child:IDockable,inPos:DockPosition,inSlot:Int):Void { }
   public function getDockablePosition(child:IDockable):Int { return Dock.DOCK_SLOT_FLOAT; }
   public function removeDockable(child:IDockable):IDockable { return null; }
   public function raiseDockable(child:IDockable):Bool
   {
      if (child.asPane()==pane)
      {
         var p = parent;
         p.removeChild(this);
         p.addChild(this);
         return true;
      }
      return false;
   }
   public function minimizeDockable(child:IDockable):Bool
   {
      // TODO
      return false;
   }
 
   public function getSlot():Int { return Dock.DOCK_SLOT_FLOAT; }
   public function setDirty(inLayout:Bool, inChrome:Bool):Void { render(); }
   public function addDockZones(outZones:DockZones):Void { }


}


