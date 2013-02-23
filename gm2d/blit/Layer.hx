package gm2d.blit;


class Layer
{
   public var offsetX(default,set_offsetX):Float;
   public var offsetY(default,set_offsetY):Float;
   public var worldWidth(get_worldWidth,null):Float;
   public var worldHeight(get_worldHeight,null):Float;
   public var viewWidth(get_viewWidth,null):Float;
   public var viewHeight(get_viewHeight,null):Float;
   public var visible(default,set_visible):Bool;
   public var blendAdd:Bool;
 

   var mViewport:Viewport;

   function new(inVP:Viewport)
   {
      mViewport = inVP;
      visible = true;
      offsetX = 0;
      offsetY = 0;
      blendAdd = false;
   }

   public function gm2dRender(inOX:Float, inOY:Float) { }

   public function resize(inWidth:Int, inHeight:Int) { }

   public function gm2dClear() { }

   public function addTile(inTile:Tile, inX:Float, inY:Float) { }

   dynamic public function dynamicRender(inOX:Float, inOY:Float) : Void { }

   public function drawTile(inTile:Tile, inX:Float, inY:Float) { }

   public function isPersistent() : Bool { return false; }

   public function set_visible(inVis:Bool) : Bool
   {
      visible= inVis;
      if (mViewport!=null) { mViewport.invalidate(); }
      return inVis;
   }

   public function clear()
   {
      if (mViewport!=null) { mViewport.invalidate(); }
      gm2dClear();
   }


   function set_offsetX(inVal:Float):Float
   {
      offsetX = Std.int(inVal);
      return inVal;
   }

   function set_offsetY(inVal:Float):Float
   {
      offsetY = Std.int(inVal);
      return inVal;
   }

   function get_worldWidth() { return mViewport.worldWidth; }
   function get_worldHeight() { return mViewport.worldWidth; }
   function get_viewWidth() { return mViewport.viewWidth; }
   function get_viewHeight() { return mViewport.viewWidth; }
}
