package gm2d.blit;

import gm2d.display.Sprite;
import gm2d.display.Stage;
import gm2d.events.Event;
import gm2d.geom.Rectangle;

class Viewport extends Sprite
{
   var mWidth:Int;
   var mHeight:Int;
   var mCallbackStage:Stage;
   var mLayers:Array<Layer>;
   var mTransparent:Bool;
   var mBackground:Int;
   var mDirty:Bool;

   public var originX(default,setOriginX):Float;
   public var originY(default,setOriginY):Float;
   public var worldWidth:Float;
   public var worldHeight:Float;

   var mRect:Rectangle;

   public static function create(inWidth:Int, inHeight:Int,
        inTransparent:Bool=false,inBackground:Int=0xffffff,inForceSoftware:Bool = false)
            : Viewport
   {
      #if flash
      return new BMPViewport(inWidth,inHeight,inTransparent,inBackground);
      #else
      if (inForceSoftware || !gm2d.Lib.isOpenGL)
         return new BMPViewport(inWidth,inHeight,inTransparent,inBackground);
      else
         return new NMEViewport(inWidth,inHeight,inTransparent,inBackground);
      #end
   }

   function new(inWidth:Int, inHeight:Int,inTransparent:Bool=false,inBackground:Int=0xffffff)
   {
      super();
      mWidth = inWidth;
      mHeight = inHeight;
      worldWidth = inWidth;
      worldHeight = inHeight;
      mBackground = inBackground;
      mTransparent = inTransparent;
      originX = 0;
      originY = 0;
      

      mRect = new Rectangle(0,0,mWidth,mHeight);

      mLayers = [];
      mDirty = false;
      // Manage handlers so we can clean up ourselves
      addEventListener(Event.ADDED_TO_STAGE,onAdded);
      addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
   }

   function getBG()
   {
      return mTransparent ? haxe.Int32.make(mBackground>>16,mBackground&0xffff) :
                           haxe.Int32.make(0xff00|(mBackground>>16),mBackground&0xffff);
   }


   public inline function makeDirty() : Void
   {
      if (!mDirty)
      {
         mDirty=true;
         if (mCallbackStage!=null)
            mCallbackStage.invalidate();
      }
   }
   public function addLayer(inLayer:Layer)
   {
      makeDirty();
      mLayers.push(inLayer);
   }

   public function centerOn(inX:Float, inY:Float)
   {
      originX = inX - mWidth/2;
      if (originX<0) originX = 0;
      else if (originX+mWidth > worldWidth) originX = worldWidth-mWidth;

      originY = inY - mHeight/2;
      if (originY<0) originY = 0;
      else if (originY+mHeight > worldHeight) originY = worldHeight-mHeight;
      makeDirty();
   }

   public function createLayer() : Layer
   {
      return null;
   }
 

   function setOriginX(inVal:Float):Float
   {
      makeDirty();
      originX = inVal;
      return inVal;
   }

   function setOriginY(inVal:Float):Float
   {
      makeDirty();
      originY = inVal;
      return inVal;
   }

   function onAdded(_)
   {
      mCallbackStage = stage;
      mCallbackStage.addEventListener(Event.RENDER,onRender);
      if (mDirty)
         mCallbackStage.invalidate();
   }
   function onRemoved(_)
   {
      mCallbackStage.removeEventListener(Event.RENDER,onRender);
      mCallbackStage = null;
   }

   function renderViewport()
   {
   }

   function onRender(_)
   {
      mDirty = false;

      renderViewport();
   }


}

