package gm2d.skin;

import nme.display.BitmapData;
import nme.display.Sprite;
import nme.display.Shape;
import nme.geom.Rectangle;
import nme.filters.BitmapFilter;
import nme.filters.BitmapFilterType;
import nme.filters.DropShadowFilter;
import nme.filters.GlowFilter;



class ShadowCache
{
   static var now = 0.0;
   static var instances = new Array<ShadowInstance>();
   static var drawing:Sprite;

   static public function create(lineStyle:LineStyle, fillStyle:FillStyle, depth:Float)
   {
      var result:ShadowInstance = null;
      for(i in instances)
         if (i.matches(lineStyle, fillStyle, depth))
         {
            result = i;
            break;
         }

      if (result==null)
      {
         var bmp = new BitmapData(32,32,true,0x0000ff);
         initGfx();
         var child = new Shape();
         drawing.addChild(child);

         var gfx = child.graphics;
         Renderer.setFill(gfx,fillStyle);
         Renderer.setLine(gfx,lineStyle);
         gfx.drawRect(6,6,32-6*2,32-6*2);
         child.filters = [ new DropShadowFilter(depth,90,0,0.8,depth*2+3,depth*2+3,1) ];

         bmp.draw(drawing);

         var inner =  new Rectangle(10,10,12,12);
         result = new ShadowInstance(lineStyle, fillStyle, depth, bmp, inner);
         instances.push(result);
      }

      result.use( now++ );

      return result;
   }

   static function initGfx()
   {
      if (drawing==null)
         drawing = new Sprite();
      else
      {
         drawing.graphics.clear();
         while(drawing.numChildren>0)
            drawing.removeChildAt( drawing.numChildren-1 );
      }
   }

}

