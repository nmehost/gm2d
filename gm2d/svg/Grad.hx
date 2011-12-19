package gm2d.svg;

import gm2d.geom.Matrix;
import gm2d.geom.Rectangle;

import gm2d.display.GradientType;
import gm2d.display.SpreadMethod;
import gm2d.display.InterpolationMethod;
import gm2d.display.CapsStyle;
import gm2d.display.JointStyle;
import gm2d.display.LineScaleMode;

class Grad
{
   public function new(inType:GradientType)
   {
      type = inType;
      cols = [];
      alphas = [];
      ratios = [];
      matrix = new Matrix();
      spread = SpreadMethod.PAD;
      interp = InterpolationMethod.RGB;
      radius = 0.0;
      focus = 0.0;
      x1 = 0.0;
      y1 = 0.0;
      x2 = 0.0;
      y2 = 0.0;
   }
   public function renference_regex()
   {
      return ~//;
   }


   public function GetMatrix(inMatrix:Matrix)
   {
      var dx = x2 - x1;
      var dy = y2 - y1;
      var theta = Math.atan2(dy,dx);
      var len = Math.sqrt(dx*dx+dy*dy);

      var mtx = new Matrix();

      if (type==GradientType.LINEAR)
      {
         mtx.createGradientBox(1.0,1.0);
         mtx.scale(len,len);
      }
      else
      {
         if (radius!=0.0)
            focus = len/radius;

         mtx.createGradientBox(1.0,1.0);
         mtx.translate(-0.5,-0.5);
         mtx.scale(radius*2,radius*2);
      }

      mtx.rotate(theta);
      mtx.translate(x1,y1);
      mtx.concat(matrix);
      mtx.concat(inMatrix);

      return mtx;
   }

   public var type:GradientType;
   public var cols:Array<Int>;
   public var alphas:Array<Float>;
   public var ratios:Array<Int>;
   public var matrix: Matrix;
   public var spread: SpreadMethod;
   public var interp:InterpolationMethod;
   public var radius:Float;
   public var focus:Float;
   public var x1:Float;
   public var y1:Float;
   public var x2:Float;
   public var y2:Float;

}

typedef GradHash = Hash<Grad>;
