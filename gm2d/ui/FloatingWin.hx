package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.skin.Skin;
import gm2d.ui.Layout;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import gm2d.ui.HitBoxes;
import nme.events.MouseEvent;

class FloatingWin extends DockFrame implements IDock
{
   var mTopLevel:TopLevelDock;
   var mHitBoxes:HitBoxes;
   var mFull:Bool;
   var mouseWatcher:MouseWatcher;
   var origRect:Rectangle;

   public function new(inTopLevel:TopLevelDock,inPane:Pane,inX:Float, inY:Float)
   {
      super(inPane, inTopLevel, { onTitleDrag:function(_,e) doStartDrag(e) } );
      mTopLevel = inTopLevel;
      mHitBoxes = new HitBoxes(this, onHitBox);
      mouseWatcher = null;
      origRect = null;
      pane.setDock(this,this);
      inPane.properties.floatingPos = { x:inX, y:inY };

      var outer = getLayout().getRect();
      var inner = pane.getLayout().getRect();
      getLayout().setRect(inX+outer.x-inner.x, inY+outer.y-inner.y, outer.width, outer.height);
   }

   public function setFull(inFull:Bool)
   {
      mFull = inFull;
      redraw();
   }

   public function destroy()
   {
      if (pane!=null)
         pane.setDock(null,null);
      parent.removeChild(this);
   }

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

   public function doStartDrag(inEvent:MouseEvent)
   {
      mouseWatcher = MouseWatcher.watchDrag(this, inEvent.stageX, inEvent.stageY, onDrag, onEndDrag);
      origRect = getLayout().getRect();
   }


   function onDrag(inEvent:MouseEvent)
   {
      mTopLevel.showDockZones(inEvent);
      //trace(" Dragged : " + mouseWatcher.draggedX() + "," + mouseWatcher.draggedY() );
      var tx = origRect.x+mouseWatcher.draggedX();
      var ty = origRect.y+mouseWatcher.draggedY();
      var layout = getLayout();
      layout.setRect( tx, ty, origRect.width, origRect.height );
      pane.asPane().properties.floatingPos = { x:tx, y:ty };
      redraw();
   }

   function verify()
   {
   }


   function onEndDrag(inEvent:MouseEvent)
   {
      //trace(" -- end -- ");
      mouseWatcher = null;
      mTopLevel.finishDockDrag(pane.asPane(),inEvent);
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
   public function setDirty(inLayout:Bool, inChrome:Bool):Void { redraw(); }
   public function addDockZones(outZones:DockZones):Void { }


}


