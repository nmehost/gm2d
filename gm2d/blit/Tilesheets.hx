package gm2d.blit;

import nme.display.BitmapData;
import gm2d.blit.Tile;
import gm2d.blit.Tilesheet;


class Tilesheets
{
   var mConstructTilesheet:Tilesheet;

   public function new()
   {
   }

   function NextPOT(inVal:Int)
   {
      var result = 1;
      while(result<inVal)
         result<<=1;
      return result;
   }

   public function addData(inData:BitmapData) : Tile
   {
      var tile:Tile = null;
      for(pass in 0...2)
      {
         if (mConstructTilesheet==null)
         {
            var w = NextPOT(inData.width * 10);
            if (w>512) w = 512;
            if (w<inData.width) w = inData.width;
            var h = NextPOT(inData.height * 10);
            if (h>512) h = 512;
            if (h<inData.height) h = inData.height;
            mConstructTilesheet = Tilesheet.create(w,h,Tilesheet.BORDERS_TRANSPARENT);
         }
         tile = mConstructTilesheet.addTile(inData);
         if (tile==null)
            mConstructTilesheet = null;
         else
            break;
      }
      return tile;
   }

   public static inline var FLIP_X = 0x0001;
   public static inline var FLIP_Y = 0x0002;
   public static inline var FLIP_XY = 0x0004;
   public function addTransformed(inTile:Tile, inTransform:Int) : Tile
	{
	   var r = inTile.rect;
		var fxy = (inTransform & FLIP_XY) > 0;
		var fx = (inTransform & FLIP_X) > 0;
		var fy = (inTransform & FLIP_Y) > 0;
		if (fxy) { var t = fx; fx = fy; fy=t; }
		var w = Std.int(fxy ? r.height : r.width);
		var h = Std.int(fxy ? r.width : r.height);
		var data = new BitmapData(w,h,true);
		var src = inTile.sheet.gm2dData;
		var x0 = Std.int(r.x);
		var y0 = Std.int(r.y);
		for(y in 0...Std.int(r.height))
		   for(x in 0...Std.int(r.width))
			{
			   var xi = x;
			   var yi = y;
				if (fx) yi = h - 1 - yi;
				if (fy) xi = w - 1 - xi;
				if (fxy)
				{
				   var t = xi;
					xi = yi;
					yi = w - 1 - t;
				}
			   data.setPixel32( x, y,  src.getPixel32(x0 + xi, y0 + yi) );
			}
		return addData(data);
	}
}


