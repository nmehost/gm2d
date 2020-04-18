package gm2d.svg;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.display.Graphics;
import gm2d.gfx.Gfx;

class PathSegment
{
   public static inline var MOVE  = 1;
   public static inline var DRAW  = 2;
   public static inline var CURVE = 3;
   public static inline var CUBIC = 4;
   public static inline var ARC   = 5;

   public var x:Float;
   public var y:Float;

   public function new(inX:Float,inY:Float)
   {
      x = inX;
      y = inY;
   }
   public function getType() : Int { return 0; }

   public function prevX() { return x; }
   public function prevY() { return y; }
   public function prevCX() { return x; }
   public function prevCY() { return y; }

   public function toGfx(inGfx:Gfx,ioContext:SvgRenderer)
   {
      ioContext.setLast(x,y);
      ioContext.firstX = ioContext.lastX;
      ioContext.firstY = ioContext.lastY;
      inGfx.moveTo(ioContext.lastX, ioContext.lastY);
   }

   public function getDirection(inFraction:Float, prev:PathSegment):Float
   {
      if (prev==null)
         return 0.0;
      var dx = x-prev.prevX();
      var dy = y-prev.prevY();
      var len = dx*dx+dy*dy;
      if (len==0)
         return 0;
      return Math.atan2(dy,dx);
   }

}

class MoveSegment extends PathSegment
{
   public function new(inX:Float,inY:Float) { super(inX,inY); }
   override public function getType() : Int { return PathSegment.MOVE; }
}


class DrawSegment extends PathSegment
{
   public function new(inX:Float, inY:Float) { super(inX,inY); }
   override public function toGfx(inGfx:Gfx,ioContext:SvgRenderer)
   {
      ioContext.setLast(x,y);
      inGfx.lineTo(ioContext.lastX,ioContext.lastY);
   }

   override public function getType() : Int { return PathSegment.DRAW; }
   public function toString() { return 'DrawSegment($x,$y)';}
}

class QuadraticSegment extends PathSegment
{
   public var cx:Float;
   public var cy:Float;

   public function new(inCX:Float, inCY:Float, inX:Float, inY:Float)
   {
      super(inX,inY);
      cx = inCX;
      cy = inCY;
   }

   override public function prevCX() { return cx; }
   override public function prevCY() { return cy; }

   override public function toGfx(inGfx:Gfx,ioContext:SvgRenderer)
   {
      ioContext.setLast(x,y);
      inGfx.curveTo(ioContext.transX(cx,cy) , ioContext.transY(cx,cy),
                    ioContext.lastX , ioContext.lastY );
   }

   override public function getType() : Int { return PathSegment.CURVE; }
   public function toString() { return 'QuadraticSegment($cx,$cy,$x,$y)';}
}

class CubicSegment extends PathSegment
{
   public var cx1:Float;
   public var cy1:Float;
   public var cx2:Float;
   public var cy2:Float;

   public function new(inCX1:Float, inCY1:Float, inCX2:Float, inCY2:Float, inX:Float, inY:Float )
   {
      super(inX,inY);
      cx1 = inCX1;
      cy1 = inCY1;
      cx2 = inCX2;
      cy2 = inCY2;
   }

   override public function prevCX() { return cx2; }
   override public function prevCY() { return cy2; }

   function Interp(a:Float, b:Float, frac:Float)
   {
      return a + (b-a)*frac;
   }

   override public function toGfx(inGfx:Gfx,ioContext:SvgRenderer)
   {
      // Transformed endpoints/controlpoints
      var tx0 = ioContext.lastX;
      var ty0 = ioContext.lastY;

      var tx1 = ioContext.transX(cx1,cy1);
      var ty1 = ioContext.transY(cx1,cy1);
      var tx2 = ioContext.transX(cx2,cy2);
      var ty2 = ioContext.transY(cx2,cy2);

      ioContext.setLast(x,y);
      var tx3 = ioContext.lastX;
      var ty3 = ioContext.lastY;

      // from http://www.timotheegroleau.com/Flash/articles/cubic_bezier/bezier_lib.as

      var pa_x = Interp(tx0,tx1,0.75);
      var pa_y = Interp(ty0,ty1,0.75);
      var pb_x = Interp(tx3,tx2,0.75);
      var pb_y = Interp(ty3,ty2,0.75);

	   // get 1/16 of the [P3, P0] segment
	   var dx = (tx3 - tx0)/16;
	   var dy = (ty3 - ty0)/16;
	
	   // calculates control point 1
	   var pcx_1 = Interp(tx0, tx1, 3/8);
	   var pcy_1 = Interp(ty0, ty1, 3/8);
	
	   // calculates control point 2
	   var pcx_2 = Interp(pa_x, pb_x, 3/8) - dx;
	   var pcy_2 = Interp(pa_y, pb_y, 3/8) - dy;
	
	   // calculates control point 3
	   var pcx_3 = Interp(pb_x, pa_x, 3/8) + dx;
	   var pcy_3 = Interp(pb_y, pa_y, 3/8) + dy;
	
	   // calculates control point 4
	   var pcx_4 = Interp(tx3, tx2, 3/8);
	   var pcy_4 = Interp(ty3, ty2, 3/8);
	
	   // calculates the 3 anchor points
	   var pax_1 = (pcx_1+pcx_2) * 0.5;
	   var pay_1 = (pcy_1+pcy_2) * 0.5;

	   var pax_2 = (pa_x+pb_x) * 0.5;
	   var pay_2 = (pa_y+pb_y) * 0.5;

	   var pax_3 = (pcx_3+pcx_4) * 0.5;
	   var pay_3 = (pcy_3+pcy_4) * 0.5;

	   // draw the four quadratic subsegments
	   inGfx.curveTo(pcx_1, pcy_1, pax_1, pay_1);
	   inGfx.curveTo(pcx_2, pcy_2, pax_2, pay_2);
	   inGfx.curveTo(pcx_3, pcy_3, pax_3, pay_3);
	   inGfx.curveTo(pcx_4, pcy_4, tx3, ty3);

   }

   public function toQuadratics(tx0:Float,ty0:Float) : Array<PathSegment>
   {
      var result = new Array<PathSegment>();
      // from http://www.timotheegroleau.com/Flash/articles/cubic_bezier/bezier_lib.as

      // Are all points co-linear?
      var dx1 = cx1-tx0;
      var dy1 = cy1-ty0;
      if (Math.abs(dx1)<0.00001 && Math.abs(dy1)<0.00001)
      {
         result.push( new QuadraticSegment(cx2,cy2,x,y) );
         return result;
      }
      var dx2 = cx2-tx0;
      var dy2 = cy2-ty0;
      if (Math.abs(dx1*dy2-dx2*dy1)<0.00001)
      {
         var dx3 = x-tx0;
         var dy3 = y-ty0;
         if (Math.abs(dx1*dy3-dx3*dy1)<0.00001)
         {
            result.push( new DrawSegment(x,y) );
            return result;
         }
      }

      var pa_x = Interp(tx0,cx1,0.75);
      var pa_y = Interp(ty0,cy1,0.75);
      var pb_x = Interp(x,cx2,0.75);
      var pb_y = Interp(y,cy2,0.75);

	   // get 1/16 of the [P3, P0] segment
	   var dx = (x - tx0)/16;
	   var dy = (y - ty0)/16;
	
	   // calculates control point 1
	   var pcx_1 = Interp(tx0, cx1, 3/8);
	   var pcy_1 = Interp(ty0, cy1, 3/8);
	
	   // calculates control point 2
	   var pcx_2 = Interp(pa_x, pb_x, 3/8) - dx;
	   var pcy_2 = Interp(pa_y, pb_y, 3/8) - dy;
	
	   // calculates control point 3
	   var pcx_3 = Interp(pb_x, pa_x, 3/8) + dx;
	   var pcy_3 = Interp(pb_y, pa_y, 3/8) + dy;
	
	   // calculates control point 4
	   var pcx_4 = Interp(x, cx2, 3/8);
	   var pcy_4 = Interp(y, cy2, 3/8);
	
	   // calculates the 3 anchor points
	   var pax_1 = (pcx_1+pcx_2) * 0.5;
	   var pay_1 = (pcy_1+pcy_2) * 0.5;

	   var pax_2 = (pa_x+pb_x) * 0.5;
	   var pay_2 = (pa_y+pb_y) * 0.5;

	   var pax_3 = (pcx_3+pcx_4) * 0.5;
	   var pay_3 = (pcy_3+pcy_4) * 0.5;

	   // draw the four quadratic subsegments
	   result.push(new QuadraticSegment(pcx_1, pcy_1, pax_1, pay_1));
	   result.push(new QuadraticSegment(pcx_2, pcy_2, pax_2, pay_2));
	   result.push(new QuadraticSegment(pcx_3, pcy_3, pax_3, pay_3));
	   result.push(new QuadraticSegment(pcx_4, pcy_4, x, y));
      return result;
   }


   override public function getType() : Int { return PathSegment.CUBIC; }
}

class ArcSegment extends PathSegment
{
   var x1:Float;
   var y1:Float;
   var rx:Float;
   var ry:Float;
   var phi:Float;
   var fA:Bool;
   var fS:Bool;

   public function new( inX1:Float, inY1:Float, inRX:Float, inRY:Float, inRotation:Float,
                        inLargeArc:Bool, inSweep:Bool, x:Float, y:Float)
   {
      x1 = inX1;
      y1 = inY1;
      super(x,y);
      rx = inRX;
      ry = inRY;
      phi = inRotation;
      fA = inLargeArc;
      fS = inSweep;
   }

   public function toQuadratics(tx0:Float,ty0:Float) : Array<PathSegment>
   {
      var result = new Array<PathSegment>();
      if (rx==0 || ry==0)
         result.push( new DrawSegment(x,y) );
      else
      {
         var rx = this.rx<0 ? -this.rx : this.rx;
         var ry = this.ry<0 ? -this.ry : this.ry;
  
         if (rx<0) rx = -rx;
         if (ry<0) ry = -ry;
  
         // See:  http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
         var p = phi*Math.PI/180.0;
         var cos = Math.cos(p);
         var sin = Math.sin(p);
  
         // Step 1, compute x', y'
         var dx = (x1-x)*0.5;
         var dy = (y1-y)*0.5;
         var x1_ = cos*dx + sin*dy;
         var y1_ = -sin*dx + cos*dy;
  
         // Step 2, compute cx', cy'
         var rx2 = rx*rx;
         var ry2 = ry*ry;
         var x1_2 = x1_*x1_;
         var y1_2 = y1_*y1_;
         var s = (rx2*ry2 - rx2*y1_2 - ry2*x1_2) /
                   (rx2*y1_2 + ry2*x1_2 );
         if (s<0)
            s=0;
         else if (fA==fS)
            s = -Math.sqrt(s);
         else
            s = Math.sqrt(s);
  
         var cx_ = s*rx*y1_/ry;
         var cy_ = -s*ry*x1_/rx;
  
         // Step 3, compute cx,cy from cx',cy'
         // Something not quite right here.
  
         var xm = (x1+x)*0.5;
         var ym = (y1+y)*0.5;
  
         var cx = cos*cx_ - sin*cy_ + xm;
         var cy = sin*cx_ + cos*cy_ + ym;
  
         var theta = Math.atan2( (y1_-cy_)/ry, (x1_-cx_)/rx );
         var dtheta = Math.atan2( (-y1_-cy_)/ry, (-x1_-cx_)/rx ) - theta;
  
         if (fS && dtheta<0)
            dtheta+=2.0*Math.PI;
         else if (!fS && dtheta>0)
            dtheta-=2.0*Math.PI;
  
         var quartics = Std.int( Math.abs(dtheta) * 4/Math.PI + 0.99 );
         if (quartics<1)
         { 
            result.push( new DrawSegment(x,y) );
         }
         else
         {
            var Txc = rx;
            var Tx0 = cx;
            var Tys = ry;
            var Ty0 = cy;
 
            dtheta /= quartics;
            var p0x = tx0;
            var p0y = ty0;

            var dDx0 = Math.sin(theta)*Txc;
            var dDy0 = -Math.cos(theta)*Tys;
            for(q in 0...quartics)
            {
               theta+=dtheta;

               var p1x = Txc*Math.cos(theta) + Tx0;
               var p1y = Tys*Math.sin(theta) + Ty0;
               var dDx1 = Math.sin(theta)*Txc;
               var dDy1 = -Math.cos(theta)*Tys;

               // Intersection of (p0 + a*dD0 = p1 + b*dD1 )
               //   (p0x-p1x) + a.dDx0 = b.dDx1
               //   (p0y-p1y) + a.dDy0 = b.dDy1
               //  (p0x-p1x)*dDy0 - (p0y-p1y)*dDx0 = b*(dDx1*dDy0-dDy1*dDx0)
               var b = ( (p0x-p1x)*dDy0 - (p0y-p1y)*dDx0 ) / (dDx1*dDy0 - dDy1*dDx0);

               result.push( new QuadraticSegment( p1x+b*dDx1, p1y+b*dDy1, p1x,p1y) );

               p0x = p1x;
               p0y = p1y;
               dDx0 = dDx1;
               dDy0 = dDy1;
            }
         }
      }

      return result;
   }

   override public function toGfx(inGfx:Gfx,ioContext:SvgRenderer)
   {
       if (x1==x && y1==y)
          return;
       ioContext.setLast(x,y);
       if (rx==0 || ry==0)
       {
          inGfx.lineTo(ioContext.lastX, ioContext.lastY);
          return;
       }

       var rx = this.rx<0 ? -this.rx : this.rx;
       var ry = this.ry<0 ? -this.ry : this.ry;

       if (rx<0) rx = -rx;
       if (ry<0) ry = -ry;

       // See:  http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
       var p = phi*Math.PI/180.0;
       var cos = Math.cos(p);
       var sin = Math.sin(p);

       // Step 1, compute x', y'
       var dx = (x1-x)*0.5;
       var dy = (y1-y)*0.5;
       var x1_ = cos*dx + sin*dy;
       var y1_ = -sin*dx + cos*dy;

       // Step 2, compute cx', cy'
       var rx2 = rx*rx;
       var ry2 = ry*ry;
       var x1_2 = x1_*x1_;
       var y1_2 = y1_*y1_;
       var s = (rx2*ry2 - rx2*y1_2 - ry2*x1_2) /
                 (rx2*y1_2 + ry2*x1_2 );
       if (s<0)
          s=0;
       else if (fA==fS)
          s = -Math.sqrt(s);
       else
          s = Math.sqrt(s);

       var cx_ = s*rx*y1_/ry;
       var cy_ = -s*ry*x1_/rx;

       // Step 3, compute cx,cy from cx',cy'
       // Something not quite right here.

       var xm = (x1+x)*0.5;
       var ym = (y1+y)*0.5;

       var cx = cos*cx_ - sin*cy_ + xm;
       var cy = sin*cx_ + cos*cy_ + ym;

       var theta = Math.atan2( (y1_-cy_)/ry, (x1_-cx_)/rx );
       var dtheta = Math.atan2( (-y1_-cy_)/ry, (-x1_-cx_)/rx ) - theta;

       if (fS && dtheta<0)
          dtheta+=2.0*Math.PI;
       else if (!fS && dtheta>0)
          dtheta-=2.0*Math.PI;


       var m = ioContext.getMatrix();

       var len = Math.abs(dtheta)*Math.sqrt(rx*rx + ry*ry);
       if (m!=null)
          len *= Math.sqrt(m.a*m.a + m.b*m.b);
  
       // TODO: Do as series of quadratics ...
       var steps = Math.round(len);
       

       if (steps>1)
       {
          dtheta /= steps;
          for(i in 1...steps-1)
          {
             var c = Math.cos(theta)*rx;
             var s = Math.sin(theta)*ry;
             theta+=dtheta;
             var px = cx + cos*c - sin*s;
             var py = cy + sin*c + cos*s;
             if (m==null)
                inGfx.lineTo(px,py);
             else
                inGfx.lineTo(m.a*px + m.c*py + m.tx, m.b*px + m.d*py + m.ty);
          }
       }
       inGfx.lineTo(ioContext.lastX, ioContext.lastY);
   }
   override public function getType() : Int { return PathSegment.ARC; }
}




