package gm2d.blit;

#if flash
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
#end

class Layer
{
	public var offsetX(default,setOffsetX):Float;
	public var offsetY(default,setOffsetY):Float;
	var mViewport:Viewport;
	#if flash
	var mHead:LayerTile;
	var mLast:LayerTile;
	#end

	public function new()
	{
		offsetX = 0;
		offsetY = 0;
		#if flash
		mHead = null;
		mLast = null;
		#end
	}

	#if flash
	public function render(inBitmap:flash.display.BitmapData,inOX:Float, inOY:Float)
	{
		var tile = mHead;
		var pos = new flash.geom.Point();
		var ox = offsetX - inOX;
		var oy = offsetY - inOY;
		while(tile!=null)
		{
			pos.x = tile.x + ox;
			pos.y = tile.y + oy;
			inBitmap.copyPixels(tile.tile.sheet.gm2dData, tile.tile.rect, pos);
			tile = tile.next;
		}
	}
	#end

	public function gm2dSetViewport(inViewport:Viewport)
	{
		mViewport = inViewport;
	}

	public function addTile(inTile:Tile, inX:Float, inY:Float)
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

	public function clear()
	{
		if (mViewport!=null) { mViewport.makeDirty(); }
		mHead = mLast = null;
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
