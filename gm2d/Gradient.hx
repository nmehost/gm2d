package gm2d;

import gm2d.display.GradientType;
import gm2d.InterpolationMethod;
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
   public function blend(other:GradStop,f:Float)
   {
      if (colour.same(other.colour))
         return new GradStop(colour, position+(other.position-position)*f );

      return new GradStop( colour.blend(other.colour,f), position+(other.position-position)*f );
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

   public static var spreads = [ SpreadMethod.PAD, SpreadMethod.REFLECT, SpreadMethod.REPEAT];
   public static var types = [ GradientType.LINEAR, GradientType.RADIAL ];
   public static var interps = [ InterpolationMethod.LINEAR_RGB, InterpolationMethod.RGB, InterpolationMethod.STEP ];


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
         result.stops.push(stop.clone());
      return result;
   }
   public function getInterpIndex() { return Lambda.indexOf(interps,interpolationMethod); }
   public function getTypeIndex() { return Lambda.indexOf(types,type); }
   public function getSpreadIndex() { return Lambda.indexOf(spreads,spreadMethod); }

   public function setInterpIndex(index:Int) { interpolationMethod = interps[index]; }
   public function setTypeIndex(index:Int) { type = types[index];}
   public function setSpreadIndex(index:Int) { spreadMethod = spreads[index];}


   public function blend(other:Gradient,f:Float)
   {
      var result = new Gradient();
      result.type = type;
      result.interpolationMethod = interpolationMethod;
      result.spreadMethod = spreadMethod;
      result.focal = focal + (other.focal-focal)*f;
      if (stops.length == other.stops.length)
      {
         for(s in 0...stops.length)
            result.stops.push(stops[s].blend(other.stops[s],f));
      }
      else
         for(stop in stops)
            result.stops.push(stop.clone());
      return result;
   }


   public function setStopPosition(inIdx:Int, inPos:Float):Int
   {
      stops[inIdx].position = inPos;
      if ( (inIdx<stops.length-1 && stops[inIdx].position>stops[inIdx+1].position) ||
           (inIdx>0 && stops[inIdx].position<stops[inIdx-1].position) )
      {
         var stop = stops.splice(inIdx,1)[0];
         for(i in 0...stops.length)
         {
            if (stop.position<stops[i].position)
            {
               stops.insert(i,stop);
               return i;
            }
         }
         stops.push(stop);
         return stops.length-1;
      }

      return inIdx;
   }

   public function add(inStop:GradStop) : Int
   {
      for(i in 0...stops.length)
      {
         if (stops[i].position>=inStop.position)
         {
            stops.insert(i,inStop.clone());
            return i;
         }
      }
      stops.push(inStop.clone());
      return stops.length-1;
   }
   public function addStop(inColour:RGBHSV, inPosition:Float)
   {
      stops.push( new GradStop(inColour, inPosition) );
   }

   public function getAlphas()
   {
     var result = new Array<Float>();
     if (interpolationMethod==InterpolationMethod.STEP && stops.length>1)
     {
        for(i in 1...stops.length)
        {
           result.push(stops[i-1].colour.a);
           result.push(stops[i].colour.a);
        }
     }
     else
        for(stop in stops)
          result.push(stop.colour.a);
     return result;
   }

   public function getColors()
   {
     var result = new Array<CInt>();
     if (interpolationMethod==InterpolationMethod.STEP && stops.length>1)
     {
        for(i in 1...stops.length)
        {
           result.push(stops[i-1].colour.getRGB());
           result.push(stops[i].colour.getRGB());
        }
     }
     else
        for(stop in stops)
          result.push(stop.colour.getRGB());
     return result;
   }
   public function getRatios()
   {
     var result = new Array<CInt>();
     if (interpolationMethod==InterpolationMethod.STEP && stops.length>1)
     {
        for(i in 1...stops.length)
        {
           result.push(Std.int(stops[i].position*255.0));
           result.push(Std.int(stops[i].position*255.0));
        }
     }
     else
        for(stop in stops)
           result.push(Std.int(stop.position*255.0));
     return result;
   }

   public function beginFill(inGfx:Graphics, ?inMatrix:Matrix, ?inType:GradientType)
   {
      var t = inType==null ? type : inType;
      if (interpolationMethod==InterpolationMethod.LINEAR_RGB)
         inGfx.beginGradientFill(t, getColors(), getAlphas(), getRatios(), inMatrix,
            spreadMethod, gm2d.display.InterpolationMethod.LINEAR_RGB, focal );
      else
         inGfx.beginGradientFill(t, getColors(), getAlphas(), getRatios(), inMatrix,
            spreadMethod, gm2d.display.InterpolationMethod.RGB, focal );
   }


   public function beginFillBox(inGfx:Graphics,inX0:Float, inY0:Float, inW:Float, inH:Float, inTheta:Float =0.0, ?inType:GradientType)
   {
      var matrix = new Matrix();
      matrix.createGradientBox(inW, inH, inTheta, inX0, inY0);
      beginFill(inGfx, matrix, inType);
   }
}
