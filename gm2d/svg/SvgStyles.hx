package gm2d.svg;

import gm2d.svg.FillType;
import gm2d.svg.Grad;
using StringTools;

class SvgStyles
{
   var defaultFill = FillSolid(0x000000);
   var urlMatch = ~/url\(#(.*?)\)/;
   var rgbMatch = ~/rgb\((.*),(.*),(.*)\)/;

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

   public static function parseRgbComp(s:String) : Int
   {
      var result = 0;
      s = s.trim();
      if (s.endsWith("%"))
         result = Std.int( Std.parseFloat(s.substr(0,s.length-1)) * 2.55 );
      else
         result = Std.parseInt(s);
      if (result<0)
         return 0;
      if (result>255)
         return 255;
      return result;
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
         return (parseRgbComp(rgbMatch.matched(1))<<16 ) |
                (parseRgbComp(rgbMatch.matched(2))<<8 ) |
                (parseRgbComp(rgbMatch.matched(3)) );
      }

      var col = gm2d.RGB.resolve(s);
      if (col!=null)
         return col;

      return Std.parseInt(s);
   }

   function hex3to6(i:Int)
   {
      return ( (i&0xf) * 0x11 ) |
             ( (i&0xf0) * 0x110 ) |
             ( (i&0xf00) * 0x1100 ) ;
   }




   public function getMarker(inKey:String,inLinks:Map<String,DisplayElement>) : Marker
   {
      var s = get(inKey,"");
      if (s=="")
         return null;
      if (s=="none")
         return null;

      if (urlMatch.match(s))
      {
         var url = urlMatch.matched(1);
         var link = inLinks.get(url);
         if (link==null)
            throw "Unknown marker " + url;
         return link.asMarker();
      }
      throw("Unknown marker string:" + s);
      return null;
   }

   public function getFilterSet(filterMap:Map<String,FilterSet>) : FilterSet
   {
      var s = get("filter","");
      if (s=="")
         return null;
      if (s=="none")
         return null;

      if (urlMatch.match(s))
      {
         var url = urlMatch.matched(1);
         var set = filterMap.get(url);
         if (set==null)
            throw "Unknown filters " + url;
         return set;
      }
      throw("Unknown filter string:" + s);
      return null;
   }


   public function getFill(inKey:String, forceCurrent:Bool)
   {
      var s = get(inKey,"");
      if (s=="" && forceCurrent)
         return FillCurrentColor;

      if (s=="" || s=="none")
         return FillNone;

      if (s=="currentColor")
         return FillCurrentColor;

      if (s.charAt(0)=='#')
      {
         if (s.length==4)
            return FillSolid( hex3to6(Std.parseInt( "0x" + s.substr(1)) ) );
         else
            return FillSolid( Std.parseInt( "0x" + s.substr(1) ) );
      }

      if (urlMatch.match(s))
      {
         var url = urlMatch.matched(1);
         var grad =  gradients!=null ? gradients.get(url) : null;
         if (grad!=null)
            return FillGrad(grad);

         trace("Warning: unknown url:" + url);
         //throw("Unknown url:" + url);
      }

      if (rgbMatch.match(s))
      {
         return FillSolid( (parseRgbComp(rgbMatch.matched(1))<<16 ) |
                           (parseRgbComp(rgbMatch.matched(2))<<8 ) |
                           (parseRgbComp(rgbMatch.matched(3))) );
      }


      var col = gm2d.RGB.resolve(s);
      if (col!=null)
         return FillSolid(col);

      throw("Unknown fill string:'" + s + "'");

      return FillNone;
   }




}
