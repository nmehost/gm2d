package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.ui.DockPosition;
import gm2d.geom.Rectangle;
import gm2d.skin.Skin;

#if haxe3
class SideDock implements IDock implements IDockable
#else
class SideDock implements IDock, implements IDockable
#end
{
   var horizontal:Bool;
   var parentDock:IDock;
   var mDockables:Array<IDockable>;
   var mRect:Rectangle;
   var mPositions:Array<Float>;
   var mWidths:Array<Float>;
   var mSizes:Array<Size>;
   var container:DisplayObjectContainer;
   var position:DockPosition;
   var properties:Dynamic;
   var toolbarGripperTop:Bool;
   var flags:Int;
   public var shortTitle:String;
   public var icon:BitmapData;
   public var title:String;

   public function new(inPos:DockPosition)
   {
      flags = 0;
      horizontal = inPos==DOCK_LEFT || inPos==DOCK_RIGHT;
      position = horizontal ? DOCK_LEFT : DOCK_TOP;
      mDockables = [];
      mPositions = [];
      mWidths = [];
      mSizes = [];
      properties = [];
      toolbarGripperTop = horizontal;
      mRect = new Rectangle();
      title = shortTitle = "";
   }
   
   // Hierarchy
   public function getDock():IDock { return parentDock; }
   public function getSlot():Int { return horizontal ? Dock.DOCK_SLOT_HORIZ : Dock.DOCK_SLOT_VERT; }
   public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void
   {
      parentDock = inDock;
      container = inParent;
      for(d in mDockables)
         d.setDock(this,container);
   }
   public function closeRequest(inForce:Bool):Void { }
   // Display
   public function getTitle():String { return title; }
   public function getShortTitle():String { return shortTitle; }
   public function getIcon():BitmapData { return icon; }
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
      var rect = Skin.current.getChromeRect(inDock,toolbarGripperTop);
      ioPos.x += rect.width;
      ioPos.y += rect.height;
      return ioPos;
   }
   public function getBestSize(inSlot:Int):Size
   {
      var best = new Size(0,0);
      for(dock in mDockables)
      {
         var s = dock.getBestSize(horizontal?Dock.DOCK_SLOT_HORIZ : Dock.DOCK_SLOT_VERT );
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
      //trace("best " + horizontal + " = " + best );
 
     return addPadding(best);
   }
   public function getProperties() : Dynamic { return properties; }


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
      if (isLocked())
      {
         var min = new Size(0,0);
         addPadding(min);
         w-=min.x;
         h-=min.y;
         for(dock in mDockables)
         {
            var chrome = Skin.current.getChromeRect(dock,toolbarGripperTop);
            var s = dock.getLayoutSize(w-chrome.width, h-chrome.height,!horizontal);
            s.x+=chrome.width;
            s.y+=chrome.height;

            if (horizontal)
            {
               min.x += s.x;
               if (s.y>min.y) min.y = s.y;
            }
            else
            {
               if (s.x>min.x) min.x = s.x;
               min.y += s.y;
            }
         }
        return min;
      }

      var min = getMinSize();
      return new Size(w<min.x ? min.x : w,h<min.y ? min.y : h);
   }

   function dockName(inIndex:Int) : String
   {
      var p = mDockables[inIndex].asPane();
      if (p==null) return "dock";
      return p.shortTitle;
   }
 
   static var indent = "";
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      mRect = new Rectangle(x,y,w,h);
      //trace(indent + "Set rect " + horizontal + " " + mRect);

      var right = x+w;
      var bottom = y+h;
      var skin = Skin.current;
      var barSize = skin.getResizeBarWidth();
      if (horizontal)
         w-= barSize * (mDockables.length-1);
      else
         h-= barSize * (mDockables.length-1);

      mPositions = [];
      mWidths = [];
      mSizes = [];



      // Only toolbars - changes logic a bit
      if (isLocked())
      {
         for(d in mDockables)
         {
            var chrome = Skin.current.getChromeRect(d,toolbarGripperTop);
            var s = d.getLayoutSize(w-chrome.width,h-chrome.height,!horizontal);
            s.x+=chrome.width;
            s.y+=chrome.height;
            mSizes.push(s);
            var layout_size = Std.int(!horizontal ? s.y:s.x);
            mWidths.push(layout_size);
         }
      }
      else
      {
         var best_total = 0;
         var min_sizes = new Array<Int>();
         var best_sizes = new Array<Int>();
         var stretch_weight = new Array<Float>();
   
         var idx = 0;
         for(d in mDockables)
         {
            var s = d.getMinSize();
            addPaneChromeSize(d,s);
            var m_size = Std.int(horizontal ? s.x : s.y);
            min_sizes.push(m_size);
   
            var s = horizontal ? d.getBestSize(Dock.DOCK_SLOT_HORIZ) : d.getBestSize(Dock.DOCK_SLOT_VERT);

            addPaneChromeSize(d,s);
   
            mSizes.push(s.clone());
            var b_size = Std.int(horizontal ? s.x : s.y);
            stretch_weight.push(b_size > 1 ? b_size : 1 );
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
            is_locked.push( (too_big && (best_sizes[d]<=min_sizes[d] )) || mDockables[d].isLocked() );
         }
   
         var locked_changed = true;
         var pass = 0;
   
         while(locked_changed)
         {
            locked_changed = false;
            var extra = Std.int((horizontal ? w : h)-best_total);
            var stretchers = 0.0;
            var is_stretch = new Array<Bool>();
            if (extra!=0)
            {
               for(d in 0...mDockables.length)
               {
                  if ( !is_locked[d] )
                  {
                     is_stretch.push(true);
                     stretchers += stretch_weight[d];
                  }
                  else
                     is_stretch.push(false);
               }
            }
   
            //trace(indent + " " + extra + " over " + is_stretch + "  best " + best_sizes);
   
            for(d in 0...mDockables.length)
            {
               var dim = best_sizes[d];
               var size = dim;
               var here = extra*stretch_weight[d]/stretchers;
               var item_extra = stretchers>0 ? Std.int( extra*stretch_weight[d]/stretchers + 0.5 ) : 0;
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
                  stretchers-=stretch_weight[d];
               }
   
               var chrome = Skin.current.getChromeRect(mDockables[d],toolbarGripperTop);
               var layout_w = (horizontal?size:w) - chrome.width;
               var layout_h = (horizontal?h:size) - chrome.height;
               var s = mDockables[d].getLayoutSize(layout_w, layout_h, horizontal);
               //trace(indent + "Layout " + dockName(d) + " = " + layout_w + "x" + layout_h + "  -> " + s + " lock:" + is_locked[d] + "  size=" + size);
               s.x += chrome.width;
               s.y += chrome.height;
               mSizes[d] = s.clone();
   
               if (is_stretch[d])
               {
                  var layout_size = Std.int(!horizontal ? s.y : s.x);
                  // Layout wants to snap to certain size - lock in this size...
                  if (layout_size!=size)
                  {
                     is_locked[d] = true;
                     best_total += layout_size - best_sizes[d];
                     best_sizes[d] = min_sizes[d] = layout_size;
                     mWidths[d] = layout_size;
                     locked_changed = true;
                     break;
                  }
               }
               else
               {
                  size = Std.int(horizontal ? s.x : s.y );
               }
   
               mWidths[d] = size;
            }
         }
      }
   
      for(d in 0...mDockables.length)
      {
         var dockable = mDockables[d];
         var size = mWidths[d];
         var chrome = Skin.current.getChromeRect(dockable,toolbarGripperTop);
         var pane = dockable.asPane();
         var dw = (horizontal?size:mSizes[d].x)-chrome.width;
         var dh = (horizontal?mSizes[d].y:size) -chrome.height;
         var oid = indent;
         indent+="   ";
         dockable.setRect(x+chrome.x,y+chrome.y, dw, dh );
         indent = oid;

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

      setDirty(false,true);
   }


   public function isLocked():Bool
   {
      for(d in mDockables)
         if (!d.isLocked())
            return false;
      return true;
   }



   public function getDockRect():gm2d.geom.Rectangle
   {
      return mRect.clone();
   }

   public function renderChrome(inContainer:Sprite,outHitBoxes:HitBoxes):Void
   {
      Skin.current.renderResizeBars(this,inContainer,outHitBoxes,mRect,horizontal,mWidths);
      for(d in 0...mDockables.length)
      {
         var pane = mDockables[d].asPane();
         var rect = horizontal ?
                      new Rectangle( mPositions[d], mRect.y, mWidths[d], mRect.height ) :
                      new Rectangle( mRect.x, mPositions[d], mRect.width, mWidths[d] );
         if (pane!=null)
         {
            Skin.current.renderPaneChrome(pane,inContainer,outHitBoxes,rect,
               toolbarGripperTop?Skin.TOOLBAR_GRIP_TOP:0);
         }
         else
         {
            mDockables[d].renderChrome(inContainer,outHitBoxes);
            var r = mDockables[d].getDockRect();
            var gap = horizontal ? mRect.height - r.height : mRect.width-r.width;
            if (gap>0.5)
            {
               if (horizontal)
                  Skin.current.renderToolbarGap(inContainer,rect.x, rect.bottom-gap, rect.width, gap);
               else
                  Skin.current.renderToolbarGap(inContainer,rect.right - gap, rect.y, gap, rect.height);
            }
         }
      }
   }

   public function asPane() : Pane { return null; }

   function onDock(inDockable:IDockable, inPos:Int )
   {
      Dock.remove(inDockable);
      addDockable(inDockable,horizontal?DOCK_LEFT:DOCK_TOP,inPos);
   }

   public function addDockZones(outZones:DockZones):Void
   {
      if (mRect.contains(outZones.x, outZones.y))
      {
          for(d in mDockables)
             d.addDockZones(outZones);
          Skin.current.addResizeDockZones(outZones,mRect,horizontal,mWidths,onDock);
      }
   }

   public function getLayoutInfo():Dynamic
   {
      var dockables = new Array<Dynamic>();
      for(i in 0...mDockables.length)
         dockables[i] = mDockables[i].getLayoutInfo();

      return { type:"SideDock", horizontal:horizontal, dockables:dockables, properties:properties, flags:flags };
   }

   public function loadLayout(inLayout:Dynamic):Void
   {
   }



   // --- Externals -----------------------------------------

   function doResize(inIndex:Int, inS0:Size, inS1:Size)
   {
      var rect = mDockables[inIndex].getDockRect();
      var delta = horizontal ? inS0.x-rect.width : inS0.y-rect.height;
      mDockables[inIndex].setRect(rect.x, rect.y, inS0.x, inS0.y);

      var rect = mDockables[inIndex+1].getDockRect();
      if (horizontal)
         rect.left += delta;
      else
         rect.top += delta;
      mDockables[inIndex+1].setRect(rect.x, rect.y, inS1.x, inS1.y );

      mWidths[inIndex] += delta;
      mWidths[inIndex+1] -= delta;
      mPositions[inIndex+1] += delta;
      setDirty(false,true);
   }

   public function tryResize(inIndex:Int, inPosition:Float )
   {
      var delta = Std.int(inPosition-mPositions[inIndex+1]);
      var prev = inIndex;
      var next = inIndex+1;
      if (next>=mPositions.length)
         return;

      //trace( inIndex + " -> " + delta );
      // See if we can resize...
      for(pass in 0...2)
      {
         var orig = mDockables[prev].getDockRect();
         // Try delta ...
         var test_w = horizontal ? orig.width+delta : orig.width;
         var test_h = horizontal ? orig.height : orig.height+delta;
         var s0 = mDockables[prev].getLayoutSize(test_w, test_h, horizontal);

         var new_delta = horizontal ? s0.x - orig.width : s0.y-orig.height;
         //trace("try " + test_w + "x" + test_h + "   " + s0 + " -> " + new_delta + " fixX=" + (horizontal) );
         if (new_delta!=0)
         {
            // now see if next pane is happy with this too...
            var orig = mDockables[next].getDockRect();
            // Try new_delta ...
            var test_w = horizontal ? orig.width-new_delta : orig.width;
            var test_h = horizontal ? orig.height : orig.height-new_delta;
            var s1 = mDockables[next].getLayoutSize(test_w, test_h, horizontal);

            var new_delta2 = horizontal ? s1.x - orig.width : s1.y-orig.height;
            if (new_delta2+new_delta == 0)
            {
               doResize(inIndex,pass==0 ? s0:s1, pass==0?s1:s0);
               return;
            }
         }

         // Try moving the other one first....
         delta = -delta;
         prev = next;
         next = inIndex;
      }
   }

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
      Dock.remove(child);
      child.setDock(this,container);
      if (inSlot>=mDockables.length)
         mDockables.push(child);
      else
         mDockables.insert(inSlot<0?0:inSlot, child);
      setDirty(true,true);
   }
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition)
   {
      var ref = getDockablePosition(inReference);
      if (ref<0)
      {
         trace("Reference not found : " + inReference + " in " + mDockables );
         throw "Bad docking reference";
      }

      var direction = inPos==DOCK_LEFT||inPos==DOCK_RIGHT ? DOCK_LEFT : DOCK_TOP;
      var after = inPos==DOCK_RIGHT||inPos==DOCK_BOTTOM;
      if (canAddDockable(inPos))
         addDockable(inIncoming, direction, after ? ref+1 : ref);
      else if (inPos==DOCK_OVER)
      {
          var rect = inReference.getDockRect();
          // Patch up references...
          var over = new MultiDock();
          mDockables[ref] = over;
          over.setDock(this,container);
          over.pushDockableInternal(inReference);
          inReference.setDock(over,container);
          over.addDockable(inIncoming,DOCK_OVER,2);
          over.setRect(rect.x,rect.y,rect.width,rect.height);
          setDirty(true,true);
      }
      else
      {
          var rect = getDockableRect(ref);
          // Patch up references...
          var split = new SideDock(direction);
          var asPane = mDockables[ref].asPane();
          if (asPane!=null)
          {
             if (Dock.isToolbar(asPane))
                split.toolbarGripperTop = toolbarGripperTop;
             asPane.onLayoutSwitch(getSlot());
          }
          mDockables[ref] = split;
          split.setDock(this,container);
          split.mDockables.push(inReference);
          inReference.setDock(split,container);
          split.addDockable(inIncoming,direction,after?1:-1);
          split.setRect(rect.x,rect.y,rect.width,rect.height);
          setDirty(true,true);
      }
      verify();
   }

   public function getDockableRect(inRef:Int)
   {
      var origin = 0.0;
      for(i in 0...inRef)
         origin += mWidths[i];
      if (inRef>1)
        origin + (inRef-1) * Skin.current.getResizeBarWidth();

      if (horizontal)
         return new Rectangle(mRect.x+origin, mRect.y, mWidths[inRef], mRect.height);
      else
         return new Rectangle(mRect.x, mRect.y+origin, mRect.width, mWidths[inRef]);
   }

   public function toString()
   {
      var r = getDockRect();
      return("SideDock(" + r.x + "," + r.y + " " + r.width + "x" + r.height + ")");
   }

   public function verify()
   {
      for(d in mDockables)
      {
         if (d.getDock()!=this)
         {
             trace("  this  " + this );
             trace("  child " + d );
             trace("  is    " + d.getDock() );
             trace("  children " + mDockables );
             throw("Bad dock reference");
         }
         d.verify();
      }
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
         child.setDock(null,null);
         if (mDockables.length==0)
         {
             // Hmmm?
             trace("Bad pane nesting");
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
         {
             mDockables[i] = mDockables[i].removeDockable(child);
             mDockables[i].setDock(this,container);
         }
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
      return false;
   }
   public function minimizeDockable(child:IDockable):Bool
   {
      return false;
   }
 
   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      if (parentDock!=null)
         parentDock.setDirty(inLayout,inChrome);
   }


}


