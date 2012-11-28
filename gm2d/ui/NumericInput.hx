package gm2d.ui;

import gm2d.text.TextField;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.events.MouseEvent;
import gm2d.ui.Button;
import gm2d.geom.Point;
import gm2d.skin.Skin;

class NumericInput extends TextInput
{
   var onUpdateFloat:Float->Void;
   var min:Float;
   var max:Float;
   var step:Float;
   var slider:Sprite;
   var sliderX:Float;
   var sliderWatcher:MouseWatcher;
   static var SLIDER_W = 22;

   public function new(inVal:Float,inInteger:Bool,inMin:Float, inMax:Float, inStep:Float,
      ?inOnUpdateFloat:Float->Void)
   {
      super(Std.string(inVal),onUpdateText);
      min = inMin;
      max = inMax;
      step = inStep;
      slider = new Sprite();
      onUpdateFloat = inOnUpdateFloat;
      addChild(slider);
      slider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderDown );
      renderSlider();
   }


   function onSliderDown(e:MouseEvent)
   {
      var pos = slider.localToGlobal( new Point(0,0) );
      stage.addChild(slider);
      slider.x = pos.x;
      slider.y = pos.y;
      sliderWatcher = new MouseWatcher(slider, null, onSliderDrag, onSliderUp,
          pos.x, pos.y+e.localY, false );
   }

   function onSliderDrag(e:MouseEvent)
   {
      var dy = sliderWatcher.pos.y - sliderWatcher.prevPos.y;
      slider.y += dy;
      var val = Std.parseFloat(mText.text);
      val -= dy*step;
      if (val<min) val = min;
      if (val>max) val = max;
      mText.text = Std.string(val);
      if (onUpdateFloat!=null)
         onUpdateFloat(val);
   }
   function onSliderUp(e:MouseEvent)
   {
      addChild(slider);
      slider.x = sliderX;
      slider.y = 0;
      sliderWatcher = null;
   }

   function renderSlider()
   {
      var gfx = slider.graphics;
      gfx.clear();
      gfx.lineStyle(1,0x000040);
      gfx.beginFill(0xffffff);
      gfx.drawRoundRect(1,1,20,20,5,5);
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
      sliderX = slider.x = inW-SLIDER_W;
   }
}
