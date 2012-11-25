package gm2d.ui;

import gm2d.text.TextField;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.events.MouseEvent;
import gm2d.ui.Button;
import gm2d.skin.Skin;

class NumericInput extends TextInput
{
   var onUpdateFloat:Float->Void;
   var min:Float;
   var max:Float;
   var step:Float;
   var slider:Sprite;
   static var SLIDER_W = 22;

   public function new(inVal:Float,inInteger:Bool,inMin:Float, inMax:Float, inStep:Float,
      ?onUpdate:Float->Void)
   {
      super(Std.string(inVal),onUpdateText);
      min = inMin;
      max = inMax;
      step = inStep;
      slider = new Sprite();
      addChild(slider);
      renderSlider();
   }

   function renderSlider()
   {
      var gfx = slider.graphics;
      gfx.clear();
      gfx.lineStyle(1,0x000040);
      gfx.beginFill(0xffffff);
      gfx.drawRect(5.5,5.5,11,11);
   }

   function onUpdateText(inText:String)
   {
      if (onUpdateFloat!=null)
      {
         onUpdateFloat( Std.parseFloat(inText) );
      }
   }

   public override function layout(inW:Float, inH:Float)
   {
      super.layout(inW-SLIDER_W, inH);
      slider.x = inW-SLIDER_W;
   }
}
