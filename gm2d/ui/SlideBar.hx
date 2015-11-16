package gm2d.ui;

import gm2d.ui.Menubar;
import gm2d.ui.Widget;
import nme.display.DisplayObjectContainer;
import gm2d.ui.DockPosition;
import gm2d.ui.MouseWatcher;
import nme.display.Sprite;
import gm2d.ui.HitBoxes;
import nme.events.MouseEvent;
import gm2d.skin.TabRenderer;
import gm2d.skin.Renderer;
import gm2d.skin.Skin;
import gm2d.skin.FillStyle;
import nme.geom.Rectangle;


class SlideBar extends Sprite implements IDock
{
   var pos:DockPosition;
   var container:DisplayObjectContainer;
   var layoutDirty:Bool;
   var chromeDirty:Bool;
   var horizontal:Bool;
   var minSize:Null<Int>;
   var maxSize:Null<Int>;
   var tabPos:Null<Int>;
   var background:Widget;
   var paneContainer:Sprite;
   var overlayContainer:Sprite;
   var slideOver:Bool;
   var hitBoxes:HitBoxes;
   var posOffset:Int;
   var tabSide:Int;
   var showing:Float;
   var lastPopDown:Float;
   var fullRect:Rectangle;
   var popOnUp:Bool;
   var mouseWatcher:MouseWatcher;
   var beginShowPos:Float;
   var showTabs:Bool;

   var current:IDockable;
   var children:Array<IDockable>;
   var tabRenderer:TabRenderer;
   public var pinned(default,set_pinned):Bool;
   public var onPinned:Bool->Void;

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
      showing = 0;
      lastPopDown = 0;
      layoutDirty = true;
      showTabs = inShowTab;
      posOffset = inOffset == null ? 0 : inOffset;
      tabSide = switch(pos) {
         case DOCK_LEFT: TabRenderer.RIGHT;
         case DOCK_RIGHT: TabRenderer.LEFT;
         case DOCK_BOTTOM: TabRenderer.TOP;
         case DOCK_TOP: TabRenderer.BOTTOM;
         default:0;
      };
      var line  = switch(pos) {
         case DOCK_LEFT: "SlideLeft";
         case DOCK_RIGHT: "SlideRight";
         case DOCK_BOTTOM: "SlideBottom";
         case DOCK_TOP: "SlideTop";
         default: "SlideDock";
      };


      children = new Array<IDockable>();
      current = null;
      pinned = false;


      background = new Widget([line,"Dock"]);
      background.build();
      addChild(background);
      paneContainer = new Sprite();
      addChild(paneContainer);
      overlayContainer = new Sprite();
      addChild(overlayContainer);
      hitBoxes = new HitBoxes(background,onHitBox);

      new DockSizeHandler(background,overlayContainer,hitBoxes);
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
            if (inEvent.type==MouseEvent.MOUSE_DOWN)
            {
               popOnUp = pane == current;
               Dock.raise(pane);
               beginScroll(inEvent);
            }

         case BUTTON(_,but):
            if (but==MiniButton.PIN)
               pinned = !pinned;

         default:
            //trace(inAction);
      }
   }

   function onUp(_)
   {
      if (!mouseWatcher.wasDragged)
      {
         if (showing<=0)
         {
            if (maxSize!=null)
               setShowing(maxSize);
            else if (lastPopDown!=0)
               setShowing(lastPopDown);
         }
         else if (popOnUp)
         {
            lastPopDown = showing;
            setShowing(0);
         }
      }
      mouseWatcher=null;
   }
   function onScroll(e:MouseEvent)
   {
      var delta = 0.0;
      if (horizontal)
         delta = e.stageX - mouseWatcher.downPos.x;
      else
         delta = e.stageY - mouseWatcher.downPos.y;
      if (pos==DOCK_RIGHT || pos==DOCK_BOTTOM)
         delta = -delta;

      setShowing( Std.int(beginShowPos + delta) );
   }

   public function beginScroll(e)
   {
      mouseWatcher = new MouseWatcher(this, null, onScroll, onUp, e.stageX, e.stageY, false);
      mouseWatcher.minDragDistance = 10.0;
      beginShowPos = showing;
   }

   public function setShowing(inShowing:Float)
   {
      if (inShowing<0)
         inShowing = 0;
      if (maxSize!=null && inShowing>maxSize)
         inShowing = maxSize;
    
      if (inShowing!=showing)
      {
         showing = inShowing;

         setDirty(true,false);
      }
   }

   public function set_pinned(inPinned:Bool):Bool
   {
      pinned = inPinned;
      tabRenderer = showTabs ? Skin.tabRenderer( [pinned ? "Pinned" : "Unpinned", "Tabs","TabRenderer"] ) : null;
      setDirty(true,true);
      if (onPinned!=null)
         onPinned(inPinned);
      return inPinned;
   }


   public function isDirty()
   {
      return layoutDirty;
   }
 
   public function setRect(x:Float, y:Float, w:Float, h:Float) : Float
   {
      layoutDirty = false;
      if (current==null)
         return 0;

      var offset = pinned ? 0 : posOffset;
      if (horizontal)
      {
         y+=offset;
         h-=offset;
      }
      else
      {
         x+=offset;
         w-=offset;
      }

      var oy = 0.0;
      var right = x+w;
      var bottom = y+h;
      if (pinned && maxSize!=null)
      {
         if (horizontal)
            w = maxSize;
         else
            h = maxSize - (tabRenderer!=null ? tabRenderer.getHeight() : 0 );
      }
      else if (maxSize!=null)
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

      if (pinned)
      {
         if (tabRenderer==null)
            oy = 0;
         else
         {
            oy = tabRenderer.getHeight();
            //h - tabRenderer.getHeight();
         }
      }

      var size = horizontal ? 
         current.getLayoutSize(showing,h,false) :
         current.getLayoutSize(w,showing,true);
      //trace(' $w $h $pinned $horizontal $showing -> 0,$oy ${size.x},${size.y}');

      current.setRect(0,oy,size.x,size.y);

      if (horizontal)
      {
         if (showing>size.x || tabRenderer==null)
            showing = size.x;
      }
      else
      {
         if (showing>size.y || tabRenderer==null)
            showing = size.y;
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
            this.y = bottom-showing-oy;

         case DOCK_TOP:
            this.x = x;
            this.y = showing - size.y - oy;

         default:
      }

      fullRect = new Rectangle(0,0,size.x,size.y);

      background.getLayout().setRect(fullRect.x, fullRect.y, fullRect.width, fullRect.height+oy);

      chromeDirty = true;

      if (slideOver)
         return 0;

      return showing;
    }

    public function checkChrome()
    {
      if (current==null)
         return;

      if (chromeDirty)
      {
         chromeDirty = false;
         hitBoxes.clear();
         background.redraw();
         current.renderChrome(background.mChrome,hitBoxes);

         if (tabRenderer!=null)
         {
            var tabRect = fullRect.clone();
            if (pos==DOCK_LEFT || pos==DOCK_RIGHT)
               tabRect.width = tabRenderer.getHeight();
            else
            {
               tabRect.height = tabRenderer.getHeight();
            }

            if (pinned)
            {
               var flags = TabRenderer.SHOW_TEXT | TabRenderer.SHOW_ICON | TabRenderer.SHOW_PIN;
               tabRenderer.renderTabs(background.mChrome, tabRect, children, current,
                  hitBoxes,  TabRenderer.TOP, flags, tabPos );
            }
            else
            {
               var flags = TabRenderer.SHOW_TEXT | TabRenderer.SHOW_ICON | TabRenderer.SHOW_PIN |
                     TabRenderer.IS_OVERLAPPED;
               tabRenderer.renderTabs(background.mChrome, tabRect, children, current,
                  hitBoxes, tabSide, flags, tabPos );
            }
         }
      }
   }

   public function setCurrent(inCurrent:IDockable)
   {
      if (inCurrent!=current)
      {
         current = inCurrent;
         var found = false;

         for(child in children)
         {
             if (current==child)
             {
                found = true;
                child.setDock(this,paneContainer);
             }
             else
                child.setDock(this,null);
         }

         if (!found && children.length>0)
            setCurrent(children[0]);

         setDirty(true,true);
      }
   }


   // IDock....
   public function getDock():IDock { return this; }
   public function canAddDockable(inPos:DockPosition):Bool
   {
      return inPos==DOCK_OVER;
   }
   public function addDockable(inChild:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      children.push(inChild);
      Dock.remove(inChild);
      setCurrent(inChild);
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
      for(i in 0...children.length)
        if (child==children[i])
        {
           setCurrent(child);
           return true;
        }
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



