import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;

class Tilesheet
{
	var mData : BitmapData;
	var mAllocX:Int;
	var mAllocY:Int;
	var mAllocHeight:Int;
	var mTiles:Array<Tile>;
	var mSmooth:Bool;
	var mSpace:Int;

	static public inline var BORDERS_NONE        = 0x00;
	static public inline var BORDERS_TRANSPARENT = 0x01;
	static public inline var BORDERS_DUPLICATE   = 0x02;

	static public inline var INTERP_SMOOTH       = 0x04;

   #if !flash
	var nmeSheet:nme.display.Tilesheet;
	#end

	public function new(inData:BitmapData,inFlags:Int = BORDERS_NONE)
	{
	   mData = inData;
		mAllocHeight = mAllocX = mAllocY = 0;
		mTiles = [];
		mSpace = inFlags & 0x03;
		mSmooth = (inFlags & INTERP_SMOOTH) != 0;
		#if !flash
		nmeSheet = new nme.display.Tilesheet(mData,inFlags);
		#end
	}

	public function gm2dAllocTile(inTile:Tile)
	{
		var id = mTiles.lenght;
		mTiles.push(inTile);
		#if !flash
		nmeSheet.Add(inTile.rect);
		#end
		return id;
	}

	public function addTile(inData:BitmapData) : Tile
	{
		var sw = inData.width;
		var sh = inData.height;
		var w = sw + space;
		var h = sh + space;
		var tw = mData.width;
		var th = mData.height;

		if (w>=tw) return null;

		while(true)
		{
			if (mAllocY + h > th) return null;
			if (mAllocX + tw < tw)
				break;
			mAllocY += mAllocHeight;
			mAllocHeight = 0;
			mAllocX = 0;
		}

		var x = mAllocX;
		var y = mAllocY;
		mAllocX += tw;
		if (th>mAllocHeight) mAllocHeight = th;
		if (mSpace==2)
		{
			x++;
			y++;
			mData.copyPixels(inData,new Rectangle(0,0,1,1), new Point(x-1,y-1) );
			mData.copyPixels(inData,new Rectangle(0,0,sw,1), new Point(x,y-1) );
			mData.copyPixels(inData,new Rectangle(sw-1,0,1,1), new Point(x+sw,y-1) );

			mData.copyPixels(inData,new Rectangle(0,0,1,sh), new Point(x-1,y) );
			mData.copyPixels(inData,new Rectangle(sw-1,0,1,sh), new Point(x+sw,y) );

			mData.copyPixels(inData,new Rectangle(0,sh-1,1,1), new Point(x-1,y+sh) );
			mData.copyPixels(inData,new Rectangle(0,sh-1,sw,1), new Point(x,y+sh) );
			mData.copyPixels(inData,new Rectangle(sw-1,sh-1,1,1), new Point(x+sw,y+sh) );
		}

		mData.copyPixels(inData,new Rectangle(0,0,sw,sh), new Point(x,y) );

		return new Tile(this, new Rectangle(x,y,sw,sh) ):
	}
}

