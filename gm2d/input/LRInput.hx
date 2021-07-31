package gm2d.input;

import gm2d.Screen;
import nme.display.*;
import nme.events.*;

class LRInput extends Input
{
   public var leftJustDown:Bool;
   public var rightJustDown:Bool;
   public var leftDown:Bool;
   public var rightDown:Bool;
   public var autoRepeatDirection:Float;
   public var autoKeyboard:Bool;

   public var onLeft:Void->Void;
   public var onRight:Void->Void;

   var leftButton:Sprite;
   var rightButton:Sprite;

   public function new(inAutoKeyboard=true )
   {
      super();
      autoRepeatDirection = 0.0;
      autoKeyboard = inAutoKeyboard;
      createButtons();
      addChild(leftButton);
      leftButton.addEventListener(MouseEvent.CLICK,(_) -> leftJustDown = true );
      addChild(rightButton);
      rightButton.addEventListener(MouseEvent.CLICK,(_) -> leftJustDown = true );
   }

   public function createButtons()
   {
      var s = gm2d.skin.Skin.dpiScale;
      var rad = s * 20;

      leftButton = new Sprite();
      var gfx = leftButton.graphics;
      gfx.lineStyle(s*2,0xff0000);
      gfx.beginFill(0xff0000,0.5);
      gfx.drawCircle(rad,rad,rad);
      rightButton = new Sprite();
      var gfx = rightButton.graphics;
      gfx.lineStyle(s*2,0xff0000);
      gfx.beginFill(0xff0000,0.5);
      gfx.drawCircle(rad,rad,rad);
   }

   override public function layout(w:Int, h:Int)
   {
      var border = 10;
      leftButton.x = border;
      leftButton.y = h - border - leftButton.height;

      rightButton.x = w - border - rightButton.width;
      rightButton.y = h - border - rightButton.height;
   }

    
   override public function onUpdated()
   {
      leftJustDown = false;
      rightJustDown = false;
   }

   function onKeyDown(ev:KeyboardEvent)
   {
   }

   function onKeyUp(ev:KeyboardEvent)
   {
   }

   override public function addEventListeners()
   {
      if (autoKeyboard)
      {
         eventStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
         eventStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
      }
   }

   override public function removeEventListeners()
   {
      if (autoKeyboard)
      {
         eventStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
         eventStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
      }
   }


}


