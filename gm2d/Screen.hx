package gm2d;

import gm2d.Game;
import gm2d.ui.Dialog;
import gm2d.events.MouseEvent;
import gm2d.events.KeyboardEvent;
import gm2d.ui.Keyboard;

class Screen extends gm2d.ui.Window
{
   var mPaused:Bool;

   public function new()
   {
	   Game.create();
      mPaused = false;
      name = "Screen";
      super();
   }

   public function makeCurrent()
   {
      Game.setCurrentScreen(this);
   }


   public function setRunning(inRun:Bool)
   {
      mPaused = !inRun;
      setActive(inRun);
   }
   public function isPaused() { return mPaused; }

   public function onActivate(inActive:Bool) { }
   public function getUpdateFrequency() { return 0.0; }
   public function updateDelta(inDT:Float) {  }
   public function updateFixed() {  }
   public function render(inFraction:Float) {  }
   public function wantsCursor() : Bool { return true; }
   public function goBack() : Void { Game.close(); }

   public function getScaleMode() : ScreenScaleMode { return ScreenScaleMode.CENTER_SCALED; }

   function setScreen(inName:String) { return Game.setScreen(inName); }
   function showDialog(inName:String) { Game.showDialog(inName); }

   function isDown(inCode:Int) { return Game.isDown(inCode); }


   public function scaleScreen(inScale:Float) { }

}


