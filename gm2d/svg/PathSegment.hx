package gm2d.svg;
import gm2d.geom.Rectangle;
import gm2d.geom.Matrix;
import gm2d.geom.Point;
import gm2d.display.Graphics;

class PathSegment
{
   var x:Float;
   var y:Float;

   public function new(inX:Float,inY:Float,inRel:Bool)
   {
      x = inX;
      y = inY;
   }

   public function prevX() { return x; }
   public function prevY() { return y; }
   public function prevCX() { return x; }
   public function prevCY() { return y; }

   public function Draw(inGfx:Graphics,ioContext:RenderContext)
   {
      ioContext.setLast(x,y);
      ioContext.firstX = ioContext.lastX;
      ioContext.firstY = ioContext.lastY;
      inGfx.moveTo(ioContext.lastX,ioContext.lastY);
   }

   public function Extent(ioRect:Rectangle)
   {
      AddExtent(x,y,ioRect);
   }

   function AddExtent(inX:Float, inY:Float, ioExtent : Rectangle )
   {
      if (inX<ioExtent.left) ioExtent.left = inX;
      if (inX>ioExtent.right) ioExtent.right = inX;
      if (inY<ioExtent.top) ioExtent.top = inY;
      if (inY>ioExtent.bottom) ioExtent.bottom = inY;
   }
}

class MoveSegment extends PathSegment
{
   public function new(inX:Float,inY:Float,inRel:Bool) { super(inX,inY,inRel); }
}


class DrawSegment extends PathSegment
{
   public function new(inX:Float, inY:Float) { super(inX,inY); }
   override public function Draw(inGfx:Graphics,ioContext:RenderContext)
   {
      ioContext.setLast(x,y);
      inGfx.lineTo(ioContext.lastX,ioContext.lastY);
   }
}

class QuadraticSegment extends PathSegment
{
   var cx:Float;
   var cy:Float;

   public function new(inCX:Float, inCY:Float, inX:Float, inY:Float)
   {
      super(inX,inY);
      cx = inCX;
      cy = inCY;
   }

   override public function prevCX() { return cx; }
   override public function prevCY() { return cy; }

   override public function Draw(inGfx:Graphics,ioContext:RenderContext)
   {
      ioContext.setLast(x,y);
      inGfx.curveTo( ioContext.transX(x,y),ioContext.transY(x,y), ioContext.lastX, ioContext.lastY);
   }

   override public function Extent(ioRect:Rectangle)
   {
      AddExtent(x,y);
      AddExtent(cx,cy);
   }
}

class CubicSegment extends PathSegment
{
   var cx1:Float;
   var cy1:Float;
   var cx2:Float;
   var cy2:Float;

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

   override public function Draw(inGfx:Graphics,ioContext:RenderContext)
   {
      var tx = ioContext.lastX;
      var ty = ioContext.lastY;
      ioContext.setLast(x,y);
      var tx1 = ioContext.lastX;
      var ty1 = ioContext.lastY;

      var tcx1 = ioContext.transX(cx1,cx1);
      var tcy1 = ioContext.transY(cy1,cy1);
      var tcx2 = ioContext.transX(cx2,cy2);
      var tcy2 = ioContext.transY(cx2,cy2);

       var dx1 = tcx1-tx0;
       var dy1 = tcy1-ty0;
       var dx2 = tcx2-tcx1;
       var dy2 = tcy2-tcy1;
       var dx3 = tx-tcx2;
       var dy3 = ty-tcy2;
       var len = Math.sqrt(dx1*dx1+dy1*dy1 + dx2*dx2+dy2*dy2 + dx3*dx3+dy3*dy3);
       var steps = Math.round(len*0.4);

       if (steps>1)
       {
          var du = 1.0/steps;
          var u = du;
          for(i in 1...steps)
          {
             var u1 = 1.0-u;
             var c0 = u1*u1*u1;
             var c1 = 3*u1*u1*u;
             var c2 = 3*u1*u*u;
             var c3 = u*u*u;
             u+=du;
             mGfx.lineTo(c0*tc0 + c1*tcx1 + c2*tcx2 + c3*tx,
                         c0*tc0 + c1*tcy1 + c2*tcy2 + c3*ty );
          }
       }
       mGfx.lineTo(tx,ty);
   }
   override public function Extent(ioRect:Rectangle)
   {
      AddExtent(x,y);
      AddExtent(cx1,cy1);
      AddExtent(cx2,cy2);
   }
}

class ArcSegment extends PathSegment
{
   var rx:Float;
   var ry:Float;
   var rotation:Float;
   var largeArc:Bool;
   var sweep:Bool;

   public function new( inRX:Float, inRY:Float, inRotation:Float,
                        inLargeArc:Bool, inSweep:Bool, x:Float, y:Float)
   {
      super(x,y);
      rx = inRX;
      ry = inRY;
      rotation = inRotation;
      largeArc = inLargeArc;
      sweep = inSweep;
   }


   override public function Draw(inGfx:Graphics,ioContext:RenderContext)
   {
       ioContext.setLast(x,y);
       if (rx==0 || ry==0)
       {
          inGfx.lineTo(ioContext.lastX, ioContext.lastY);
          return;
       }
       if (rx<0) rx = -rx;
       if (ry<0) ry = -ry;

       var p = phi*Math.PI/180.0;
       var cos = Math.cos(p);
       var sin = Math.sin(p);
       var dx = (x1-x2)*0.5;
       var dy = (y1-y2)*0.5;
       var x1_ = cos*dx + sin*dy;
       var y1_ = -sin*dx + cos*dy;

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

       // Something not quite right here.
       // See:  http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
       var xm = (x1+x2)*0.5;
       var ym = (y1+y2)*0.5;

       var cx = cos*cx_ + sin*cy_ + xm;
       var cy = -sin*cx_ + cos*cy_ + ym;

       var theta = Math.atan2( (y1_-cy_)/ry, (x1_-cx_)/rx );
       var dtheta = Math.atan2( (-y1_-cy_)/ry, (-x1_-cx_)/rx ) - theta;

       if (fS && dtheta<0)
          dtheta+=2.0*Math.PI;
       else if (!fS && dtheta>0)
          dtheta-=2.0*Math.PI;


       // axis, at theta = 0;
       //
       // p =  [ M ] [ + centre ] [ rotate phi ] [ rx 0 ] [ cos(theta),sin(theta) ]t
       //                                        [ 0 ry ]
       //   = [ a c tx ] [ cos*rx  sin*ry cx ]  [ cos(theta), sin(theta) 1 ]t;
       //     [ b d ty ] [-sin*rx  cos*ry cy ]
       //     [ 0 0 1  ] [ 0       0       1 ]
       //
       var m = ioContext.matrix;
       if (m==null) m = new Matrix();
       var ta = m.a*cos*rx - m.c*sin*rx;
       var tc = m.a*sin*ry + m.c*cos*ry;
       var tx = m.a*cx     + m.c*cy + m.tx;

       var tb = m.b*cos*rx - m.d*sin*rx;
       var td = m.b*sin*ry + m.d*cos*ry;
       var ty = m.b*cx     + m.d*cy + m.ty;

       var len = Math.abs(dtheta)*Math.sqrt(ta*ta + tb*tb + tc*tc + td*td);
       var steps = Math.round(len);

       if (steps>1)
       {
          dtheta /= steps;
          for(i in 1...steps-1)
          {
             var c = Math.cos(theta);
             var s = Math.sin(theta);
             theta+=dtheta;
             inGfx.lineTo( ta*c + tb*s + tx, tc*c + td*s + ty );
          }
       }
       inGfx.lineTo(ioContext.transX(x2,y2), ioContext.transY(x2,y2));
   }
}




