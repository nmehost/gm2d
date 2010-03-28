package gm2d.blit;

import gm2d.blit.Grid;


class GridHandler
{
   var mLayer:Layer;
   var mGrid:Grid;
   var mGridW:Int;
   var mGridH:Int;
   var mTileW:Int;
   var mTileH:Int;

   var mLastX0:Int;
   var mLastY0:Int;
   var mLastX1:Int;
   var mLastY1:Int;

   public function new(inLayer:Layer, inGrid:Grid)
   {
      mLayer = inLayer;
      mGrid = inGrid;

      mGridH = mGrid.length;
      mTileW = mTileH = mGridW = 0;

      for(row in mGrid)
      {
         if (row.length>mGridW) mGridW = row.length;
         for(tile in row)
         {
            if (tile.rect.width>mTileW)
               mTileW = Std.int(tile.rect.width);
            if (tile.rect.height>mTileH)
               mTileH = Std.int(tile.rect.height);
         }
      }

      inLayer.dynamicRender = doRender;
      mLastX0 = mLastY0 = mLastX1 = mLastY1 = 0;
   }

   function doRender(inOX:Float, inOY:Float) : Void
   {
      var x0 = Std.int(Math.floor(inOX/mTileW));
      var y0 = Std.int(Math.floor(inOY/mTileH));
      var x1 = Std.int(Math.ceil((mLayer.viewWidth+inOX)/mTileW));
      var y1 = Std.int(Math.ceil((mLayer.viewHeight+inOY)/mTileH));

      if (x1<0 || y1<0 || x0>=mGridW || y0>=mGridH )
         return;

      if (mLayer.isPersistent())
      {
         if (x0>=mLastX0 && y0>=mLastY0 && x1<=mLastX1 && y1<=mLastY1)
            return;

         // Add gap, so we don't have to re-do the map too often
         x0--;
         y0--;
         x1++;
         y1++;
         // Don't need to re-do if it is in these bounds
         mLastX0 = x0;
         mLastY0 = y0;
         mLastX1 = x1;
         mLastY1 = y1;
      }

      mLayer.clear();

      if (x0<0) x0 = 0;
      if (y0<0) y0 = 0;
      if (x1>mGridW) x1=mGridW;
      if (y1>mGridH) y1=mGridH;
 
      if (x0>=x1 || y0>=y1) return;

      for(y in y0...y1)
      {
         var row = mGrid[y];
         var ty = y*mTileH;
         for(x in x0...x1)
         {
            var tile = row[x];
            if (tile!=null)
            {
               mLayer.drawTile(tile,x*mTileW,ty);
            }
         }
      }
   }

}
