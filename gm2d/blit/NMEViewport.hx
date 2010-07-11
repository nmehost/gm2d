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
      scrollRect = new Rectangle(0,0,inWidth,inHeight);
      /*
      if (!inTransparent)
         opaqueBackground = 
         #if neko
            getBG().rgb;
         #else
            getBG();
         #end
       */
   }

   public override function createLayer() : Layer
   {
      var layer = NMELayer.gm2dCreate(this);
      addLayer(layer);
      addChild(layer.gm2dShape);
      return layer;
   }

   override function resize(inWidth:Int, inHeight:Int)
   {
      scrollRect = new Rectangle(0,0,inWidth,inHeight);
      super.resize(inWidth,inHeight);
   }
 
   override function renderViewport()
   {
      for(layer in mLayers)
         layer.gm2dRender(originX,originY);
   }

}

