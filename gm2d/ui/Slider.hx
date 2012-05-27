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

class Slider extends Control
{
   var mTrack : Sprite;
   var mThumb : Sprite;
   var mCallback : Float->Void;
   var mMin:Float;
   var mMax:Float;
   var mSliding:Bool;
   var mX0:Float;
   var mX1:Float;
   var mLength:Float;
   var mPrefW:Null<Float>;
   var mPrefH:Null<Float>;

   public function new(inTrack:Sprite,inThumb:Sprite,
                       inText:DisplayObject,inMin:Float,inMax:Float,inPos:Float,
                       inOnChange:Float->Void,
                       ?inX0:Float = 0.0,
                       ?inX1:Null<Float>)
   {
      super();
      name = "Slider";
      mCallback = inOnChange;
      mTrack = inTrack;
      if (mTrack!=null) mTrack.name = "Track";
      mThumb = inThumb;
      if (mThumb!=null) mThumb.name = "Thumb";
      addChild(mTrack);
      mMax = inMax;
      mMin = inMin;
      mX0 = inX0;
      mX1 = (inX1==null) ? (mTrack==null ? 100 : mTrack.width) : inX1;
      mLength = mX1-mX0;
      if (mLength==0) mLength = 1;
      mSliding = false;

      if (mThumb!=null)
      {
         addChild(mThumb);
         mTrack.addEventListener(MouseEvent.MOUSE_DOWN, OnTrack );
         mTrack.addEventListener(MouseEvent.CLICK, OnClick );
         mThumb.addEventListener(MouseEvent.MOUSE_DOWN, OnTrack );
      }
      SetPos(inPos);
   }

   function OnTrackDone(_)
   {
      //mThumb.stopDrag();
   }

   function SetThumbX(inX:Float)
   {
      inX -= mTrack.x + mX0;
      if (inX<0)
         SetPos(mMin);
      else if (inX>mLength)
         SetPos(mMax);
      else
         SetPos( mMin + (mMax-mMin)*inX/mLength );
   }

   function EndMoveSlider()
   {
      mSliding = false;
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMoveSlider);
   }
   function OnClick(inEvent:MouseEvent) { SetThumbX(mouseX); }

   function OnMoveSlider(inEvent:MouseEvent)
   {
      if (!inEvent.buttonDown && mSliding)
         EndMoveSlider();
      else
      {
         SetThumbX(mouseX);
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

   function SetPos(inPos:Float)
   {
      if (mThumb!=null)
      {
         mThumb.x = mTrack.x + mX0 + mLength * (inPos-mMin)/(mMax-mMin);
      }
   }

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

/*
   override public function activate(inDirection:Int)
   {
      if (inDirection>=0)
        mCallback();
   }
   */
}

