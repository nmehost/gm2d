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

   static public function create(lineStyle:LineStyle, fillStyle:FillStyle, depth:Float,flags:Int,rad:Float)
   {
      var result:ShadowInstance = null;
      for(i in instances)
         if (i.matches(lineStyle, fillStyle, depth, flags, rad))
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
         Renderer.setFill(gfx,fillStyle,null);
         Renderer.setLine(gfx,lineStyle);

         var lw = Renderer.getLineWidth(lineStyle)*0.5;
         var rectMode =  (flags & EdgeFlags.Rect) > 0;
         var gap = rectMode ? lw : 6.0;

         var x0 = gap;
         var y0 = gap;
         var x1 = 32.0-gap;
         var y1 = 32.0-gap;
         var avoid = lw + rad;

         if ( (flags&EdgeFlags.TopSolid)>0 )
            y0 =  - avoid;
         else if ( (flags&EdgeFlags.TopLine)>0 )
            y0 =  lw;

         if ( (flags&EdgeFlags.LeftSolid)>0 )
            x0 =  - avoid;
         else if ( (flags&EdgeFlags.LeftLine)>0 )
            x0 =  lw;

         if ( (flags&EdgeFlags.RightSolid)>0 )
            x1 =  32+avoid;
         else if ( (flags&EdgeFlags.RightLine)>0 )
            x1 =  32-lw;


         if ( (flags&EdgeFlags.BottomSolid)>0 )
            y1 =  32+avoid;
         else if ( (flags&EdgeFlags.BottomLine)>0 )
            y1 =  32-lw;

         if (rad==0)
            gfx.drawRect(x0,y0,x1-x0,y1-y0);
         else
            gfx.drawRoundRect(x0,y0,x1-x0,y1-y0,rad,rad);

         if (depth>0)
            child.filters = [ new DropShadowFilter(depth,90,0,0.8,depth*2+3,depth*2+3,1) ];
         else
            child.filters = null;

         bmp.draw(drawing);

         var inner =  new Rectangle(10,10,12,12);
         result = new ShadowInstance(lineStyle, fillStyle, depth, flags, rad, bmp, inner);
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

