package gm2d.ui;

import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.display.Bitmap;
import nme.display.BitmapData;

import gm2d.svg.BitmapDataManager;


class Joystick extends Sprite
{
   public var w:Float;
   public var h:Float;
   public var state:Int;
   public var turnX:Float;
   public var turnY:Float;
   public var twitch:Bool;
   var knobFilename:String;
   var backgroundFilename:String;

   static public inline var POS_PENDING = -1;
   static public inline var POS_NONE = 0;

   static public inline var POS_LEFT =  0x0001;
   static public inline var POS_RIGHT = 0x0002;
   static public inline var POS_UP =    0x0004;
   static public inline var POS_DOWN =  0x0008;

   static public inline var POS_UP_LEFT    = 0x0005;
   static public inline var POS_UP_RIGHT   = 0x0006;
   static public inline var POS_DOWN_LEFT  = 0x0009;
   static public inline var POS_DOWN_RIGHT = 0x000A;

   var knob:Bitmap;
   var track:Bitmap;
   var knobPosX:Array<Float>;
   var knobPosY:Array<Float>;
   var onChange:Int->Bool->Void;
   var mBorder:Float;
   var nWays:Int;
  

   public function new(inScale:Float, inOnChange:Int->Bool->Void,inBorder:Float, inNWays:Int,
                  inKnobFilename:String,
                  inBackgroundFilename:String,
                  inTwitch:Bool = false)
   {
      backgroundFilename = inBackgroundFilename;
      knobFilename = inKnobFilename;

      #if !flash
      var addMouseListeners = !nme.ui.Multitouch.supportsTouchEvents;
      #else
      var addMouseListeners = true;
      #end

      super();
      state = 0;
      nWays = inNWays;
      mBorder = inBorder;
      onChange = inOnChange;

      // Twitch controller is based on movement, not position
      twitch = inTwitch;

		knob = new Bitmap();
		track = new Bitmap();
		addChild(track);
		addChild(knob);
      if (inScale>0)
         scale(inScale);

      mouseChildren = false;


      var me = this;
      if (addMouseListeners)
      {
         addEventListener(MouseEvent.MOUSE_DOWN, function(e) me.setFromPos(e.localX,e.localY, "mouseDown") );
         addEventListener(MouseEvent.MOUSE_UP, function(e) me.setState(POS_NONE,"mouseUp") );
         addEventListener(MouseEvent.MOUSE_MOVE, function(e) me.setFromPos(e.localX,e.localY,"mouseMove") );
         addEventListener(MouseEvent.ROLL_OUT, function(e) me.setState(POS_NONE,"rollOut") );
      }

      #if !flash
      if (!addMouseListeners)
      {
         addEventListener(TouchEvent.TOUCH_END, function(e) me.setState(POS_NONE,"touchEnd") );
         addEventListener(TouchEvent.TOUCH_BEGIN, function(e) me.setFromPos(e.localX,e.localY,"touchBegin") );
         addEventListener(TouchEvent.TOUCH_OVER, function(e) me.setFromPos(e.localX,e.localY,"touchOver") );
         addEventListener(TouchEvent.TOUCH_MOVE, function(e)
            { me.setFromPos(e.localX,e.localY,"touchMove"); } );
         addEventListener(TouchEvent.TOUCH_OUT, function(e) me.setState(POS_NONE,"touchOut") );
      }
      #end
      onChange = inOnChange;
   }

   public function scale(inScale:Float)
   {
      var knob_bmp = BitmapDataManager.create(knobFilename,"",inScale);
		knob.bitmapData = knob_bmp;

      var scale = nWays==2 ? inScale : inScale*1.5;
      //var scale = inScale;
      var track_bmp = BitmapDataManager.create(backgroundFilename,"",scale);
		track.bitmapData = track_bmp;
      w = track_bmp.width;
      h = Math.max(knob_bmp.height,track_bmp.height)+mBorder*2*inScale;

      knobPosX =  [ 0, (w/2)-(knob_bmp.width/2), w-knob_bmp.width ];

      var cy = (h/2) - (knob_bmp.height/2);
      if (nWays==2)
         knobPosY =  [ cy,cy,cy ];
      else
         knobPosY =  [ 0, cy, h-knob_bmp.height ];

      knob.x = knobPosX[1];
      knob.y = knobPosY[1];
      track.y = h/2-track_bmp.height/2;

      // Zero alpha for hit-testing
      var gfx = graphics;
      gfx.clear();
      gfx.beginFill(0xffffff,0);
      gfx.drawRect(0,0,w,h);
   }

   function stateX(inState:Int)
   {
      switch(inState)
      {
         case POS_LEFT, POS_UP_LEFT, POS_DOWN_LEFT: return knobPosX[0];
         case POS_RIGHT, POS_UP_RIGHT, POS_DOWN_RIGHT: return knobPosX[2];
      }
      return knobPosX[1];
   }

   function stateY(inState:Int)
   {
      switch(inState)
      {
         case POS_UP, POS_UP_LEFT, POS_UP_RIGHT: return knobPosY[0];
         case POS_DOWN, POS_DOWN_LEFT, POS_DOWN_RIGHT: return knobPosY[2];
      }
      return knobPosY[1];
   }


   function setState(inState:Int,inWhy:String)
   {
      //trace("Set state : (" + inWhy + ") " + state + " -> " + inState );
      if (inState!=state)
      {
         knob.x = stateX(inState);
         knob.y = stateY(inState);
         if (state>POS_NONE)
         {
            //trace(" ---------------------> " + state + " UP");
            onChange(state,false);
         }
         state = inState;
         if (state>POS_NONE)
         {
            //trace(" ---------------------> " + state + " DOWN");
            onChange(state,true);
         }
      }
      /*
      else if (inState>POS_PENDING)
         onChange(state,true);
      */
   }


   function setFromPos(inX:Float,inY:Float,inWhy:String)
   {
      var dx = inX-turnX;
      var dy = inY-turnY;
      if (nWays==2)
         dy = 0;
      //trace("setFromPos  (" + inWhy + ") :" + inX + "," + inY);
      if (state==POS_NONE)
      {
         turnX = inX;
         state = POS_PENDING;
         //trace("Pending....");
      }
      else if ( twitch && (inWhy=="touchBegin" || inWhy=="mouseDown") )
      {
         turnX = inX;
         turnY = inY;
         trace("begin turn: " + turnX + "," + turnY );
      }
      else if ( !twitch || (dx*dx + dy*dy > 100) )
      {
         var s = 0;
         var thresh:Float;

         if (twitch)
         {
            thresh = Math.sqrt(dx*dx+dy*dy) *0.4;
         }
         else
         {
            dx = inX - w/2;
            dy = inY - h/2;
            thresh = w/10;
            //trace("POS : " + dx + "," + dy + "/" + thresh);
         }

         if (nWays==4)
         {
            if (Math.abs(dx) > Math.abs(dy) )
               dy = 0;
            else
               dx = 0;
         }

         if (dx<=-thresh)
         {
            s = dy<=-thresh ? POS_UP_LEFT : dy>=thresh ? POS_DOWN_LEFT : POS_LEFT;
         }
         else if (dx>=thresh)
         {
            s = dy<=-thresh ? POS_UP_RIGHT : dy>=thresh ? POS_DOWN_RIGHT : POS_RIGHT;
         }
         else if (dy<=-thresh)
         {
            s = POS_UP;
         }
         else if (dy>=thresh)
         {
            s = POS_DOWN;
         }
         turnX = inX;
         turnY = inY;
         if (twitch)
         {
            trace("turn: " + turnX + "," + turnY );
         }
         setState(s,inWhy);
      }
   }
}

