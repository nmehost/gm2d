package gm2d.blit;

import gm2d.display.Sprite;
import gm2d.display.Stage;
import gm2d.events.Event;
import gm2d.geom.Rectangle;


import gm2d.blit.Grid;


class Viewport extends Sprite
{
   public var viewWidth(default,null):Int;
   public var viewHeight(default,null):Int;
   var mCallbackStage:Stage;
   var mLayers:Array<Layer>;
   var mTransparent:Bool;
   var mBackground:Int;
   var mDirty:Bool;

   public var originX(default,setOriginX):Float;
   public var originY(default,setOriginY):Float;
   public var worldWidth:Float;
   public var worldHeight:Float;


   inline public static var BG_TRANSPARENT = 0;
   inline public static var BG_DONT_CARE = 1;
   inline public static var BG_OPAQUE = 2;

   var mRect:Rectangle;

   public static function create(inWidth:Int, inHeight:Int,
        inBGMode:Int=1,inBackground:Int=0xffffff,inForceSoftware:Bool = false,inForceNME:Bool=false)
            : Viewport
   {
      #if flash
      return new BMPViewport(inWidth,inHeight,inBGMode==BG_TRANSPARENT,inBackground);
      #else
      if (inForceSoftware || (!gm2d.Lib.isOpenGL && !inForceNME) )
         return new BMPViewport(inWidth,inHeight,inBGMode==BG_TRANSPARENT,inBackground);
      else
         return new NMEViewport(inWidth,inHeight,inBGMode!=BG_OPAQUE,inBackground);
      #end
   }

   function new(inWidth:Int, inHeight:Int,inTransparent:Bool=false,inBackground:Int=0xffffff)
   {
      super();
      viewWidth = inWidth;
      viewHeight = inHeight;
      worldWidth = inWidth;
      worldHeight = inHeight;
      mBackground = inBackground;
      mTransparent = inTransparent;
      originX = 0;
      originY = 0;
      

      mRect = new Rectangle(0,0,viewWidth,viewHeight);

      mouseEnabled = false;

      mLayers = [];
      mDirty = false;
      // Manage handlers so we can clean up ourselves
      addEventListener(Event.ADDED_TO_STAGE,onAddedCB);
      addEventListener(Event.REMOVED_FROM_STAGE,onRemovedCB);
   }

   public function resize(inWidth:Int, inHeight:Int)
   {
      viewWidth = inWidth;
      viewHeight = inHeight;
      mRect = new Rectangle(0,0,viewWidth,viewHeight);
      invalidate();
      for(layer in mLayers)
         layer.resize(inWidth,inHeight);
   }


   #if !neko
   function getBG()
   {
      return mBackground | ( mTransparent ? 0 : 0xff000000 );
   }
   #else
   function getBG()
   {
      return gm2d.RGB.RGBA(mBackground&0xffffff,mTransparent?0x00:0xff);
   }
   #end


   public inline function invalidate() : Void
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
      invalidate();
      mLayers.push(inLayer);
   }

   public function centerOn(inX:Float, inY:Float)
   {
      originX = inX - viewWidth/2;
      if (originX<0) originX = 0;
      else if (originX+viewWidth > worldWidth) originX = worldWidth-viewWidth;

      originY = inY - viewHeight/2;
      if (originY<0) originY = 0;
      else if (originY+viewHeight > worldHeight) originY = worldHeight-viewHeight;
      invalidate();
   }

   public function createLayer() : Layer
   {
      return null;
   }

   public function createGridLayer(inGrid:Grid)
   {
      var layer = createLayer();

      var handler = new GridHandler(layer, inGrid );

      return layer;
   }

 

   function setOriginX(inVal:Float):Float
   {
      invalidate();
      originX = inVal;
      return inVal;
   }

   function setOriginY(inVal:Float):Float
   {
      invalidate();
      originY = inVal;
      return inVal;
   }

   function onAddedCB(_) { onAdded(); }

   function onAdded()
   {
      mCallbackStage = stage;
      mCallbackStage.addEventListener(Event.RENDER,onRender);
      if (mDirty)
         mCallbackStage.invalidate();
   }

   function onRemovedCB(_) { onRemoved(); }
   function onRemoved()
   {
      mCallbackStage.removeEventListener(Event.RENDER,onRender);
      mCallbackStage = null;
   }

   function renderViewport()
   {
   }

   function onRender(_)
   {
      renderViewport();
      mDirty = false;
   }


}

