package gm2d.ui;

import nme.events.MouseEvent;
import nme.events.Event;
import nme.display.Stage;
import nme.display.DisplayObject;
import nme.geom.Point;
import nme.geom.Rectangle;
import gm2d.tween.Tween;
import gm2d.math.TimeAverage;
import haxe.Timer;

class ScrollWidget extends Control
{
   public var scrollX(get_scrollX,set_scrollX):Float;
   public var scrollY(get_scrollY,set_scrollY):Float;
   public var scrollWheelStep:Float;
   public var maxScrollX:Float;
   public var maxScrollY:Float;
   public var windowWidth:Float;
   public var windowHeight:Float;
   public var viscousity:Float;
   public var onScroll:Void->Void;
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
   var scrollTarget:DisplayObject;
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
      windowWidth = windowHeight = 0.0;
      mScrollX = mScrollY = 0.0;
      scrollWheelStep = 20.0;
      mScrolling = false;
      viscousity = 2500.0;
      scrollTarget = this;
      speedX = new TimeAverage(0.2);
      speedY = new TimeAverage(0.2);
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
   }


   public static function create(inChild:Widget)
   {
      var result = new ScrollWidget( );
      result.addChild(inChild);
      result.setItemLayout( inChild.getLayout().stretch() );
      result.build();
      return result;
   }

   public function setScrollRange(inControlWidth:Float, inWindowWidth:Float,
                           inControlHeight:Float, inWindowHeight:Float)
   {
       windowWidth = inWindowWidth;
       windowHeight = inWindowHeight;
       maxScrollX = inControlWidth - inWindowWidth;
       if (maxScrollX<0) maxScrollX = 0;
       maxScrollY = inControlHeight - inWindowHeight;
       if (maxScrollY<0) maxScrollY = 0;
       if (mScrollX>maxScrollX)
         mScrollX = maxScrollX;
       if (mScrollY>maxScrollY)
         mScrollY = maxScrollY;
       scrollTarget.scrollRect = new Rectangle(mScrollX,mScrollY,windowWidth,windowHeight);
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
         targetX = y+h-windowHeight;

      scrollTo(targetX, targetY, 0.5);
   }


   function onMouseWheel(event:MouseEvent)
   {
      if (maxScrollY>0 && scrollWheelStep>0)
      {
          set_scrollY(mScrollY - scrollWheelStep * event.delta);
          if (onScroll!=null)
             onScroll();
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

       mLastT = Timer.stamp();
       mEventStage = stage;
       mDownPos = new Point(ev.stageX,ev.stageY);
       mLastPos = mDownPos;
       mEventStage.addEventListener(MouseEvent.MOUSE_MOVE, onStageDrag);
       mEventStage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
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

   public function scrollTo(inX:Float, inY:Float, inSeconds:Float = 0)
   {
      Game.removeTween(name);
      var x0:Float = get_scrollX();
      var y0:Float = get_scrollY();


      if (inSeconds==0)
      {
         scrollX = inX;
         scrollY = inY;
      }
      else
      {
         Game.tween(name,0,1, inSeconds,
           function(t) {
              scrollX = x0+(inX-x0)*t;
              scrollY = x0+(inY-y0)*t;
           },  Tween.DECELERATE );
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
         if (speedX.isValid)
         {
            var pixels_per_second = speedX.mean;
            //trace("pixels_per_second : " + pixels_per_second);
            var time = Math.abs(pixels_per_second/viscousity);
            var dest = 0.5*pixels_per_second*time;
    
            gm2d.Game.tween(name,mScrollX,mScrollX-dest, time,
                function(x) scrollX = x, finishScroll, Tween.DECELERATE );
         }
         if (speedY.isValid)
         {
            var pixels_per_second = speedY.mean;
            //trace("pixels_per_second : " + pixels_per_second);
            var time = Math.abs(pixels_per_second/viscousity);
            var dest = 0.5*pixels_per_second*time;
    
            gm2d.Game.tween(name,mScrollY,mScrollY-dest, time,
                function(y) scrollY = y, finishScroll, Tween.DECELERATE );
         }
         if (!speedX.isValid && !speedY.isValid)
            finishScroll();
      }
      removeStageListeners();
   }
   public function finishScroll()
   {
      //if (mScrolling) trace("Scrolling done");
      mScrolling = false;
   }
   public function get_scrollX() : Float{ return mScrollX; }
   public function set_scrollX(val:Float) : Float
   {
      mScrollX = val;
      if (mScrollX<0) mScrollX=0;
      if (mScrollX>maxScrollX) mScrollX = maxScrollX;
      scrollTarget.scrollRect = new Rectangle(mScrollX,mScrollY,windowWidth,windowHeight);
      if (onScroll!=null)
         onScroll();
      invalidate();
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
         scrollTarget.scrollRect = new Rectangle(mScrollX,mScrollY,windowWidth,windowHeight);
         if (onScroll!=null)
            onScroll();
      }
      invalidate();
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
      if (!mScrolling && (Math.abs(dx)>10 || Math.abs(dy)>10))
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
      }
      mLastT = now;
   }
}

