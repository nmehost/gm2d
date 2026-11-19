package gm2d.svg;

import gm2d.svg.FillType;
import gm2d.svg.Grad;
using StringTools;

class SvgStyles
{
   public var defaultFill = FillSolid(0x000000);
   public var defaultStroke = FillNone;
   // Allows quotes around the reference, as in url("#id")
   var urlMatch = ~/url\(\s*["']?#(.*?)["']?\s*\)/;
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


   // Only the fill/stroke ordering of "paint-order" is supported - markers are ignored.
   // Per the spec, anything not listed follows in the default order (fill, stroke, markers),
   //  so the first of fill or stroke to be listed decides.
   public function getPaintOrder() : nme.display.LineOrder
   {
      var s = StringTools.trim( get("paint-order","normal") );
      for(token in ~/\s+/g.split(s))
      {
         if (token=="fill")
            return nme.display.LineOrder.OVER_FILL;
         if (token=="stroke")
            return nme.display.LineOrder.UNDER_FILL;
      }
      return nme.display.LineOrder.OVER_FILL;
   }

   // The svg defaults are butt caps, miter joins and a miter limit of 4
   public function getLineCap() : nme.display.CapsStyle
   {
      return switch(get("stroke-linecap","butt"))
      {
         case "round": nme.display.CapsStyle.ROUND;
         case "square": nme.display.CapsStyle.SQUARE;
         default: nme.display.CapsStyle.NONE;
      }
   }

   // miter-clip and arcs are svg2 extras, treated as miter
   public function getLineJoin() : nme.display.JointStyle
   {
      return switch(get("stroke-linejoin","miter"))
      {
         case "round": nme.display.JointStyle.ROUND;
         case "bevel": nme.display.JointStyle.BEVEL;
         default: nme.display.JointStyle.MITER;
      }
   }

   public function getMiterLimit() : Float return getFloat("stroke-miterlimit",4.0);

   public function getFill(inKey:String, forceCurrent:Bool)
   {
      var s = get(inKey,"");
      if (s=="" && forceCurrent)
         return FillCurrentColor;

      if (s=="")
         return inKey=="fill" ? defaultFill : defaultStroke;

      if (s=="none")
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

         // A reference to something that is not there renders as no fill
         trace("Warning: unknown url:" + url);
         return FillNone;
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
