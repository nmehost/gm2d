package gm2d;

import gm2d.Game;
import gm2d.ui.Dialog;
import gm2d.ui.Widget;
import gm2d.ui.Layout;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;
import gm2d.tween.Timeline;
import gm2d.input.Input;
import gm2d.skin.Skin;

class Screen extends gm2d.ui.Window
{
   var mPaused:Bool;
   public var timeline(default,null):Timeline;
   public var controller(default,set):Input;


   public function new(?inSkin:Skin, ?inLineage:Array<String>, ?inAttribs:Dynamic )
   {
      Game.create();
      mPaused = false;
      timeline = new Timeline();
      super(inSkin,Widget.addLine(inLineage,"Screen"),inAttribs);
   }

   public function makeCurrent()
   {
      applyStyles();
      Game.setCurrentScreen(this);
      relayout();
   }

   public function screenLayout(w:Int, h:Int)
   {
      if (controller!=null)
         controller.layout(w,h);
   }

   override public function relayout()
   {
      super.relayout();
      if (stage!=null)
      {
         screenLayout( stage.stageWidth, stage.stageHeight );
      }
   }

   public function set_controller(inController:Input)
   {
      if (controller!=null)
      {
         removeChild(controller);
         if (Game.screen==this)
         {
            controller.onActivate(this,false);
            controller.setRunning(false);
         }
      }

      controller = inController;

      if (controller!=null)
      {
         addChild(controller);
         if (Game.screen==this)
         {
            controller.setRunning(true);
            controller.onActivate(this,true);
         }
      }
      return inController;
   }


   public function setRunning(inRun:Bool)
   {
      mPaused = !inRun;
      setActive(inRun);
   }
   public function isPaused() { return mPaused; }

   public function onActivate(inActive:Bool)
   {
      if (controller!=null)
         controller.onActivate(this,inActive);
   }
   public function getUpdateFrequency() { return 0.0; }
   public function onUpdated()
   {
      if (controller!=null)
         controller.onUpdated();
   }
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
   public function closeIfDialog() { }

   public function getScaleMode() : ScreenScaleMode { return ScreenScaleMode.TOPLEFT_UNSCALED; }

   function setScreen(inName:String) { return Game.setScreen(inName); }
   function showDialog(inName:String) { Game.showDialog(inName); }

   function isDown(inCode:Int) { return Game.isDown(inCode); }

   public function onStageActivate(inActive:Bool)
   {
   }

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
      if (stage!=null)
         screenLayout( stage.stageWidth, stage.stageHeight );
   }

   


}


