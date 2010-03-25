package gm2d.blit;

class Layer
{
   public var offsetX(default,setOffsetX):Float;
   public var offsetY(default,setOffsetY):Float;
   var mViewport:Viewport;

   function new(inVP:Viewport)
   {
      mViewport = inVP;
      offsetX = 0;
      offsetY = 0;
   }

   public function gm2dRender(inOX:Float, inOY:Float) { }

   public function gm2dClear() { }

   public function addTile(inTile:Tile, inX:Float, inY:Float) { }

   public function clear()
   {
      if (mViewport!=null) { mViewport.makeDirty(); }
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
}
