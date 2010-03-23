package gm2d.blit;
import gm2d.geom.Rectangle;

class Tile
{
	public var rect(default,null):Rectangle;
	public var id(default,null):Int;
	public var sheet:Tilesheet;
	public var hotX:Float;
	public var hotY:Float;

	public function new(inSheet:Tilesheet, inRect:Rectangle)
	{
		sheet = inSheet;
		rect = inRect.clone();
		id = sheet.gm2dAllocTile(this);
		hotX = hotY = 0;
	}
}
