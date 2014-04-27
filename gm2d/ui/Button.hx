package gm2d.ui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.geom.Rectangle;
import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.skin.Renderer;

class Button extends Control
{
   var mDisplayObj : DisplayObject;
   var mStateBitmap : Bitmap;

   public var isToggle:Bool;
	public var noFocus:Bool;
   public var mCallback : Void->Void;
   var mDownDX:Float;
   var mDownDY:Float;
   var mCurrentDX:Float;
   var mCurrentDY:Float;
   public var onCurrentChangedFunc:Bool->Void;

   public function new(inObject:DisplayObject,?inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      super( Widget.addLine(inLineage,"Button"), inAttribs);
      var offset = mRenderer.offset;
      mDownDX = offset.x;
      mDownDY = offset.y;

      mCallback = inOnClick;
      mDisplayObj = inObject;

      mCurrentDX = mCurrentDY = 0;
      noFocus = false;
      mouseChildren = false;
      isToggle = false;
      addEventListener(MouseEvent.CLICK, onClick );
      addEventListener(MouseEvent.MOUSE_DOWN, onDown );
      addEventListener(MouseEvent.MOUSE_UP, onUp );

      if (mDisplayObj==null)
      {
         var bmp = mRenderer.getBitmap(name,0);
         if (bmp!=null)
            mDisplayObj = mStateBitmap = new Bitmap(bmp);
      }

      var tf:TextField = null;
      var layout:Layout = null;
      if (mDisplayObj!=null)
      {
         addChild(mDisplayObj);
         if ( Std.is(mDisplayObj,TextField))
         {
            var tf = cast mDisplayObj;
            layout = new AutoTextLayout(tf);
         }
         else
         {
            layout = new DisplayLayout(mDisplayObj);
         }
         layout.mAlign = Layout.AlignCenterX | Layout.AlignCenterY | Layout.AlignPixel;
         layout.mDebugCol = 0x00ff00;
         setItemLayout(layout);
      }

      build();

   }

   override public function redraw()
   {
      if (mStateBitmap!=null)
         mStateBitmap.bitmapData = mRenderer.getBitmap(name,state);
      super.redraw();
   }


   public static function create(?inLineage:Array<String>, ?inAttribs:Dynamic,?inOnClick:Void->Void)
   {
      return new Button(null,inOnClick,inLineage,inAttribs);
   }

   function onClick(e:MouseEvent)
   {
      if (mCallback!=null && !isToggle)
         mCallback();
   }
   function onDown(e:MouseEvent)
   {
      if (isToggle)
      {
         set_down(!get_down());
         if (mCallback!=null)
            mCallback();
      }
      else
         set_down(true);
   }
   function onUp(e:MouseEvent)
   {
      if (!isToggle)
         set_down(false);
   }

   public function getInnerLayout()
   {
      getLayout();
      return mItemLayout;
   }

   override public function getLabel() : TextField
   { 
      if (mDisplayObj!=null && Std.is(mDisplayObj,TextField))
         return cast mDisplayObj;
      return null;
   }




/*
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
   */
   override public function set_down(inDown:Bool) : Bool
   {
      if (inDown!=down)
      {
         state = state ^ Widget.DOWN;

         if (mDisplayObj!=null)
         {
			   var dx = inDown ? mDownDX : 0;
			   var dy = inDown ? mDownDY : 0;
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

         if (mRenderer!=null && mRect!=null)
         {
            mChrome.graphics.clear();
            while(mChrome.numChildren>0)
               mChrome.removeChildAt(0);
            mRenderer.renderWidget(this);
         }
      }
      return inDown;
   }


   public static function BMPButton(inBitmapData:BitmapData,?inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      var bmp = new Bitmap(inBitmapData);
      var result = new Button(bmp,inOnClick,Widget.addLine(inLineage,"BitmapButton"), inAttribs);
      return result;
   }

   public static function BitmapButton(inBitmapData:BitmapData,?inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:Dynamic)
   {
      var bmp = new Bitmap(inBitmapData);
      var result = new Button(bmp,inOnClick, Widget.addLine(inLineage,"BitmapButton"), inAttribs);
      return result;
   }


   public static function TextButton(inText:String,inOnClick:Void->Void,?inLineage:Array<String>,
       ?inArrtibs:Dynamic)
   {
      var renderer = Skin.renderer(["ButtonText","Button","StaticText","Text"]);
      var label = new TextField();
      //label.align = "center";
      label.text = inText;
      renderer.renderLabel(label);
      label.selectable = false;
      var result =  new Button(label,inOnClick,Widget.addLine(inLineage,"TextButton"),inArrtibs);
      return result;
   }

   public static function BMPTextButton(inBitmapData:BitmapData,inText:String, ?inOnClick:Void->Void,?inLineage:Array<String>)
   {
      var sprite = new Sprite();
      var bmp = new Bitmap(inBitmapData);
      sprite.addChild(bmp);
      var label = new TextField();
      var renderer = Skin.renderer(["ButtonText","StaticText","Text"]);
      label.text = inText;
      renderer.renderLabel(label);
      sprite.addChild(label);
      label.autoSize = TextFieldAutoSize.LEFT;
      label.x = bmp.width;
      label.y = (bmp.height - label.height)/2;
      var result = new Button(sprite,inOnClick,Widget.addLine(inLineage,"BitmapButton"));
      var layout = result.getItemLayout();
      layout.setBestSize(label.x + label.width, bmp.height);
      return result;
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
      {
        if (isToggle)
           set_down(!get_down());
        if (mCallback!=null)
           mCallback();
      }
   }
}

class BmpButton extends Button
{
   public var bitmap(default,null):Bitmap;
   public var normal:BitmapData;
   public var disabledBmp:BitmapData;

   public function new(inBitmapData:BitmapData,?inOnClick:Void->Void,?inLineage:Array<String>,?inAttribs:Dynamic)
   {
      normal = inBitmapData;
      bitmap = new Bitmap(normal);
      super(bitmap,inOnClick,inLineage,inAttribs);
   }

   public function createDisabled(inBmp:BitmapData)
   {
      var w = inBmp.width;
      var h = inBmp.height;
      var result = new BitmapData(w,h,true,gm2d.RGB.CLEAR);

      for(y in 0...h)
         for(x in 0...w)
         {
            var pix:Int = inBmp.getPixel32(x,y);
            var val:Int = (pix&0xff) + ( (pix>>8)&0xff ) + ( (pix>>16)&0xff ); 
            if (val<255) val=0;
            else if (val>512) val = 255;
            else val = 128;
            val = (val * 0x10101) | (pix&0xff000000);
            result.setPixel32(x,y,val);
         }

      return result;
   }

   public function enable(inEnable:Bool)
   {
      mouseEnabled = inEnable;
      if (inEnable)
         bitmap.bitmapData = normal;
      else
      {
         if (disabledBmp==null)
            disabledBmp = createDisabled(normal);
         bitmap.bitmapData = disabledBmp;
      }
   }
}

