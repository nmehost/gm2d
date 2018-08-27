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
   var barContainer:Sprite;
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
   var barDockable:IDockable;
   var tabRenderer:TabRenderer;
   public var pinned(default,set_pinned):Bool;
   public var onPinned:Bool->Void;
   public var showText = true;
   public var showPin = true;
   public var tabGap = false;
   public var showGrip = false;

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


      background = new Widget([ line, "Dock"]);
      background.applyStyles();
      addChild(background);
      paneContainer = new Sprite();
      addChild(paneContainer);
      barContainer = new Sprite();
      addChild(barContainer);
      overlayContainer = new Sprite();
      addChild(overlayContainer);
      hitBoxes = new HitBoxes(background,onHitBox);

      new DockSizeHandler(background,overlayContainer,hitBoxes);
   }

   public function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      popOnUp = false;
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
         case GRIP:
             popOnUp = true;
            beginScroll(inEvent);

         case BUTTON(_,but):
            if (but==MiniButton.PIN)
               pinned = !pinned;

         default:
            //trace(inAction);
      }
   }

   function onUp(_)
   {
      if (mouseWatcher!=null && !mouseWatcher.wasDragged)
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
         paneContainer.visible = inShowing>0;
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

   public function getBarHeight()
   {
      var h = tabRenderer==null ? 0.0 : tabRenderer.getHeight(); 

      if (barDockable!=null)
      {
         var bh = tabSide==TabRenderer.LEFT || tabSide==TabRenderer.RIGHT ?
                    barDockable.getLayoutSize(h,100000,false).x :
                    barDockable.getLayoutSize(100000,h,true).y;
         if (bh>h)
            h = bh;
      }

      return h;
   }
 
   public function setRect(x:Float, y:Float, w:Float, h:Float) : Float
   {
      layoutDirty = false;
      //if (current==null) return 0;

      var offset = (pinned || showGrip) ? 0 : posOffset;
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
      if ((pinned || showGrip) && maxSize!=null)
      {
         if (horizontal)
            w = maxSize;
         else
            h = maxSize - getBarHeight();
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

      if (pinned || showGrip )
      {
         if (tabRenderer==null)
            oy = 0;
         else
         {
            oy = getBarHeight();
            h -= oy;
         }
      }
      paneContainer.y = oy;
      barContainer.y = oy;

      var size = new Size(horizontal ? 0 : w,horizontal ? h : 0);
      if (current!=null)
      {
         size = horizontal ? 
             current.getLayoutSize(showing,h,false) :
             current.getLayoutSize(w,showing,true);
         current.getLayout().setRect(0,0,size.x,size.y);
      }
      //paneContainer.scrollRect = new Rectangle(0,0,size.x,size.y);


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
      //trace( "Set BG " + fullRect.x +","+ fullRect.y +","+ fullRect.width +","+ fullRect.height+oy);

      chromeDirty = true;

      if (slideOver)
         return 0;

      return showing + (tabGap ? getBarHeight() : 0);
    }

    public function checkChrome()
    {
      if (chromeDirty)
      {
         chromeDirty = false;
         hitBoxes.clear();
         background.redraw();
         if (current!=null)
            current.renderChrome(background.mChrome,hitBoxes);

         var tallBar = false;
         var barHeight = getBarHeight();
         if (tabRenderer!=null)
         {
            var tabRect = fullRect.clone();
            var flags = (showText?TabRenderer.SHOW_TEXT:0) |
                         TabRenderer.SHOW_ICON |
                         (showPin?TabRenderer.SHOW_PIN:0) |
                         (showGrip && current!=null ?TabRenderer.SHOW_GRIP:0);
            var renderPos = tabSide;
            if (pinned || showGrip)
            {
               renderPos = TabRenderer.TOP;
               tabRect.height = barHeight;
               if (showGrip)
                  tabRect.width += barHeight;
            }
            else
            {
               flags |= TabRenderer.IS_OVERLAPPED;
               if (renderPos==TabRenderer.LEFT || renderPos==TabRenderer.RIGHT)
               {
                  if (renderPos==TabRenderer.RIGHT)
                     tabRect.x += tabRect.width;
                  tabRect.width = barHeight;
                  tallBar = true;
               }
               else
               {
                  //if (pos==DOCK_BOTTOM)
                  //   tabRect.y += tabRect.height;
                  tabRect.height = barHeight;
               }
            }

            // tabRect returns the gap after the tabs
            var gapRect = tabRenderer.renderTabs(background.mChrome, tabRect, children, current,
                hitBoxes,  renderPos, flags, tabPos );

            if (barDockable!=null)
            {
                if (tallBar)
                {
                trace("tallbar");
                   // Tabs run vertically...
                   barDockable.getLayout().setRect(tabRect.x, tabRect.y+gapRect.y, tabRect.width, tabRect.height-gapRect.y);
                }
                else if (showGrip)
                {
                   var x0 = tabRect.x+tabRect.width - barHeight;
                   var w = barHeight;
                   var y0 = 0;
                   var h = fullRect.height - tabRect.height;
                   // Tabs run horizontally, but extend into bar region
                   barDockable.getLayout().setRect(x0, y0, w, h);
                }
                else
                {
                   var y = tabRect.y;
                   if (pos==DOCK_BOTTOM)
                      y-= barHeight;
                   // tabs run horizontally, followed by bar
                   barDockable.getLayout().setRect(gapRect.x, y, gapRect.width, barHeight);
                }
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
      return inPos==DOCK_OVER || inPos==DOCK_BAR;
   }
   public function addDockable(inChild:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      if (inPos==DOCK_BAR)
      {
         if (barDockable!=null)
            Dock.remove(barDockable);
         barDockable = inChild;
         barContainer.visible = true;
         barDockable.setDock(this,barContainer);
         setDirty(true,true);
      }
      else
      {
         children.push(inChild);
         Dock.remove(inChild);
         setCurrent(inChild);
      }
   }

   public function getDockablePosition(child:IDockable):Int
   {
      return -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      if (child==barDockable)
         barDockable = null;
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



