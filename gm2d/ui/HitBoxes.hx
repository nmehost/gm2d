package gm2d.ui;

import gm2d.geom.Rectangle;
import gm2d.geom.Point;
import gm2d.display.Bitmap;
import gm2d.display.Sprite;
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
   public static inline var COUNT = 5;

   public static inline var TITLE = 6;
}

enum HitAction
{
   NONE;
   REDRAW;
   DRAG(pane:IDockable);
   BUTTON(pane:IDockable,button:Int);
   TITLE(pane:IDockable);
   RESIZE(pane:IDockable,flags:Int);
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

   public var bitmaps:Array<Bitmap>;
   var mCallback:HitAction->Void;
   var mObject:Sprite;
   var rects:Array<HitBox>;
   var mDownX:Float;
   var mDownY:Float;
   var mMoved:Bool;
   var mDownPane:IDockable;
   var mResizeFlags:Int;
   public var buttonState(default,null):Array<Int>;


   public function new(inObject:Sprite,inCallback:HitAction->Void)
   {
      rects = [];
      bitmaps = [];

      mObject = inObject;
      mCallback = inCallback;
      mDownPane = null;
      mResizeFlags = 0;
      buttonState = [0,0,0,0,0];
      inObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      inObject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      inObject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      inObject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
   }

   function onMouseDown(event:MouseEvent)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==mObject)
         onDown(event.localX, event.localY);
   }

   function onMouseUp(event:MouseEvent)
   {
      var obj:gm2d.display.DisplayObject = event.target;
      if (obj==mObject)
         onUp(event.localX, event.localY);
   }

   function onMouseMove(event:MouseEvent) { onMove(event.localX, event.localY); }

   function onMouseOut(event:MouseEvent) { onMove(-100,-100); }



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

   public function onDown(inX:Float, inY:Float)
   {
      mDownX = inX;
      mDownY = inY;
      mMoved = false;
      mDownPane = null;
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            switch(r.action)
            {
               case BUTTON(pane,id) :
                  var states = pane==null ? buttonState : pane.buttonStates();
                  states[id] = BUT_STATE_DOWN;
                  mCallback(HitAction.REDRAW);
               case TITLE(pane) :
                  mDownPane = pane;
                  mCallback(r.action);
               case RESIZE(pane,flags) :
                  mCallback(r.action);
               default:
            }
         }
   }


   public function onUp(inX:Float, inY:Float)
   {
      mDownPane = null;
      mResizeFlags = 0;
      mMoved = false;
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            switch(r.action)
            {
               case BUTTON(pane,id):
                  var states = pane==null ? buttonState : pane.buttonStates();
                  if (states[id]==BUT_STATE_DOWN)
                  {
                     states[id]=BUT_STATE_OVER;
                  }
               default:
            }
            mCallback(r.action);
         }
   }


   public function onMove(inX:Float, inY:Float)
   {
      var result = false;

      for(rect in rects)
      {
         switch(rect.action)
         {
            case BUTTON(pane,id):
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
            default:
         }
      }

      var moved = (mDownPane!=null) && (!mMoved) && (Math.abs(inX-mDownX)>5 || Math.abs(inY-mDownY)>5);
      if (moved)
      {
         mMoved = true;
         if (mDownPane!=null)
            mCallback(DRAG(mDownPane));
         mDownPane = null;
      }

      if (result)
         mCallback(REDRAW);
   }


}




