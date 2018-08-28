package gm2d;

import nme.display.Sprite;
import nme.display.Shape;
import gm2d.Screen;
import nme.display.StageScaleMode;
import nme.display.StageDisplayState;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.text.TextField;
import gm2d.ui.Dialog;
import nme.geom.Point;
import gm2d.ui.PopupMenu;
import gm2d.ui.Window;
import gm2d.ui.TextInput;
import nme.filters.BitmapFilter;
import nme.filters.DropShadowFilter;
import nme.display.DisplayObject;

typedef Hash<T> = haxe.ds.StringMap<T>;


class Game
{
   static public var initWidth = 320;
   static public var initHeight = 240;
   static public var safeWidth:Null<Int>;
   static public var safeHeight:Null<Int>;
   static public var screenWidth = 320;
   static public var screenHeight = 240;
   static public var useHardware = true;
   static public var isResizable = true;
   static public var frameRate = 30.0;
   static public var rotation:Int = 0;
   static public var showFPS(get_showFPS,set_showFPS):Bool;
   static public var fpsColor(get_fpsColor,set_fpsColor):Int;
   static public var backgroundColor = 0xffffff;
   static public var title(default,set_title):String;
   static public var icon(default,set_icon):String;
   static public var debugLayout(get,set):Bool;
   static public var pixelAccurate:Bool = false;
   static public var toggleFullscreenOnAltEnter:Bool = false;
   static public var mapEscapeToBack:Bool = true;
   static public var onClosePopup:Void->Void;
   static public var gapDetect = 1.0;
   static public var gapReplace = 0.1;

   static var mCurrentScreen:Screen;
   public static var mCurrentDialog(default,null):Dialog;
   public static var mCurrentPopup(default,null):Window;

   static var mScreenParent:Sprite;
   static var mDialogGrey:Shape;
   static var mDialogParent:Sprite;
   static var mPopupParent:Sprite;
   static var mDebugOverlay:Shape;
   static var mFPSControl:TextField;
   static var mAutoCloseDialog:Bool;
   static var mFPSColor:Int = 0xff0000;
   static var mLastEnter = 0.0;
   static var mLastStep = 0.0;

   static var mShowFPS = false;
   static var mFrameTimes = new Array<Float>();
   static var created = false;

   static var mScreenMap:Hash<Screen> = new Hash<Screen>();
   static var mDialogMap:Hash<Dialog> = new Hash<Dialog>();
   static var mKeyDown = new Array<Bool>();

   static var screenStack = new Array<Screen>();
   static public var screen(get_screen,null):Screen;


   static public function create()
   {
      if (created)
         return;
      created = true;

      screenWidth = nme.Lib.current.stage.stageWidth;
      screenHeight = nme.Lib.current.stage.stageHeight;

      #if !flash
      initWidth = nme.Lib.initWidth;
      initHeight = nme.Lib.initHeight;
      #else
      initWidth = screenWidth;
      initHeight = screenHeight;
      #end
      if (safeWidth==null)
         safeWidth = initWidth;
      if (safeHeight==null)
         safeHeight = initHeight;

      mAutoCloseDialog = true;

      mScreenParent = new Sprite();
      mDialogGrey = new Shape();
      mDialogGrey.visible = false;
      mDialogParent = new Sprite();
      mPopupParent = new Sprite();
      mDebugOverlay = new Shape();
      mDebugOverlay.visible = false;
      mDialogParent.visible = true;

      mFPSControl = new TextField();
      mFPSControl.text = "FPS: ---";
      mFPSControl.selectable = false;
      mFPSControl.mouseEnabled = false;
      mFPSControl.x = 10;
      mFPSControl.y = 10;
      mFPSControl.visible = mShowFPS;
      mFPSControl.textColor = mFPSColor;

      var parent = nme.Lib.current;
      parent.addChildAt(mScreenParent,0);
      parent.addChildAt(mDialogGrey,1);
      parent.addChildAt(mDialogParent,2);
      parent.addChildAt(mPopupParent,3);
      parent.addChildAt(mFPSControl,4);
      parent.addChildAt(mDebugOverlay,5);

      //if (pixelAccurate)
      parent.stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;

      parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
      parent.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp );
      parent.stage.addEventListener(Event.RESIZE, onSize);
      parent.stage.addEventListener(Event.ENTER_FRAME, onEnter);
      parent.stage.addEventListener(Event.RENDER, onEnter);

      parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, onPreMouseMove, true);
      parent.stage.addEventListener(MouseEvent.MOUSE_DOWN, onPreMouseDown, true);

      parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      parent.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      parent.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      parent.stage.addEventListener(MouseEvent.CLICK, onMouseClick);

      setStageTransform();
   }

   public static function invalidate()
   {
      var stage = nme.Lib.current.stage;
      if (stage!=null)
         stage.invalidate();
   }

   public static function destroy()
   {
      var parent = nme.Lib.current;
      if (mScreenParent!=null)
         parent.removeChild(mScreenParent);
      if (mDialogGrey!=null)
         parent.removeChild(mDialogGrey);
      if (mDialogParent!=null)
         parent.removeChild(mDialogParent);
      if (mPopupParent!=null)
         parent.removeChild(mPopupParent);
      if (mDebugOverlay!=null)
         parent.removeChild(mDebugOverlay);
      if (mFPSControl!=null)
         parent.removeChild(mFPSControl);
      var stage = parent.stage;

      stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
      stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp );
      stage.removeEventListener(Event.RESIZE, onSize);
      stage.removeEventListener(Event.ENTER_FRAME, onEnter);

      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onPreMouseMove, true);
      stage.removeEventListener(MouseEvent.MOUSE_DOWN, onPreMouseDown, true);

      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      stage.removeEventListener(MouseEvent.CLICK, onMouseClick);
   
      parent.rotation = 0;
      parent.x = 0;
      parent.y = 0;
      
      mScreenParent = null;
      mDialogGrey = null;
      mDialogParent = null;
      mPopupParent = null;
      mDebugOverlay = null;
      mFPSControl = null;
      mCurrentPopup = null;
      mCurrentScreen = null;
      mCurrentDialog = null;
   }

   static function setStageTransform()
   {
      var parent = nme.Lib.current;
      var sw = parent.stage.stageWidth;
      var sh = parent.stage.stageHeight;

      parent.rotation=0;   parent.x=0;   parent.y = 0;

     /*
      #if (iphone || android)
         rotation  = (initWidth>initHeight) == (sw>sh) ? 0 : 90;
      #else
         rotation = 0;
      #end

      //trace("SET Stage Transform : " + rotation );
      //trace("    Stage size      : " + sw + "," + sh );
      //trace("    Init  size      : " + initWidth + "," + initHeight );

      switch(rotation)
      {
         case 0:   parent.rotation=0;   parent.x=0;   parent.y = 0;
         case 90:  parent.rotation=90;  parent.x=sw;  parent.y = 0;
         case 180: parent.rotation=180; parent.x=sw;  parent.y=sh;
         case 270: parent.rotation=270; parent.x = 0; parent.y=sw;
         default: throw("Unsupported orientation :" + rotation);
      }
      */

      layoutScreen();
   }

   public static function isKeyDown(inCode:Int) { return mKeyDown[inCode]; } 

   public static function addScreen(inName:String,inScreen:Screen)
   {
      mScreenMap.set(inName,inScreen);
   }

   static function get_screen() { return mCurrentScreen; }

   static function getCurrentWindow() : Window
   {
      return  mCurrentPopup!=null ? mCurrentPopup :
              mCurrentDialog!=null ? mCurrentDialog :
              mCurrentScreen;
   }

   public static function onMouseMove(inEvent)
   {
      var window = getCurrentWindow();
      if (window!=null)
      {
         var pos = window.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         window.onMouseMove(pos.x,pos.y);
      }
   }

   public static function filterMouseEvent(inEvent:MouseEvent,inCloseIfNeeded:Bool)
   {
      if (mCurrentPopup!=null)
      {
         var target:DisplayObject = inEvent.target;
         var found = false;
         while(target!=null && !found)
         {
            found = target==mCurrentPopup;
            target = target.parent;
         }

         if (!found)
         {
            if (inCloseIfNeeded)
               closePopup();
            inEvent.stopImmediatePropagation();
         }
      }
      else if (mCurrentDialog!=null)
      {
         var target:DisplayObject = inEvent.target;
         var found = false;
         while(target!=null && !found)
         {
            found = target==mCurrentDialog;
            target = target.parent;
         }

         if (!found)
         {
            if (mCurrentDialog.shouldConsumeEvent==null ||
                 mCurrentDialog.shouldConsumeEvent(inEvent))
            {
               if (inCloseIfNeeded && mAutoCloseDialog)
                  closeDialog();
               inEvent.stopImmediatePropagation();
            }
         }
      }
   }

   public static function onPreMouseDown(inEvent:MouseEvent)
   {
      filterMouseEvent(inEvent,true);
   }

   public static function onPreMouseMove(inEvent:MouseEvent)
   {
      filterMouseEvent(inEvent,false);
   }

   public static function onPreMouseUp(inEvent:MouseEvent)
   {
      filterMouseEvent(inEvent,true);
   }


   public static function onMouseDown(inEvent:MouseEvent)
   {
      var window = getCurrentWindow();
      if (window!=null)
      {
         var pos = window.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         window.onMouseDown(pos.x,pos.y);
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


   public static function onMouseClick(inEvent)
   {
      if (mCurrentScreen!=null)
      {
         var pos = mCurrentScreen.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         mCurrentScreen.onMouseClick(pos.x,pos.y);
      }
   }


   public static function removeTween(inName:String, inWithCallback = true)
   {
      if (mCurrentScreen!=null)
         mCurrentScreen.timeline.remove(inName,inWithCallback);
   }

   public static function tween(inName:String,inVal0:Float,inVal1:Float,
                     inSeconds:Float,
                     inOnUpdate:Float->Void,
                     ?inOnComplete:Void->Void,
                     ?inEasing:Float->Float )
   {
      if (mCurrentScreen!=null)
      {
         mCurrentScreen.timeline.createTween(inName, inVal0, inVal1,
             inSeconds, inOnUpdate, inOnComplete, inEasing );
      }
      else
      {
         inOnUpdate(inVal1);
         if (inOnComplete!=null)
            inOnComplete();
      }
   }


   public static function layoutScreen()
   {
      if (mCurrentScreen!=null)
      {
         var layout = mCurrentScreen.getLayout();
         if (layout!=null)
         {
            var stage = nme.Lib.current.stage;
            layout.setRect(0,0,stage.stageWidth, stage.stageHeight);
            stage.invalidate();
         }
      }
   }
 

   static public function pushScreen(inScreen:Screen)
   {
      screenStack.push(mCurrentScreen);
      setCurrentScreen(inScreen);
   }

   static public function popScreen():Bool
   {
      if (screenStack.length==0)
         return false;
      setCurrentScreen(screenStack.pop());
      return true;
   }


   static public function setCurrentScreen(inScreen:Screen)
   {
      if (mCurrentScreen==inScreen)
         return;

      if (mCurrentScreen!=null)
      {
         mCurrentScreen.timeline.onActivate(false);
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
         mCurrentScreen.timeline.onActivate(true);
         mCurrentScreen.onActivate(true);
         updateScale();

         if (mCurrentDialog==null)
         {
            if (mCurrentScreen.wantsCursor())
               nme.ui.Mouse.show();
            else
               nme.ui.Mouse.hide();
         }

         layoutScreen();
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

   static function updateDialogGrey()
   {
      var s = mCurrentScreen.stage;
      if (s!=null && mDialogGrey.visible)
      {
         var gfx = mDialogGrey.graphics;
         gfx.clear();
         gfx.beginFill(0x000000,0.25);
         gfx.drawRect(0,0,s.stageWidth, s.stageHeight);
      }
   }


   static function updateScale()
   {
      if (mCurrentScreen!=null)
      {
         var scale = 1.0;
         var stage = mCurrentScreen.stage;
         var stage_width = stageWidth();
         var stage_height = stageHeight();
   
         var sw = stage_width / safeWidth;
         var sh = stage_height / safeHeight;
         scale = sw < sh ? sw : sh;
         var graphics_scale = scale;

         var mode = mCurrentScreen.getScaleMode();
         var px = 0;
         var py = 0;
         if (mode==ScreenScaleMode.TOPLEFT_UNSCALED)
         {
            scale =1.0;
         }
         else if (mode==ScreenScaleMode.PIXEL_PERFECT)
         {
            px = Std.int((stage_width  - initWidth*scale)/2);
            py = Std.int((stage_height - initHeight*scale)/2);
            scale =1.0;
         }
         else
         {
            px = Std.int( (stage_width  - initWidth*scale)/2);
            py = Std.int( (stage_height - initHeight*scale)/2);
         }

         mScreenParent.x = px;
         mScreenParent.y = py;

         screenWidth = Std.int(stage_width * scale);
         screenHeight = Std.int(stage_height * scale);

         mScreenParent.scaleX = scale;
         mScreenParent.scaleY = scale;

         #if flash
         var dlgScale = 1.0;
         #else
         var dlgScale = mCurrentScreen.stage.dpiScale;
         #end
         mDialogParent.x = Std.int( (stage_width  - initWidth*dlgScale)/2);
         mDialogParent.y = Std.int( (stage_height - initHeight*dlgScale)/2);
         mDialogParent.scaleX = dlgScale;
         mDialogParent.scaleY = dlgScale;

         mPopupParent.x = px;
         mPopupParent.y = py;
         mPopupParent.scaleX = scale;
         mPopupParent.scaleY = scale;

         mCurrentScreen.scaleScreen(graphics_scale);
      }
   }

   static function get_showFPS() { return mShowFPS; } 
   static function set_showFPS(inShowFPS:Bool) : Bool
   {
      mShowFPS = inShowFPS;
      if (mFPSControl!=null)
         mFPSControl.visible = mShowFPS;
      return inShowFPS;
   }

   static function get_fpsColor() { return mFPSColor; } 
   static function set_fpsColor(inCol:Int) : Int
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

   static function onEnter(_) update();

   public static function update()
   {
      var now = haxe.Timer.stamp();
      var big_gap = now>mLastEnter+gapDetect;
      if (mCurrentScreen!=null)
      {
         mCurrentScreen.updateTimeline(big_gap ? gapReplace : now-mLastEnter);
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
            if (big_gap)
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
      mKeyDown[event.keyCode] = true;

      if (toggleFullscreenOnAltEnter && event.keyCode==13 && event.altKey)
         toggleFullscreen();

      var used = false;
      if (mCurrentPopup!=null)
          used = mCurrentPopup.onKeyDown(event);

      if (!used && mCurrentDialog!=null)
          used = mCurrentDialog.onKeyDown(event);

      if (!used && mCurrentScreen!=null)
         used = mCurrentScreen.onKeyDown(event);
   }

   static function onKeyUp(event:KeyboardEvent )
   {
      mKeyDown[event.keyCode] = false;

      var used = false;
      //if (mCurrentDialog!=null) mCurrentDialog.onKeyUp(event); else


      if (mapEscapeToBack && event.keyCode==27 )
      {
         if (mCurrentPopup!=null)
         {
            closePopup();
            event.stopPropagation();
            return;
         }
         else if (mCurrentDialog!=null && mAutoCloseDialog)
         {
            mCurrentDialog.goBack();
            event.stopPropagation();
            return;
         }
         else if (mCurrentScreen!=null)
         {
            if (mCurrentScreen.goBack())
            {
               event.stopPropagation();
               return;
            }
         }
      }
      else if (mCurrentScreen!=null)
         mCurrentScreen.onKeyUp(event);


   }


   static function set_title(inTitle:String) : String
   {
      title = inTitle;
      return inTitle;
   }

   static function set_debugLayout(inValue:Bool) : Bool
   {
      if (mDebugOverlay!=null)
      {
         mDebugOverlay.graphics.clear();
         if (inValue)
            gm2d.ui.Layout.setDebugObject(mDebugOverlay);
         else
            gm2d.ui.Layout.setDebugObject(null);
         mDebugOverlay.visible = inValue;
         return inValue;
      }
      return false;
   }

   static function get_debugLayout() : Bool
   {
      return mDebugOverlay!=null && mDebugOverlay.visible;
   }

   static function set_icon(inIcon:String) : String
   {
      icon = inIcon;
      return inIcon;
   }


   public static function addDialog(inName:String, inDialog:Dialog)
   {
      mDialogMap.set(inName,inDialog);
   }


   static public function showDialog(inDialog:String,inCenter:Bool=true,inAutoClose=true) : Dialog
   {
      var dialog:Dialog = mDialogMap.get(inDialog);
      if (dialog==null)
         throw "Invalid Dialog "+  inDialog;
      doShowDialog(dialog,inCenter, inAutoClose);
      return dialog;
   }

   static public function closeDialog()
   {
      doShowDialog(null,false);
   }

   static public function doShowDialog(inDialog:Dialog,inCenter:Bool, inAutoClose = true)
   {
      closePopup();
      mAutoCloseDialog = inAutoClose;
      if (mCurrentDialog!=null)
      {
         mCurrentDialog.onClose();
         mDialogParent.removeChild(mCurrentDialog);
         mCurrentDialog = null;
         if (mCurrentScreen!=null && inDialog==null)
            mCurrentScreen.setRunning(true);
         mScreenParent.mouseEnabled = true;
         mDialogGrey.visible = false;
      }

      mCurrentDialog = inDialog;

      if (mCurrentDialog!=null)
      {
         if (mCurrentScreen!=null)
            mCurrentScreen.setRunning(false);
         mScreenParent.mouseEnabled = false;
         mDialogParent.addChild(mCurrentDialog);
         mCurrentDialog.onAdded();
         //mCurrentDialog.doLayout();
         if (inCenter)
            mCurrentDialog.center(initWidth,initHeight);
      }

      mDialogParent.visible = mCurrentDialog!=null;
      mDialogGrey.visible = mCurrentDialog!=null;
      updateDialogGrey();
   }

   public static function messageBox( inData:{title:String,label:String }, ?inAttribs:{} )
   {
      var panel = new gm2d.ui.Panel(inData.title);
      panel.addLabel(inData.label);
      panel.addTextButton("Ok", Game.closeDialog );
      var dialog = new Dialog(panel.getPane(),inAttribs);
      doShowDialog(dialog,true);
   }


   public static function inputBox(inData:{ title:String, label:String, ?value:String, onOk:String->Void }, ?inAttribs:{} )
   {
      var panel = new gm2d.ui.Panel(inData.title);
      var input = new TextInput( inData.value );
      panel.addLabelUI(inData.label, input);
      panel.addTextButton("Ok", function() { Game.closeDialog(); inData.onOk(input.text); } );
      panel.addTextButton("Cancel", Game.closeDialog );
      var dialog = new Dialog(panel.getPane(),inAttribs);
      doShowDialog(dialog,true);
   }


   public static function popup(inPopup:Window,?inX:Float,?inY:Float, ?inOnClosePopup:Void->Void)
   {
       closePopup();

       onClosePopup = inOnClosePopup;
       mCurrentPopup = inPopup;
       mPopupParent.addChild(inPopup);
       var w = inPopup.getWindowWidth();
       var h = inPopup.getWindowHeight();
       if (inX==null)
          inX = Std.int( (stageWidth()-w) * 0.5 );
       if (inY==null)
          inY = Std.int( (stageHeight()-h) * 0.5 );

       var asPopup:PopupMenu = cast inPopup;

       var pos = mPopupParent.localToGlobal( new Point(inX+w,inY+h) );
       if (pos.x>mPopupParent.stage.stageWidth)
          inX -= (pos.x-stageWidth()) / mPopupParent.scaleX;
       var clipY = pos.y-mPopupParent.stage.stageHeight;
       if (clipY>0)
       {
          if (asPopup!=null)
          {
             h -= clipY;
             inPopup.setRect(0,0,w,h);
          }
          else
          {
             inY -= clipY;
          }
       }

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
       invalidate();
   }

   public static function moveToPopupLayer(inObject:DisplayObject)
   {
      mPopupParent.addChild(inObject);
   }

   public static function closePopup()
   {
     if (mCurrentPopup!=null)
     {
         if (onClosePopup!=null)
         {
            var cb = onClosePopup;
            onClosePopup = null;
            cb();
         }
 
         mPopupParent.removeChild(mCurrentPopup);
         mCurrentPopup.destroy();
         mCurrentPopup = null;
      }
      mPopupParent.visible = false;
      mDialogParent.mouseEnabled = true;
      mScreenParent.mouseEnabled = true;
      invalidate();
   }


   public static function close()
   {
      #if !flash
      nme.Lib.close();
      #end
   }


   public static function isDown(inCode:Int) : Bool { return mKeyDown[inCode]; }

/*
   static function onUpdate(e:nme.events.Event)
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
*/

   static function onSize(e:Event)
   {
      setStageTransform();
      updateScale();
      updateDialogGrey();
   }


}
