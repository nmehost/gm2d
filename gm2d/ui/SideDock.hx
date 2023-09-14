package gm2d.ui;

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.BitmapData;
import gm2d.ui.DockPosition;
import nme.geom.Rectangle;
import gm2d.skin.Skin;
import gm2d.skin.DockRenderer;

class FramedDockable
{
   var frame:DockFrame;

   public var parent:SideDock;
   public var item(default,null):IDockable;
   public var layoutSize:Null<Int>;
   public var position:Int;

   public function new(inParent:SideDock,inItem:IDockable)
   {
      parent = inParent;
      setItem(inItem);
   }


   public function setItem(inItem:IDockable)
   {
      clearFrame();
 
      item = inItem;
      var pane = item.asPane();
      if (pane!=null)
      {
         frame = new DockFrame(pane, parent, { onTitleDrag:TopLevelDock.dragTitle }, pane.frameAttribs );
         frame.name = "DockFrame(" + pane + ")";
      }
      item.setDock(parent,frame);
   }

   public function clearFrame()
   {
      layoutSize = null;
      position = 0;
      if (frame!=null)
      {
         if (frame.parent!=null)
            frame.parent.removeChild(frame);
         frame = null;
      }
   }


   public function getLayout() : Layout
   {
      if (frame!=null)
          return frame.getLayout();
      return item.getLayout();
   }
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size
   {
      return item.getLayoutSize(w,h,limitX);
   }
   public function getDockedSize(w:Float,h:Float,variableWidth:Bool):Int
   {
      if (layoutSize==null)
      {
         if (variableWidth)
            layoutSize = Std.int(getLayout().getBestWidth(h));
         else
            layoutSize = Std.int(getLayout().getBestHeight(w));
      }
      return layoutSize;
   }
   public function getBestSize(?w:Null<Float>,?h:Null<Float>,variableWidth:Bool):Int
   {
      if (variableWidth)
         return Std.int(getLayout().getBestWidth(h));
      else
         return Std.int(getLayout().getBestHeight(w));
   }
   public function getMinSize(variableWidth:Bool)
   {
      var s = getLayout().getMinSize();
      if (variableWidth)
         return s.x;
      else
         return s.y;
   }
   public function setRect(container:DisplayObjectContainer,x:Float, y:Float, w:Float, h:Float)
   {
      if (frame!=null && frame.parent != container)
         container.addChild(frame);
      else if (frame==null)
         item.setDock(parent,container);
      getLayout().setRect(x,y,w,h);
   }
   public function toString():String
   {
      return 'FramedDockable($item)';
   }
}


class SideDock extends Layout implements IDock implements IDockable
{
   var variableWidths:Bool;
   var parentDock:IDock;
   var mDockables:Array<FramedDockable>;
   var mRect:Rectangle;
   var mSizes:Array<Float>;
   var container:DisplayObjectContainer;
   var position:DockPosition;
   var properties:Dynamic;
   var flags:Int;
   var mRenderer:DockRenderer;
   var skin:Skin;
   //var sideLayout:SideLayout;

   public var shortTitle:String;
   public var icon:BitmapData;
   public var title:String;

   public function new(?inSkin:Skin, inPos:DockPosition)
   {
      super();
      skin = Skin.getSkin(inSkin);

      flags =  Dock.RESIZABLE;
      variableWidths = inPos==DOCK_LEFT || inPos==DOCK_RIGHT;
      position = variableWidths ? DOCK_LEFT : DOCK_TOP;
      mRenderer = skin.dockRenderer([variableWidths?"VariableWidth":"VariableHeight","SideDock","Dock"]);
      mDockables = [];
      mSizes = [];
      properties = [];
      mRect = new Rectangle();
      title = shortTitle = "";
      stretch();
      //sideLayout = new SideLayout(this);
   }
   
   // Hierarchy
   public function getDock():IDock { return parentDock; }
   public function getSlot():Int { return variableWidths ? Dock.DOCK_SLOT_HORIZ : Dock.DOCK_SLOT_VERT; }
   public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void
   {
      parentDock = inDock;
      container = inParent;
      //for(d in mDockables)
      //   d.setDock(this,container);
   }
   public function closeRequest(inForce:Bool):Void { }
   // Display
   public function getTitle():String { return title; }
   public function getShortTitle():String { return shortTitle; }
   public function getIcon():BitmapData { return icon; }
   public function buttonStates():Array<Int> { return null; }
   public function getFlags():Int { return flags; }
   public function setFlags(inFlags:Int):Void { flags = inFlags; }
   public function isHorizontal() { return variableWidths; }
   // Layout
   public function getLayout() : Layout return this;
   function addPadding(size:Size) : Size
   {
      if (variableWidths)
         size.x += (mDockables.length-1) * mRenderer.getResizeBarWidth();
      else
         size.y += (mDockables.length-1) * mRenderer.getResizeBarWidth();
      return size;
   }

   override public function getBestWidth(?inHeight:Null<Float>) : Float
   {
      return getBestSize().x;
   }
   override public function getBestHeight(?inWidth:Null<Float>) : Float
   {
      return getBestSize().y;
   }
   override public function getBestSize():Size
   {
      var best = new Size(0,0);
      for(dv in mDockables)
      {
         var dock = dv.item;
         //var s = dock.getBestSize(variableWidths?Dock.DOCK_SLOT_HORIZ : Dock.DOCK_SLOT_VERT );
         var s = dv.getLayout().getBestSize();
         if (variableWidths)
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
      //trace("best " + variableWidths + " = " + best );
 
     return addPadding(best);
   }
   public function getProperties() : Dynamic { return properties; }


   override public function getMinSize():Size
   {
      var min = new Size(0,0);
      for(dv in mDockables)
      {
         var dock = dv.item;
         var s = dv.getLayout().getMinSize();
         if (variableWidths)
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
         for(dv in mDockables)
         {
            var dock = dv.item;
            var chrome = mRenderer.getChromeRect(dock);
            var s = dock.getLayoutSize(w-chrome.width, h-chrome.height,!variableWidths);
            s.x+=chrome.width;
            s.y+=chrome.height;

            if (variableWidths)
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
      var p = mDockables[inIndex].item.asPane();
      if (p==null) return "dock";
      return p.shortTitle;
   }
 
   static var indent = "";
   override public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      mRect = new Rectangle(x,y,w,h);
      layoutChildren();
      super.setRect(x,y,w,h);
   }

   function layoutChildren()
   {
      var x = mRect.x;
      var y = mRect.y;
      var w = mRect.width;
      var h = mRect.height;

      var right = x+w;
      var bottom = y+h;
      var barSize = mRenderer.getResizeBarWidth();
      if (variableWidths)
         w-= barSize * (mDockables.length-1);
      else
         h-= barSize * (mDockables.length-1);

      mSizes = [];

      // Only toolbars - changes logic a bit
      if (isLocked())
      {
         for(dv in mDockables)
         {
            var s = dv.getDockedSize(w,h,variableWidths);
            mSizes.push(s);
         }
      }
      else
      {
         var best_total = 0.0;
         var min_sizes = new Array<Int>();
         var best_sizes = new Array<Int>();
         var stretch_weight = new Array<Float>();
         var first_no_best = -1;
   
         var idx = 0;
         for(idx in 0...mDockables.length)
         {
            var dv = mDockables[idx];
            var m_size = Std.int(dv.getMinSize(variableWidths));
            min_sizes.push(m_size);
   
            var has_best = true;
            if (first_no_best<0 && !dv.item.hasBestSize())
            {
               has_best = false;
               first_no_best = idx;
            }
            var has_best = first_no_best>=0 || dv.item.hasBestSize();
            var b_size = dv.getDockedSize(w,h,variableWidths);
            if (b_size<m_size)
               b_size = m_size;

            best_sizes.push(b_size);
            best_total += b_size;

            stretch_weight.push(b_size+1);
         }
   
         var is_locked = new Array<Bool>();
         var too_big = best_total > (variableWidths ? w : h);
         //trace('first_no_best : $first_no_best  bs:'+best_sizes[first_no_best]+" min:" + min_sizes[first_no_best]);
         if ( first_no_best>=0 && (!too_big || best_sizes[first_no_best]>min_sizes[first_no_best]))
         {
            //stretch_weight[first_no_best] = 1.0;
            for(i in 0...mDockables.length)
               is_locked.push(i!=first_no_best);
         }
         else
         {
            for(d in 0...mDockables.length)
            {
               var dock = mDockables[d].item;
               var pane = dock.asPane();
               is_locked.push( (too_big && (best_sizes[d]<=min_sizes[d] )) || dock.isLocked() || !Dock.isResizeable(dock));
            }
         }

         var locked_changed = true;
   
         while(locked_changed)
         {
            locked_changed = false;
            var extra = Std.int((variableWidths ? w : h)-best_total);
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
            //trace('EXTRAS $extra, stretches: $stretchers $is_stretch $stretch_weight : $stretchers');
   
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
   
               //trace(indent + "Layout " + dockName(d) + " = " + layout_w + "x" + layout_h + "  -> " + s + " lock:" + is_locked[d] + "  size=" + size);
               var s = mDockables[d].getLayoutSize(variableWidths?size:w, variableWidths?h:size, variableWidths);
               var layout_size = Std.int(variableWidths ? s.x : s.y);
               if (is_stretch[d])
               {
                  // Layout wants to snap to certain size - lock in this size...
                  if (layout_size!=size)
                  {
                     is_locked[d] = true;
                     best_total += layout_size - best_sizes[d];
                     best_sizes[d] = min_sizes[d] = layout_size;
                     mSizes[d] = layout_size;
                     locked_changed = true;
                     break;
                  }
               }
               else
               {
                  size = layout_size;
               }
   
               mSizes[d] = size;
            }
         }
      }
   
      //trace("Sizes  " + mSizes );
      for(d in 0...mDockables.length)
      {
         var dockable = mDockables[d].item;
         var size = Std.int(mSizes[d]);
         var pane = dockable.asPane();
         var dw = (variableWidths?size:w);
         var dh = (variableWidths?h:size);
         var oid = indent;
         indent+="   ";
         //trace("  child set rect " + [x,y, dw, dh ]);
         mDockables[d].setRect(container,x,y, dw, dh );

         indent = oid;

         mDockables[d].layoutSize = size;

         if (variableWidths)
         {
            mDockables[d].position = Std.int(x);
            x+=size + barSize;
         }
         else
         {
            mDockables[d].position = Std.int(y);
            y+=size + barSize;
         }
      }
      //trace(" -> " + mSizes);

      setDirty(false,true);
   }


   public function isLocked():Bool
   {
      for(d in mDockables)
         if (!d.item.isLocked())
            return false;
      return true;
   }

   public function renderChrome(inContainer:Sprite,outHitBoxes:HitBoxes):Void
   {
      //trace("renderChrome " + mRect + " "  + mSizes);
      for(d in 0...mDockables.length)
      {
         mDockables[d].item.renderChrome(inContainer,outHitBoxes);
         /*
         var dv = mDockables[d];
         var pane = dv.item.asPane();
         var rect = variableWidths ?
              new Rectangle( dv.position, mRect.y, mSizes[d], mRect.height ) :
              new Rectangle( mRect.x, dv.position, mRect.width, mSizes[d] );
         */
         //var frame = mDockables[d].getFrame();
         //if (frame.parent!=inContainer)
            //inContainer.addChild(frame);
         //frame.setRect(rect.x,rect.y,rect.width,rect.height);
      }

      var gap = mRenderer.getResizeBarWidth();
      for(i in 0...mSizes.length-1)
      {
         var dv = mDockables[i];
         var pos = dv.position + dv.layoutSize;

         var extra = 1;
         var rect = variableWidths ?
            new Rectangle(pos-extra, mRect.y,   gap+extra*2, mRect.height) :
            new Rectangle(mRect.x,   pos-extra, mRect.width, gap+extra*2);
         //trace(mRect + " "  + rect + " " + inContainer);
         var gfx = inContainer.graphics;
         gfx.beginFill(0xff0000);
         gfx.drawRect( rect.x, rect.y, rect.width, rect.height );
         mRenderer.renderResizeBar(inContainer, rect);

         outHitBoxes.add( rect, DOCKSIZE(this,i) );
      }
   }

   public function asPane() : Pane { return null; }

   function onDock(inDockable:IDockable, inPos:Int )
   {
      Dock.remove(inDockable);
      addDockable(inDockable,variableWidths?DOCK_LEFT:DOCK_TOP,inPos);
   }

   public function addDockZones(outZones:DockZones):Void
   {
      if (mRect.contains(outZones.x, outZones.y))
      {
          for(d in mDockables)
             d.item.addDockZones(outZones);
          skin.addResizeDockZones(outZones,mRect,variableWidths,mSizes,onDock);
      }
   }
   public function hasBestSize()
   {
      for(d in mDockables)
         if (d.item.hasBestSize())
            return true;
      return false;
   }

   public function getLayoutInfo():Dynamic
   {
      var dockables = new Array<Dynamic>();
      for(i in 0...mDockables.length)
         dockables[i] = mDockables[i].item.getLayoutInfo();

      return { type:"SideDock", variableWidths:variableWidths, dockables:dockables, properties:properties, flags:flags };
   }

   public function loadLayout(inLayout:Dynamic):Void
   {
   }



   // --- Externals -----------------------------------------

   /*
   function doResize1(inIndex:Int, inS0:Size, inS1:Size)
   {
      trace("doResize " + inIndex);
      var orig = mDockables[inIndex].layoutSize;
      var delta = Std.int(variableWidths ? inS0.x-orig : inS0.y-orig);

      trace("Delta ->" + delta);
      var rect = mDockables[inIndex].getRect();
      mDockables[inIndex].setRect(rect.x, rect.y, inS0.x, inS0.y);

      var rect = mDockables[inIndex+1].getRect();
      if (variableWidths)
         rect.left += delta;
      else
         rect.top += delta;
      mDockables[inIndex+1].setRect(rect.x, rect.y, inS1.x, inS1.y );

      // TODO - apply to array
      mSizes[inIndex] += delta;
      mSizes[inIndex+1] -= delta;
      mDockables[inIndex].layoutSize += delta;
      mDockables[inIndex+1].layoutSize -= delta;

      mPositions[inIndex+1] += delta;
      setDirty(false,true);
   }
   */

   public function tryResize(inIndex:Int, inPosition:Float )
   {
      var prev = inIndex;
      var next = inIndex+1;
      if (next>=mDockables.length)
         return;

      var dv = mDockables[prev];
      var delta = Std.int(inPosition-dv.position-dv.layoutSize);

      // Account for quantized layouts
      // Pass 0, we try moving the first bopx, calcualte the delta and move the second box and see it it fits.
      // Pass 1, we reverse it and try moving the second one first
      for(pass in 0...2)
      {
         var orig = mDockables[prev].item.getLayout().getRect();
         // Try delta ...
         var test_w = variableWidths ? orig.width+delta : orig.width;
         var test_h = variableWidths ? orig.height : orig.height+delta;
         var s0 = mDockables[prev].getLayoutSize(test_w, test_h, variableWidths);
         var new_delta = Std.int(variableWidths ? s0.x - orig.width : s0.y-orig.height);

         //trace("try " + test_w + "x" + test_h + "   " + s0 + " -> " + new_delta + " fixX=" + (variableWidths) );
         if (new_delta!=0)
         {
            // now see if next pane is happy with this too...
            var orig = mDockables[next].item.getLayout().getRect();
            // Try new_delta ...
            var test_w = variableWidths ? orig.width-new_delta : orig.width;
            var test_h = variableWidths ? orig.height : orig.height-new_delta;
            var s1 = mDockables[next].getLayoutSize(test_w, test_h, variableWidths);

            var new_delta2 = variableWidths ? s1.x - orig.width : s1.y-orig.height;
            if (new_delta2+new_delta == 0)
            {
               var deltaS = pass==0 ? s0:s1;
               mDockables[inIndex].layoutSize += new_delta;
               mDockables[inIndex+1].layoutSize -= new_delta;
               layoutChildren();
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
      if (variableWidths)
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
      var v = new FramedDockable(this,child);
      if (inSlot>=mDockables.length)
      {
         mDockables.push(v);
      }
      else
         mDockables.insert(inSlot<0?0:inSlot, v);
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
      {
         trace("canAddDockable");
         addDockable(inIncoming, direction, after ? ref+1 : ref);
      }
      else if (inPos==DOCK_OVER)
      {
          var rect = inReference.getLayout().getRect();
          // Patch up references...
          var over = new MultiDock();
          mDockables[ref].setItem(over);
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
          var split = new SideDock(skin,direction);
          var asPane = mDockables[ref].item.asPane();
          if (asPane!=null)
          {
             if (Dock.isToolbar(asPane))
                split.mRenderer.gripperTop = mRenderer.gripperTop;
             asPane.onLayoutSwitch(getSlot());
          }
          mDockables[ref].setItem(split);
          split.addDockable(inReference,direction,-1);
          split.setDock(this,container);

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
         origin += mSizes[i];
      if (inRef>1)
        origin + (inRef-1) * mRenderer.getResizeBarWidth();

      if (variableWidths)
         return new Rectangle(mRect.x+origin, mRect.y, mSizes[inRef], mRect.height);
      else
         return new Rectangle(mRect.x, mRect.y+origin, mRect.width, mSizes[inRef]);
   }

   override public function toString()
   {
      if (lastRect==null)
         return "SideDock(null)";
      return("SideDock(" + lastRect.x + "," + lastRect.y + " " + lastRect.width + "x" + lastRect.height + ")");
   }

   public function verify()
   {
      for(dv in mDockables)
      {
         var d = dv.item;
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
        if (child==mDockables[i].item)
           return i;
      return -1;
   }

   // removeDockable - and collapse if required.
   public function removeDockable(child:IDockable):IDockable
   {
      var idx = getDockablePosition(child);
      if (idx>=0)
      {
         var d = mDockables[idx];
         d.clearFrame();
         mDockables.splice(idx,1);
         child.setDock(null,null);
         if (mDockables.length==0)
         {
             // Hmmm?
             trace("Bad pane nesting");
             return null;
         }
         else if (mDockables.length==1)
         {
            mDockables[0].clearFrame();
            return mDockables[0].item;
         }
      }
      else
      {
         // Child may have collapsed from SideDock into a container
         for(i in 0...mDockables.length)
         {
             var item = mDockables[i].item;
             var newItem = item.removeDockable(child);
             if (item!=newItem)
                 mDockables[i].setItem(newItem);
         }
      }
      setDirty(true,true);
      
      return this;
   }
 
   public function raiseDockable(child:IDockable):Bool
   {
      for(i in 0...mDockables.length)
        if (child==mDockables[i].item)
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


