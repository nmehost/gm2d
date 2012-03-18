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
   var container:DisplayObjectContainer;
   var position:DockPosition;
   var flags:Int;

   public function new(inPos:DockPosition)
   {
      flags = 0;
      position = inPos;
      horizontal = inPos==DOCK_LEFT || inPos==DOCK_RIGHT;
      mDockables = [];
      mPositions = [];
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
   // Layout
   function addPadding(size:Size) : Size
   {
      if (horizontal)
         size.x += (mDockables.length-1) + Skin.current.getResizeBarWidth();
      else
         size.y += (mDockables.length-1) + Skin.current.getResizeBarWidth();
      return size;
   }
   public function getBestSize(inPos:DockPosition):Size
   {
      var best = new Size(0,0);
      for(dock in mDockables)
      {
         var s = dock.getBestSize(position);
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
   public function wantsResize(inHorizontal:Bool,inMove:Int):Bool
   {
      for(dock in mDockables)
         if (!dock.wantsResize(inHorizontal,inMove))
            return false;
      return true;
   }

   public function getMinSize():Size
   {
      var min = new Size(0,0);
      for(dock in mDockables)
      {
         var s = dock.getMinSize();
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
      var pad = addPadding(new Size(0,0));
      w-=pad.x;
      h-=pad.y;
      var barSize = skin.getResizeBarWidth();
      if (horizontal)
         w-= barSize * (mDockables.length-1);
      else
         h-= barSize * (mDockables.length-1);

      mRect = new Rectangle(x,y,w,h);

      mPositions = [];
      mPositions.push( horizontal ? x : y );

      while(true)
      {
         var total = 0;
         var sizes = new Array<Int>();

         for(d in mDockables)
         {
            var s = d.getBestSize(position);
            var size = Std.int(horizontal ? s.x : s.y);
            sizes.push(size);
            total += size;
         }

         var extra = Std.int((horizontal ? w : h)-total);
         var stretchers = 0;
         if (extra!=0)
            for(d in mDockables)
               if (d.wantsResize(horizontal,extra))
                  stretchers ++;

         var idx = 0;
         var orig_extra = extra;
         for(d in mDockables)
         {
            var dim = sizes[idx];
            var size = dim;
            var item_extra = stretchers>0 ? Std.int( extra/stretchers + 0.5 ) : 0;
            if ( item_extra!=0 && d.wantsResize(horizontal,item_extra))
            {
               size += item_extra;
               stretchers--;
            }

            var s = d.getLayoutSize(horizontal?size:w, horizontal?h:size, !horizontal);
            d.setRect(x,y,s.x,s.y);

            if (horizontal)
            {
               size = Std.int(s.x+0.5);
               x+=size + barSize;
            }
            else
            {
               size = Std.int(s.y+0.5);
               y+=size + barSize;
            }
            mPositions.push( horizontal ? x : y );
            extra -= size - dim;
            idx++;
         }
         if (extra==orig_extra)
            break;
         break;
      }
      //trace("horizontal :" + mRect + "   " + horizontal + mPositions );
      setChromeDirty();
   }

   function doLayout()
   {
   }

   public function renderChrome(inContainer:Sprite):Void
   {
      for(d in 0...mDockables.length)
      {
         var pane = mDockables[d].asPane();
         if (pane!=null)
         {
            var gfx = inContainer.graphics;
            var p0 = mPositions[d];
            var p1 = mPositions[d+1];
            gfx.beginFill(Panel.panelColor);
            if (horizontal)
               gfx.drawRect( p0, mRect.y, p1-p0, mRect.height );
            else
               gfx.drawRect( mRect.x, p0, mRect.width, p1-p0 );
         }
         else
            mDockables[d].renderChrome(inContainer);
      }

      //trace("horizontal :" + mRect + "   " + horizontal + mPositions );
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


