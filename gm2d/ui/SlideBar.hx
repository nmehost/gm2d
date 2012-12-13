package gm2d.ui;

import gm2d.ui.Menubar;
import gm2d.display.DisplayObjectContainer;
import gm2d.ui.DockPosition;
import gm2d.display.Sprite;
import gm2d.ui.HitBoxes;
import gm2d.events.MouseEvent;



class SlideBar extends Sprite, implements IDock
{
   var pos:DockPosition;
   var container:DisplayObjectContainer;
   var child:IDockable;
   var layoutDirty:Bool;
   var chromeDirty:Bool;
   var horizontal:Bool;
   var maxSize:Null<Int>;
   var background:Sprite;
   var hitBoxes:HitBoxes;


   public function new(inParent:DisplayObjectContainer,inPos:DockPosition,?inMaxSize:Null<Int>)
   {
      super();
      pos = inPos;
      container = inParent;
      horizontal = pos==DOCK_LEFT || pos==DOCK_RIGHT;
      maxSize = inMaxSize;

      background = new Sprite();
      addChild(background);
      hitBoxes = new HitBoxes(background,onHitBox);
      //hitBoxes.onOverDockSize = onOverDockSize;
      //hitBoxes.onDockSizeDown = onDockSizeDown;

   }

   public function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         /*
         case BUTTON(pane,but):
            if (but==MiniButton.EXPAND)
              Dock.raise(pane);
            else if (but==MiniButton.MINIMIZE)
              Dock.minimize(pane);
         */
         case TITLE(pane):
            Dock.raise(pane);

         default:
      }
   }


   public function isDirty()
   {
      return layoutDirty;
   }
 
   public function setRect(x:Float, y:Float, w:Float, h:Float) : Float
   {
      layoutDirty = false;
      if (child==null)
         return 0;

      var right = x+w;
      var bottom = y+h;
      if (maxSize!=null)
      {
         if (horizontal && w>maxSize)
            w = maxSize;
         else if (!horizontal && h>maxSize)
            h = maxSize;
      }
   
      var size = child.getLayoutSize(w,h,!horizontal);

      child.setRect(0,0,size.x,size.y);

      if (pos==DOCK_RIGHT)
      {
         this.x = right-size.x;
      }
      else if (pos==DOCK_BOTTOM)
      {
         this.y = bottom-size.y;
      }

      if (pos==DOCK_LEFT || pos==DOCK_RIGHT)
         this.y = y + Std.int((h-size.y)*0.5);
      else
         this.x = x + Std.int((w-size.x)*0.5);

      chromeDirty = true;

      return horizontal ? size.x : size.y;
    }

    public function checkChrome()
    {
      if (child==null)
         return;
      if (chromeDirty)
      {
         chromeDirty = false;
         hitBoxes.clear();
         background.graphics.clear();
         while(background.numChildren>0)
            background.removeChildAt(0);
         child.renderChrome(background,hitBoxes);
      }
   }



   // IDock....
   public function getDock():IDock { return this; }
   public function canAddDockable(inPos:DockPosition):Bool
   {
      return inPos==DOCK_OVER && child==null;
   }
   public function addDockable(inChild:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      child = inChild;
      Dock.remove(child);
      child.setDock(this,this);
      setDirty(true,true);
   }

   public function getDockablePosition(child:IDockable):Int
   {
      return -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      return null;
   }
   public function raiseDockable(child:IDockable):Bool
   {
      return false;
   }
   public function minimizeDockable(child:IDockable):Bool
   {
      return false;
   }
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition):Void
   {
   }
   public function getSlot():Int
   {
      return -1;
   }
   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      if (inLayout)
        layoutDirty = true;
      if (inChrome)
        chromeDirty = true;

      if (stage!=null)
         stage.invalidate();
   }
}



