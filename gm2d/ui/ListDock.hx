package gm2d.ui;

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.BitmapData;
import gm2d.ui.DockPosition;
import nme.geom.Rectangle;
import gm2d.skin.Skin;
import nme.events.MouseEvent;
import gm2d.ui.HitBoxes;

class ListDock extends SideDock
{
   var mScroll:ScrollWidget;
   var mBackground:Sprite;
   var hitBoxes:HitBoxes;
   //var chromeDirty:Bool;
   //var layoutDirty:Bool;

   public function new( )
   {
      super(DOCK_TOP);
      mScroll = new ScrollWidget();
      mScroll.wantFocus = false;
      container = mScroll;
      mScroll.shouldBeginScroll = shouldBeginScroll;
      mBackground = new Sprite();
      mScroll.addChild(mBackground);
      hitBoxes = new HitBoxes(mBackground,onHitBox);
   }

   function shouldBeginScroll(ev:MouseEvent) : Bool
   {
      return ev.target==mScroll || ev.target==mBackground;
   }

   function onHitBox(inAction:HitAction,inEvent:MouseEvent)
   {
      switch(inAction)
      {
         //case DRAG(_pane):
         //   doStartDrag(inEvent);
         case TITLE(pane):
            Dock.raise(pane);
         case BUTTON(pane,id):
            if (id==MiniButton.CLOSE)
            {
               pane.closeRequest(false);
            }
            else if (id==MiniButton.MINIMIZE)
            {
               Dock.setCollapsed(pane,true);
               setDirty(true,true);
            }
            else if (id==MiniButton.MAXIMIZE)
            {
               Dock.setCollapsed(pane,false);
               setDirty(true,true);
            }
            //redraw();
         case REDRAW:
            //redraw();
         default:
      }
   }


   override public function setDock(inDock:IDock,inParent:DisplayObjectContainer):Void
   {
      parentDock = inDock;
      if (mScroll.parent!=null)
         mScroll.parent.removeChild(mScroll);
      if (inParent!=null)
         inParent.addChild(mScroll);
   }

   override public function getMinSize():Size
   {
      var min = new Size(0,0);
      for(dock in mDockables)
      {
         var s = Dock.isCollapsed(dock) ? new Size(0,0) : dock.getMinSize();
         addPaneChromeSize(dock,s);
         if (min.x==0 || s.x>min.x) min.x = s.x;
         min.y += s.y;
      }
     return addPadding(min);
   }

   override public function getLayoutSize(w:Float,h:Float,limitX:Bool):Size
   {
      var min = getMinSize();
      return new Size(w<min.x ? min.x : w,h<min.y ? min.y : h);
   }

 
   override public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      mRect = new Rectangle(x,y,w,h);
      //trace(indent + "Set rect " + variableWidths + " " + mRect);

      var right = w;
      var bottom = h;
      var barSize = Skin.getResizeBarWidth();
      h-= barSize * (mDockables.length-1);

      mPositions = [];
      mWidths = [];
      mSizes = [];

      for(d in mDockables)
      {
         var chrome = mRenderer.getChromeRect(d);
         if (Dock.isCollapsed(d))
         {
            mSizes.push( new Size(chrome.width,chrome.height) );
            mWidths.push(chrome.y);
         }
         else
         {
            var best = d.getBestSize(Dock.DOCK_SLOT_VERT);
            var s = d.getLayoutSize(w, best.y, true);
            s.x+=chrome.width;
            s.y+=chrome.height;
            mSizes.push(s);
            var layout_size = Std.int(s.y);
            mWidths.push(layout_size);
         }
      }

      for(d in 0...mDockables.length)
      {
         var dockable = mDockables[d];
         var size = mWidths[d];
         var chrome = mRenderer.getChromeRect(dockable);
         if (Dock.isCollapsed(dockable))
         {
            dockable.setDock(this,null);
         }
         else
         {
            dockable.setDock(this,mScroll);
            var pane = dockable.asPane();
            var dw = (variableWidths?size:mSizes[d].x)-chrome.width;
            var dh = (variableWidths?mSizes[d].y:size) -chrome.height;
            var oid = SideDock.indent;
            SideDock.indent+="   ";
            dockable.setRect(chrome.x,y+chrome.y, dw, dh );
            SideDock.indent = oid;
        }

         mPositions.push( y );
         y+=size + barSize;
      }

      mScroll.setScrollRange(w,w, y,h);

      setDirty(false,true);
   }


   override public function renderChrome(inContainer:Sprite,outHitBoxes:HitBoxes):Void
   {
      mBackground.graphics.clear();
      while(mBackground.numChildren>0)
         mBackground.removeChildAt(0);
      hitBoxes.clear();

      //Skin.current.renderResizeBars(this,inContainer,outHitBoxes,mRect,variableWidths,mWidths);
      for(d in 0...mDockables.length)
      {
         var pane = mDockables[d].asPane();
         var rect = new Rectangle( mRect.x, mPositions[d], mRect.width, mWidths[d] );

         if (pane!=null)
         {
            Skin.renderPaneChrome(pane,mBackground,hitBoxes,rect,
               (mRenderer.gripperTop? Skin.TOOLBAR_GRIP_TOP : 0) |
                 (Dock.isCollapsed(pane) ? Skin.SHOW_EXPAND : Skin.SHOW_COLLAPSE )
               );
         }
         else
         {
            mDockables[d].renderChrome(mBackground,hitBoxes);
            var r = mDockables[d].getDockRect();
            var gap = variableWidths ? mRect.height - r.height : mRect.width-r.width;
            if (gap>0.5)
            {
               if (variableWidths)
                  Skin.renderToolbarGap(mBackground,rect.x, rect.bottom-gap, rect.width, gap);
               else
                  Skin.renderToolbarGap(mBackground,rect.right - gap, rect.y, gap, rect.height);
            }
         }
      }
   }

   override public function getLayoutInfo():Dynamic
   {
      var dockables = new Array<Dynamic>();
      for(i in 0...mDockables.length)
         dockables[i] = mDockables[i].getLayoutInfo();

      return { type:"ListDock", dockables:dockables, properties:properties, flags:flags };
   }

   // --- Externals -----------------------------------------

   override public function tryResize(inIndex:Int, inPosition:Float )
   {
      return;
   }

   // --- IDock -----------------------------------------

   override public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition)
   {
      if (canAddDockable(inPos) || inPos==DOCK_OVER)
         super.addSibling(inReference,inIncoming,inPos);
   }

   override public function toString()
   {
      var r = getDockRect();
      return("ListDock(" + r.x + "," + r.y + " " + r.width + "x" + r.height + ")");
   }

   override public function raiseDockable(child:IDockable):Bool
   {
      for(i in 0...mDockables.length)
        if (child==mDockables[i])
        {
           return true;
        }
      return false;
   }

}


