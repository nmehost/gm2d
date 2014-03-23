package gm2d.ui2;

import nme.geom.Rectangle;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Point;

class DockSizeHandler
{
   var container:Sprite;
   var overlayContainer:Sprite;
   var resizeBox:Rectangle;
   var resizeListen:Bool;


   public function new(inContainer:Sprite, inOverlay:Sprite, inHitBoxes:HitBoxes)
   {
      container = inContainer;
      overlayContainer = inOverlay;
      inHitBoxes.onOverDockSize = onOverDockSize;
      inHitBoxes.onDockSizeDown = onDockSizeDown;
      resizeListen = false;
   }

   public function onOverDockSize(inDock:SideDock, inIndex:Int, inX:Float, inY:Float, inRect:Rectangle )
   {
      showResizeHint(inX,inY,inDock.isHorizontal());

      resizeBox = inRect;
      if (!resizeListen)
      {
         container.stage.addEventListener(MouseEvent.MOUSE_MOVE,checkResizeDock);
         resizeListen = true;
      }
   }

   public function onDockSizeDown(inDock:SideDock, inIndex:Int, inX:Float, inY:Float, inRect:Rectangle )
   {
      //trace("Drag dock " + inX + "," + inY);
      resizeBox = null;
      container.stage.removeEventListener(MouseEvent.MOUSE_MOVE,checkResizeDock);
      resizeListen = false;

      MouseWatcher.watchDrag(container,inX,inY,
          function(_) onDockSize(inDock,inIndex,_) , clearOverlay );
   }

   function onDockSize(inDock:SideDock, inIndex:Int, inEvent:MouseEvent)
   {
      showResizeHint(inEvent.stageX,inEvent.stageY,inDock.isHorizontal());
      inDock.tryResize(inIndex, inDock.isHorizontal() ? inEvent.stageX : inEvent.stageY );
      //trace(inEvent);
   }

   public function checkResizeDock(inMouse:MouseEvent)
   {
      if (resizeBox!=null)
      {
         var pos = container.globalToLocal( new Point(inMouse.stageX,inMouse.stageY) );
         if (!resizeBox.contains(pos.x,pos.y))
         {
            resizeBox = null;
            container.removeEventListener(MouseEvent.MOUSE_MOVE,checkResizeDock);
            resizeListen = false;
            clearOverlay();
         }
      }
   }

   function clearOverlay(?_:Dynamic)
   {
      overlayContainer.graphics.clear();
      overlayContainer.x = 0;
      overlayContainer.y = 0;
      while(overlayContainer.numChildren>0)
         overlayContainer.removeChildAt(0);
   }


   function showResizeHint(inX:Float, inY:Float, inHorizontal:Bool)
   {
      overlayContainer.x = inX-16;
      overlayContainer.y = inY-16;
      overlayContainer.cacheAsBitmap = true;
      overlayContainer.mouseEnabled = false;
      var gfx = overlayContainer.graphics;
      gfx.clear();
      if (inHorizontal)
         new gm2d.icons.EastWest().render(gfx);
      else
         new gm2d.icons.NorthSouth().render(gfx);
   }


}



