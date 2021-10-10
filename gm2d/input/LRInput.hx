package gm2d.input;

import gm2d.Screen;
import gm2d.ui.*;
import gm2d.ui.Layout;
import gm2d.skin.Shape;
import nme.display.*;
import nme.events.*;
import nme.ui.Keyboard;

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

   var leftButton:Widget;
   var rightButton:Widget;

   public function new(inAutoKeyboard=true )
   {
      super();
      autoRepeatDirection = 0.0;
      autoKeyboard = inAutoKeyboard;
      controlLayout = createButtons();
   }

   function onLeftDown()
   {
      leftJustDown = true;
      if (onLeft!=null)
         onLeft();
   }

   function onRightDown()
   {
      rightJustDown = true;
      if (onRight!=null)
         onRight();
   }


   public function createButtons()
   {
      var layout = new StackLayout();

      var s = gm2d.skin.Skin.dpiScale;
      var rad = s * 30;

      var d = new Sprite();
      var gfx = d.graphics;
      gfx.lineStyle(s*2,0xff0000);
      gfx.beginFill(0xff0000,0.5);
      gfx.drawCircle(rad,rad,rad);
      leftButton = new Button(d, onLeftDown, {
         shape:ShapeNone,
         itemAlign: Layout.AlignLeft | Layout.AlignBottom,
         onState:(s) -> leftDown = (s & Widget.DOWN)!= 0,
         wantsFocus : false,
      });
      addChild(leftButton);
      layout.add(leftButton.getLayout().stretch());

      var d = new Sprite();
      var gfx = d.graphics;
      gfx.lineStyle(s*2,0xff0000);
      gfx.beginFill(0xff0000,0.5);
      gfx.drawCircle(rad,rad,rad);
      rightButton = new Button(d, onRightDown, {
         shape:ShapeNone,
         itemAlign: Layout.AlignRight | Layout.AlignBottom,
         onState:(s) -> rightDown = (s & Widget.DOWN)!= 0,
         wantsFocus : false,
      });
      addChild(rightButton);
      layout.add(rightButton.getLayout().stretch());

      return layout;
   }

   override public function onUpdated()
   {
      leftJustDown = false;
      rightJustDown = false;
   }

   public function showButtons(show:Bool)
   {
      leftButton.visible = show;
      rightButton.visible = show;
   }

   function onKeyDown(ev:KeyboardEvent)
   {
      if (ev.keyCode==Keyboard.LEFT)
      {
         onLeftDown();
         if (autoKeyboard)
            showButtons(false);
      }
      else if (ev.keyCode==Keyboard.RIGHT)
      {
         onRightDown();
         if (autoKeyboard)
            showButtons(false);
      }
   }

   function onKeyUp(ev:KeyboardEvent)
   {
   }

   function onMouseMove(m:MouseEvent)
   {
      if (autoKeyboard)
         showButtons(true);
   }

   override public function addEventListeners()
   {
      if (autoKeyboard)
      {
         eventStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
         eventStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
         eventStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      }
   }

   override public function removeEventListeners()
   {
      if (autoKeyboard)
      {
         eventStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
         eventStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
         eventStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      }
   }


}


