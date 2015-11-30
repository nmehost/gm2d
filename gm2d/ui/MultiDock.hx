package gm2d.ui;

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.BitmapData;
import gm2d.ui.DockPosition;
import gm2d.ui.HitBoxes;
import nme.geom.Rectangle;
import gm2d.skin.Skin;
import gm2d.skin.TabRenderer;
import nme.display.SimpleButton;
import nme.events.MouseEvent;
import nme.text.TextField;

class MultiDock implements IDock implements IDockable
{
   public var forceTabStyle(default,set):Bool;
   public var title:String;
   public var shortTitle:String;
   public var icon:BitmapData;

   var parentDock:IDock;
   var mDockables:Array<IDockable>;
   var mRect:Rectangle;
   var container:DisplayObjectContainer;
   var currentDockable:IDockable;
   var bestSize:Array<Size>;
   var properties:Dynamic;
   var flags:Int;
   var tabRenderer:TabRenderer;
   var tabStyle:Bool;

   public function new()
   {
      flags = 0;
      mDockables = [];
      bestSize = [];
      tabStyle = false;
      forceTabStyle = false;
      tabRenderer = Skin.tabRenderer( ["MultiDock","Tabs","TabRenderer"] );
      properties = {};
      mRect = null;
   }

   public function set_forceTabStyle(inTabs:Bool)
   {
      forceTabStyle = inTabs;
      setDirty(true,true);
      return inTabs;
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
   public function getTitle():String { return title; }
   public function getShortTitle():String { return shortTitle; }
   public function getIcon():nme.display.BitmapData { return icon; }
   public function getFlags():Int { return flags; }
   public function setFlags(inFlags:Int):Void { flags = inFlags; }
   // Layout
   public function addPadding(ioSize:Size):Size
   {
      var pad = Skin.getMultiDockChromePadding(mDockables.length,tabStyle);
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
            min.x = s.x;
         if (s.y>min.y)
            min.y = s.y;
      }
 
     return addPadding(min);
   }
   public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size
   {
      var min = getMinSize();
      return new Size(w<min.x ? min.x : w,h<min.y ? min.y : h);
   }

   public function isLocked():Bool { return false; }

   function getCurrentRect()
   {
      var rect:Rectangle = null;
      if (tabStyle)
      {
         var tabHeight = tabRenderer.getHeight();
         return new Rectangle(mRect.x, mRect.y + tabHeight, mRect.width, mRect.height-tabHeight);
      }

      var pos = 0;
      for(i in 0...mDockables.length)
         if (currentDockable==mDockables[i])
           pos = i;
      return new Rectangle(mRect.x, mRect.y+24*(pos+1),
                  mRect.width, Math.max(0,mRect.height-mDockables.length*24));
   }


   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      mRect = new Rectangle(x,y,w,h);

      tabStyle = w>h || w>200 || forceTabStyle;

      if (currentDockable!=null)
      {
         var rect = getCurrentRect();

         currentDockable.setRect(rect.x,rect.y,rect.width,rect.height);
      }
      else
      {
         // All collapsed
         trace("No current?");
      }

      bestSize[getSlot()] = new Size(w,h);
      setDirty(false,true);
   }

   public function getDockRect():nme.geom.Rectangle
   {
      return mRect.clone();
   }

   public function renderChrome(inContainer:Sprite,outHitBoxes:HitBoxes):Void
   {
      var gfx = inContainer.graphics;
      if (tabStyle)
      {
         var tabRect = mRect.clone();
         if (tabRect.width>0)
         {
            var tabHeight = tabRenderer.getHeight();
            tabRect.height = tabHeight;
            gfx.beginFill(Skin.panelColor);
            gfx.drawRect(mRect.x,mRect.y+tabHeight,mRect.width,mRect.height-tabHeight);
            gfx.endFill();
            var flags = TabRenderer.SHOW_TEXT | TabRenderer.SHOW_ICON | TabRenderer.SHOW_POPUP;
            tabRenderer.renderTabs(inContainer,tabRect,mDockables, currentDockable, outHitBoxes, TabRenderer.TOP,flags );
         }
         return;
      }

      var gap = mRect.height - mDockables.length*24;
      if (gap<0)
        gap = 0;
      var y = mRect.y;
      gfx.lineStyle();
      gfx.beginFill(Skin.panelColor);
      gfx.drawRect(mRect.x,mRect.y,mRect.width,mRect.height);
      gfx.endFill();

      for(d in mDockables)
      {
         gfx.beginFill(Skin.guiDark);
         gfx.drawRoundRect(mRect.x+1+0.5, y+0.5, mRect.width-2, 22,5,5);
         gfx.endFill();

         var pane = d.asPane();
         if (pane!=null)
         {
            var but = (currentDockable==d) ? MiniButton.MINIMIZE : MiniButton.EXPAND;
            var button =  Button.create(["MultiDock", "UiButton"], { id:but });

            /*
            var state =  Skin.getButtonBitmap(but,HitBoxes.BUT_STATE_UP);
            var button =  new SimpleButton( state,
                                        Skin.getButtonBitmap(but,HitBoxes.BUT_STATE_OVER),
                                        Skin.getButtonBitmap(but,HitBoxes.BUT_STATE_DOWN), state );
            */
            inContainer.addChild(button);
            button.x = mRect.right-16;
            button.y = Std.int( y + 3);

            outHitBoxes.add(new Rectangle(mRect.x+2, y+2, mRect.width-18, 18), TITLE(pane) );

            if (outHitBoxes.mCallback!=null)
               button.mCallback = function() outHitBoxes.mCallback( BUTTON(pane,but), null);
               //button.addEventListener( MouseEvent.CLICK, function(e) outHitBoxes.mCallback( BUTTON(pane,but), e ) );
         }

         if (pane!=null)
         {
            var text = new TextField();
            Skin.styleText(text);
            text.selectable = false;
            text.mouseEnabled = false;
            text.text = pane.shortTitle;
            text.x = mRect.x+2;
            text.y = y+2;
            text.width = mRect.width-4;
            text.height = mRect.height-4;
            inContainer.addChild(text);
         }
         
         y+=24;
         if (d==currentDockable)
            y+=gap;
      }


      //Skin.renderMultiDock(this,inContainer,outHitBoxes,mRect,mDockables,currentDockable,tabStyle);
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
         var dock = getDock();
         Skin.renderDropZone(rect,outZones,DOCK_LEFT,true,   function(d) dock.addSibling(this,d,DOCK_LEFT) );
         Skin.renderDropZone(rect,outZones,DOCK_RIGHT,true,  function(d) dock.addSibling(this,d,DOCK_RIGHT));
         Skin.renderDropZone(rect,outZones,DOCK_TOP,true,    function(d) dock.addSibling(this,d,DOCK_TOP) );
         Skin.renderDropZone(rect,outZones,DOCK_BOTTOM,true, function(d) dock.addSibling(this,d,DOCK_BOTTOM) );
         Skin.renderDropZone(rect,outZones,DOCK_OVER,true,   function(d) addDockable(d,DOCK_OVER,9999) );
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

   public function setCurrent(child:IDockable)
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
          {
             d.setDock(this,null);
          }
      }

      if (!found && tabStyle && mDockables.length>0)
         setCurrent(mDockables[0]);
      else if (currentDockable!=null && mRect!=null)
      {
         var rect = getCurrentRect();

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


