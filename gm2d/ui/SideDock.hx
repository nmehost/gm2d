package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.ui.DockPosition;


class SideDock implements IDock, implements IDockable
{
   var horizontal:Bool;
   var parentDock:IDock;
   var mDockables:Array<IDockable>;
   var container:DisplayObjectContainer;
   var position:DockPosition;
   var flags:Int;

   public function new(inPos:DockPosition)
   {
      flags = 0;
      position = inPos;
      horizontal = inPos==DOCK_LEFT || inPos==DOCK_RIGHT;
      mDockables = [];
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
         size.x += (mDockables.length-1) + Skin.current.getSideGap() + Skin.current.getSideBorder()*2;
      else
         size.y += (mDockables.length-1) + Skin.current.getSideGap() + Skin.current.getSideBorder()*2;
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
      if (horizontal)
         x+=skin.getSideBorder();
      else
         y+=skin.getSideBorder();
      var pad = addPadding(new Size(0,0));
      w-=pad.x;
      h-=pad.y;

      var total = 0;
      var sizes = new Array<Int>();
      for(d in mDockables)
      {
         var s = d.getBestSize(position);
         var size = Std.int(horizontal ? s.x : s.y);
         sizes.push(size);
         total += size;
      }

      var extra = (horizontal ? w : h)-total;
      var idx = 0;
      for(d in mDockables)
      {
         var dim = sizes[idx];
         var size = dim + extra/(mDockables.length-idx);
         var s = d.getLayoutSize(horizontal?size:w, horizontal?h:size, !horizontal);
         switch(position)
         {
            case DOCK_LEFT, DOCK_TOP : d.setRect(x,y,s.x,s.y);
            case DOCK_RIGHT : d.setRect(right-x-s.x,y,s.x,s.y);
            case DOCK_BOTTOM : d.setRect(x,bottom-y-s.y,s.x,s.y);
            default:
         }

         if (horizontal)
         {
            size = s.x;
            x+=s.x + skin.getSideGap();
         }
         else
         {
            size = s.y;
            y+=s.y + skin.getSideGap();
         }
         extra -= size - dim;
         idx++;
      }
   }

   function doLayout()
   {
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

}


