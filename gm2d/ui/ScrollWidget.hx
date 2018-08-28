package gm2d.ui;

import nme.events.MouseEvent;
import nme.events.Event;
import nme.display.Stage;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import gm2d.tween.Tween;
import gm2d.math.TimeAverage;
import gm2d.skin.Skin;
import haxe.Timer;

class ScrollWidget extends Widget //Control
{
   public var scrollX(get_scrollX,set_scrollX):Float;
   public var scrollY(get_scrollY,set_scrollY):Float;
   public var scrollWheelStep:Float;
   public var maxScrollX:Float;
   public var maxScrollY:Float;
   public var controlW:Float;
   public var controlH:Float;
   public var windowWidth:Float;
   public var windowHeight:Float;
   public var viscousity:Float;
   public var onScroll:Void->Void;
   public var virtualScroll:Bool;
   public var showScrollbarX:Bool;
   public var showScrollbarY:Bool;
   public var scrollbarAwake:Bool;

   var mScrollX:Float;
   var mScrollY:Float;
   var mDownPos:Point;
   var mLastPos:Point;
   var mEventStage:Stage;
   public var mScrolling(default,null):Bool;
   var mDownScrollX:Float;
   var mDownScrollY:Float;
   var mAutoScrollMouseWatch:MouseWatcher;
   var mAutoScrollTime:Float;
   var contents:Sprite;
   var scrollTarget:DisplayObject;
   var scrollbarContainer:Sprite;
   var scrollbarActive:Bool;
   public var autoScrollRate = 500.0;

   // This is for a click, rather than mouse down-move-up
   public var onClick:MouseEvent->Void;

   var speedX:TimeAverage;
   var speedY:TimeAverage;
   var mLastT:Float;

   public function new(?inLineage:Array<String>,?inAttribs:{})
   {
      super(Widget.addLine(inLineage,"Scroll"), inAttribs);
      mEventStage = null;
      maxScrollX = 0;
      maxScrollY = 0;
      controlW = controlH = 0.0;
      windowWidth = windowHeight = 0.0;
      mScrollX = mScrollY = 0.0;
      scrollWheelStep = Skin.scale(20);
      mScrolling = false;
      viscousity = 2500.0;
      scrollTarget = this;
      speedX = new TimeAverage(0.2);
      speedY = new TimeAverage(0.2);
      virtualScroll = false;
      showScrollbarX = true;
      showScrollbarY = true;
      scrollbarAwake = false;
      scrollbarActive = false;
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, true);
      addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
      addEventListener(MouseEvent.CLICK,onScrollClick,true);
   }

   public function makeContentContainer()
   {
      if (contents==null)
      {
         contents = new Sprite();
         addChild(contents);
         scrollTarget = contents;
         if (scrollbarContainer!=null)
             addChild(scrollbarContainer);
      }
      return contents;
   }

   public function updateScrollbars()
   {
      if (maxScrollX<=0 && maxScrollY<=0)
         scrollbarActive = false;
      var sx = maxScrollX>0 && showScrollbarX && (scrollbarAwake||scrollbarActive);
      var sy = maxScrollY>0 && showScrollbarY && (scrollbarAwake||scrollbarActive);

      if (sx || sy)
      {
         if (scrollbarContainer==null)
         {
            scrollbarContainer = new Sprite();
            addChild(scrollbarContainer);
            scrollbarContainer.addEventListener(MouseEvent.MOUSE_DOWN, onScrollbarDown);
         }
         var gfx  = scrollbarContainer.graphics;
         gfx.clear();
         var size = Skin.scale(24);
         gfx.lineStyle(0,0x00000000);
         if (sy)
         {
            gfx.beginFill(0x808080,0.25);
            var h = windowHeight - (sx ? size : 0);
            gfx.drawRect(windowWidth-size,0,size,h);
            gfx.beginFill(0xffffff,0.75);
            gfx.drawRect(windowWidth-size, mScrollY/controlH*h, size, windowHeight/controlH*h);
         }

      }
      else if (scrollbarContainer!=null)
      {
         removeChild(scrollbarContainer);
         scrollbarContainer = null;
      }
   }

   function onScrollbarDragY(e:MouseEvent,offset:Float)
   {
      var localPos = scrollbarContainer.globalToLocal(new Point(e.stageX,e.stageY)).y;

      var sx = maxScrollX>0 && showScrollbarX;
      var size = Skin.scale(24);
      var h = windowHeight - (sx ? size : 0);
      if (h>0)
         set_scrollY( (localPos-offset)*controlH/h );
   }

   function onScrollbarDown(e:MouseEvent)
   {
      e.stopPropagation();

      var sx = maxScrollX>0 && showScrollbarX;
      var sy = maxScrollY>0 && showScrollbarY;

      var size = Skin.scale(24);
      if (sy && e.localX>windowWidth-size)
      {
         var h = windowHeight - (sx ? size : 0);
         var thumb0 = mScrollY/controlH*h;
         var thumbH = windowHeight/controlH*h;

         if (e.localY<thumb0-size/2)
         {
            // page-up
            set_scrollY( Std.int(mScrollY - thumbH*maxScrollY/h) );
            fadeupScrollbars();
         }
         else if (e.localY>thumb0+thumbH+size/2)
         {
            // page-down
            set_scrollY( Std.int(mScrollY + thumbH*maxScrollY/h) );
            fadeupScrollbars();
         }
         else
         {
            // drag
            scrollbarActive = true;
            var ypos = e.localY - thumb0;
            MouseWatcher.watchDrag(scrollbarContainer, e.stageX,e.stageY, function(e) onScrollbarDragY(e,ypos),
              function(_) { scrollbarActive = false; fadeupScrollbars(); } );
         }
      }
   }


   public static function create(inChild:Widget)
   {
      var result = new ScrollWidget( );
      result.addChild(inChild);
      result.setItemLayout( inChild.getLayout().stretch() );
      result.applyStyles();
      return result;
   }

   function onScrollClick(e:MouseEvent)
   { 
      if (mScrolling)
      {
         // Absorb the click
         e.stopPropagation();
      }
   }

   public function setVirtualSize(inControlWidth:Float, inControlHeight:Float)
   {
      controlW = inControlWidth;
      controlH = inControlHeight;
      if (mRect!=null)
          setWindowSize( mRect.width, mRect.height );
   }


   public function setWindowSize(inWindowWidth:Float, inWindowHeight:Float)
   {
      windowWidth = inWindowWidth;
      windowHeight = inWindowHeight;
      maxScrollX = controlW - inWindowWidth;
      if (maxScrollX<0) maxScrollX = 0;
      maxScrollY = controlH- inWindowHeight;
      if (maxScrollY<0) maxScrollY = 0;
      if (mScrollX>maxScrollX)
        mScrollX = maxScrollX;
      if (mScrollY>maxScrollY)
        mScrollY = maxScrollY;

      if (virtualScroll)
         scrollTarget.scrollRect = new Rectangle(0,0,windowWidth,windowHeight);
      else
         scrollTarget.scrollRect = new Rectangle(mScrollX,mScrollY,windowWidth,windowHeight);

      updateScrollbars();
   }

   public function setScrollRange(inControlWidth:Float, inWindowWidth:Float,
                           inControlHeight:Float, inWindowHeight:Float)
   {
      controlW = inControlWidth;
      controlH = inControlHeight;
      setWindowSize(inWindowWidth, inWindowHeight);
   }

   override public function onLayout(x,y,w,h)
   {
      super.onLayout(x,y,w,h);
      //trace('onLayout $x,$y,$w,$h');
      setWindowSize(w,h);
   }

   public function showChild(child:DisplayObject)
   {
      var targetX = scrollX;
      var targetY = scrollY;

      var x = child.x;
      var y = child.y;
      var w = child.width;
      var h = child.height;

      if (targetX>x)
         targetX = x;
      else if ( x+w > targetX+windowWidth )
         targetX = x+w-windowWidth;

      if (targetY>y)
         targetY = y;
      else if ( y+h > targetY+windowHeight )
         targetY = y+h-windowHeight;

      scrollTo(targetX, targetY, 0.5);
   }


   function onMouseWheel(event:MouseEvent)
   {
      if (maxScrollY>0 && scrollWheelStep>0)
      {
         set_scrollY(mScrollY - scrollWheelStep * event.delta);
         fadeupScrollbars();
      }
   }

   public dynamic function shouldBeginScroll(ev:MouseEvent) : Bool
   {
      return true;
   }

   function onMouseDown(ev:MouseEvent)
   {
       if (!shouldBeginScroll(ev))
          return;
       if (scrollbarContainer!=null && ev.target==scrollbarContainer)
          return;
       

       mLastT = Timer.stamp();
       mEventStage = stage;
       mDownPos = new Point(ev.stageX,ev.stageY);
       mLastPos = mDownPos;
       mEventStage.addEventListener(MouseEvent.MOUSE_MOVE, onStageDrag);
       mEventStage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
       if (mScrolling)
       {
          ev.stopPropagation();
          ev.clickCancelled = true;
       }
       mScrolling = false;
       //trace("Not scrolling!");
       mDownScrollX= mScrollX;
       mDownScrollY= mScrollY;
       speedX.clear();
       speedY.clear();
       gm2d.Game.removeTween(name);
   }
   function removeStageListeners()
   {
      if (mEventStage!=null)
      {
         mEventStage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageDrag);
         mEventStage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
         mEventStage = null;
      }
   }

   function removeAutoScrollCheck(_)
   {
      if (mAutoScrollMouseWatch!=null)
      {
         removeEventListener(Event.ENTER_FRAME,onAutoScrollMouseCheck);
         removeEventListener(Event.RENDER,onAutoScrollMouseCheck);
      }
      mAutoScrollMouseWatch = null;
   }
   function onAutoScrollMouseCheck(e)
   {
      var now =  haxe.Timer.stamp();
      var dt = now - mAutoScrollTime;
      mAutoScrollTime = now;
      if (dt>1.0)
         dt = 1.0;

      if (mAutoScrollMouseWatch.wasDragged)
      {
         if (maxScrollX>0)
         {
            var x = mAutoScrollMouseWatch.pos.x;
         }
         if (maxScrollY>0)
         {
            var y = mAutoScrollMouseWatch.pos.y;
            if (y<5)
               scrollY = scrollY - dt*autoScrollRate;
            if (y>windowHeight-5)
               scrollY = scrollY + dt*autoScrollRate;
         }
      }
   }

   public function beginScrollToMouse(ev:MouseEvent)
   {
      var pos = scrollTarget.globalToLocal( new Point(ev.stageX,ev.stageY) );
      removeAutoScrollCheck(null);
      mAutoScrollTime = haxe.Timer.stamp();
      mAutoScrollMouseWatch = new MouseWatcher(scrollTarget,
                null,
                null,
                removeAutoScrollCheck,
                pos.x, pos.y, false);
      addEventListener(Event.ENTER_FRAME,onAutoScrollMouseCheck);
      addEventListener(Event.RENDER,onAutoScrollMouseCheck);
   }

   function doClick(inX:Float, inY:Float,ev:MouseEvent)
   {
      if (onClick!=null)
         onClick(ev);
   }

   public function fadeupScrollbars()
   {
      var tname = name + " scrollbar";
      Game.removeTween(tname,false);


      if ( (maxScrollX>0 && showScrollbarX ) || (maxScrollY>0 && showScrollbarY ) )
       {
          var seconds = 3;
          if (!scrollbarAwake)
          {
             scrollbarAwake = true;
             updateScrollbars();
          }
          Game.tween(tname,0,1, seconds, null, clearScrollbars  );
       }
   }

   public function clearScrollbars()
   {
      if (scrollbarAwake)
      {
         scrollbarAwake = false;
         updateScrollbars();
      }
   }

   public function scrollTo(inX:Float, inY:Float, inSeconds:Float = 0)
   {
      Game.removeTween(name);

      if (inSeconds==0)
      {
         scrollX = inX;
         scrollY = inY;
      }
      else
      {
         var x0:Float = get_scrollX();
         var y0:Float = get_scrollY();
         Game.tween(name,0,1, inSeconds,
           function(t) {
              scrollX = Std.int(x0+(inX-x0)*t);
              scrollY = Std.int(y0+(inY-y0)*t);
           },  Tween.DECELERATE );
          fadeupScrollbars();
       }
   }


   function onStageUp(ev:MouseEvent)
   {
      if (!mScrolling)
      {
         var local = scrollTarget.globalToLocal(mDownPos);
         doClick(local.x,local.y,ev);
      }
      else
      {
         Game.removeTween(name);
         var doX = speedX.isValid;
         var doY = speedY.isValid;
         if (doX || doY)
         {

            var pixels_per_second_x = speedX.mean;
            var time_x = doX ? Math.abs(pixels_per_second_x/viscousity) : 0.0;
            var dest_x = 0.5*pixels_per_second_x*time_x;

            var pixels_per_second_y = speedY.mean;
            var time_y = doY ? Math.abs(pixels_per_second_y/viscousity) : 0.0;
            var dest_y = 0.5*pixels_per_second_y*time_y;
    
            var x0 = scrollX;
            var y0 = scrollY;

            gm2d.Game.tween(name,0,1, Math.max(time_x,time_y),
                function(t) {
                   if (doX) scrollX = x0 - dest_x * t;
                   if (doY) scrollY = y0 - dest_y * t;
                }, finishScroll, Tween.DECELERATE );
         }
         else
            finishScroll();
      }
      removeStageListeners();
   }
   public function finishScroll()
   {
      // if (mScrolling) trace("Scrolling done");
      mScrolling = false;
   }
   public function get_scrollX() : Float{ return mScrollX; }
   public function set_scrollX(val:Float) : Float
   {
      var s = val;
      if (s<0) s=0;
      if (s>maxScrollX) s=maxScrollX;
      if (s!=mScrollX)
      {
         mScrollX = s;
         if (!virtualScroll)
            scrollTarget.scrollRect = new Rectangle(mScrollX,mScrollY,windowWidth,windowHeight);
         if (onScroll!=null)
            onScroll();
         updateScrollbars();
         invalidate();
      }
      return mScrollX;
   }
   public function get_scrollY() { return mScrollY; }
   public function set_scrollY(val:Float) : Float
   {
      var s = val;
      if (s<0) s=0;
      if (s>maxScrollY) s = maxScrollY;
      if (s!=mScrollY)
      {
         mScrollY = s;
         if (!virtualScroll)
            scrollTarget.scrollRect = new Rectangle(mScrollX,mScrollY,windowWidth,windowHeight);
         if (onScroll!=null)
            onScroll();
         updateScrollbars();
         invalidate();
      }
      return mScrollY;
   }

   function onStageDrag(ev:MouseEvent)
   {
      var now = Timer.stamp();
      var p0 = scrollTarget.globalToLocal(mDownPos);
      var pos = new Point(ev.stageX,ev.stageY);
      var p1 = scrollTarget.globalToLocal(pos);
      var dx = p1.x-p0.x;
      var dy = p1.y-p0.y;
      var close = gm2d.skin.Skin.scale(10.0);
      if (!mScrolling && (Math.abs(dx)>close || Math.abs(dy)>close))
      {
         mScrolling = true;
      }
      if (mScrolling)
      {
         mScrollX = mDownScrollX - dx;
         if (mScrollX<0) mScrollX = 0;
         if (mScrollX>maxScrollX) mScrollX= maxScrollX;
         mScrollY = mDownScrollY - dy;
         if (mScrollY<0) mScrollY = 0;
         if (mScrollY>maxScrollY) mScrollY= maxScrollY;
         if (!virtualScroll)
            scrollTarget.scrollRect = new Rectangle(mScrollX,mScrollY,windowWidth,windowHeight);
         var plast = scrollTarget.globalToLocal(mLastPos);
         var dt = now-mLastT;
         if (dt>0)
         {
            speedX.add( (p1.x - plast.x)/dt, dt );
            speedY.add( (p1.y - plast.y)/dt, dt );
            mLastPos = pos;
         }
         invalidate();
         if (onScroll!=null)
            onScroll();
         fadeupScrollbars();
         updateScrollbars();
      }
      mLastT = now;
   }

}

