package gm2d.ui;

import gm2d.ui.Menubar;
import gm2d.display.DisplayObjectContainer;
import gm2d.ui.DockPosition;
import gm2d.display.Sprite;
import gm2d.ui.HitBoxes;
import gm2d.events.MouseEvent;
import gm2d.skin.TabRenderer;
import gm2d.skin.Skin;
import gm2d.geom.Rectangle;



class SlideBar extends Sprite, implements IDock
{
   var pos:DockPosition;
   var container:DisplayObjectContainer;
   var child:IDockable;
   var layoutDirty:Bool;
   var chromeDirty:Bool;
   var horizontal:Bool;
   var minSize:Null<Int>;
   var maxSize:Null<Int>;
   var tabPos:Null<Int>;
   var background:Sprite;
   var slideOver:Bool;
   var hitBoxes:HitBoxes;
   var posOffset:Int;
   var tabSide:Int;
   var scroll:Float;
   var tabRenderer:TabRenderer;
   var fullRect:Rectangle;


   public function new(inParent:DisplayObjectContainer,inPos:DockPosition,
             inMinSize:Null<Int>, inMaxSize:Null<Int>,
             inSlideOver:Bool, inShowTab:Bool,
             inOffset:Null<Int>, inTabPos:Null<Int>)
   {
      super();
      pos = inPos;
      container = inParent;
      horizontal = pos==DOCK_LEFT || pos==DOCK_RIGHT;
      maxSize = inMaxSize;
      minSize = inMinSize;
      slideOver = inSlideOver;
      tabPos = inTabPos;
      scroll = 0;
      posOffset = inOffset == null ? 0 : inOffset;
      tabRenderer = inShowTab ? Skin.current.tabRenderer : null;
      tabSide = switch(pos) {
         case DOCK_LEFT: TabRenderer.RIGHT;
         case DOCK_RIGHT: TabRenderer.LEFT;
         case DOCK_BOTTOM: TabRenderer.TOP;
         case DOCK_TOP: TabRenderer.BOTTOM;
         default:0;
      };


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

   public function setScroll(inScroll:Float)
   {
      scroll = inScroll;

      layoutDirty = true;
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

      if (horizontal)
      {
         y+=posOffset;
         h-=posOffset;
      }
      else
      {
         x+=posOffset;
         w-=posOffset;
      }

      var right = x+w;
      var bottom = y+h;
      if (maxSize!=null)
      {
         if (horizontal && w>maxSize)
            w = maxSize;
         else if (!horizontal && h>maxSize)
            h = maxSize;
      }
      if (minSize!=null)
      {
         if (horizontal && w<minSize)
            w = minSize;
         else if (!horizontal && h<minSize)
            h = minSize;
      }


      var size = child.getLayoutSize(w,h,!horizontal);

      child.setRect(0,0,size.x,size.y);

      var showing = 0.0;
      if (horizontal)
      {
         if (scroll>size.x)
            scroll = size.x;
         showing = size.x - scroll;
      }
      else
      {
         if (scroll>size.y)
            scroll = size.y;
         showing = size.y - scroll;
      }

      switch(pos)
      {
         case DOCK_LEFT:
            this.x = showing - size.x;
            this.y = y;

         case DOCK_RIGHT:
            this.x = right-showing;
            this.y = y;

         case DOCK_BOTTOM:
            this.x = x;
            this.y = bottom-showing;

         case DOCK_TOP:
            this.x = x;
            this.y = showing - size.y;

         default:
      }

      fullRect = new Rectangle(0,0,size.x,size.y);

      chromeDirty = true;

      if (slideOver)
         return 0;

      return showing;
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
      
         if (tabRenderer!=null)
            tabRenderer.renderTabs(background, fullRect, [child], child, hitBoxes, false, tabSide,
                                 true, horizontal, true, tabPos );
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



