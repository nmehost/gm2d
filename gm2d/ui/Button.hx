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
import gm2d.skin.Skin;
import gm2d.skin.ButtonRenderer;
import gm2d.skin.ButtonState;

class Button extends Control
{
   var mDisplayObj : DisplayObject;
   public var mChrome : Sprite;
   public var down(getDown,setDown):Bool;
	public var noFocus:Bool;
   public var mCallback : Void->Void;
   var mIsDown:Bool;
   var mDownBmp:BitmapData;
   var mDownDX:Float;
   var mDownDY:Float;
   var mUpBmp:BitmapData;
   var mCurrentDX:Float;
   var mCurrentDY:Float;
   var mMainLayout:Layout;
   var mItemLayout:Layout;
   var mRenderer:ButtonRenderer;
   public var onCurrentChangedFunc:Bool->Void;

   static public var BMPButtonFont = "Arial";

   public function new(inObject:DisplayObject,?inOnClick:Void->Void,?inRenderer:ButtonRenderer)
   {
      super();
      name = "button";
      mCallback = inOnClick;
      mIsDown = false;
      mChrome = new Sprite();
      mDisplayObj = inObject;
      addChild(mChrome);
      addChild(mDisplayObj);
      mCurrentDX = mCurrentDY = 0;
      noFocus = false;
      var me = this;
      mRenderer = inRenderer==null ? Skin.current.buttonRenderer : inRenderer;
      addEventListener(MouseEvent.CLICK, function(_) { mCallback(); } );
      addEventListener(MouseEvent.MOUSE_DOWN, function(_) { me.setDown(true); } );
      addEventListener(MouseEvent.MOUSE_UP, function(_) { me.setDown(false); } );

      var label = getLabel();
      if (label!=null)
         mRenderer.styleLabel(label);
      var offset = mRenderer.downOffset;
      mDownDX = offset.x;
      mDownDY = offset.y;
      getLayout();
   }

   public function getItemLayout()
   {
      getLayout();
      return mItemLayout;
   }

   public function getLabel() : TextField
   { 
      if (Std.is(mDisplayObj,TextField))
         return cast mDisplayObj;
      return null;
   }

/*
   public function setBackground(inSVG:gm2d.svg.SvgRenderer, inW:Float, inH:Float)
   {
      inSVG.renderSprite(mBG);
      mBG.width = inW;
      mBG.height = inH;
   }

   public function setBGRenderer(inRenderer:gm2d.display.Graphics->Float->Float->Void)
   {
      var layout = getLayout();
      setBG(inRenderer,
          layout.getBestWidth()+Skin.current.buttonBorderX,
          layout.getBestHeight()+Skin.current.buttonBorderY);
   }

   public function setBG(inRenderer:gm2d.display.Graphics->Float->Float->Void,inW:Float, inH:Float)
   {
      var gfx = mBG.graphics;
      gfx.clear();
      inRenderer(gfx,inW,inH);
      var layout = getLayout();
      mMainLayout.setBestSize(mBG.width,mBG.height);
   }
   */

   public function setBGStates(inUpBmp:BitmapData, inDownBmp:BitmapData,
             inDownDX:Int = 0, inDownDY:Int = 0)
   {
      mUpBmp = inUpBmp;
      mDownBmp = inDownBmp;
      var w = mUpBmp!=null ? mUpBmp.width : mDownBmp==null? mDownBmp.width : 32;
      var h = mUpBmp!=null ? mUpBmp.height : mDownBmp==null? mDownBmp.height : 32;
      var layout = getLayout();
      mMainLayout.setBestSize(w,h);
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
            var gfx = mChrome.graphics;
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


   public static function BMPButton(inBitmapData:BitmapData,inX:Float=0, inY:Float=0,?inOnClick:Void->Void)
   {
      var bmp = new Bitmap(inBitmapData);
      var result = new Button(bmp,inOnClick);
      result.x = inX;
      result.y = inY;
      return result;
   }

   public static function TextButton(inText:String,inOnClick:Void->Void,?inRenderer:ButtonRenderer)
   {
      var label = new TextField();
      label.text = inText;
      label.selectable = false;
      var result =  new Button(label,inOnClick,inRenderer);
      return result;
   }

   public static function BMPTextButton(inBitmapData:BitmapData,inText:String,?inOnClick:Void->Void)
   {
      var sprite = new Sprite();
      var bmp = new Bitmap(inBitmapData);
      sprite.addChild(bmp);
      var text = new TextField();
      var textFormat = new gm2d.text.TextFormat();
      textFormat.size = Std.int(inBitmapData.height*0.4);
      textFormat.font = BMPButtonFont;
      text.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      text.selectable = false;
      text.mouseEnabled = false;
      text.defaultTextFormat = textFormat;
      text.text = inText;
      sprite.addChild(text);
      text.x = bmp.width+ 10;
      text.y = (bmp.height - text.textHeight)/2;
      var result = new Button(sprite,inOnClick);
      var layout = result.getItemLayout();
      layout.setBestSize(text.x + text.textWidth, bmp.height);
      return result;
   }

   function renderBackground(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      mRenderer.render(mChrome,new Rectangle(inX-x,inY-y,inW,inH), mIsDown ? BUTTON_DOWN:BUTTON_UP);
   }

   override public function createLayout() : Layout
   {
      var layout = new ChildStackLayout( );
      layout.setBorders(0,0,0,0);
      layout.add( mMainLayout = (new DisplayLayout(this)).setOrigin(0,0) );
      mItemLayout = ( Std.is(mDisplayObj,TextField)) ?
           new TextLayout(cast mDisplayObj)  : 
           new DisplayLayout(mDisplayObj) ;
      mRenderer.updateLayout(mItemLayout);
      layout.add(mItemLayout);
      layout.mDebugCol = 0x00ff00;
      layout.onLayout = renderBackground;
      return layout;
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
      if (inDirection>=0 && mCallback!=null)
        mCallback();
   }
}

