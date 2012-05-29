package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.Sprite;
import gm2d.events.MouseEvent;
import gm2d.text.TextField;
import gm2d.geom.Rectangle;
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
   var mRenderer:gm2d.skin.SliderRenderer;

   public function new(inMin:Float,inMax:Float,inPos:Float,inOnChange:Float->Void,
      ?inRenderer:SliderRenderer)
   {
      super();
      name = "Slider";
      mCallback = inOnChange;
      mMax = inMax;
      mMin = inMin;
      mX0 = 0;
      mX1 = 1;
      mRenderer = inRenderer==null ? new SliderRenderer() : inRenderer;

      mTrack = new Sprite();
      addChild(mTrack);

      mRenderer.onCreate(this);

      mSliding = false;

      if (mThumb!=null)
      {
         addChild(mThumb);
         mThumb.addEventListener(MouseEvent.MOUSE_DOWN, OnTrack );
      }

      addEventListener(MouseEvent.MOUSE_DOWN, OnTrack );
      addEventListener(MouseEvent.CLICK, OnClick );

      setValueQuiet(inPos);
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

   function EndMoveSlider()
   {
      mSliding = false;
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMoveSlider);
   }
   function OnClick(inEvent:MouseEvent) { setThumbX(mouseX); }

   function OnMoveSlider(inEvent:MouseEvent)
   {
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
         stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMoveSlider);
      }
   }

   function setValueQuiet(inPos:Float)
   {
      mValue = inPos;
      mRenderer.onPosition(this);
   }


   function setValue(inPos:Float)
   {
      setValueQuiet(inPos);
      if (mCallback!=null)
         mCallback(inPos);
   }

/*
   public static function SkinnedSlider(inSkin:Svg,inText:DisplayObject,
             inMin:Float,inMax:Float,inPos:Float,inOnChange:Float->Void)
   {
      var track = new Sprite();
      var renderer = new SvgRenderer(inSkin);
      renderer.renderSprite(track,null, function(name,groups) { return groups[1]=="Track"; } );

      var thumb = new Sprite();
      renderer.renderSprite(thumb,null, function(name,groups) { return groups[1]=="Thumb"; } );

      var rect = renderer.getExtent(null,
                     function(name,groups) { return groups[1]==".Active"; },true );

      var result:Slider = null;
      if (rect!=null)
         result =  new Slider(track,thumb,null, inMin,inMax,inPos,inOnChange,rect.left,rect.right);
      else
         result =  new Slider(track,thumb,null, inMin,inMax,inPos,inOnChange);

      result.getLayout().setBestSize(inSkin.width,inSkin.height);
      return result;
   }
*/

/*
   override public function activate(inDirection:Int)
   {
      if (inDirection>=0)
        mCallback();
   }
   */
}

