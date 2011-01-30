package gm2d;

import gm2d.display.Sprite;
import gm2d.Screen;
import gm2d.display.StageScaleMode;
import gm2d.display.StageDisplayState;
import gm2d.events.Event;
import gm2d.events.KeyboardEvent;
import gm2d.events.MouseEvent;
import gm2d.text.TextField;
import gm2d.ui.Dialog;
import gm2d.reso.Loader;
import gm2d.reso.Resources;
import gm2d.geom.Point;
import gm2d.ui.Window;
import gm2d.filters.BitmapFilter;
import gm2d.filters.DropShadowFilter;
import gm2d.display.DisplayObject;


class Game
{
   static public var initWidth = 480;
   static public var initHeight = 320;
   static public var useHardware = true;
   static public var isResizable = true;
   static public var frameRate = 30.0;
   static public var screenOrientation:Null<Int> = null;
   static public var rotation:Int = 0;
   static public var showFPS(getShowFPS,setShowFPS):Bool;
   static public var fpsColor(getFPSColor,setFPSColor):Int;
   static public var backgroundColor = 0xffffff;
   static public var title(default,setTitle):String;
   static public var icon(default,setIcon):String;
   static public var pixelAccurate:Bool = false;
   static public var toggleFullscreenOnAltEnter:Bool = true;

   static var mCurrentScreen:Screen;
   static var mCurrentDialog:Dialog;
   static var mCurrentPopup:Window;

   static var mScreenParent:Sprite;
   static var mDialogParent:Sprite;
   static var mPopupParent:Sprite;
   static var mFPSControl:TextField;
   static var mFPSColor:Int = 0xff0000;
   static var mLastEnter = 0.0;
   static var mLastStep = 0.0;

   static var mShowFPS = false;
   static var mFrameTimes = new Array<Float>();
   static var created = false;

   static var mScreenMap:Hash<Screen> = new Hash<Screen>();
   static var mDialogMap:Hash<Dialog> = new Hash<Dialog>();
   static var mKeyDown = new Array<Bool>();
   static var mResources = new Hash<Dynamic>();
   static var mPopupFilters:Array<BitmapFilter>;

   static public var screen(getCurrent,null):Screen;


   public static function create( inOnLoaded:Void->Void )
   {
      if (created) throw "Game.create : already created";

      created = true;

   #if flash
     init();
     inOnLoaded();
   #else
     var w = initWidth;
     var h = initHeight;
     if (screenOrientation==90 || screenOrientation==270)
     {
        w = initHeight;
        h = initWidth;
     }

     nme.Lib.create(function() { init(); inOnLoaded(); },
          w,h,frameRate,backgroundColor,
          (useHardware ? nme.Lib.HARDWARE : 0) | (isResizable ? nme.Lib.RESIZABLE : 0),
          title, icon );
   #end
   
   }

   static function init()
   {
      mScreenParent = new Sprite();
      mDialogParent = new Sprite();
      mPopupParent = new Sprite();
      mDialogParent.visible = true;
      mFPSControl = new TextField();
      mFPSControl.text = "1.0 FPS";
      mFPSControl.selectable = false;
      mFPSControl.mouseEnabled = false;
      mFPSControl.x = 10;
      mFPSControl.y = 10;
      mFPSControl.visible = mShowFPS;
      mFPSControl.textColor = mFPSColor;

      var parent = gm2d.Lib.current;
      parent.addChild(mScreenParent);
      parent.addChild(mDialogParent);
      parent.addChild(mPopupParent);
      parent.addChild(mFPSControl);

      //if (pixelAccurate)
      parent.stage.scaleMode = gm2d.display.StageScaleMode.NO_SCALE;

      parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
      parent.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp );
      parent.stage.addEventListener(Event.RESIZE, onSize);
      parent.stage.addEventListener(Event.ENTER_FRAME, onEnter);
      parent.stage.addEventListener("mouseMove", onMouseMove);
      parent.stage.addEventListener("mouseDown", onMouseDown);
      parent.stage.addEventListener("mouseUp", onMouseUp);

      setStageTransform();
   }

   static function setStageTransform()
   {
      var parent = gm2d.Lib.current;
      var sw = parent.stage.stageWidth;
      var sh = parent.stage.stageHeight;
      if (screenOrientation==null)
      {
         #if (iphone || android)
            rotation  = (initWidth>initHeight) == (sw>sh) ? 0 : 90;
         #else
            rotation = 0;
         #end
      }
      else
         rotation = screenOrientation;
      trace(rotation + " (" + sw + "x" + sh + ")" );


      switch(rotation)
      {
         case 0:
         case 90:  parent.rotation=90; parent.x=sw;
         case 180: parent.rotation=180; parent.x=sw; parent.y=sh;
         case 270: parent.rotation=270; parent.y=sw;
         default: throw("Unsupported orientation :" + rotation);
      }
   }

   public static function isKeyDown(inCode:Int) { return mKeyDown[inCode]; } 

   public static function addScreen(inName:String,inScreen:Screen)
   {
      mScreenMap.set(inName,inScreen);
   }

   static function getCurrent() { return mCurrentScreen; }

   public static function onMouseMove(inEvent)
   {
      if (mCurrentPopup!=null)
      {
         var pos = mCurrentPopup.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         mCurrentPopup.onMouseMove(pos.x,pos.y);
      }
      else if (mCurrentScreen!=null)
      {
         var pos = mCurrentScreen.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         mCurrentScreen.onMouseMove(pos.x,pos.y);
      }
   }

   public static function onMouseDown(inEvent:MouseEvent)
   {
      if (inEvent.target == gm2d.Lib.current.stage)
      {
         if (mCurrentPopup!=null)
         {
             closePopup();
             return;
         }
      }

      if (mCurrentScreen!=null)
      {
         var pos = mCurrentScreen.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         mCurrentScreen.onMouseDown(pos.x,pos.y);
      }
   }

   public static function onMouseUp(inEvent)
   {
      if (mCurrentScreen!=null)
      {
         var pos = mCurrentScreen.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         mCurrentScreen.onMouseUp(pos.x,pos.y);
      }
   }



   static public function setCurrentScreen(inScreen:Screen)
   {
      if (mCurrentScreen==inScreen)
         return;

      if (mCurrentScreen!=null)
      {
         mCurrentScreen.onActivate(false);
         mScreenParent.removeChild(mCurrentScreen);
      }

      mCurrentScreen = inScreen;

      if (mCurrentScreen!=null)
      {
         var mode = mCurrentScreen.getScaleMode();
			/*
         mScreenParent.stage.scaleMode =
           (mode==ScreenScaleMode.PIXEL_PERFECT || mode==ScreenScaleMode.TOPLEFT_UNSCALED) ?
           StageScaleMode.NO_SCALE  : StageScaleMode.SHOW_ALL;
			  */
         
         mScreenParent.addChild(mCurrentScreen);
         mCurrentScreen.onActivate(true);
         updateScale();

         mCurrentScreen.setRunning(mCurrentDialog==null);
      }

      mLastEnter = haxe.Timer.stamp();
      mLastStep = mLastEnter;
   }
  
   static function isRotated() : Bool
   {
      return (rotation==90 || rotation==270);
   }

   static function stageWidth()
   {
      var s = mCurrentScreen.stage;
      return isRotated() ? s.stageHeight : s.stageWidth;
   }

   static function stageHeight()
   {
      var s = mCurrentScreen.stage;
      return isRotated() ?  s.stageWidth : s.stageHeight;
   }


   static function updateScale()
   {
      var scale = 1.0;
      var stage = mCurrentScreen.stage;
      var stage_width = stageWidth();
      var stage_height = stageHeight();

      var sw = stage_width / initWidth;
      var sh = stage_height / initHeight;
      scale = sw < sh ? sw : sh;
		var graphics_scale = scale;

      if (mCurrentScreen!=null)
      {
         var mode = mCurrentScreen.getScaleMode();
         var px = 0;
         var py = 0;
         if (mode==ScreenScaleMode.TOPLEFT_UNSCALED)
         {
            scale =1.0;
         }
         else if (mode==ScreenScaleMode.PIXEL_PERFECT)
         {
            scale =1.0;
            px = Std.int((stage_width  - initWidth*scale)/2);
            py = Std.int((stage_height - initHeight*scale)/2);
         }
         else
         {
            px = Std.int( (stage_width  - initWidth*scale)/2);
            py = Std.int( (stage_height - initHeight*scale)/2);
         }

         mScreenParent.x = px;
         mScreenParent.y = py;

         mScreenParent.scaleX = scale;
         mScreenParent.scaleY = scale;
         mDialogParent.x = px;
         mDialogParent.y = py;
         mDialogParent.scaleX = scale;
         mDialogParent.scaleY = scale;
         mPopupParent.x = px;
         mPopupParent.y = py;
         mPopupParent.scaleX = scale;
         mPopupParent.scaleY = scale;

         mCurrentScreen.scaleScreen(graphics_scale);
      }
   }

   static function getShowFPS() { return mShowFPS; } 
   static function setShowFPS(inShowFPS:Bool) : Bool
   {
      mShowFPS = inShowFPS;
      if (mFPSControl!=null)
         mFPSControl.visible = mShowFPS;
      return inShowFPS;
   }

   static function getFPSColor() { return mFPSColor; } 
   static function setFPSColor(inCol:Int) : Int
   {
      mFPSColor = inCol;
      if (mFPSControl!=null)
         mFPSControl.textColor = mFPSColor;
      return inCol;
   }

   public static function setScreen(inName:String) : String
   {
      if (!mScreenMap.exists(inName))
         throw "Unknown screen : " + inName;

      setCurrentScreen( mScreenMap.get(inName) );
      return inName;
   }

   static function onEnter(_)
   {
      var now = haxe.Timer.stamp();
      if (mCurrentScreen!=null)
      {
         var freq = mCurrentScreen.getUpdateFrequency();
         if (freq<=0)
         {
            mCurrentScreen.updateDelta(now-mLastEnter);
            mLastEnter = now;
            mCurrentScreen.render(0.0);
         }
         else
         {
            var steps = 0;

            // Looks like a gap?
            if (now>mLastEnter+1.0)
            {
               steps = 1;
               mLastStep = now;
            }
            else
            {
               // Do a number of descrete steps based on the frequency.
               steps = Math.floor( (now-mLastStep) * freq );
               mLastStep += steps / freq;
            }

            for(i in 0...steps)
               mCurrentScreen.updateFixed();

            var fractional_step = (now-mLastStep) * freq;

            mCurrentScreen.render(fractional_step);

            //var fps = (now==mLastEnter) ? 1000 : 1.0/(now-mLastEnter);
            //trace(steps + ":" + fps + "   (" + fractional_step + ")");

         }
      }
      mLastEnter = now;
      if (mShowFPS)
      {
         mFrameTimes.push(now);
         now -= 0.99;
         while(mFrameTimes[0]<now)
            mFrameTimes.shift();
         mFPSControl.text = "FPS:" + mFrameTimes.length;
      }
   }

   static public function toggleFullscreen()
   {
      #if nme
      var stage = nme.Lib.current.stage;
      stage.displayState = Type.enumEq(stage.displayState,StageDisplayState.NORMAL) ?
       StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
      #end
   }


   static function onKeyDown(event:KeyboardEvent )
   {
      if (toggleFullscreenOnAltEnter && event.keyCode==13 && event.altKey)
         toggleFullscreen();

      var used = false;
      if (mCurrentDialog!=null)
          used = mCurrentDialog.onKeyDown(event);

      if (!used && mCurrentScreen!=null)
         mCurrentScreen.onKeyDown(event);

      mKeyDown[event.keyCode] = true;
   }

   static function onKeyUp(event:KeyboardEvent )
   {
      //if (mCurrentDialog!=null) mCurrentDialog.onKeyUp(event); else
      if (mCurrentScreen!=null)
         mCurrentScreen.onKeyUp(event);

      mKeyDown[event.keyCode] = false;
   }


   static function setTitle(inTitle:String) : String
   {
      title = inTitle;
      return inTitle;
   }

   static function setIcon(inIcon:String) : String
   {
      icon = inIcon;
      return inIcon;
   }


   public static function addDialog(inName:String, inDialog:Dialog)
   {
      mDialogMap.set(inName,inDialog);
   }


   static public function showDialog(inDialog:String,inCenter:Bool=true) : Dialog
   {
      var dialog:Dialog = mDialogMap.get(inDialog);
      if (dialog==null)
         throw "Invalid Dialog "+  inDialog;
      doShowDialog(dialog,inCenter);
      return dialog;
   }

   static public function closeDialog() { doShowDialog(null,false); }

   static public function doShowDialog(inDialog:Dialog,inCenter:Bool)
   {
      if (mCurrentDialog!=null)
      {
         mCurrentDialog.onClose();
         mDialogParent.removeChild(mCurrentDialog);
         mCurrentDialog = null;
         if (mCurrentScreen!=null && inDialog==null)
            mCurrentScreen.setRunning(true);
      }

      mCurrentDialog = inDialog;

      if (mCurrentDialog!=null)
      {
         if (mCurrentScreen!=null)
            mCurrentScreen.setRunning(false);
         mDialogParent.addChild(mCurrentDialog);
         mCurrentDialog.onAdded();
         mCurrentDialog.doLayout();
         if (inCenter)
            mCurrentDialog.center(initWidth,initHeight);
      }

      mDialogParent.visible = mCurrentDialog!=null;
   }

   public static function popup(inPopup:Window,inX:Float,inY:Float,inShadow:Bool=true)
   {
       closePopup();
       if (inShadow)
       {
          if (mPopupFilters==null)
          {
             mPopupFilters = [];
             mPopupFilters.push( new DropShadowFilter(3,45,0,0.5,3,3,1) );
          }
          inPopup.filters = mPopupFilters;
       }
       mCurrentPopup = inPopup;
       mPopupParent.addChild(inPopup);
		 var pos = mPopupParent.localToGlobal( new Point(inX+inPopup.width,inY+inPopup.height) );
		 if (pos.x>mPopupParent.stage.stageWidth)
		    inX -= (pos.x-stageWidth()) / mPopupParent.scaleX;
		 if (pos.y>mPopupParent.stage.stageHeight)
		    inY -= (pos.y-stageHeight()) / mPopupParent.scaleY;

		 var pos = mPopupParent.localToGlobal( new Point(inX,inY) );
		 if (pos.x<0)
		    inX += -pos.x/mPopupParent.scaleX;
		 if (pos.y<0)
		    inY += -pos.y/mPopupParent.scaleY;
		 inPopup.x = inX;
		 inPopup.y = inY;

       mPopupParent.visible = true;
       mDialogParent.mouseEnabled = false;
       mScreenParent.mouseEnabled = false;
   }

   public static function moveToPopupLayer(inObject:DisplayObject)
	{
	   mPopupParent.addChild(inObject);
	}

   public static function closePopup()
   {
      if (mCurrentPopup!=null)
      {
          mPopupParent.removeChild(mCurrentPopup);
          mCurrentPopup.destroy();
          mCurrentPopup = null;
      }
      mPopupParent.visible = false;
      mDialogParent.mouseEnabled = true;
      mScreenParent.mouseEnabled = true;
   }


   public static function close()
   {
      #if nme
      nme.Lib.close();
      #end
   }


   public static function setResources(inResources:Resources) { mResources = inResources; }

   public static function resource(inName:String) { return mResources.get(inName); }


   public static function freeResource(inName:String) { return mResources.remove(inName); }



   public static function isDown(inCode:Int) : Bool { return mKeyDown[inCode]; }

   static function onUpdate(e:gm2d.events.Event)
   {
      var now = haxe.Timer.stamp();
      if (mCurrentScreen!=null)
      {
         var freq = mCurrentScreen.getUpdateFrequency();
         if (freq<=0)
         {
            mCurrentScreen.updateDelta(now-mLastEnter);
            mCurrentScreen.render(0);
            mLastEnter = now;
         }
         else
         {
            var fps = 1.0/(now-mLastEnter);

            // Do a number of descrete steps based on the frequency.
            var steps = Math.floor( (now-mLastStep) * freq );
            for(i in 0...steps)
               mCurrentScreen.updateFixed();

            mLastStep += steps / freq;


            var fractional_step = (now-mLastStep) * freq;

            mCurrentScreen.render(fractional_step);

            //hxcpp.Lib.println(steps + ":" + fps + "   (" + fractional_step + ")");

         }
      }
      mLastEnter = now;
   }


   static function onSize(e:Event)
   {
      setStageTransform();
      updateScale();
   }


}
