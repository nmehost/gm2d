package gm2d.ui;

import nme.geom.Rectangle;
import nme.geom.Point;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.events.MouseEvent;
import gm2d.skin.Skin;

class ResizeFlag
{
   public static inline var E = 0x0010;
   public static inline var W = 0x0020;
   public static inline var N = 0x0040;
   public static inline var S = 0x0080;
}

class MiniButton
{
   public static inline var CLOSE    = "#close";
   public static inline var MINIMIZE = "#minimize";
   public static inline var MAXIMIZE = "#maximize";
   public static inline var RESTORE  = "#restore";
   public static inline var POPUP    = "#popup";
   public static inline var EXPAND   = "#expand";
   public static inline var PIN      = "#pin";
   public static inline var ADD      = "#add";
   public static inline var REMOVE   = "#remove";
   //public static inline var TITLE = 10;
}

enum HitAction
{
   NONE;
   REDRAW;
   GRIP;
   DRAG(pane:IDockable);
   BUTTON(pane:IDockable,buttonId:String);
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
   var downTitle:HitBox;
   var mResizeFlags:Int;
   var skin:Skin;


   public function new(inSkin:Skin,inObject:Sprite,inCallback:HitAction->MouseEvent->Void)
   {
      rects = [];

      skin = inSkin;
      mObject = inObject;
      mCallback = inCallback;
      downPane = null;
      downTitle = null;
      mResizeFlags = 0;
      inObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDowny);
      inObject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      inObject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      inObject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
   }

   public function getHitBoxOffset(inObj:DisplayObject,  inX:Float, inY:Float )
   {
      return mObject.globalToLocal( inObj.localToGlobal(new Point(inX,inY)) );
   }

   function onMouseDowny(event:MouseEvent)
   {
      var obj:nme.display.DisplayObject = event.target;
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
      var obj:nme.display.DisplayObject = event.target;
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
      var obj:nme.display.DisplayObject = event.target;
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

   function buttonID(inAction:HitAction) : String
   {
      switch(inAction)
      {
         case BUTTON(_,id): return id;
         default:
      }
      return "";
   }

   public function onDown(inX:Float, inY:Float,inEvent:MouseEvent)
   {
      downX = inX;
      downY = inY;
      mMoved = false;
      downPane = null;
      downTitle = null;
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            inEvent.stopImmediatePropagation();
            switch(r.action)
            {
               case BUTTON(pane,id) :
                  downPane = pane;
                  //var states = pane==null ? buttonState : pane.buttonStates();
                  //states[id] = BUT_STATE_DOWN;
                  //mCallback(HitAction.REDRAW,inEvent);
               case TITLE(pane) :
                  downPane = pane;
                  downTitle = r;
                  //Don't do callback until button-up
                  //mCallback(r.action,inEvent);
               case RESIZE(_pane,_flags) :
                  mCallback(r.action,inEvent);
               case DOCKSIZE(dock,index):
                  if (onDockSizeDown!=null && r.rect.contains(inX,inY))
                     onDockSizeDown(dock,index,inX,inY,r.rect);
               case GRIP:
                  mCallback(r.action,inEvent);
               default:
            }
            break;
         }
   }


   public function onUp(inX:Float, inY:Float,inEvent:MouseEvent)
   {
      if (downTitle!=null)
      {
         downPane = null;
         if (!mMoved)
            mCallback(downTitle.action,inEvent);
         downTitle = null;
         return;
      }
      var oldPane = downPane;
      downPane = null;
      mResizeFlags = 0;
      mMoved = false;
      for(r in rects)
         if (r.rect.contains(inX,inY))
         {
            switch(r.action)
            {
               case BUTTON(pane,_id):
                  if (oldPane!=pane)
                     return;
               case TITLE(pane) :
                  if (oldPane!=pane)
                     return;
               case GRIP: return;
               default:
            }

            mCallback(r.action,inEvent);
            break;
         }
   }


   public function onMove(inX:Float, inY:Float, inEvent:MouseEvent)
   {
      var result = false;

      for(rect in rects)
      {
         switch(rect.action)
         {
            case DOCKSIZE(dock,index):
               if (onOverDockSize!=null && rect.rect.contains(inX,inY))
                  onOverDockSize(dock,index,inX,inY,rect.rect);

            // Let mouseWatcher handle it
            case GRIP: return;
            default:
         }
         break;
      }

      var dragDist = skin.scale(20);
      var dx = inX-downX;
      var dy = inY-downY;
      var moved = (downPane!=null) && (!mMoved) && ( (dx*dx + dy*dy) > dragDist*dragDist );
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




