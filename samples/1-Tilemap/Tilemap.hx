import gm2d.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.blit.Grid;
import gm2d.Game;
import gm2d.events.Event;
import gm2d.Screen;

import gm2d.ui.Keyboard;


class Tilemap extends Screen
{
   var mResources:Hash<Dynamic>;
   var mTilesheet:Tilesheet;
   var mTiles:Array<Tile>;
   var mViewport:gm2d.blit.Viewport;
   var mMapLayer:Layer;
   var mPlayerLayer:Layer;
   var mPlayerX:Float;
   var mPlayerY:Float;

   static var map = [
     "########################################",
     "#      #####      ######################",
     "#     ###### #    ####      ##        ##",
     "#     ###### ########O     ###        ##",
     "### ########       ###     ###       ###",
     "### ############## ##### ######## ######",
     "###         ###### ##### ######## ######",
     "### ####### ###### ##### ######## ######",
     "### #######        #####              ##",
     "#        ############################ ##",
     "#               # ##          ####### ##",
     "#        #####    ## ########       # ##",
     "#        ###### ################### # ##",
     "## ############ ################### # ##",
     "## #   #     ## ###            #### # ##",
     "## # ###     ## ### ########## #### # ##",
     "## # ##### #### ### ########## #### # ##",
     "## # #####      ### ########## #### # ##",
     "##   ###### ####### ########## #### # ##",
     "########### ####### ########## #### # ##",
     "########### #######      ##### #### # ##",
     "########### ############       #### # ##",
     "########### ############ ########## # ##",
     "##                       ########## # ##",
     "## ################################ # ##",
     "## ################################ # ##",
     "## ############                       ##",
     "## ############ ##### ##################",
     "## ############ ##### ##################",
     "##        ##### ##### ##################",
     "##        ##### ##### ##################",
     "##        ##### #####               ####",
     "#### ########## #####               ####",
     "#  # ########## #####               ####",
     "# ## ########## #####               ####",
     "# ##             ############ ##########",
     "# ########################### ##########",
     "# ########################### ##########",
     "#                             ##########",
     "########################################"
];

   function new()
   {
      super();
      var loader = new gm2d.reso.Loader();
      loader.loadBitmap("Tiles.png","tiles");
      loader.Process(onLoaded);
   }

   function onLoaded(inResources:Hash<Dynamic>)
   {
      mResources = inResources;
      //cpp bug
      mTilesheet = new Tilesheet(mResources.get("tiles"));
      //var bmp:gm2d.display.BitmapData = mResources.get("tiles");
      //mTilesheet = new Tilesheet(bmp);
      mTiles = mTilesheet.partition(32,32);
      mTiles[3].hotX = 16;
      mTiles[3].hotY = 16;

      mViewport = gm2d.blit.Viewport.create(400, 300);
      mViewport.worldWidth = 640*2;
      mViewport.worldHeight = 640*2;
      mViewport.x = 40;
      mViewport.y = 10;
      addChild(mViewport);
      //mViewport.cacheAsBitmap = true;

      var grid = new Grid();
      for(y in 0...40)
      {
         var row = map[y];
         grid[y] = new Tiles();
         var tiles = grid[y];
         for(x in 0...40)
         {
            switch( row.substr(x,1) )
            {
               case "#" : tiles.push(mTiles[0]);
               case " " : tiles.push(mTiles[1]);
               case "O" : tiles.push(mTiles[2]);
               default  : tiles.push(null);
            }
         }
      }

      mMapLayer = mViewport.createGridLayer(grid);
      mPlayerLayer = mViewport.createLayer();

      mPlayerX = 48;
      mPlayerY = 48;
      mPlayerLayer.addTile(mTiles[3],mPlayerX,mPlayerY);

      makeCurrent();
      /*
      flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, function(_)
        {
           flash.Lib.current.stage.fullScreenSourceRect = new flash.geom.Rectangle(0,0,480,320);
           flash.Lib.current.stage.displayState = flash.display.StageDisplayState.FULL_SCREEN;
           
        } );
      */
   }

   public function canMove(inX:Float, inY:Float)
   {
      var x0 = Std.int( (inX-8)/32 );
      var x1 = Std.int( (inX+8)/32 );
      var y0 = Std.int( (inY-8)/32 );
      var y1 = Std.int( (inY+8)/32 );

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
      Game.backgroundColor = 0x202040;
      Game.create(function() new Tilemap());
   }
}

