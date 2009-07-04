package gm2d.game;
import gm2d.ui.ItemList;
import gm2d.ui.Dialog;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

class Screen extends flash.display.Sprite
{
   static var mGame : Game;
   var mMarginX:Float;
   var mMarginY:Float;
   var mNominalWidth:Float;
   var mNominalHeight:Float;
   var mItems:gm2d.ui.ItemList;

   public function new()
   {
      super();
      mNominalWidth = 640;
      mNominalHeight = 480;
      mMarginX = 0;
      mMarginY = 0;
      mItems = new ItemList(this);
   }

   // These are not static, even though they could be.
   // This allows non-static function to see them
   function Resource(inName:String) { return mGame.Resource(inName); }
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
}


