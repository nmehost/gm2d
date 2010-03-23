import gm2d.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.Game;
import gm2d.Screen;

import flash.ui.Keyboard;


class Tilemap extends Screen
{
   var mResources:Dynamic;
   var mTilesheet:Tilesheet;
   var mTiles:Array<Tile>;
   var mViewport:gm2d.blit.Viewport;
   var mMapLayer:Layer;
   var mPlayerLayer:Layer;
	var mPlayerX:Float;
	var mPlayerY:Float;

   static var map = [
     "####################",
     "#     ######      ##",
     "#     ###### #    ##",
     "#     ###### #######",
     "### ########       #",
     "### ############## #",
     "###         ###### #",
     "### ####### ###### #",
     "### #######        #",
     "#        ###########",
     "#               # ##",
     "#        #####    ##",
     "#        ###### ####",
     "## ############ ####",
     "## #  ##     ## ####",
     "## # ##O     ## ####",
     "## # ##### #### ####",
     "## # #####      ####",
     "##   ###############",
     "####################" ];

   function new()
   {
      super("Main");
      var loader = new gm2d.game.Loader();
      loader.loadBitmap("Tiles.png","tiles");
      loader.Process(onLoaded);
   }

   function onLoaded(inResources:Dynamic)
   {
      mResources = inResources;
      mTilesheet = new Tilesheet(mResources.get("tiles"));
      mTiles = mTilesheet.partition(32,32);
		mTiles[3].hotX = 16;
		mTiles[3].hotY = 16;

      mViewport = new gm2d.blit.Viewport(400, 300, false, 0xff0000);
      mViewport.worldWidth = 640;
      mViewport.worldHeight = 640;
      mViewport.x = 40;
      mViewport.y = 10;
      addChild(mViewport);
      mMapLayer = new gm2d.blit.Layer();
      mViewport.addLayer(mMapLayer);
      mPlayerLayer = new gm2d.blit.Layer();
      mViewport.addLayer(mPlayerLayer);

      for(y in 0...20)
      {
         var row = map[y];
         for(x in 0...20)
         {
            switch( row.substr(x,1) )
            {
               case "#" : mMapLayer.addTile(mTiles[0],x*32,y*32);
               case " " : mMapLayer.addTile(mTiles[1],x*32,y*32);
               case "O" : mMapLayer.addTile(mTiles[2],x*32,y*32);
            }
         }
      }

      mPlayerX = 48;
      mPlayerY = 48;
      mPlayerLayer.addTile(mTiles[3],mPlayerX,mPlayerY);
      makeCurrent();
   }

	public function canMove(inX:Float, inY:Float)
	{
		var x0 = Std.int( (inX-10)/32 );
		var x1 = Std.int( (inX+10)/32 );
		var y0 = Std.int( (inY-10)/32 );
		var y1 = Std.int( (inY+10)/32 );

		for(y in y0...y1+1)
			for(x in x0...x1+1)
				if (map[y].substr(x,1)=="#")
					return false;
		return true;
	}

   override public function updateDelta(inDT:Float)
	{
		if (inDT>0.1) inDT = 0.1;
		var px = mPlayerX;
		if (Game.isKeyDown(Keyboard.LEFT))
			px -= inDT*100;
		if (Game.isKeyDown(Keyboard.RIGHT))
			px += inDT*100;
      if (px!=0 && canMove(px,mPlayerY))
			mPlayerX = px;

		var py = mPlayerY;
		if (Game.isKeyDown(Keyboard.UP))
			py -= inDT*100;
		if (Game.isKeyDown(Keyboard.DOWN))
			py += inDT*100;
      if (py!=0 && canMove(mPlayerX,py))
			mPlayerY = py;

	   mPlayerLayer.clear();
      mPlayerLayer.addTile(mTiles[3],mPlayerX,mPlayerY);
      mViewport.centerOn(mPlayerX,mPlayerY);
	}


   static public function main()
   {
      Game.useHardware = true;
      Game.title = "Tilemap";
      Game.showFPS = true;
      Game.fpsColor = 0xffffff;
      Game.create(function() new Tilemap());
   }
}

