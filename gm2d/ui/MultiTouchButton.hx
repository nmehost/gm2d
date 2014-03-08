package gm2d.ui;

import gm2d.svg.BitmapDataManager;
import gm2d.reso.Resources;
import gm2d.svg.SvgRenderer;

import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.display.Bitmap;
import nme.display.BitmapData;


class MultiTouchButton  extends Sprite
{
   public var w:Float;
   public var h:Float;
   var up:Bitmap;
   var down:Bitmap;
   var isDown:Bool;
   var onChange:Bool->Void;
   var mFilename:String;
   var mDownTime:Float;
   var minDownMS:Int;
   var mScale:Float;
   var mSeparateUpDown:Bool;

   public function new(inFilename:String,inSeparateUpDown:Bool,inScale:Float,inOnChange:Bool->Void)
   {
      super();
      onChange = null;
      #if !flash
      nme.ui.Multitouch.inputMode = nme.ui.MultitouchInputMode.TOUCH_POINT;
      var addMouseListeners = !nme.ui.Multitouch.supportsTouchEvents;
      #else
      var addMouseListeners = true;
      #end
 
      mFilename = inFilename;
      mSeparateUpDown = inSeparateUpDown;
      up = new Bitmap();
      down = new Bitmap();
      mScale = 0.0;
      if (inScale>0)
         scale(inScale);

      mDownTime = 0;
      minDownMS = 0;

      addChild(up);
      addChild(down);
      down.visible = true;
      isDown = true;
      setState(false);
      var me = this;

      if (addMouseListeners)
      {
         addEventListener(MouseEvent.MOUSE_DOWN, function(_) me.setState(true) );
         addEventListener(MouseEvent.MOUSE_UP, function(_) me.setState(false) );
         addEventListener(MouseEvent.ROLL_OUT, function(_) me.setState(false) );
      }

      #if !flash
      addEventListener(TouchEvent.TOUCH_END, function(_) me.setState(false) );
      addEventListener(TouchEvent.TOUCH_BEGIN, function(_) me.setState(true) );
      addEventListener(TouchEvent.TOUCH_OVER, function(_) me.setState(true) );
      addEventListener(TouchEvent.TOUCH_OUT, function(_) me.setState(false) );
      #end
      onChange = inOnChange;
   }

   public function scale(inScale:Float)
   {
      mScale = inScale;
      BitmapDataManager.setCacheScale(inScale);
      if (mFilename!="")
      {
         var svg:SvgRenderer = new SvgRenderer(Resources.loadSvg(mFilename));
         if (mSeparateUpDown)
         {
            up.bitmapData = BitmapDataManager.create(mFilename,"up",inScale);
            down.bitmapData = BitmapDataManager.create(mFilename,"down",inScale);
            w = up.width;
            h = up.height;
            down.x = 0;
            down.y = 0;
         }
         else
         {
            up.bitmapData = BitmapDataManager.create(mFilename,"",inScale, true);
            down.bitmapData = BitmapDataManager.create(mFilename,"",inScale*0.8, true);
            w = up.width;
            h = up.height;
            down.x = (w-down.width)*0.5;
            down.y = (h-down.height)*0.5;
         }
      }
   }

   public function setGraphicsSource(inFilename:String)
   {
      mFilename = inFilename;
      scale(mScale);
   }

   function fakeUp()
   {
      if (isDown)
      {
         trace(" fake up");
         setState(false);
      }
      else
      {
         trace("Skip fake up");
      }
   }

   public function setState(inDown:Bool)
   {
      if (inDown!=isDown)
      {
         var now:Float = haxe.Timer.stamp();
         if (inDown)
            mDownTime = now;
         else
         {
            var been = Std.int( (now-mDownTime) * 1000 );
            if (been < minDownMS)
            {
               trace("Only been : " + been);
               haxe.Timer.delay( fakeUp, minDownMS-been );
               return;
            }
         }

         isDown = inDown;
         up.visible = !isDown;
         down.visible = isDown;
         //trace("Down.visible "  + down.visible );
         if (onChange!=null)
            onChange(isDown);
      }
   }
}


