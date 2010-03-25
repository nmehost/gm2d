package gm2d.blit;

import gm2d.display.BitmapData;

class LayerTile
{
   public function new(inTile:Tile,inX:Float,inY:Float)
   {
      tile = inTile;
      x = inX - inTile.hotX;
      y = inY - inTile.hotY;
      next = null;
   }
   public var tile:Tile;
   public var x:Float;
   public var y:Float;
   public var next:LayerTile;
}

class BMPLayer extends Layer
{
   var mHead:LayerTile;
   var mLast:LayerTile;
   var mBMP:BitmapData;

   function new(inVP:BMPViewport)
   {
      super(inVP);
      mHead = null;
      mLast = null;
      mBMP = inVP.gm2dBitmapData;
   }

   public static function gm2dCreate(inVP:BMPViewport)
   {
      return new BMPLayer(inVP);
   }

   public override function gm2dRender(inOX:Float, inOY:Float)
   {
      var tile = mHead;
      var pos = new gm2d.geom.Point();
      var ox = offsetX - inOX;
      var oy = offsetY - inOY;
      while(tile!=null)
      {
         pos.x = tile.x + ox;
         pos.y = tile.y + oy;
         mBMP.copyPixels(tile.tile.sheet.gm2dData, tile.tile.rect, pos);
         tile = tile.next;
      }
   }

   public override function addTile(inTile:Tile, inX:Float, inY:Float)
   {
      if (mViewport!=null) { mViewport.makeDirty(); }
      if (mLast==null)
      {
         mLast = mHead = new LayerTile(inTile,inX,inY);
      }
      else
      {
         mLast.next = new LayerTile(inTile,inX,inY);
         mLast = mLast.next;
      }
   }

   public function doClear()
   {
      mHead = mLast = null;
   }

}
