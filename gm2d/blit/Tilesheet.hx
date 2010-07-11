package gm2d.blit;

import gm2d.display.BitmapData;
import gm2d.geom.Rectangle;
import gm2d.geom.Point;

class Tilesheet
{
   public var gm2dData : BitmapData;
        public var useAlpha(default,null):Bool;
   var mAllocX:Int;
   var mAllocY:Int;
   var mAllocHeight:Int;
   var mTiles:Array<Tile>;
   var mSmooth:Bool;
   var mSpace:Int;

   public var tileCount(getTileCount,null):Int;

   static public inline var BORDERS_NONE        = 0x00;
   static public inline var BORDERS_TRANSPARENT = 0x01;
   static public inline var BORDERS_DUPLICATE   = 0x02;

   static public inline var INTERP_SMOOTH       = 0x04;

   #if !flash
   public var gm2dSheet:nme.display.Tilesheet;
   #end

   public function new(inData:BitmapData,inFlags:Int = BORDERS_NONE)
   {
      gm2dData = inData;
      mAllocHeight = mAllocX = mAllocY = 0;
      mTiles = [];
      mSpace = inFlags & 0x03;
      mSmooth = (inFlags & INTERP_SMOOTH) != 0;
      #if !flash
      gm2dSheet = new nme.display.Tilesheet(gm2dData);
      #end
           useAlpha = inData.transparent;
   }

   public static function create(inW:Float, inH:Float,inFlags:Int = BORDERS_NONE)
   {
       var bmp = new BitmapData( Std.int(Math.ceil(inW)), Std.int(Math.ceil(inH)),true,
            gm2d.RGB.CLEAR );
       return new Tilesheet(bmp,inFlags);
   }

   public function gm2dAllocTile(inTile:Tile)
   {
      var id = mTiles.length;
      mTiles.push(inTile);
      #if !flash
      gm2dSheet.addTileRect(inTile.rect);
      #end
      return id;
   }

   public function addTile(inData:BitmapData) : Tile
   {
      var sw = inData.width;
      var sh = inData.height;
      var w = sw + mSpace;
      var h = sh + mSpace;
      var tw = gm2dData.width;
      var th = gm2dData.height;

      if (w>=tw) return null;

      while(true)
      {
         if (mAllocY + h > th) return null;
         if (mAllocX + w < tw)
            break;
         mAllocY += mAllocHeight;
         mAllocHeight = 0;
         mAllocX = 0;
      }

      var x = mAllocX;
      var y = mAllocY;
      mAllocX += w;
      if (th>mAllocHeight) mAllocHeight = th;
      if (mSpace==2)
      {
         x++;
         y++;
         gm2dData.copyPixels(inData,new Rectangle(0,0,1,1), new Point(x-1,y-1), null,null,true );
         gm2dData.copyPixels(inData,new Rectangle(0,0,sw,1), new Point(x,y-1), null,null,true );
         gm2dData.copyPixels(inData,new Rectangle(sw-1,0,1,1), new Point(x+sw,y-1), null,null,true );

         gm2dData.copyPixels(inData,new Rectangle(0,0,1,sh), new Point(x-1,y), null,null,true );
         gm2dData.copyPixels(inData,new Rectangle(sw-1,0,1,sh), new Point(x+sw,y), null,null,true );

         gm2dData.copyPixels(inData,new Rectangle(0,sh-1,1,1), new Point(x-1,y+sh), null,null,true );
         gm2dData.copyPixels(inData,new Rectangle(0,sh-1,sw,1), new Point(x,y+sh), null,null,true );
         gm2dData.copyPixels(inData,new Rectangle(sw-1,sh-1,1,1), new Point(x+sw,y+sh), null,null,true );
      }

      gm2dData.copyPixels(inData,new Rectangle(0,0,sw,sh), new Point(x,y), null,null,true );

      return new Tile(this, new Rectangle(x,y,sw,sh) );
   }

   public function partition(inTW:Int, inTH:Int, inOffsetX:Int=0, inOffsetY:Int=0,
              inGapX:Int=0, inGapY:Int=0, ?inLimitX:Int, ?inLimitY:Int ) : Array<Tile>
   {
      var tiles_x = Std.int( (gm2dData.width-inOffsetX+inGapX)/(inTW+inGapX) );
      if (inLimitX!=null && tiles_x>inLimitX)
         tiles_x = inLimitX;
      var tiles_y = Std.int( (gm2dData.height-inOffsetY+inGapY)/(inTH+inGapY) );
      if (inLimitY!=null && tiles_y>inLimitY)
         tiles_y = inLimitY;

      var result = new Array<Tile>();
      var y = inOffsetY;
      for(ty in 0...tiles_y)
      {
         var x = inOffsetX;
         for(tx in 0...tiles_x)
         {
            result.push(new Tile(this, new Rectangle(x,y,inTW,inTH)));
            x += inTW+inGapX;
         }
         y += inTH+inGapY;
      }
      return result;
   }

   function getTileCount() { return mTiles.length; }
}

