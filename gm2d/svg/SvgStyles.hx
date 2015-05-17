package gm2d.svg;

import gm2d.svg.FillType;
import gm2d.svg.Grad;

class SvgStyles
{
   var defaultFill = FillSolid(0x000000);
   var urlMatch = ~/url\(#(.*)\)/;
   var rgbMatch = ~/rgb\((\d+)[,\s](\d+)[,\s](\d+)\)/;

   var stack : Array<Map<String,String>>;
   var gradients:GradHash;

   public function new(inGradients:GradHash)
   {
      stack = [];
      gradients = inGradients;
   }
   public function push(inStyle:Map<String,String>)
   {
      if (inStyle==null)
         return false;
      stack.push(inStyle);
      return true;
   }
   public function pop() stack.pop();
   public function reset()
   {
      if (stack.length!=0)
         stack = [];
   }



   public function get(inKey:String,inDefault:String) : String
   {
      var i = stack.length-1;
      while(i>=0)
      {
         if (stack[i].exists(inKey))
            return stack[i].get(inKey);
         --i;
      }
      return inDefault;
   }

   public function getFloat(inKey:String, inDefault:Float)
   {
      var s = get(inKey,"");
      if (s=="")
         return inDefault;
      return Std.parseFloat(s);
   }


   public function getStroke(inKey:String,?inDefault:Null<Int>) : Null<Int>
   {
      var s = get(inKey,"");
      if (s=="")
         return inDefault;

      if (s=="none")
         return null;

      if (s.charAt(0)=='#')
         return Std.parseInt( "0x" + s.substr(1) );

      if (rgbMatch.match(s))
      {
         return (Std.parseInt(rgbMatch.matched(1))<<16 ) |
                (Std.parseInt(rgbMatch.matched(2))<<8 ) |
                (Std.parseInt(rgbMatch.matched(3))<<8 );
      }

      var col = gm2d.RGB.resolve(s);
      if (col!=null)
         return col;

      return Std.parseInt(s);
   }



   public function getFill(inKey:String)
   {
      var s = get(inKey,"");
      if (s=="")
         return defaultFill;

      if (s.charAt(0)=='#')
         return FillSolid( Std.parseInt( "0x" + s.substr(1) ) );
 
      if (s=="none")
         return FillNone;

      if (rgbMatch.match(s))
      {
         return FillSolid( (Std.parseInt(rgbMatch.matched(1))<<16 ) |
                           (Std.parseInt(rgbMatch.matched(2))<<8 ) |
                           (Std.parseInt(rgbMatch.matched(3))<<8 ) );
      }

      if (urlMatch.match(s))
      {
         var url = urlMatch.matched(1);
         var grad =  gradients!=null ? gradients.get(url) : null;
         if (grad!=null)
            return FillGrad(grad);

         throw("Unknown url:" + url);
      }

      var col = gm2d.RGB.resolve(s);
      if (col!=null)
         return FillSolid(col);

      throw("Unknown fill string:" + s);

      return FillNone;
   }




}
