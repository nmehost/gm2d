package gm2d.ui;

import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.display.DisplayObject;
import gm2d.display.DisplayObjectContainer;
import gm2d.display.Sprite;
import gm2d.events.MouseEvent;
import gm2d.text.TextField;
import gm2d.ui.Layout;

class Button extends Base
{
   var mDisplayObj : DisplayObject;
   public var mBG : Sprite;
   public var down(getDown,setDown):Bool;
   var mCallback : Void->Void;
   var mIsDown:Bool;
   var mDownBmp:BitmapData;
   var mUpBmp:BitmapData;
   var mDownDX:Float;
   var mDownDY:Float;
   var mLayout:Layout;
   var mItemLayout:Layout;

   public function new(inObject:DisplayObject,inOnClick:Void->Void)
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
      var me = this;
      addEventListener(MouseEvent.CLICK, function(_) { inOnClick(); } );
      addEventListener(MouseEvent.MOUSE_DOWN, function(_) { me.setDown(true); } );
      addEventListener(MouseEvent.MOUSE_UP, function(_) { me.setDown(false); } );
   }

   public function setBackground(inSVG:gm2d.svg.SVG2Gfx, inW:Float, inH:Float)
   {
      inSVG.RenderSprite(mBG);
      mBG.width = inW;
      mBG.height = inH;
   }
   public function setBGStates(inUpBmp:BitmapData, inDownBmp:BitmapData,
             inDownDX:Int = 0, inDownDY:Int = 0)
   {
      mUpBmp = inUpBmp;
      mDownBmp = inDownBmp;
      mDownDX = inDownDX;
      mDownDY = inDownDY;
      mIsDown = !mIsDown;
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
         if (mDownDX!=0 || mDownDY!=0)
         {
            getLayout();
            if (mIsDown)
               mItemLayout.setOffset(mDownDX,mDownDY);
            else
               mItemLayout.setOffset(0,0);
            mLayout.setRect(x,y,width,height);
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

   public static function TextButton(inText:String,inOnClick:Void->Void)
   {
      var label = new TextField();
      label.text = inText;
      label.setTextFormat( Dialog.labelFormat );
      label.textColor = Dialog.labelColor;
      label.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      label.selectable = false;
      var result =  new Button(label,inOnClick);
      return result;
   }


   public function getLayout() : Layout
   {
      if (mLayout==null)
      {
         mLayout = new ChildStackLayout( );
         mLayout.setBorders(0,0,0,0);
         mLayout.add( (new DisplayLayout(this)).setOrigin(0,0) );
         mLayout.add( new DisplayLayout(mBG) );
   
         mItemLayout = ( Std.is(mDisplayObj,TextField)) ?
             new TextLayout(cast mDisplayObj)  : 
             new DisplayLayout(mDisplayObj) ;
         mLayout.add(mItemLayout);
         mLayout.mDebugCol = 0x00ff00;
      }
      return mLayout;
   }



   override public function activate(inDirection:Int)
   {
      if (inDirection>=0)
        mCallback();
   }
}

