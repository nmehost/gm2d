package gm2d.ui;

import gm2d.Screen;
import gm2d.ScreenScaleMode;
import gm2d.ui.Skin;
import gm2d.ui.Layout;
import gm2d.display.Sprite;
import gm2d.geom.Point;
import gm2d.geom.Rectangle;
import gm2d.ui.HitBoxes;
import gm2d.events.MouseEvent;

class FloatingWin extends Sprite, implements IDock
{
   public var pane: Pane;

   var mTopLevel:TopLevelDock;
   var mHitBoxes:HitBoxes;
   var mClientWidth:Float;
   var mClientHeight:Float;
   var mFull:Bool;
   var chrome:Sprite;
   var mouseWatcher:MouseWatcher;
   var origRect:Rectangle;

   public function new(inTopLevel:TopLevelDock,inPane:Pane,inX:Float, inY:Float)
   {
      super();
      pane = inPane;
      mTopLevel = inTopLevel;
      mHitBoxes = new HitBoxes(this, onHitBox);
      chrome = new Sprite();
      mouseWatcher = null;
      origRect = null;
      addChild(chrome);
      pane.setDock(this);
      pane.setContainer(this);

      var size = inPane.getBestSize( Dock.DOCK_SLOT_FLOAT );

      mClientWidth = Std.int(Math.max(size.x,Skin.current.getMinFrameWidth())+0.99);
      mClientHeight = Std.int(size.y+0.99);
      setClientSize(mClientWidth,mClientHeight);

      pane.setRect(inX,inY, mClientWidth, mClientHeight);

      setFull(true);
      addEventListener(MouseEvent.ROLL_OVER,function(_) setFull(true));
      addEventListener(MouseEvent.ROLL_OUT,function(_) setFull(false));
      //pane.displayObject.scrollRect = new Rectangle(20,20,mClientWidth, mClientHeight);
   }

   public function setFull(inFull:Bool)
   {
      mFull = inFull;
      redraw();
   }

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


   public function destroy()
   {
      if (pane!=null)
      {
         pane.setContainer(null);
         pane.setDock(null);
      }
      parent.removeChild(this);
   }

   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         case DRAG(pane):
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
      //trace("start " + inEvent.stageX + "," +  inEvent.stageY );
      mouseWatcher = MouseWatcher.watchDrag(this, inEvent.stageX, inEvent.stageY, onDrag, onEndDrag);
      origRect = pane.getDockRect();
   }

   function redraw()
   {
      var solid = (mFull || (mouseWatcher!=null));
      alpha = solid ? 1.0 : 0.5;
      var rect = pane.getDockRect();
      Skin.current.renderMiniWin(chrome,pane,rect,mHitBoxes,solid);
   }

   function onDrag(_)
   {
      //trace(" Dragged : " + mouseWatcher.draggedX() + "," + mouseWatcher.draggedY() );
      pane.setRect( origRect.x+mouseWatcher.draggedX(), origRect.y+mouseWatcher.draggedY(),
                    origRect.width, origRect.height );
      redraw();
   }

   function onEndDrag(_)
   {
      //trace(" -- end -- ");
      mouseWatcher = null;
   }

   public function getDock():IDock { return this; }
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
   public function getSlot():Int { return Dock.DOCK_SLOT_FLOAT; }
   public function setChromeDirty():Void { redraw(); }


}


