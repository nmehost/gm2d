package gm2d.game;

import flash.events.Event;
import flash.events.KeyboardEvent;
import gm2d.ui.Dialog;

class Game extends flash.display.Sprite
{
   var mScreen:Screen;
   var mDialogScreen:Screen;
   var mDialog:Dialog;
   var mKeyDown:Array<Bool>;
   var mLastStep:Float;
   var mLastEnter:Float;
   var mScreenMap:Hash<Screen>;
   var mDialogMap:Hash<Dialog>;
   var mResources:Resources;

   public function new()
   {
      super();
      #if !flash
      neash.Lib.mQuitOnEscape = false;
      #end
      flash.Lib.current.addChild(this);
      stage.stageFocusRect = false;
      stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

      stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown );
      stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp );
      stage.addEventListener(Event.ENTER_FRAME, OnEnter);
      stage.addEventListener(Event.RESIZE, OnSize);


      mLastEnter = haxe.Timer.stamp();
      mLastStep = mLastEnter;
      mScreen = null;
      mDialog = null;
      mKeyDown = [];

      mScreenMap = new Hash<Screen>();
      mDialogMap = new Hash<Dialog>();
      Screen.SetGame(this);
   }

   function SetResources(inResources:Resources) { mResources = inResources; }


   function AddScreen(inName:String, inScreen:Screen) { mScreenMap.set(inName,inScreen); }
   function AddDialog(inName:String, inDialog:Dialog) { mDialogMap.set(inName,inDialog); }

   public function Resource(inName:String) { return mResources.get(inName); }
   public function FreeResource(inName:String) { return mResources.remove(inName); }

   public function IsDown(inCode:Int) : Bool { return mKeyDown[inCode]; }



   function OnKeyDown(event:flash.events.KeyboardEvent )
   {
      if (mDialog!=null)
         mDialog.OnKeyDown(event);
      else if (mScreen!=null)
         mScreen.OnKeyDown(event);
      mKeyDown[event.keyCode] = true;
   }

   function OnKeyUp(event:flash.events.KeyboardEvent )
   {
      if (mDialog==null && mScreen!=null)
         mScreen.OnKeyUp(event);
      mKeyDown[event.keyCode] = false;
   }

   function OnEnter(e:flash.events.Event)
   {
      var now = haxe.Timer.stamp();
      if (mScreen!=null)
      {
         var freq = mScreen.GetUpdateFrequency();
         if (freq<=0)
         {
            mScreen.UpdateDelta(now-mLastEnter);
            mScreen.Render(0);
            mLastEnter = now;
         }
         else
         {
            var fps = 1.0/(now-mLastEnter);

            // Do a number of descrete steps based on the frequency.
            var steps = Math.floor( (now-mLastStep) * freq );
            for(i in 0...steps)
               mScreen.UpdateFixed();

            mLastStep += steps / freq;


            var fractional_step = (now-mLastStep) * freq;

            mScreen.Render(fractional_step);

            //hxcpp.Lib.println(steps + ":" + fps + "   (" + fractional_step + ")");

         }
      }
      mLastEnter = now;
   }

   public function SetScreen(inScreen:String)
   {
      var screen:Screen = mScreenMap.get(inScreen);
      if (screen==null)
         throw "Invalid Screen "+  inScreen;

      CloseDialog();

      mLastEnter = haxe.Timer.stamp();
      if (mScreen!=null)
      {
         removeChild(mScreen);
         mScreen = null;
      }

      mScreen = screen;

      addChildAt(mScreen,0);
      mScreen.OnAdded();
      mScreen.Layout(stage.stageWidth,stage.stageHeight);
   }

   public function ShowDialog(inDialog:String)
   {
      var dialog:Dialog = mDialogMap.get(inDialog);
      if (dialog==null)
         throw "Invalid Dialog "+  inDialog;
      DoShowDialog(dialog);
   }

   public function CloseDialog() { DoShowDialog(null); }

   function DoShowDialog(inDialog:Dialog)
   {
      if (mDialog!=null)
      {
         mDialog.onClose();
         mDialogScreen.removeChild(mDialog);
         mDialog = null;
      }

      mDialog = inDialog;

      if (mDialog!=null)
      {
         if (mScreen==null)
            throw "Can't add a dialog without a screen.";

         mDialogScreen = mScreen;
         mDialogScreen.addChild(mDialog);
         mDialog.onAdded();
         mDialog.DoLayout();
      }
   }

   function OnSize(e:Event)
   {
      if (mScreen!=null)
         mScreen.Layout(stage.stageWidth,stage.stageHeight);
   }


}
