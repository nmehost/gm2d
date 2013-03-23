package gm2d.ui;

import gm2d.geom.Rectangle;
import gm2d.geom.Point;
import gm2d.display.Bitmap;
import gm2d.display.Sprite;
import gm2d.display.DisplayObject;
import gm2d.events.MouseEvent;

class ResizeFlag
{
   public static inline var E = 0x0010;
   public static inline var W = 0x0020;
   public static inline var N = 0x0040;
   public static inline var S = 0x0080;
}

class MiniButton
{
   public static inline var CLOSE    = 0;
   public static inline var MINIMIZE = 1;
   public static inline var MAXIMIZE = 2;
   public static inline var RESTORE = 3;
   public static inline var POPUP = 4;
   public static inline var EXPAND = 6;
   public static inline var PIN  = 7;
   public static inline var COUNT = 8;

   public static inline var TITLE = 8;
}

enum HitAction
{
   NONE;
   REDRAW;
   DRAG(pane:IDockable);
   BUTTON(pane:IDockable,button:Int);
   TITLE(pane:IDockable);
   RESIZE(pane:IDockable,flags:Int);
   DOCKSIZE(dock:SideDock,index:Int);
}

class HitBox
{
   public function new(inRect:Rectangle, inAction:HitAction)
   {
      rect = inRect;
      action = inAction;
   }
   public var rect:Rectangle;
   public var action:HitAction;
}

class HitBoxes
{
   public static var BUT_STATE_UP = 0;
   public static var BUT_STATE_OVER = 1;
   public static var BUT_STATE_DOWN = 2;

   public var onOverDockSize:SideDock->Int->Float->Float->Rectangle->Void;
   public var onDockSizeDown:SideDock->Int->Float->Float->Rectangle->Void;
   public var mCallback:HitAction->MouseEvent->Void;
   var mObject:Sprite;
   var rects:Array<HitBox>;
   public var downX(default,null):Float;
   public var downY(default,null):Float;
   var mMoved:Bool;
   var downPane:IDockable;
   var mResizeFlags:Int;


   public function new(inObject:Sprite,inCallback:HitAction->MouseEvent->Void)
   {
      rects = [];

      mObject = inObject;
      mCallback = inCallback;
      downPane = null;
      mResizeFlags = 0;
      inObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      inObject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      inObject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      inObject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
   }

   public function getHitBoxOffset(inObj:DisplayObject,  inX:Float, inY:Float )
   {
      return mObject.globalToLocal( inObj.localToGlobal(new Point(inX,inY)) );
   }

   function onMouseDown(event:MouseEvent)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==mObject)
         onDown(event.localX, event.localY, event);
      else
      {
         var opos = mObject.globalToLocal( obj.localToGlobal(new Point(event.localX,event.localY)) );
         onDown(opos.x,opos.y, event);
      }
   }


   function onMouseUp(event:MouseEvent)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==mObject)
         onUp(event.localX, event.localY, event);
      else
      {
         var opos = mObject.globalToLocal( obj.localToGlobal(new Point(event.localX,event.localY)) );
         onUp(opos.x,opos.y, event);
      }
   }

   function onMouseMove(event:MouseEvent)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==mObject)
         onMove(event.localX, event.localY, event);
      else
      {
         var opos = mObject.globalToLocal( obj.localToGlobal(new Point(event.localX,event.localY)) );
         onMove(opos.x,opos.y, event);
      }
   }

   function onMouseOut(event:MouseEvent) { /*trace("Fake move!"); */onMove(-1000,-1000, event);}



   public function clear() { rects = []; }

   public function add(rect:Rectangle, action:HitAction)
   {
      rects.push( new HitBox(rect,action) );
   }

   function buttonID(inAction:HitAction) : Int
   {
      switch(inAction)
      {
         case BUTTON(_,id): return id;
         default:
      }
      return -1;
   }

   public function onDown(inX:Float, inY:Float,inEvent:MouseEvent)
   {
      downX = inX;
      downY = inY;
      mMoved = false;
      downPane = null;
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            switch(r.action)
            {
               case BUTTON(_pane,_id) :
                  //var states = pane==null ? buttonState : pane.buttonStates();
                  //states[id] = BUT_STATE_DOWN;
                  //mCallback(HitAction.REDRAW,inEvent);
               case TITLE(pane) :
                  downPane = pane;
                  mCallback(r.action,inEvent);
               case RESIZE(_pane,_flags) :
                  mCallback(r.action,inEvent);
               case DOCKSIZE(dock,index):
                  if (onDockSizeDown!=null && r.rect.contains(inX,inY))
                     onDockSizeDown(dock,index,inX,inY,r.rect);
               default:
            }
         }
   }


   public function onUp(inX:Float, inY:Float,inEvent:MouseEvent)
   {
      downPane = null;
      mResizeFlags = 0;
      mMoved = false;
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            switch(r.action)
            {
               case BUTTON(_pane,_id):
                  //var states = pane==null ? buttonState : pane.buttonStates();
                  //if (states[id]==BUT_STATE_DOWN)
                  //{
                     //states[id]=BUT_STATE_OVER;
                  //}
               default:
            }
            mCallback(r.action,inEvent);
         }
   }


   public function onMove(inX:Float, inY:Float, inEvent:MouseEvent)
   {
      var result = false;

      for(rect in rects)
      {
         switch(rect.action)
         {
            case BUTTON(_pane,_id):
               /*
               var states = pane==null ? buttonState : pane.buttonStates();
               if (rect.rect.contains(inX,inY))
               {
                  if (states[id]==BUT_STATE_UP)
                  {
                      states[id] = BUT_STATE_OVER;
                      result = true;
                  }
               }
               else if (states[id]!=BUT_STATE_UP)
               {
                   states[id] = BUT_STATE_UP;
                   result = true;
               }
               */
            case DOCKSIZE(dock,index):
               if (onOverDockSize!=null && rect.rect.contains(inX,inY))
                  onOverDockSize(dock,index,inX,inY,rect.rect);
            default:
         }
      }

      var moved = (downPane!=null) && (!mMoved) && (Math.abs(inX-downX)>5 || Math.abs(inY-downY)>5);
      if (moved)
      {
         mMoved = true;
         if (downPane!=null)
            mCallback(DRAG(downPane),inEvent);
         downPane = null;
      }

      if (result)
         mCallback(REDRAW,inEvent);
   }


}




