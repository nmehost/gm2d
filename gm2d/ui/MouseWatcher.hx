package gm2d.ui;

import nme.events.MouseEvent;
import nme.events.Event;
import nme.display.Stage;
import nme.display.DisplayObject;
import nme.geom.Point;
import haxe.Timer;

class MouseWatcher
{
   var mWatch:DisplayObject;
   var mEventStage:Stage;

   var mCombineTime:Float;
   var mLastCombineRenderTime:Float;
   var mPendingDrag:MouseEvent;
   var mPendingDragTimer:Timer;
   var mDragsSinceRender:Int;
   var mLongTimer:haxe.Timer;

   public var onDown:MouseEvent->Void;
   public var onDrag:MouseEvent->Void;
   public var onUp:MouseEvent->Void;

   public var isDown:Bool;
   public var wasDragged:Bool;
   public var minDragDistance:Float;
   public var prevPos:Point;
   public var pos:Point;
   public var downPos:Point;

   public function new(inWatch:DisplayObject,
                inOnDown:MouseEvent->Void,
                inOnDrag:MouseEvent->Void,
                inOnUp:MouseEvent->Void,
                inX:Float, inY:Float, inWatchDown:Bool)
   {
      mWatch = inWatch;
      pos = new Point(inX,inY);
      downPos = new Point(inX,inY);
      prevPos = new Point(inX,inY);
      onDown = inOnDown;
      onDrag = inOnDrag;
      onUp = inOnUp;

      mCombineTime = 0.0;
      mLastCombineRenderTime = 0.0;
      mPendingDrag = null;
      mPendingDragTimer = null;
      mDragsSinceRender = 0;

      wasDragged = false;
      minDragDistance = 0.0;

      if (inWatchDown)
      {
         isDown = false;
         mEventStage = null;
         inWatch.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      }
      else
      {
         isDown = true;
         mEventStage = inWatch.stage;
         mEventStage.addEventListener(MouseEvent.MOUSE_MOVE, onStageDrag);
         mEventStage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
      }
   }


   public static function create(inWatch:DisplayObject,
                       ?inOnDown:MouseEvent->Void,
                       ?inOnDrag:MouseEvent->Void,
                       ?inOnUp:MouseEvent->Void)
   {
      return new MouseWatcher(inWatch, inOnDown, inOnDrag, inOnUp, 0, 0, true );
   }

    public static function watchDrag(inWatch:DisplayObject,inX:Float, inY:Float,
                       ?inOnDrag:MouseEvent->Void,
                       ?inOnUp:MouseEvent->Void)
   {
      return new MouseWatcher(inWatch, null, inOnDrag, inOnUp, inX, inY, false );
   }

   public function deltaX() { return pos.x - prevPos.x; }
   public function deltaY() { return pos.y - prevPos.y; }
   public function draggedX() { return pos.x - downPos.x; }
   public function draggedY() { return pos.y - downPos.y; }

   public function ignoreDown() { isDown = false; }

   public function combineDragEvents(inAfterSeconds:Float):Void
   {
      var wasCombining = mCombineTime>0.0;
      mCombineTime = inAfterSeconds;
      var isCombining = mCombineTime>0.0;

      if (mEventStage!=null && isCombining!=wasCombining && isDown)
      {
         if (isCombining)
         {
            mEventStage.addEventListener(Event.ENTER_FRAME, onRender);
            mEventStage.addEventListener(Event.RENDER, onRender);
         }
         else
         {
            mEventStage.removeEventListener(Event.ENTER_FRAME, onRender);
            mEventStage.removeEventListener(Event.RENDER, onRender);
         }
      }
      mLastCombineRenderTime = Timer.stamp();
      mDragsSinceRender = 0;
   }

   public function setLongTimer(onLong:Void->Void, inTimeoutMs:Int)
   {
      killTimer();
      mLongTimer = new haxe.Timer(inTimeoutMs);
      mLongTimer.run = function() { mLongTimer.stop(); mLongTimer=null; onLong(); }
   }
   public function stopSequence()
   {
      removeStageListeners();
   }


   function onMouseDown(ev:MouseEvent)
   {
       killTimer();
       mEventStage = mWatch.stage;
       pos = new Point(ev.stageX,ev.stageY);
       downPos = new Point(ev.stageX,ev.stageY);
       prevPos = new Point(ev.stageX,ev.stageY);
       isDown = true;
       wasDragged = false;
       if (onDown!=null)
          onDown(ev);
       if (isDown)
       {
          mEventStage.addEventListener(MouseEvent.MOUSE_MOVE, onStageDrag);
          mEventStage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
          if (mCombineTime>0.0)
          {
             mEventStage.addEventListener(Event.ENTER_FRAME, onRender);
             mEventStage.addEventListener(Event.RENDER, onRender);
          }
          mLastCombineRenderTime = Timer.stamp();
       }
   }
   function removeStageListeners()
   {
      if (mEventStage!=null)
      {
         mEventStage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageDrag);
         mEventStage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
         if (mCombineTime>0.0)
         {
            mEventStage.removeEventListener(Event.ENTER_FRAME, onRender);
            mEventStage.removeEventListener(Event.RENDER, onRender);
         }
         mEventStage = null;
      }
   }

   function onPendingDrag()
   {
      if (mPendingDragTimer!=null)
      {
         mPendingDragTimer.stop();
         mPendingDragTimer = null;
      }
      if (mPendingDrag!=null)
      {
         processDrag(mPendingDrag);
         mPendingDrag = null;
      }
   }

   function onRender(_)
   {
      mLastCombineRenderTime = Timer.stamp();
      if (mPendingDrag!=null && mPendingDragTimer==null)
      {
         mPendingDragTimer = new Timer(0);
         mPendingDragTimer.run = onPendingDrag;
      }
      mDragsSinceRender = 0;
   }

   function onStageUp(ev:MouseEvent)
   {
      killTimer();
      // Flush
      onPendingDrag();

      removeStageListeners();
      isDown = false;
      if (onUp!=null)
      {
         onUp(ev);
      }
   }

   function onStageDrag(ev:MouseEvent)
   {
      if (mCombineTime>0 && (mPendingDrag!=null ||
           (mDragsSinceRender>0 && Timer.stamp()>mLastCombineRenderTime+mCombineTime) ) )
      {
         mPendingDrag = ev;
         if (mEventStage!=null)
            mEventStage.invalidate();
      }
      else
         processDrag(ev);
   }

   function processDrag(ev:MouseEvent)
   {
      mDragsSinceRender++;
      prevPos.x = pos.x;
      prevPos.y = pos.y;
      pos.x = ev.stageX;
      pos.y = ev.stageY;
      killTimer();
      if (!wasDragged)
      {
         var dx = draggedX();
         var dy = draggedY();
         if (dx*dx+dy*dy >= minDragDistance*minDragDistance)
            wasDragged = true;
      }

      if (onDrag!=null && wasDragged)
         onDrag(ev);
   }

   function killTimer()
   {
      if (mLongTimer!=null)
      {
         mLongTimer.stop();
         mLongTimer = null;
      }
   }
}



