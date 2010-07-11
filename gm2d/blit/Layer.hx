package gm2d.blit;


class Layer
{
   public var offsetX(default,setOffsetX):Float;
   public var offsetY(default,setOffsetY):Float;
   public var worldWidth(getWorldWidth,null):Float;
   public var worldHeight(getWorldHeight,null):Float;
   public var viewWidth(getViewWidth,null):Float;
   public var viewHeight(getViewHeight,null):Float;


   var mViewport:Viewport;

   function new(inVP:Viewport)
   {
      mViewport = inVP;
      offsetX = 0;
      offsetY = 0;
   }

   public function gm2dRender(inOX:Float, inOY:Float) { }

   public function resize(inWidth:Int, inHeight:Int) { }

   public function gm2dClear() { }

   public function addTile(inTile:Tile, inX:Float, inY:Float) { }

   dynamic public function dynamicRender(inOX:Float, inOY:Float) : Void;

   public function drawTile(inTile:Tile, inX:Float, inY:Float) { }

   public function isPersistent() : Bool { return false; }

   public function clear()
   {
      if (mViewport!=null) { mViewport.invalidate(); }
      gm2dClear();
   }


   function setOffsetX(inVal:Float):Float
   {
      offsetX = Std.int(inVal);
      return inVal;
   }

   function setOffsetY(inVal:Float):Float
   {
      offsetY = Std.int(inVal);
      return inVal;
   }

   function getWorldWidth() { return mViewport.worldWidth; }
   function getWorldHeight() { return mViewport.worldWidth; }
   function getViewWidth() { return mViewport.viewWidth; }
   function getViewHeight() { return mViewport.viewWidth; }
}
