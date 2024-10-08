package gm2d.ui;

import nme.text.TextField;
import nme.display.Sprite;
import nme.display.Shape;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.events.FocusEvent;
import gm2d.ui.Button;
import gm2d.ui.Layout;
import nme.geom.Point;
import nme.text.TextFieldType;
import gm2d.skin.Skin;

class NumericInput extends TextInput
{
   public static inline var INLINE_SLIDE = 0;
   public static inline var TEXT         = 1;
   public static inline var CENTRE_DRAG  = 2;

   public var onUpdate:Float->Int->Void;
   public var onEnter:Float->Void;
   public var popupMode:Int;
   public var quantization:Float;
   public var maxBar:Float;
   public var minBar:Float;
   public var value(get,set):Float;
   public var handler(default,set):AdoHandler<Float>;

   var underlay:Shape;
   var min:Float;
   var max:Float;
   var step:Float;
   var slider:Sprite;
   var sliderX:Float;
   var sliderWatcher:MouseWatcher;
   var textWatcher:MouseWatcher;
   var fullValue:Float;
   var restrictedValue:Float;
   var isInteger:Bool;
   var newDrag:Bool;
   var textChanged:Bool;
   var dynamicMax:Bool;
   var dynamicMin:Bool;
   var init:Bool;
   static var SLIDER_W = 22;


   public function new(inVal:Float,?inOnUpdateFloat:Float->Int->Void, ?inLineage:Array<String>, ?inAttribs:{} )
   {
      init = false;
      super(Std.string(inVal),onUpdateText, Widget.addLine(inLineage,"NumericInput"), inAttribs);

      isInteger = attribBool("isInteger",false);
      var minVal:Dynamic = attrib("minValue");
      if (minVal==null)
      {
         max = -1e20;
         dynamicMin = true;
      }
      else
      {
         dynamicMin = false;
         min = minVal;
      }

      var maxVal:Dynamic = attrib("maxValue");
      if (maxVal==null)
      {
         max = 1e20;
         dynamicMax = true;
      }
      else
      {
         dynamicMax = false;
         max = maxVal;
      }
      maxBar = max;
      minBar = min;
      fullValue = inVal;
      textChanged = false;
      if (fullValue<min)
         fullValue = min;
      if (fullValue>max)
         fullValue = max;
      restrictedValue = isInteger ? Std.int(fullValue) : fullValue;
      onUpdate = inOnUpdateFloat;
      step = attribFloat("step",0.1);
      quantization = 0.01;
      if (step>0)
         quantization = step;
      newDrag = false;
      popupMode = INLINE_SLIDE;
      if (popupMode==INLINE_SLIDE)
      {
         mText.type = nme.text.TextFieldType.DYNAMIC;
         textWatcher = MouseWatcher.create( mText, onTextDown, onTextDrag, onTextUp);
         textWatcher.minDragDistance = 10.0;
         mText.addEventListener(FocusEvent.FOCUS_OUT, function(_) setTextEditMode(false) );
      }
      init = true;
      if (restrictedValue!=inVal)
         setValue(restrictedValue);
      if (dynamicMax || dynamicMin)
         updateMinMax();
      else
         redrawBar();
   }

   override function alwaysPlaceholder() return true;


   override public function createUnderlay()
   {
      underlay = new Shape();
      addChild(underlay);
   }

   public function set_handler(inHandler:AdoHandler<Float>)
   {
      handler = inHandler;
      onUpdate = handler.onValue;
      handler.updateGui = setValue;
      return handler;
   }


   /*
   override public function createExtraWidgetLayout() : Layout
   {
      slider = new Sprite();
      slider.name = "Numeric slider";
      slider.cacheAsBitmap = true;
      addChild(slider);
      slider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderDown );
      renderSlider();
      return new DisplayLayout(slider);
   }
   */

   public function getValue() : Float
   {
      return restrictedValue;
   }

   inline public function get_value() : Float
   {
      return getValue();
   }

   function updateMinMax()
   {
      if (dynamicMin)
      {
         minBar = restrictedValue>-1 ? -5 : restrictedValue * 5;
         if (minBar>=max)
            minBar = max;
      }
      if (dynamicMax)
      {
         maxBar = restrictedValue<1 ? 5 : restrictedValue * 5;
         if (maxBar<=min)
            maxBar = min + 1;
      }

      redrawBar();
   }

   public function set_value(inValue:Float) : Float
   {
      setValue(inValue);
      updateMinMax();
      return restrictedValue;
   }


   public function getInt() : Int
   {
      return Std.int(restrictedValue);
   }


   public function setValue(inValue:Float) : Void
   {
      var v = inValue;
      if (!Math.isFinite(v))
         v = min;
      if (v<min) v = min;
      if (v>max) v = max;
      if (isInteger)
         v = Std.int(Math.round(v));
      if (quantization>0)
      {
         v = min + (Std.int((v-min)/quantization+0.5)*quantization);
      }

      if (v!=restrictedValue || textChanged)
      {
         textChanged = false;
         restrictedValue = fullValue = v;

         mText.text = Std.string(restrictedValue);
         redrawBar();
      }
   }
 
   public function onTextDown(e:MouseEvent)
   {
      newDrag = true;
   }

   public function onTextDrag(e:MouseEvent)
   {
      if (textWatcher.wasDragged)
      {
         setTextEditMode(false);
         var range =maxBar-minBar;
         if (range>0)
         {
            var x = mText.globalToLocal( new Point(e.stageX, e.stageY) ).x;
            setValue( x*range/mText.width + min );
         }

         if (onUpdate!=null)
            onUpdate(restrictedValue,newDrag ? Phase.BEGIN : Phase.UPDATE);
         newDrag = false;
      }
   }

   public function onTextUp(e:MouseEvent)
   {
      updateMinMax();

      if (!textWatcher.wasDragged && isInput)
         setTextEditMode(true);

      if (!newDrag && onUpdate!=null)
         onUpdate(restrictedValue,Phase.END);
   }

   public function setTextEditMode(inText:Bool)
   {
      var isText = mText.type == TextFieldType.INPUT;
      if (isText==inText)
         return;
 
      if (inText)
      {
         mText.type = TextFieldType.INPUT;
         stage.focus = mText;
         var len = mText.text.length;
         mText.setSelection(len, len);
      }
      else
      {
         mText.type = TextFieldType.DYNAMIC;
         setValue(Std.parseFloat(mText.text));
      }
      redrawBar();
   }




   public function setMinimum(inValue:Float)
   {
      min = inValue;
      if (fullValue<min)
         setValue(min);
      redrawBar();
   }

   public function setMaximum(inValue:Float)
   {
      max = inValue;
      dynamicMax = false;
      maxBar = inValue;
      if (fullValue>max)
         setValue(max);
      redrawBar();
   }

   function redrawBar()
   {
      if (!init)
         return;
      underlay.x = mText.x;
      underlay.y = mText.y;
      var gfx = underlay.graphics;
      var range = maxBar-minBar;
      if (range>0)
      {
         gfx.clear();
         gfx.beginFill(0xc0c0c0,1);
         var val = restrictedValue<maxBar ? fullValue : maxBar;
         if (val<min)
            val = min;
         if (val-min > range)
            val = min+range;
         gfx.drawRect(1,1,(mText.width-2) * (val-min) / range, mText.height-2 );
      }
   }

/*
   function onSliderDown(e:MouseEvent)
   {
      var pos = slider.localToGlobal( new Point(0,0) );
      stage.addChild(slider);
      slider.x = pos.x;
      slider.y = pos.y;
      sliderWatcher = new MouseWatcher(slider, null, onSliderDrag, onSliderUp,
          pos.x, pos.y+e.localY, false );
      if (onUpdate!=null)
         onUpdate(restrictedValue,Phase.BEGIN);
   }

   function onSliderDrag(e:MouseEvent)
   {
      var dy = sliderWatcher.pos.y - sliderWatcher.prevPos.y;
      slider.y += dy;
      fullValue -= dy*step;
      if (fullValue<min) fullValue = min;
      if (fullValue>max) fullValue = max;
      var v = isInteger ? Std.int(fullValue) : fullValue;
      if (v!=restrictedValue)
      {
         restrictedValue = v;
         redrawBar();
         mText.text = Std.string(restrictedValue);
         if (onUpdate!=null)
            onUpdate(restrictedValue,Phase.UPDATE);
      }
   }
   function onSliderUp(e:MouseEvent)
   {
      addChild(slider);
      slider.x = sliderX;
      slider.y = 0;
      sliderWatcher = null;
      updateMinMax();
      if (onEnter!=null)
         onEnter(restrictedValue);
      if (onUpdate!=null)
         onUpdate(restrictedValue,Phase.END);
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
   */

   function onUpdateText(inText:String)
   {
      textChanged = true;
      var v = Std.parseFloat(inText);
      if (!Math.isFinite(v))
         return;
      if (isInteger)
         v = Std.int(v);

      if (v!=fullValue)
      {
         fullValue = v;
         restrictedValue = fullValue;
         if (restrictedValue<min)
            restrictedValue = min;

         if (restrictedValue>max)
            restrictedValue = max;

         updateMinMax();
         redrawBar();

         if (onEnter!=null)
            onEnter(restrictedValue);

         else if (onUpdate!=null)
            onUpdate(restrictedValue,Phase.ALL);

      }
   }

   public override function redraw()
   {
      super.redraw();
      sliderX =  Std.int(mRect.width-SLIDER_W);
      if (slider!=null)
         slider.x = sliderX;
      redrawBar();
      //super.layout(inW-SLIDER_W, inH);
      //sliderX = slider.x = Std.int(inW-SLIDER_W);
   }
}
