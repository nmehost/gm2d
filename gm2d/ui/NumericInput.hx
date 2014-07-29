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
   var underlay:Shape;
   var min:Float;
   var max:Float;
   var step:Float;
   var slider:Sprite;
   var sliderX:Float;
   var sliderWatcher:MouseWatcher;
   var textWatcher:MouseWatcher;
   var value:Float;
   var restrictedValue:Float;
   var isInteger:Bool;
   var newDrag:Bool;
   var textChanged:Bool;
   var init:Bool;
   static var SLIDER_W = 22;

   public function new(inVal:Float,?inOnUpdateFloat:Float->Int->Void, ?inLineage:Array<String>, ?inAttribs:{} )
   {
      init = false;
      super(Std.string(inVal),onUpdateText, inLineage, inAttribs);

      isInteger = attribBool("isInteger",false);
      min = attribFloat("minValue");
      max = attribFloat("maxValue",100.0);
      maxBar = max;
      value = inVal;
      textChanged = false;
      quantization = 0.01;
      if (value<min)
         value = min;
      if (value>max)
         value = max;
      restrictedValue = isInteger ? Std.int(value) : value;
      onUpdate = inOnUpdateFloat;
      step = attribFloat("step",0.1);
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
      redrawBar();
   }

   override public function createUnderlay()
   {
      underlay = new Shape();
      addChild(underlay);
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
         v = Std.int(v);
      if (v!=restrictedValue || textChanged)
      {
         textChanged = false;
         restrictedValue = value = v;
         if (quantization>0)
            restrictedValue = min + (Std.int((restrictedValue+quantization*0.5-min)/quantization)*quantization);

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
         var range =maxBar-min;
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
      if (!textWatcher.wasDragged)
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
      if (value<min)
         setValue(min);
      redrawBar();
   }

   public function setMaximum(inValue:Float)
   {
      max = inValue;
      if (value>max)
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
      var range = maxBar-min;
      if (range>0)
      {
         gfx.clear();
         gfx.beginFill(0xc0c0c0,1);
         var val = restrictedValue<maxBar ? value : maxBar;
         gfx.drawRect(0,0,mText.width * (val-min) / range, mText.height);
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
         onUpdate(restrictedValue,Phase.BEGIN);
   }

   function onSliderDrag(e:MouseEvent)
   {
      var dy = sliderWatcher.pos.y - sliderWatcher.prevPos.y;
      slider.y += dy;
      value -= dy*step;
      if (value<min) value = min;
      if (value>max) value = max;
      var v = isInteger ? Std.int(value) : value;
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

   function onUpdateText(inText:String)
   {
      textChanged = true;
      var v = Std.parseFloat(inText);
      if (!Math.isFinite(v))
         return;
      if (isInteger)
         v = Std.int(v);

      if (v!=value)
      {
         value = v;
         restrictedValue = value;
         if (restrictedValue<min)
            restrictedValue = min;

         if (restrictedValue>max)
            restrictedValue = max;

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
