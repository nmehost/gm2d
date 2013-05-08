package gm2d;

import gm2d.display.GradientType;
import gm2d.display.InterpolationMethod;
import gm2d.display.SpreadMethod;
import gm2d.geom.Matrix;
import gm2d.display.Graphics;


class GradStop
{
   public function new(inCol:RGBHSV, inPosition:Float)
   {
      colour = inCol.clone();
      position = inPosition;
   }
   public function clone()
   {
      return  new GradStop(colour,position);
   }
   public var colour:RGBHSV;
   public var position:Float;
}

class Gradient
{
   public var stops:Array<GradStop>;
   public var type:GradientType;
   public var interpolationMethod:InterpolationMethod;
   public var spreadMethod:SpreadMethod;
   public var focal:Float;

   public function new()
   {
      stops = [];
      type = GradientType.LINEAR;
      interpolationMethod = InterpolationMethod.RGB;
      spreadMethod = SpreadMethod.PAD;
      focal = 0.0;
   }
   public function clone()
   {
      var result = new Gradient();
      result.type = type;
      result.interpolationMethod = interpolationMethod;
      result.spreadMethod = spreadMethod;
      result.focal = focal;
      for(stop in stops)
         result.add(stop);
      return result;
   }
   public function add(inStop:GradStop)
   {
      stops.push(inStop.clone());
   }
   public function addStop(inColour:RGBHSV, inPosition:Float)
   {
      stops.push( new GradStop(inColour, inPosition) );
   }

   public function getAlphas()
   {
     var result = new Array<Float>();
     for(stop in stops)
       result.push(stop.colour.a);
     return result;
   }

   public function getColors()
   {
     var result = new Array<CInt>();
     for(stop in stops)
       result.push(stop.colour.getRGB());
     return result;
   }
   public function getRatios()
   {
     var result = new Array<CInt>();
     for(stop in stops)
       result.push(Std.int(stop.position*255.0));
     return result;
   }

   public function beginFill(inGfx:Graphics, ?inMatrix:Matrix)
   {
      inGfx.beginGradientFill(type, getColors(), getAlphas(), getRatios(), inMatrix,
         spreadMethod, interpolationMethod, focal );
   }


   public function beginFillBox(inGfx:Graphics,inX0:Float, inY0:Float, inW:Float, inH:Float, inTheta:Float =0.0)
   {
      var matrix = new Matrix();
      matrix.createGradientBox(inW, inH, inTheta, inX0, inY0);
      beginFill(inGfx, matrix);
   }
}
