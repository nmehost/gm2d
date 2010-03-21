import gm2d.display.Sprite;


class Tilemap extends Sprite
{
	var mResources:Dynamic;

	function new()
	{
		super();
		var loader = new gm2d.game.Loader();
		loader.loadBitmap("Tiles.png","tiles");
		loader.Process(onLoaded);
	}

	function onLoaded(inResources:Dynamic)
	{
	   mResources = inResources;
		//trace("Loaded " + mResources);
	}


   static public function main()
	{
		gm2d.Lib.boot(function() new Tilemap());
	}
}

