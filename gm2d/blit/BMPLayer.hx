package gm2d.blit;

import gm2d.display.BitmapData;
import gm2d.geom.Point;

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
   var mDynamicOX:Float;
   var mDynamicOY:Float;
   var mPos:Point;
   var mBMPViewport:BMPViewport;
   public var bitmap(default,null):BitmapData;

   function new(inVP:BMPViewport)
   {
      super(inVP);
      mHead = null;
      mLast = null;
      mDynamicOX = mDynamicOY = 0;
      mPos = new Point();
      mBMPViewport = inVP;
      bitmap = mBMPViewport.gm2dBitmapData;
   }

   public static function gm2dCreate(inVP:BMPViewport)
   {
      return new BMPLayer(inVP);
   }

   public override function resize(inWidth:Int, inHeight:Int)
   {
      bitmap = mBMPViewport.gm2dBitmapData;
   }


   public override function drawTile(inTile:Tile, inX:Float, inY:Float)
   {
      var p = mPos;
      p.x = inX + mDynamicOX -inTile.hotX;
      p.y = inY + mDynamicOY -inTile.hotY;
      bitmap.copyPixels(inTile.sheet.gm2dData, inTile.rect, p, null, null, inTile.sheet.useAlpha);
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
         var t = tile.tile;
         bitmap.copyPixels(t.sheet.gm2dData, t.rect, pos, null, null, t.sheet.useAlpha);
         tile = tile.next;
      }

      if (dynamicRender!=null)
      {
         mDynamicOX = ox;
         mDynamicOY = oy;
         dynamicRender(inOX,inOY);
      }
   }

   public override function addTile(inTile:Tile, inX:Float, inY:Float)
   {
      if (mViewport!=null) { mViewport.invalidate(); }
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

   public override function gm2dClear()
   {
      mHead = mLast = null;
   }

}
