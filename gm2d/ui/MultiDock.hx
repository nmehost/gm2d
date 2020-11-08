package gm2d.ui;

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.BitmapData;
import gm2d.ui.DockPosition;
import gm2d.ui.HitBoxes;
import gm2d.ui.Layout;
import nme.geom.Rectangle;
import gm2d.skin.Skin;
import gm2d.skin.TabRenderer;
import gm2d.skin.FillStyle;
import nme.display.SimpleButton;
import nme.events.MouseEvent;
import nme.text.TextField;



class MultiDock extends Widget implements IDock implements IDockable
{
   public var title:String;
   public var shortTitle:String;
   public var icon:BitmapData;

   var parentDock:IDock;
   var mDockables:Array<IDockable>;
   var currentDockable:IDockable;
   var bestSize:Array<Size>;
   var properties:Dynamic;
   var flags:Int;
   var tabRenderer:TabRenderer;
   var hitBoxes:HitBoxes;
   var tabBar:TabBar;
   var clientLayout:Layout;

   public function new()
   {
      super(["Dock"]);
      flags = 0;
      mDockables = [];
      bestSize = [];
      tabRenderer = Skin.createTabRenderer( ["MultiDock","Tabs","TabRenderer"] );
      hitBoxes = new HitBoxes(mChrome, onHitBox);
      properties = {};

      tabBar = new TabBar(mDockables,onHitBox,false);
      tabBar.applyStyles();
      addChild(tabBar);

      var layout = new VerticalLayout([0,1]);
      layout.setAlignment(Layout.AlignStretch);
      layout.add(tabBar.getLayout());
      clientLayout = new Layout().stretch();
      layout.add(clientLayout);
      clientLayout.onLayout = setClientRect;
      setItemLayout(layout);
   }

   function setClientRect(x:Float, y:Float, w:Float, h:Float)
   {
      if (currentDockable!=null)
         currentDockable.getLayout().setRect(x,y,w,y);
   }

   public function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      var tld = TopLevelDock.findRoot(this);
      var doDefault = false;

      switch(inAction)
      {
         case DRAG(p):
            tld.floatWindow(p,inEvent,null);
         case TITLE(pane):
            Dock.raise(pane);
         case BUTTON(pane,id):
            if (id==MiniButton.CLOSE)
            {
               currentDockable.asPane().closeRequest(false);
            }
            else if (id==MiniButton.POPUP)
            {
               tld.showPaneMenu(mDockables,inEvent.stageX, inEvent.stageY);
            }
            else
            {
               trace("Unknown button " + inAction);
               doDefault = true;
            }
         case REDRAW:
            redraw();
         default:
      }
      if (doDefault)
          tld.onHitBox(inAction, inEvent);
   }

   // Hierarchy
   public function getDock():IDock { return parentDock; }
   public function getSlot():Int { return parentDock==null ? Dock.DOCK_SLOT_FLOAT : parentDock.getSlot(); }
   public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void
   {
      if (parent!=inParent)
         inParent.addChild(this);
      if (parentDock!=inDock)
      {
         parentDock = inDock;
         setCurrent(currentDockable);
      }
   }
   public function closeRequest(inForce:Bool):Void { }
   // Display
   public function getTitle():String { return title; }
   public function getShortTitle():String { return shortTitle; }
   public function getIcon():nme.display.BitmapData { return icon; }
   public function getFlags():Int { return flags; }
   public function setFlags(inFlags:Int):Void { flags = inFlags; }
   // Layout
   public function hasBestSize() return true;

   public function addPadding(ioSize:Size):Size
   {
      var outer = mLayout.getRect();
      var inner = clientLayout.getRect();
      ioSize.x += outer.width-inner.width;
      ioSize.y += outer.height-inner.height;
      return ioSize;
   }
   public function getBestSize(inSlot:Int):Size
   {
      if (bestSize[inSlot]==null)
      {
         var best = new Size(0,0);
         for(dock in mDockables)
         {
            var s = dock.getLayout().getBestSize();
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
         var s = dock.getLayout().getMinSize();
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

   function getCurrentRect() return clientLayout.getRect();


   override public function redraw()
   {
      var x = mRect.x;
      var y = mRect.y;
      var w = mRect.width;
      var h = mRect.height;

      if (currentDockable!=null)
      {
         var rect = getCurrentRect();

         currentDockable.getLayout().setRect(rect.x,rect.y,rect.width,rect.height);
      }
      else
      {
         // All collapsed
         //trace("No current?");
      }

      tabBar.setTop(currentDockable, true);

      //bestSize[getSlot()] = new Size(w,h);
      //setDirty(false,true);
   }

   public function getDockRect():nme.geom.Rectangle
   {
      return new Rectangle(x,y,mRect.width,mRect.height);
   }

   
   public function renderChrome(inContainer:Sprite,outHitBoxes:HitBoxes):Void
   {
      var fill:FillStyle = null;
      var asPane = currentDockable.asPane();
      if (asPane!=null)
      {
         fill = Reflect.field(asPane.frameAttribs,"fill");
         if (fill==null)
            fill = attribDynamic("fill",null);
         if (fill!=null && fill!=FillNone)
         {
            var gfx = inContainer.graphics;
            if (gm2d.skin.Renderer.setFill(gfx,fill,this))
            {
               var rect = getLayout().getRect();
               gfx.drawRect(rect.x, rect.y, rect.width, rect.height);
            }
         }
      }
   }


   public function asPane() : Pane { return null; }


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


   //public function getLayout() return layout;

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
      child.setDock(this,this);
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

   override public function toString()
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
            if (parent!=null)
               parent.removeChild(this);
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
                  mDockables[i].setDock(this,this);
               }
               else
                  mDockables[i].setDock(null,null);
               setDirty(true,true);
            }
         }
      }

      return this;
   }

   public function setCurrent(child:IDockable)
   {
      if (currentDockable!=child)
         setDirty(true,true);

      currentDockable = child;
      var found = false;

      for(d in mDockables)
      {
          if (d==child)
          {
             found = true;
             d.setDock(this,this);
          }
          else
          {
             d.setDock(this,null);
          }
      }

      if (!found && mDockables.length>0)
         setCurrent(mDockables[0]);
      else if (currentDockable!=null && mRect!=null)
      {
         var rect = getCurrentRect();

         currentDockable.getLayout().setRect(rect.x,rect.y,rect.width,rect.height);
      }
      if (child!=null)
      {
         var s = child.getLayout().getBestSize();

         getLayout().setBestSize(s.x,s.y);
      }
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


