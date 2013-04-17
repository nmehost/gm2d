package gm2d.ui;

import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.ui.DockPosition;
import gm2d.geom.Rectangle;
import gm2d.skin.Skin;

class ListDock extends SideDock
{
   var mScroll:ScrollWidget;

   public function new( )
   {
      super(DOCK_TOP);
      mScroll = new ScrollWidget();
      container = mScroll;
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
      //trace(indent + "Set rect " + horizontal + " " + mRect);

      var right = w;
      var bottom = h;
      var skin = Skin.current;
      var barSize = skin.getResizeBarWidth();
      h-= barSize * (mDockables.length-1);

      mPositions = [];
      mWidths = [];
      mSizes = [];

      for(d in mDockables)
      {
         var chrome = Skin.current.getChromeRect(d,toolbarGripperTop);
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
         var chrome = Skin.current.getChromeRect(dockable,toolbarGripperTop);
         if (Dock.isCollapsed(dockable))
         {
            dockable.setDock(this,null);
         }
         else
         {
            dockable.setDock(this,mScroll);
            var pane = dockable.asPane();
            var dw = (horizontal?size:mSizes[d].x)-chrome.width;
            var dh = (horizontal?mSizes[d].y:size) -chrome.height;
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
      //Skin.current.renderResizeBars(this,inContainer,outHitBoxes,mRect,horizontal,mWidths);
      for(d in 0...mDockables.length)
      {
         var pane = mDockables[d].asPane();
         var rect = horizontal ?
                      new Rectangle( mPositions[d], mRect.y, mWidths[d], mRect.height ) :
                      new Rectangle( mRect.x, mPositions[d], mRect.width, mWidths[d] );
         if (pane!=null)
         {
            Skin.current.renderPaneChrome(pane,mScroll,outHitBoxes,rect, toolbarGripperTop);
         }
         else
         {
            mDockables[d].renderChrome(mScroll,outHitBoxes);
            var r = mDockables[d].getDockRect();
            var gap = horizontal ? mRect.height - r.height : mRect.width-r.width;
            if (gap>0.5)
            {
               if (horizontal)
                  Skin.current.renderToolbarGap(mScroll,rect.x, rect.bottom-gap, rect.width, gap);
               else
                  Skin.current.renderToolbarGap(mScroll,rect.right - gap, rect.y, gap, rect.height);
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


