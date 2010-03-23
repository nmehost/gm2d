import gm2d.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.Game;
import gm2d.Screen;


class Tilemap extends Screen
{
   var mResources:Dynamic;
   var mTilesheet:Tilesheet;
   var mTiles:Array<Tile>;
   var mViewport:gm2d.blit.Viewport;
   var mMapLayer:Layer;
   var mPlayerLayer:Layer;

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
     "#        #####    ##",
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

      mViewport.centerOn(300,300);
      makeCurrent();
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

