package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.ui.DockPosition;
import gm2d.geom.Rectangle;
import gm2d.skin.Skin;

class MultiDock implements IDock, implements IDockable
{
   var parentDock:IDock;
   var mDockables:Array<IDockable>;
   var mRect:Rectangle;
   var container:DisplayObjectContainer;
   var currentDockable:IDockable;
   var bestSize:Array<Size>;
   var properties:Dynamic;
   var flags:Int;
   var tabStyle:Bool;

   public function new()
   {
      flags = 0;
      mDockables = [];
      bestSize = [];
      tabStyle = false;
      properties = {};
      mRect = new Rectangle();
   }
   
   // Hierarchy
   public function getDock():IDock { return parentDock; }
   public function getSlot():Int { return parentDock==null ? Dock.DOCK_SLOT_FLOAT : parentDock.getSlot(); }
   public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void
   {
      parentDock = inDock;
      container = inParent;
      setCurrent(currentDockable);
   }
   public function closeRequest(inForce:Bool):Void { }
   // Display
   public function getTitle():String { return ""; }
   public function getShortTitle():String { return ""; }
   public function getFlags():Int { return flags; }
   public function setFlags(inFlags:Int):Void { flags = inFlags; }
   // Layout
   public function addPadding(ioSize:Size):Size
   {
      var pad = Skin.current.getMultiDockChromePadding(mDockables.length,tabStyle);
      ioSize.x += pad.x;
      ioSize.y += pad.y;
      return ioSize;
   }
   public function getBestSize(inSlot:Int):Size
   {
      if (bestSize[inSlot]==null)
      {
         var best = new Size(0,0);
         for(dock in mDockables)
         {
            var s = dock.getBestSize(inSlot);
            if (s.x>best.x)
               best.x = s.x;
            if (s.y>best.y)
               best.y = s.y;
         }
         bestSize[inSlot] = addPadding(best);
      }
      return bestSize[inSlot].clone();
   }
   public function getProperties() : Dynamic { return properties; }





   public function getMinSize():Size
   {
      var min = new Size(0,0);
      var s = getSlot();
      for(dock in mDockables)
      {
         var s = dock.getMinSize();
         if (s.x>min.x)
            s.x = min.x;
         if (s.y>min.y)
            s.y = min.y;
      }
 
     return addPadding(min);
   }
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size
   {
      var min = getMinSize();
      return new Size(w<min.x ? min.x : w,h<min.y ? min.y : h);
   }
   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      mRect = new Rectangle(x,y,w,h);

      tabStyle = w>h;

      if (currentDockable!=null)
      {
         var rect = Skin.current.getMultiDockRect(mRect,mDockables,currentDockable,tabStyle);

         currentDockable.setRect(rect.x,rect.y,rect.width,rect.height);
      }
      bestSize[getSlot()] = new Size(w,h);

      setDirty(false,true);
   }

   public function getDockRect():gm2d.geom.Rectangle
   {
      return mRect.clone();
   }

   public function renderChrome(inContainer:Sprite,outHitBoxes:HitBoxes):Void
   {
      Skin.current.renderMultiDock(this,inContainer,outHitBoxes,mRect,mDockables,currentDockable,tabStyle);
   }

   public function asPane() : Pane { return null; }

   /*
   function onDock(inDockable:IDockable, inPos:Int )
   {
      Dock.remove(inDockable);
      addDockable(inDockable,horizontal?DOCK_LEFT:DOCK_TOP,inPos);
      raiseDockable(inDockable);
   }
   */

   public function addDockZones(outZones:DockZones):Void
   {
      var rect = getDockRect();

      if (rect.contains(outZones.x,outZones.y))
      {
         var skin = Skin.current;
         var dock = getDock();
         skin.renderDropZone(rect,outZones,DOCK_LEFT,true,   function(d) dock.addSibling(this,d,DOCK_LEFT) );
         skin.renderDropZone(rect,outZones,DOCK_RIGHT,true,  function(d) dock.addSibling(this,d,DOCK_RIGHT));
         skin.renderDropZone(rect,outZones,DOCK_TOP,true,    function(d) dock.addSibling(this,d,DOCK_TOP) );
         skin.renderDropZone(rect,outZones,DOCK_BOTTOM,true, function(d) dock.addSibling(this,d,DOCK_BOTTOM) );
         skin.renderDropZone(rect,outZones,DOCK_OVER,true,   function(d) addDockable(d,DOCK_OVER,9999) );
      }
   }


   public function getLayoutInfo():Dynamic
   {
      var dockables = new Array<Dynamic>();
      for(i in 0...mDockables.length)
         dockables[i] = mDockables[i].getLayoutInfo();

      return { type:"MultiDock",
          dockables:dockables, properties:properties, flags:flags,
          current:currentDockable==null ? null : currentDockable.getTitle(),
          bestSize : bestSize.copy() };
   }

   public function loadLayout(inLayout:Dynamic):Void
   {
      bestSize = [];
      var sizes:Array<Dynamic> = inLayout.bestSize;
      for(idx in 0...sizes.length)
      {
         var s = sizes[idx];
         if (s!=null)
            bestSize[idx] = new Size( s.x, s.y );
      }
   }




   // --- IDock -----------------------------------------
   public function canAddDockable(inPos:DockPosition):Bool
   {
      return inPos==DOCK_OVER;
   }
   public function pushDockableInternal(child:IDockable)
   {
      mDockables.push(child);
   }
   public function addDockable(child:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
      Dock.remove(child);
      child.setDock(this,container);
      if (inSlot>=mDockables.length)
         mDockables.push(child);
      else
         mDockables.insert(inSlot<0?0:inSlot, child);
      raiseDockable(child);
      setDirty(true,true);
   }
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition)
   {
      throw "No sibling for multi-dock";
   }

   public function toString()
   {
      var r = getDockRect();
      return("MultiDock " + mDockables);
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
            var old = mDockables[i];
            mDockables[i] = old.removeDockable(child);
            if (mDockables[i]!=old)
            {
               if (currentDockable==old)
               {
                  currentDockable = mDockables[i];
                  mDockables[i].setDock(this,container);
               }
               else
                  mDockables[i].setDock(this,container);
               setDirty(true,true);
            }
         }
      }
      
      return this;
   }

   function setCurrent(child:IDockable)
   {
      currentDockable = child;
      var found = false;
           
      for(d in mDockables)
      {
          if (d==child)
          {
             found = true;
             d.setDock(this,container);
          }
          else
             d.setDock(this,null);
      }

      if (!found && tabStyle && mDockables.length>0)
         setCurrent(mDockables[0]);
      else if (currentDockable!=null)
      {
         var rect = Skin.current.getMultiDockRect(mRect,mDockables,currentDockable,tabStyle);

         currentDockable.setRect(rect.x,rect.y,rect.width,rect.height);
      }

      setDirty(true,true);
   }
 
 
   public function raiseDockable(child:IDockable):Bool
   {
      for(i in 0...mDockables.length)
        if (child==mDockables[i])
        {
           setCurrent(child);
           return true;
        }
      return false;
   }

   public function minimizeDockable(child:IDockable):Bool
   {
      if (currentDockable==child)
      {
         setCurrent(null);
         return true;
      }
      return false;
   }

   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
      if (parentDock!=null)
         parentDock.setDirty(inLayout,inChrome);
   }


}


