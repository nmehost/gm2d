package gm2d.blit;


class NMELayer extends Layer
{
   var mXYID:Array<Float>;
   var mCurrentSheet:Tilesheet;
   public var gm2dShape:nme.display.Shape;
   
   function new(inVP:NMEViewport)
   {
      super(inVP);
      mXYID = [];
      mCurrentSheet = null;
      gm2dShape = new nme.display.Shape();
   }

   function Flush()
   {
      if (mXYID.length>0)
      {
         gm2dShape.graphics.drawTiles(mCurrentSheet.gm2dSheet,mXYID);
         mCurrentSheet = null;
         mXYID = [];
      }
   }

   public static function gm2dCreate(inVP:NMEViewport)
   {
      return new NMELayer(inVP);
   }

   public override function gm2dRender(inOX:Float, inOY:Float)
   {
      Flush();
      gm2dShape.x = -inOX;
      gm2dShape.y = -inOY;
   }

   public override function addTile(inTile:Tile, inX:Float, inY:Float)
   {
      var sheet = inTile.sheet;
      if (sheet!=mCurrentSheet)
      {
         Flush();
         mCurrentSheet = sheet;
      }
      mXYID.push(inX-inTile.hotX);
      mXYID.push(inY-inTile.hotY);
      mXYID.push(inTile.id);
   }

   public override function gm2dClear()
   {
      mCurrentSheet = null;
      mXYID = [];
      gm2dShape.graphics.clear();
   }

}
