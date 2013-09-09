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
   var qvalue:Float;
   var isInteger:Bool;
   static var SLIDER_W = 22;

   public function new(inVal:Float,inIsInteger:Bool,inMin:Float, inMax:Float, inStep:Float,
      ?inOnUpdateFloat:Float->Int->Void)
   {
      isInteger = inIsInteger;
      min = inMin;
      max = inMax;
      value = inVal;
      if (value<min)
         value = min;
      if (value>max)
         value = max;
      qvalue = isInteger ? Std.int(value) : value;
      super(Std.string(qvalue),onUpdateText);
      step = inStep;
      slider = new Sprite();
      slider.name = "Numeric slider";
      slider.cacheAsBitmap = true;
      onUpdate = inOnUpdateFloat;
      addChild(slider);
      slider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderDown );
      renderSlider();
   }

   public function getValue() : Float
   {
      return qvalue;
   }

   public function setValue(inValue:Float) : Void
   {
      var v = inValue;
      if (v<min) v = min;
      if (v>max) v = max;
      if (isInteger)
         v = Std.int(v);
      if (v!=qvalue)
      {
         qvalue = value = v;
         mText.text = Std.string(qvalue);
      }
   }

   public function setMinimum(inValue:Float)
   {
      min = inValue;
      if (value<min)
         setValue(min);
   }

   public function setMaximum(inValue:Float)
   {
      max = inValue;
      if (value>max)
         setValue(max);
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
         onUpdate(qvalue,Phase.BEGIN);
   }

   function onSliderDrag(e:MouseEvent)
   {
      var dy = sliderWatcher.pos.y - sliderWatcher.prevPos.y;
      slider.y += dy;
      value -= dy*step;
      if (value<min) value = min;
      if (value>max) value = max;
      var v = isInteger ? Std.int(value) : value;
      if (v!=qvalue)
      {
         qvalue = v;
         mText.text = Std.string(qvalue);
         if (onUpdate!=null)
            onUpdate(qvalue,Phase.UPDATE);
      }
   }
   function onSliderUp(e:MouseEvent)
   {
      addChild(slider);
      slider.x = sliderX;
      slider.y = 0;
      sliderWatcher = null;
      if (onEnter!=null)
         onEnter(qvalue);
      if (onUpdate!=null)
         onUpdate(qvalue,Phase.END);
   }

   function renderSlider()
   {
      var gfx = slider.graphics;
      gfx.clear();

      gfx.beginFill(0x000000,0.0);
      gfx.drawRect(0,0,22,22);
      gfx.endFill();

      gfx.lineStyle(1,0x000040);
      gfx.beginFill(0xffffff);
      //gfx.drawRoundRect(1.5,1.5,20,20,7,7);

      gfx.moveTo(3.5,9.5);
      gfx.lineTo(16.5,9.5);
      gfx.lineTo(10.5,1.5);
      gfx.lineTo(3.5,9.5);

      gfx.moveTo(3.5,12.5);
      gfx.lineTo(16.5,12.5);
      gfx.lineTo(10.5,20.5);
      gfx.lineTo(3.5,12.5);
   }

   function onUpdateText(inText:String)
   {
      var v = Std.parseFloat(inText);
      if (isInteger)
         v = Std.int(v);
      if (v!=qvalue)
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
         qvalue = value;

         if (onEnter!=null)
            onEnter(qvalue);
         else if (onUpdate!=null)
            onUpdate(qvalue,Phase.ALL);
      }
   }

   public override function layout(inW:Float, inH:Float)
   {
      super.layout(inW-SLIDER_W, inH);
      sliderX = slider.x = Std.int(inW-SLIDER_W);
   }
}
