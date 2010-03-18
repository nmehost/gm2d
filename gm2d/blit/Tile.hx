import flash.geom.Rectangle;

class Tile
{
	public var rect(default,null):Rectangle;
	public var id(default,null):Int;
	var sheet:Tilesheet;

	public function new(inSheet:Tilesheet, inRect:Rectangle)
	{
		sheet = inSheet;
		rect = inRect.clone();
		id = sheet.gm2dAllocTile(this);
	}
}
