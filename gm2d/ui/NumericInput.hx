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
   public var onUpdate:Float->Int->Void;
   public var onEnter:Float->Void;
   var min:Float;
   var max:Float;
   var step:Float;
   var slider:Sprite;
   var sliderX:Float;
   var sliderWatcher:MouseWatcher;
   var value:Float;
   static var SLIDER_W = 22;

   public function new(inVal:Float,inInteger:Bool,inMin:Float, inMax:Float, inStep:Float,
      ?inOnUpdateFloat:Float->Int->Void)
   {
      min = inMin;
      max = inMax;
      value = inVal;
      if (value<min)
         value = min;
      if (value>max)
         value = max;
      super(Std.string(value),onUpdateText);
      step = inStep;
      slider = new Sprite();
      slider.name = "Numeric slider";
      slider.cacheAsBitmap = true;
      onUpdate = inOnUpdateFloat;
      addChild(slider);
      slider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderDown );
      renderSlider();
   }

   public function setValue(inValue:Float) : Void
   {
      var v = inValue;
      if (v<min) v = min;
      if (v>max) v = max;
      if (v!=value)
      {
         value = v;
         mText.text = Std.string(value);
      }
   }

   function onSliderDown(e:MouseEvent)
   {
      var pos = slider.localToGlobal( new Point(0,0) );
      stage.addChild(slider);
      slider.x = pos.x;
      slider.y = pos.y;
      sliderWatcher = new MouseWatcher(slider, null, onSliderDrag, onSliderUp,
          pos.x, pos.y+e.localY, false );
      if (onUpdate!=null)
         onUpdate(value,Phase.BEGIN);
   }

   function onSliderDrag(e:MouseEvent)
   {
      var dy = sliderWatcher.pos.y - sliderWatcher.prevPos.y;
      slider.y += dy;
      value -= dy*step;
      if (value<min) value = min;
      if (value>max) value = max;
      mText.text = Std.string(value);
      if (onUpdate!=null)
         onUpdate(value,Phase.UPDATE);
   }
   function onSliderUp(e:MouseEvent)
   {
      addChild(slider);
      slider.x = sliderX;
      slider.y = 0;
      sliderWatcher = null;
      if (onEnter!=null)
         onEnter(value);
      if (onUpdate!=null)
         onUpdate(value,Phase.END);
   }

   function renderSlider()
   {
      var gfx = slider.graphics;
      gfx.clear();
      gfx.lineStyle(1,0x000040);
      gfx.beginFill(0xffffff);
      gfx.drawRoundRect(1.5,1.5,20,20,7,7);
   }

   function onUpdateText(inText:String)
   {
      var v = Std.parseFloat(inText);
      if (v!=value)
      {
         value = v;
         if (value<min)
         {
            value = min;
            mText.text = Std.string(value);
         }

         if (value>max)
         {
            value = max;
            mText.text = Std.string(value);
         }

         if (onEnter!=null)
            onEnter(value);
         else if (onUpdate!=null)
            onUpdate(value,Phase.ALL);
      }
   }

   public override function layout(inW:Float, inH:Float)
   {
      super.layout(inW-SLIDER_W, inH);
      sliderX = slider.x = Std.int(inW-SLIDER_W);
   }
}
