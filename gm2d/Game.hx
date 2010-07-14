package gm2d;

import gm2d.display.Sprite;
import gm2d.Screen;
import gm2d.display.StageScaleMode;
import gm2d.display.StageDisplayState;
import gm2d.events.Event;
import gm2d.events.KeyboardEvent;
import gm2d.text.TextField;
import gm2d.ui.Dialog;
import gm2d.reso.Loader;
import gm2d.reso.Resources;


class Game
{
   static public var initWidth = 480;
   static public var initHeight = 320;
   static public var useHardware = true;
   static public var isResizable = true;
   static public var frameRate = 30.0;
   static public var iPhoneOrientation:Null<Int> = null;
   static public var showFPS(getShowFPS,setShowFPS):Bool;
   static public var fpsColor(getFPSColor,setFPSColor):Int;
   static public var backgroundColor = 0xffffff;
   static public var title(default,setTitle):String;
   static public var icon(default,setIcon):String;
   static public var pixelAccurate:Bool = false;
   static public var toggleFullscreenOnAltEnter:Bool = true;

   static var mCurrentScreen:Screen;
   static var mCurrentDialog:Dialog;

   static var mScreenParent:Sprite;
   static var mDialogParent:Sprite;
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
     #if (testOrientation)
     if (iPhoneOrientation==90 || iPhoneOrientation==270 ||
          (iPhoneOrientation==null && initWidth>initHeight ))
     {
        w = initHeight;
        h = initWidth;
     }
     #end

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
      parent.addChild(mFPSControl);

      if (pixelAccurate)
         parent.stage.scaleMode = gm2d.display.StageScaleMode.NO_SCALE;

      parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
      parent.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp );
      parent.stage.addEventListener(Event.ENTER_FRAME, onEnter);
      parent.stage.addEventListener(Event.RESIZE, onSize);

      #if (iphone || testOrientation)
      var o = iPhoneOrientation==null ? (initWidth>initHeight ? 90:0) : iPhoneOrientation;
      switch(o)
      {
         case 0:
         case 90:  parent.rotation=90; parent.x=initHeight;
         case 180: parent.rotation=180; parent.x=initWidth; parent.y=initHeight;
         case 270: parent.rotation=270; parent.y=initWidth;
         default: throw("Unsupported orientation :" + iPhoneOrientation);
      }
      #end
   }

   public static function isKeyDown(inCode:Int) { return mKeyDown[inCode]; } 

   public static function addScreen(inName:String,inScreen:Screen)
   {
      mScreenMap.set(inName,inScreen);
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
         mScreenParent.stage.scaleMode = mode==ScreenScaleMode.PIXEL_PERFECT ?
           StageScaleMode.NO_SCALE  : StageScaleMode.SHOW_ALL;
         
         mScreenParent.addChild(mCurrentScreen);
         mCurrentScreen.onActivate(true);
         updateScale();
           
      }
      mLastEnter = haxe.Timer.stamp();
      mLastStep = mLastEnter;
   }

   static function updateScale()
   {
      var scale = 1.0;
      var stage = mCurrentScreen.stage;
      var sw = stage.stageWidth / initWidth;
      var sh = stage.stageHeight / initHeight;
      scale = sw < sh ? sw : sh;


      if (mCurrentScreen!=null)
      {
         var mode = mCurrentScreen.getScaleMode();
         if (mode!=ScreenScaleMode.PIXEL_PERFECT)
         {
            mScreenParent.x = ((stage.stageWidth  - initWidth*scale)/2)/scale;
            mScreenParent.y = ((stage.stageHeight - initHeight*scale)/2)/scale;
            scale =1.0;
         }
         else
         {
            mScreenParent.x = (stage.stageWidth  - initWidth*scale)/2;
            mScreenParent.y = (stage.stageHeight - initHeight*scale)/2;
            mDialogParent.x = (stage.stageWidth - initWidth*scale)/2;
            mDialogParent.y = (stage.stageHeight - initHeight*scale)/2;
         }
         mDialogParent.x = mScreenParent.x;
         mDialogParent.y = mScreenParent.y;
         mDialogParent.scaleX = scale;
         mDialogParent.scaleY = scale;
         mCurrentScreen.scaleScreen(scale);
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


      //if (mCurrentDialog!=null) mCurrentDialog.onKeyDown(event); else
      if (mCurrentScreen!=null)
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
      DoShowDialog(dialog);
      if (inCenter)
      {
         dialog.center(dialog.stage.stageWidth,dialog.stage.stageHeight);
      }
      return dialog;
   }

   static public function closeDialog() { DoShowDialog(null); }

   static function DoShowDialog(inDialog:Dialog)
   {
      if (mCurrentDialog!=null)
      {
         mCurrentDialog.onClose();
         mDialogParent.removeChild(mCurrentDialog);
         mCurrentDialog = null;
      }

      mCurrentDialog = inDialog;

      if (mCurrentDialog!=null)
      {
         mDialogParent.addChild(mCurrentDialog);
         mCurrentDialog.onAdded();
         mCurrentDialog.DoLayout();
      }

      mDialogParent.visible = mCurrentDialog!=null;
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
      updateScale();
   }


}
