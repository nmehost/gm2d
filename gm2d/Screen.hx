package gm2d;

import gm2d.Game;
import gm2d.ui.ItemList;
import gm2d.ui.Dialog;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

class Screen extends flash.display.Sprite
{
   public var screenName(default,null):String;
 
   var mMarginX:Float;
   var mMarginY:Float;
   var mNominalWidth:Float;
   var mNominalHeight:Float;
   var mItems:gm2d.ui.ItemList;

   public function new(inName:String)
   {
      super();

      screenName = inName;

      mItems = new ItemList(this);

      Game.gm2dAddScreen(this);
   }

   public function makeCurrent()
   {
      Game.setCurrentScreen(this);
   }

   public function onActivate(inActive:Bool) { }
   public function getUpdateFrequency() { return 0.0; }
   public function updateDelta(inDT:Float) { return 0.0; }
   public function updateFixed() {  }
   public function renderFixedExtra(inFraction:Float) {  }

#if false
   public function OnKeyUp(event:flash.events.KeyboardEvent ) { }
   public function OnAdded() { }



   // These are not static, even though they could be.
   // This allows non-static function to see them
   function Resource(inName:String) { return mGame.Resource(inName); }
   function FreeResource(inName:String) { return mGame.FreeResource(inName); }
   function SetScreen(inName:String) { return mGame.SetScreen(inName); }
   function ShowDialog(inName:String) { mGame.ShowDialog(inName); }

   static public function SetGame(inGame : Game) { Screen.mGame = inGame; }
   function IsDown(inCode:Int) { return mGame.IsDown(inCode); }

   public function OnKeyDown(event:flash.events.KeyboardEvent ) : Bool
   {
      if (mItems.OnKeyDown(event))
         return true;
      return false;
   }


   public function OnKeyUp(event:flash.events.KeyboardEvent ) { }
   public function OnAdded() { }
   public function GetUpdateFrequency() { return 0.0; }
   public function UpdateDelta(inDT:Float) { }
   public function UpdateFixed() { }
   public function Render(inExtra:Float) { }

   public function ScaleScreen(inScale:Float)
   {
      scaleX = scaleY = inScale;
   }

   public function setCurrent(inItem:gm2d.ui.Base) { mItems.setCurrent(inItem); }
   public function addUI(inItem:gm2d.ui.Base) { mItems.addUI(inItem); }

   public function Layout(inW:Int,inH:Int)
   {
      // Width-limited
      if (inW*mNominalHeight < inH*mNominalWidth)
      {
         mMarginX = 0;
         var h = inW*mNominalHeight/mNominalWidth;
         mMarginY = (h-inH) * 0.5;
         x = 0;
         y = -mMarginY;

         ScaleScreen(inW/mNominalWidth);
      }
      // Height-limited
      else
      {
         mMarginY = 0;
         var w = (inH*mNominalWidth/mNominalHeight);
         mMarginX = (w-inW) * 0.5;
         y = 0;
         x = -mMarginX;

         ScaleScreen(inH/mNominalHeight);
      }
   }
#end
}


