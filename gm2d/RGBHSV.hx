package gm2d;

import nme.display.BitmapData;
import nme.geom.Rectangle;

class RGBHSV
{
   public static inline var RED        = 0;
   public static inline var GREEN      = 1;
   public static inline var BLUE       = 2;
   public static inline var HUE        = 3;
   public static inline var SATURATION = 4;
   public static inline var VALUE      = 5;
   public static inline var ALPHA      = 6;


   public var r(default,null):Int;  // 0...256
   public var g(default,null):Int;  // 0...256
   public var b(default,null):Int;  // 0...256

   public var h(default,null):Float; // 0...360
   public var s(default,null):Float; // 0...1
   public var v(default,null):Float; // 0...256

   public var a(default,null):Float; // 0...1


   static var spectrum:BitmapData;
   /*
    Green    
        +---+ 
       /2\1/0\
      +---+---+  Red
       \3/4\5/          
        +---+          
    Blue  
   */
   public static var range = [ 256, 256, 256, 360, 1, 256, 1 ];

   public function new(inColour:Int=0,inAlpha=1.0)
   {
      h = 0;
      a = inAlpha;
      setRGB(inColour);
   }

   public function clone() : RGBHSV
   {
      var result = new RGBHSV(0,0);
      result.a = a;
      result.r = r;
      result.g = g;
      result.b = b;
      result.h = h;
      result.s = s;
      result.v = v;
      return result;
   }

   public function compare(inOther:RGBHSV) : Int
   {
      if (r!=inOther.r)
         return r-inOther.r;
      if (g!=inOther.g)
         return g-inOther.g;
      return b-inOther.b;
   }


   public function same(inOther:RGBHSV) : Bool
   {
      return r==inOther.r && g==inOther.g && b==inOther.b && a==inOther.a;
   }

   public function with(inComponent:Int, inValue:Float)
   {
      var result = clone();
      result.set(inComponent,inValue);
      return result;
   }

   public function set(inComponent:Int, inValue:Float)
   {
      switch(inComponent)
      {
         case ALPHA: a = inValue;

         case RED:   r = Std.int(inValue); recalcHSV();
         case GREEN: g = Std.int(inValue); recalcHSV();
         case BLUE:  b = Std.int(inValue); recalcHSV();

         case HUE:        h = inValue; recalcRGB();
         case SATURATION: s = inValue; if (s>0.99999) s = 1; recalcRGB();
         case VALUE:      v = Std.int(inValue); recalcRGB();
      }
      return this;
   }

   public function get(inComponent:Int) : Float
   {
      switch(inComponent)
      {
         case ALPHA: return a;

         case RED:   return r;
         case GREEN: return g;
         case BLUE:  return b;

         case HUE:        return h;
         case SATURATION: return s;
         case VALUE:      return v;
      }
      return 0;
   }

   public static function getRange(inComponent:Int):Int { return range[inComponent]; }

   public function setHSV(inH:Float, inS:Float, inV:Float)
   {
      h = inH;
      s = inS;
      v = inV;

      recalcRGB();
   }

   public function recalcRGB()
   {
      h = h%360;
      if (v<0) v = 0; else if (v>255) v = 255;
      if (s<0) s = 0; else if (s>=1) s = 1;
      var rgb = hsv2rgb(h,s,v);
      r = (rgb>>16) & 0xff;
      g = (rgb>>8) & 0xff;
      b = (rgb) & 0xff;

      return this;
   }

   public function setRGB(inRGB:Int)
   {
      r = (inRGB>>16) & 0xff;
      g = (inRGB>>8) & 0xff;
      b = (inRGB) & 0xff;
      recalcHSV();
   }

   public function recalcHSV()
   {
      if (r<0) r = 0; else if (r>255) r = 255;
      if (g<0) g = 0; else if (g>255) g = 255;
      if (b<0) b = 0; else if (b>255) b = 255;
      if (r==g && r==b)
      {
         // keep h
         s = 0;
         v = r;
      }
      else
      {
         var M = 0;
         var m = 0;
         if (r>=g && r>=b)
            M = r;
         else if (g>=r && g>=b)
            M = g;
         else
            M = b;

         if (r<=g && r<=b)
            m = r;
         else if (g<=r && g<=b)
            m = g;
         else
            m = b;

         var C = M-m;

         var H = M==r ? (g-b)/C : M==g ? (b-r)/C+2 : (r-g)/C + 4;
         if (H<0) H+= 6;

         h = H * 60;
         v = M;
         s = C/M;
      }
      return this;
   }

   public function setRGBs(r:Int, g:Int, b:Int)
   {
      setRGB((r<<16)|(g<<8)|b);
   }
   public function setR(inR:Int) { r=inR; recalcHSV(); return this; }
   public function setG(inG:Int) { g=inG; recalcHSV(); return this; }
   public function setB(inB:Int) { b=inB; recalcHSV(); return this; }
   public function setH(inH:Float) { h=inH; recalcRGB(); return this; }
   public function setS(inS:Float) { s=inS; recalcRGB(); return this; }
   public function setV(inV:Float) { v=inV; recalcRGB(); return this; }
   public function setA(inA:Float) { a=inA; return this; }
   // For when r==g==b
   public function setHueQuick(inH:Float) { h=inH; return this; }

   public function getRGB() : Int
   {
      return (r<<16)|(g<<8)|b;
   }
   public function getRGBA() : Int
   {
      var alpha = Std.int(a*255);
      if (alpha<0) alpha = 0;
      else if (alpha>255) alpha = 255;
      return (alpha<<24) | (r<<16)|(g<<8)|b;
   }
   public function getAlpha() : Float
   {
      return a;
   }


   public static function fromHex(inHex:String,alphaToo = true) {
      var val = Std.parseInt(inHex);
      return new RGBHSV( val & 0xffffff, alphaToo ? (val>>24)/255.0 : 1.0 );
  }

   public function getHex() { return "0x" + StringTools.hex(getRGBA(),8); }

   public function toString() { return "#" + StringTools.hex(getRGBA(),8); }

   public static function getSpectrum()
   {
      if (spectrum==null)
      {
         spectrum = new BitmapData(1,255*6);
         var pixels = new nme.utils.ByteArray();
         var col = 0xffff0000;
         for(hex in 0...6)
         {
            for(x in 0...255)
            {
               pixels.writeInt(col);
               switch(hex)
               {
                  case 0: col += 0x000100;
                  case 1: col -= 0x010000;
                  case 2: col += 0x000001;
                  case 3: col -= 0x000100;
                  case 4: col += 0x010000;
                  case 5: col -= 0x000001;
               }
            }
         }
         pixels.position = 0;
         spectrum.setPixels(new Rectangle(0,0,1,255*6),pixels);
      }
      return spectrum;
   }

   public function blend(other:RGBHSV, f:Float)
   {
      var result = new RGBHSV(0,0);
      result.a = Std.int(a + (other.a-a)*f);
      result.r = Std.int(r + (other.r-r)*f);
      result.g = Std.int(g + (other.g-g)*f);
      result.b = Std.int(b + (other.b-b)*f);
      return result.recalcHSV();
   }

   public static function hsv2rgb(h:Float, s:Float, v:Float ) : Int
   {
      var r = 0.0;
      var g = 0.0;
      var b = 0.0;

      var h_ = h/60;
      switch(Std.int(h_))
      {
         case 0: r=1; g = h_;
         case 1: g=1; r = 2-h_;
         case 2: g=1; b = h_-2;
         case 3: b=1; g = 4-h_;
         case 4: b=1; r = h_-4;
         case 5: r=1; b = 6-h_;
      }
 
      var red =   Std.int((1-(1-r)*s)*v);
      var green = Std.int((1-(1-g)*s)*v);
      var blue =  Std.int((1-(1-b)*s)*v);
      return (red<<16)|(green<<8)|blue;
   }
}

