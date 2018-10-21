package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.text.TextField;
import nme.ui.Keyboard;
import nme.geom.Rectangle;
import gm2d.ui.Layout;
import gm2d.svg.Svg;
import gm2d.svg.SvgRenderer;
import gm2d.skin.Skin;
import gm2d.skin.SliderRenderer;

class Slider extends Control
{
   public var mTrack : Sprite;
   public var mThumb : Sprite;
   public var mText  : TextField;
   public var mCallback : Float->Void;
   public var mMin:Float;
   public var mMax:Float;
   public var mSliding:Bool;
   public var mX0:Float;
   public var mX1:Float;
   public var mValue:Float;
   public var mSliderRenderer:gm2d.skin.SliderRenderer;
   public var isActive:Bool;
   var removeStage:DisplayObject;

   public function new(inMin:Float,inMax:Float,inPos:Float,inOnChange:Float->Void )
   {
      super("Slider");
      name = "Slider";
      mCallback = inOnChange;
      mMax = inMax;
      mMin = inMin;
      mX0 = 0;
      mX1 = 1;
      mSliderRenderer = Skin.sliderRenderer;

      mTrack = new Sprite();
      addChild(mTrack);

      isActive = false;

      setItemLayout( new Layout() );


      mSliderRenderer.onCreate(this);

      mSliding = false;

      if (mThumb!=null)
      {
         addChild(mThumb);
         mThumb.addEventListener(MouseEvent.MOUSE_DOWN, OnTrack );
      }

      addEventListener(MouseEvent.MOUSE_DOWN, OnTrack );
      addEventListener(MouseEvent.CLICK, OnClick );

      setValueQuiet(inPos);
      //build();
   }

   override public function activate()
   {
      isActive = true;
   }


   public override function onKeyDown(event:nme.events.KeyboardEvent ) : Bool
   {
      var code: #if flash UInt #else Int #end = event.keyCode;

      if (!isActive)
         return false;

      if (code==Keyboard.ENTER || code==27)
      {
         isActive = false;
         return true;
      }

      if (code==Keyboard.LEFT || code==Keyboard.RIGHT)
      {
         addDelta(code==Keyboard.LEFT ? -1 : 1);
         return true;
      }

      return false;
   }


   override public function set_isCurrent(inVal:Bool) : Bool
   {
      if (!inVal)
         isActive = false;
      return super.set_isCurrent(inVal);
   }

   function setThumbX(inX:Float)
   {
      inX -= mTrack.x + mX0;
      var len = mX1-mX0;
      if (inX<0)
         setValue(mMin);
      else if (inX>len)
         setValue(mMax);
      else
         setValue( mMin + (mMax-mMin)*inX/len );
   }

   public function addDelta(inDelta:Float)
   {
      setValue( mValue + (mMax-mMin) * 0.05 * inDelta );
   }

   function EndMoveSlider()
   {
      mSliding = false;
      if (removeStage!=null)
      {
         removeStage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMoveSlider);
         removeStage = null;
      }
   }
   function OnClick(inEvent:MouseEvent) { setThumbX(mouseX); isActive = true; }

   function OnMoveSlider(inEvent:MouseEvent)
   {
      isActive = true;
      if (!inEvent.buttonDown && mSliding)
         EndMoveSlider();
      else
      {
         setThumbX(mouseX);
      }
   }
   function OnTrack(_)
   {
      if (!mSliding)
      {
         mSliding = true;
         if (stage!=null)
         {
            removeStage = stage;
            removeStage.addEventListener(MouseEvent.MOUSE_MOVE, OnMoveSlider);
         }
      }
   }

   override public function set(inValue:Dynamic) : Void
   {
      setValue(inValue);
   }

   
   override public function get(inValue:Dynamic) : Void
   {
      if (Reflect.hasField(inValue,name))
         Reflect.setField(inValue, name, getValue() );
   }


   public function setValueQuiet(inPos:Float)
   {
      mValue = inPos;
      mSliderRenderer.onPosition(this);
   }


   public function getValue() : Float { return mValue; }

   function setValue(inPos:Float)
   {
      if (inPos<mMin)
         inPos = mMin;
      else if (inPos>mMax)
         inPos  =  mMax;

      setValueQuiet(inPos);
      if (mCallback!=null)
         mCallback(inPos);
   }

/*
   override public function activate(inDirection:Int)
   {
      if (inDirection>=0)
        mCallback();
   }
   */
}

