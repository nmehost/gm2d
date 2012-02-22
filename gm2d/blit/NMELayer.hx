package gm2d.blit;

import nme.display.Graphics;

class NMELayer extends Layer
{
   var mXYID:Array<Float>;
   var mCurrentSheet:Tilesheet;
   public var gm2dShape:nme.display.Shape;
   
   function new(inVP:NMEViewport)
   {
      gm2dShape = new nme.display.Shape();
      mXYID = [];
      mCurrentSheet = null;
      super(inVP);
   }

   function Flush()
   {
      if (mXYID.length>0)
      {
         gm2dShape.graphics.drawTiles(mCurrentSheet.gm2dSheet,mXYID,blendAdd?Graphics.TILE_BLEND_ADD:0);
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
      inOX -= offsetX;
      inOY -= offsetY;
      gm2dShape.x = -inOX;
      gm2dShape.y = -inOY;

      if (dynamicRender!=null)
         dynamicRender(inOX,inOY);

      Flush();
   }


   public override function isPersistent() : Bool { return true; }

   public override function drawTile(inTile:Tile, inX:Float, inY:Float)
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

   override public function setVisible(inVis:Bool) : Bool
   {
      gm2dShape.visible = inVis;
      return super.setVisible(inVis);
   }


   public override function gm2dClear()
   {
      mCurrentSheet = null;
      mXYID = [];
      gm2dShape.graphics.clear();
   }

}
