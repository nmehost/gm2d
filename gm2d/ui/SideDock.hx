package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.ui.DockPosition;
import gm2d.geom.Rectangle;


class SideDock implements IDock, implements IDockable
{
   var horizontal:Bool;
   var parentDock:IDock;
   var mDockables:Array<IDockable>;
   var mRect:Rectangle;
   var mPositions:Array<Float>;
   var mSizes:Array<Float>;
   var container:DisplayObjectContainer;
   var position:DockPosition;
   var flags:Int;

   public function new(inPos:DockPosition)
   {
      flags = 0;
      horizontal = inPos==DOCK_LEFT || inPos==DOCK_RIGHT;
      position = horizontal ? DOCK_LEFT : DOCK_TOP;
      mDockables = [];
      mPositions = [];
      mSizes = [];
      mRect = new Rectangle();
   }
   
   // Hierarchy
   public function getDock():IDock { return parentDock; }
   public function setDock(inDock:IDock):Void { parentDock = inDock; }
   public function setContainer(inParent:DisplayObjectContainer):Void
   {
      container = inParent;
      for(d in mDockables)
         d.setContainer(container);
   }
   public function closeRequest(inForce:Bool):Void { }
   // Display
   public function getTitle():String { return ""; }
   public function getShortTitle():String { return ""; }
   public function buttonStates():Array<Int> { return null; }
   public function getFlags():Int { return flags; }
   public function setFlags(inFlags:Int):Void { flags = inFlags; }
   public function isHorizontal() { return horizontal; }
   // Layout
   function addPadding(size:Size) : Size
   {
      if (horizontal)
         size.x += (mDockables.length-1) * Skin.current.getResizeBarWidth();
      else
         size.y += (mDockables.length-1) * Skin.current.getResizeBarWidth();
      return size;
   }
   public function addPaneChromeSize(inDock:IDockable,ioPos:Size):Size
   {
      var rect = Skin.current.getChromeRect(inDock);
      ioPos.x += rect.width;
      ioPos.y += rect.height;
      return ioPos;
   }
   public function getBestSize(inPos:DockPosition):Size
   {
      var best = new Size(0,0);
      for(dock in mDockables)
      {
         var s = dock.getBestSize(position);
         addPaneChromeSize(dock,s);
         if (horizontal)
         {
            best.x += s.x;
            if (best.y==0 || s.y>best.y) best.y = s.y;
         }
         else
         {
            if (best.x==0 || s.x>best.x) best.x = s.x;
            best.y += s.y;
         }
      }
 
     return addPadding(best);
   }

   public function getMinSize():Size
   {
      var min = new Size(0,0);
      for(dock in mDockables)
      {
         var s = dock.getMinSize();
         addPaneChromeSize(dock,s);
         if (horizontal)
         {
            min.x += s.x;
            if (min.y==0 || s.y>min.y) min.y = s.y;
         }
         else
         {
            if (min.x==0 || s.x>min.x) min.x = s.x;
            min.y += s.y;
         }
      }
     return addPadding(min);
   }
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size
   {
      return new Size(w,h);
   }
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      var right = x+w;
      var bottom = y+h;
      var skin = Skin.current;
      var barSize = skin.getResizeBarWidth();
      if (horizontal)
         w-= barSize * (mDockables.length-1);
      else
         h-= barSize * (mDockables.length-1);

      mRect = new Rectangle(x,y,w,h);

      mPositions = [];
      mSizes = [];


      var best_total = 0;
      var min_sizes = new Array<Int>();
      var best_sizes = new Array<Int>();

      for(d in mDockables)
      {
         var s = d.getMinSize();
         addPaneChromeSize(d,s);
         var m_size = Std.int(horizontal ? s.x : s.y);
         min_sizes.push(m_size);

         var s = d.getBestSize(position);
         addPaneChromeSize(d,s);
         var b_size = Std.int(horizontal ? s.x : s.y);
         if (b_size<m_size)
            b_size = m_size;
         best_sizes.push(b_size);
         best_total += b_size;
      }

      var is_locked = new Array<Bool>();
      var too_big = best_total > (horizontal ? w : h);
      for(d in 0...mDockables.length)
      {
         var pane = mDockables[d].asPane();
         is_locked.push( (too_big && (best_sizes[d]<=min_sizes[d] )) || (pane!=null &&  Dock.isToolbar(pane) ) );
      }

      var locked_changed = true;
      while(locked_changed)
      {
         locked_changed = false;
         var extra = Std.int((horizontal ? w : h)-best_total);
         var stretchers = 0;
         var is_stretch = new Array<Bool>();
         if (extra!=0)
         {
            for(d in 0...mDockables.length)
            {
               if ( !is_locked[d] )
               {
                  is_stretch.push(true);
                  stretchers ++;
               }
               else
                  is_stretch.push(false);
            }
         }


         for(d in 0...mDockables.length)
         {
            var dim = best_sizes[d];
            var size = dim;
            var item_extra = stretchers>0 ? Std.int( extra/stretchers + 0.5 ) : 0;
            if ( item_extra!=0 && is_stretch[d] )
            {
               size += item_extra;
               // Hit min - set it in stone and try again...
               if (size<min_sizes[d] && best_sizes[d]>min_sizes[d])
               {
                  is_locked[d] = true;
                  best_total += min_sizes[d] - best_sizes[d];
                  best_sizes[d] = min_sizes[d];
                  locked_changed = true;
                  break;
               }
               extra -= size - dim;
               stretchers--;
            }

            if (is_stretch[d])
            {
               var chrome = Skin.current.getChromeRect(mDockables[d]);
               var layout_w = (horizontal?w:size) - chrome.width;
               var layout_h = (horizontal?size:h) - chrome.width;
               var s = mDockables[d].getLayoutSize(layout_w, layout_h, !horizontal);
               var layout_size = Std.int(horizontal ? s.y+chrome.height : s.x+chrome.width);
               // Layout wants to snap to certain size - lock in this size...
               if (layout_size!=size)
               {
                  is_locked[d] = true;
                  best_total += layout_size - best_sizes[d];
                  best_sizes[d] = min_sizes[d] = layout_size;
                  locked_changed = true;
                  break;
               }
            }

            mSizes[d] = size;
         }
      }

      for(d in 0...mDockables.length)
      {
         var dockable = mDockables[d];
         var size = mSizes[d];
         var chrome = Skin.current.getChromeRect(dockable);
         dockable.setRect(x+chrome.x,y+chrome.y,
            (horizontal?size:w)-chrome.width, (horizontal?h:size) -chrome.height);

         if (horizontal)
         {
            mPositions.push( x );
            x+=size + barSize;
         }
         else
         {
            mPositions.push( y );
            y+=size + barSize;
         }
      }

      setChromeDirty();
   }

   function doLayout()
   {
   }

   public function renderChrome(inContainer:Sprite,outHitBoxes:HitBoxes):Void
   {
      Skin.current.renderResizeBars(this,inContainer,outHitBoxes,mRect,horizontal,mSizes);
      for(d in 0...mDockables.length)
      {
         var pane = mDockables[d].asPane();
         if (pane!=null)
         {
            Skin.current.renderPaneChrome(pane,inContainer,outHitBoxes,
                  horizontal ?
                      new Rectangle( mPositions[d], mRect.y, mSizes[d], mRect.height ) :
                      new Rectangle( mRect.x, mPositions[d], mRect.width, mSizes[d] ) );
         }
         else
            mDockables[d].renderChrome(inContainer,outHitBoxes);
      }
   }

   public function asPane() : Pane { return null; }


   // --- IDock -----------------------------------------
   public function canAddDockable(inPos:DockPosition):Bool
   {
      if (horizontal)
         return inPos==DOCK_LEFT || inPos==DOCK_RIGHT;
      else
         return inPos==DOCK_TOP || inPos==DOCK_BOTTOM;
   }
   public function addDockable(child:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      if (inPos!=position)
         inSlot = mDockables.length-inSlot;
      child.setDock(this);
      child.setContainer(container);
      if (inSlot>=mDockables.length)
         mDockables.push(child);
      else
         mDockables.insert(inSlot<0?0:inSlot, child);
      doLayout();
   }
   public function getDockablePosition(child:IDockable):Int
   {
      for(i in 0...mDockables.length)
        if (child==mDockables[i])
           return i;
      return -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      if (mDockables.remove(child))
      {
         if (mDockables.length==0)
         {
             // Hmmm?
             return null;
         }
         else if (mDockables.length==1)
         {
            return mDockables[0];
         }
      }
      else
      {
         for(i in 0...mDockables.length)
             mDockables[i] = mDockables[i].removeDockable(child);
      }
      return this;
   }
 
   public function raiseDockable(child:IDockable):Bool
   {
      for(i in 0...mDockables.length)
        if (child==mDockables[i])
        {
           return true;
        }
        else
        {
        }
      return false;
   }
   public function setChromeDirty():Void
   {
      if (parentDock!=null)
         parentDock.setChromeDirty();
   }


}


