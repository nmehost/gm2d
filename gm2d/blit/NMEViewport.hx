package gm2d.blit;

import gm2d.display.Sprite;
import gm2d.display.Stage;
import gm2d.events.Event;
import gm2d.geom.Rectangle;

class NMEViewport extends Viewport
{
   public function new(inWidth:Int, inHeight:Int,inTransparent:Bool,inBackground)
   {
      super(inWidth,inHeight,inTransparent,inBackground);
   }

   public override function createLayer() : Layer
   {
      var layer = NMELayer.gm2dCreate(this);
      addLayer(layer);
		addChild(layer.gm2dShape);
      return layer;
   }



   override function renderViewport()
   {
   }

}

