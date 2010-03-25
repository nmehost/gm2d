package gm2d.blit;


class NMELayer extends Layer
{
   function new(inVP:NMEViewport)
   {
      super(inVP);
   }

   public static function gm2dCreate(inVP:NMEViewport)
   {
      return new NMELayer(inVP);
   }

   public override function gm2dRender(inOX:Float, inOY:Float)
   {
   }

   public override function addTile(inTile:Tile, inX:Float, inY:Float)
   {
   }

   public function gmedClear()
   {
   }

}
