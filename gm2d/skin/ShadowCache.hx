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

   static public function create(lineStyle:LineStyle, fillStyle:FillStyle, depth:Float,flags:Int)
   {
      var result:ShadowInstance = null;
      for(i in instances)
         if (i.matches(lineStyle, fillStyle, depth, flags))
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

         var x0 = 6.0;
         var y0 = 6.0;
         var x1 = 32.0-6;
         var y1 = 32.0-6;
         var lw = Renderer.getLineWidth(lineStyle)*0.5;

         if ( (flags&ShadowFlags.TopSolid)>0 )
            y0 =  - lw;
         else if ( (flags&ShadowFlags.TopLine)>0 )
            y0 =  lw;

         if ( (flags&ShadowFlags.LeftSolid)>0 )
            x0 =  - lw;
         else if ( (flags&ShadowFlags.LeftLine)>0 )
            x0 =  lw;

         if ( (flags&ShadowFlags.RightSolid)>0 )
            x1 =  32+lw;
         else if ( (flags&ShadowFlags.RightLine)>0 )
            x1 =  32-lw;


         if ( (flags&ShadowFlags.BottomSolid)>0 )
            y1 =  32+lw;
         else if ( (flags&ShadowFlags.BottomLine)>0 )
            y1 =  32-lw;

         gfx.drawRect(x0,y0,x1-x0,y1-y0);

         child.filters = [ new DropShadowFilter(depth,90,0,0.8,depth*2+3,depth*2+3,1) ];

         bmp.draw(drawing);

         var inner =  new Rectangle(10,10,12,12);
         result = new ShadowInstance(lineStyle, fillStyle, depth, flags, bmp, inner);
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

