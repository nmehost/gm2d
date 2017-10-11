package gm2d;

import gm2d.Game;
import gm2d.ui.Dialog;
import gm2d.ui.Widget;
import gm2d.ui.Layout;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import gm2d.tween.Timeline;

class Screen extends gm2d.ui.Window
{
   var mPaused:Bool;
   public var timeline(default,null):Timeline;

   public function new(?inLineage:Array<String>, ?inAttribs:Dynamic )
   {
	   Game.create();
      mPaused = false;
      timeline = new Timeline();
      super(Widget.addLine(inLineage,"Screen"),inAttribs);
   }

   public function makeCurrent()
   {
      applyStyles();
      relayout();
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
   public function updateTimeline(inDT:Float)
   {
      if (!mPaused)
         timeline.update(inDT);
   }
   public function updateDelta(inDT:Float) {  }
   public function updateFixed() {  }
   public function render(inFraction:Float) {  }
   public function wantsCursor() : Bool { return true; }
   public function goBack() : Bool
   {
      if (!Game.popScreen())
         Game.close();
      return true;
   }
   public function getTime() : Float
   {
      if (timeline==null)
         return 0.0;
      return timeline.time;
   }

   public function getScaleMode() : ScreenScaleMode { return ScreenScaleMode.TOPLEFT_UNSCALED; }

   function setScreen(inName:String) { return Game.setScreen(inName); }
   function showDialog(inName:String) { Game.showDialog(inName); }

   function isDown(inCode:Int) { return Game.isDown(inCode); }

   override public function setItemLayout(inLayout:Layout)
   {
      var layout = super.setItemLayout(inLayout);
      mLayout.setMinSize(Game.screenWidth, Game.screenHeight);
      mLayout.stretch();
      return layout;
   }


   public function scaleScreen(inScale:Float)
   {
      if (mLayout!=null)
      {
         mLayout.setMinSize(Game.screenWidth, Game.screenHeight);
         mLayout.setRect(0,0, Game.screenWidth, Game.screenHeight );
      }
   }

}


