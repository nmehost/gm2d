package gm2d.ui;

import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.display.DisplayObject;
import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.events.MouseEvent;
import gm2d.text.TextField;
import gm2d.geom.Rectangle;
import gm2d.ui.Layout;

class Button extends Control
{
   var mDisplayObj : DisplayObject;
   public var mBG : Sprite;
   public var down(getDown,setDown):Bool;
	public var noFocus:Bool;
   var mCallback : Void->Void;
   var mIsDown:Bool;
   var mDownBmp:BitmapData;
   var mUpBmp:BitmapData;
   var mDownDX:Float;
   var mDownDY:Float;
   var mCurrentDX:Float;
   var mCurrentDY:Float;
   var mLayout:Layout;
   var mBGLayout:Layout;
   var mMainLayout:Layout;
   var mItemLayout:Layout;
   public var onCurrentChangedFunc:Bool->Void;

   public function new(inObject:DisplayObject,inOnClick:Void->Void,inSkinBG= false)
   {
      super();
      name = "button";
      mCallback = inOnClick;
      mIsDown = false;
      mBG = new Sprite();
      mDisplayObj = inObject;
      addChild(mBG);
      addChild(mDisplayObj);
      mDownDX = mDownDY = 0;
      mCurrentDX = mCurrentDY = 0;
		noFocus = false;
      var me = this;
      addEventListener(MouseEvent.CLICK, function(_) { inOnClick(); } );
      addEventListener(MouseEvent.MOUSE_DOWN, function(_) { me.setDown(true); } );
      addEventListener(MouseEvent.MOUSE_UP, function(_) { me.setDown(false); } );

      if (inSkinBG)
      {
         var layout = getLayout();
         setBG(Skin.current.renderButton,
             layout.getBestWidth()+Skin.current.buttonBorderX,
             layout.getBestHeight()+Skin.current.buttonBorderY);
      }
   }

   public function getLabel() : TextField
   { 
      if (Std.is(mDisplayObj,TextField))
         return cast mDisplayObj;
      return null;
   }

   public function setBackground(inSVG:gm2d.svg.SVG2Gfx, inW:Float, inH:Float)
   {
      inSVG.RenderSprite(mBG);
      mBG.width = inW;
      mBG.height = inH;
   }

   public function setBG(inRenderer:gm2d.display.Graphics->Float->Float->Void,inW:Float, inH:Float)
   {
      var gfx = mBG.graphics;
      gfx.clear();
      inRenderer(gfx,inW,inH);
      var layout = getLayout();
      mMainLayout.setBestSize(mBG.width,mBG.height);
      mBGLayout.setBestSize(mBG.width,mBG.height);
   }

   public function setDownOffsets( inDownDX:Float, inDownDY:Float)
   {
      mDownDX = inDownDX;
      mDownDY = inDownDY;
   }
   public function setBGStates(inUpBmp:BitmapData, inDownBmp:BitmapData,
             inDownDX:Int = 0, inDownDY:Int = 0)
   {
      mUpBmp = inUpBmp;
      mDownBmp = inDownBmp;
      var w = mUpBmp!=null ? mUpBmp.width : mDownBmp==null? mDownBmp.width : 32;
      var h = mUpBmp!=null ? mUpBmp.height : mDownBmp==null? mDownBmp.height : 32;
      var layout = getLayout();
      mMainLayout.setBestSize(w,h);
      mBGLayout.setBestSize(w,h);
      mDownDX = inDownDX;
      mDownDY = inDownDY;
      mIsDown = !mIsDown;
      mItemLayout.setRect(0,0,w,h);
      down = !mIsDown;
   }
   public function getDown() : Bool { return mIsDown; }
   public function setDown(inDown:Bool) : Bool
   {
      if (inDown!=mIsDown)
      {
         mIsDown = inDown;
         if (mDownBmp!=null || mUpBmp!=null)
         {
            var gfx = mBG.graphics;
            gfx.clear();
            var bmp:BitmapData = mIsDown?mDownBmp:mUpBmp;
            if (bmp!=null)
            {
               gfx.beginBitmapFill(bmp,null,true,true);
               gfx.drawRect(0,0,bmp.width,bmp.height);
            }
         }
			var dx = mIsDown ? mDownDX : 0;
			var dy = mIsDown ? mDownDY : 0;
         if (dx!=mCurrentDX)
         {
			   mDisplayObj.x += dx-mCurrentDX;
				mCurrentDX = dx;
         }
         if (dy!=mCurrentDY)
         {
			   mDisplayObj.y += dy-mCurrentDY;
				mCurrentDY = dy;
         }
      }
      return mIsDown;
   }


   public static function BMPButton(inBitmapData:BitmapData,inX:Float, inY:Float,inOnClick:Void->Void)
   {
      var bmp = new Bitmap(inBitmapData);
      var result = new Button(bmp,inOnClick);
      result.x = inX;
      result.y = inY;
      return result;
   }

   public static function TextButton(inText:String,inOnClick:Void->Void,inSkinBG=false)
   {
      var label = new TextField();
		Skin.current.styleButtonText(label);
		label.text = inText;
      //label.mouseEnabled = false;
      var result =  new Button(label,inOnClick,inSkinBG);
      result.setDownOffsets(1,1);
      return result;
   }


   override public function getLayout() : Layout
   {
      if (mLayout==null)
      {
         mLayout = new ChildStackLayout( );
         mLayout.setBorders(0,0,0,0);
         mLayout.add( mMainLayout = (new DisplayLayout(this)).setOrigin(0,0) );
         mLayout.add( mBGLayout = new DisplayLayout(mBG) );
   
         mItemLayout = ( Std.is(mDisplayObj,TextField)) ?
             new TextLayout(cast mDisplayObj)  : 
             new DisplayLayout(mDisplayObj) ;
         mLayout.add(mItemLayout);
         mLayout.mDebugCol = 0x00ff00;
      }
      return mLayout;
   }

   override public function onCurrentChanged(inCurrent:Bool)
	{
	   if (onCurrentChangedFunc!=null)
			onCurrentChangedFunc(inCurrent);
		else
		   super.onCurrentChanged(inCurrent);
	}


   override public function activate(inDirection:Int)
   {
      if (inDirection>=0)
        mCallback();
   }
}

