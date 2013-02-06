package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.BitmapData;
import gm2d.display.Shape;
import gm2d.display.Bitmap;
import gm2d.geom.Rectangle;
import gm2d.text.TextField;
import gm2d.ui.MouseWatcher;
import gm2d.ui.Layout;
import gm2d.display.GradientType;
import gm2d.geom.Matrix;
import gm2d.events.MouseEvent;
import gm2d.skin.Skin;

class RGBHSV
{
   public var r(default,null):Int;
   public var g(default,null):Int;
   public var b(default,null):Int;

   public var h(default,null):Float; // 0...6
   public var s(default,null):Float; // 0...1
   public var v(default,null):Float; // 0...255

   /*
    Green    
        +---+ 
       /2\1/0\
      +---+---+  Red
       \3/4\5/          
        +---+          
    Blue  
   */
   public function new(inColour:Int=0)
   {
     setRGB(inColour);
   }

   public function setHSV(inH:Float, inS:Float, inV:Float)
   {
      h = inH;
      s = inS;
      v = inV;

      var rgb = hsv2rgb(h,s,v);
      r = (rgb>>16);
      g = (rgb>>8);
      b = (rgb) & 0xff;

      return this;
   }

   public function setRGB(inRGB:Int)
   {
      r = (inRGB>>16) & 0xff;
      g = (inRGB>>8) & 0xff;
      b = (inRGB) & 0xff;

      if (r==g && r==b)
      {
         h = 0;
         s = 0;
         v = r;
      }
      else if (r>=g && r>=b)
      {
         if (g>=b) // 0
         {
           h = g/r;
           s = b/255.0;
         }
         else // 5
         {
           h = 6-b/r;
           s = g/255.0;
         }
         v = r/(1-s);
      }
      else if (g>=r && g>=b)
      {
         if (r>=b) // 1
         {
           h = 2-r/g;
           s = b/255.0;
         }
         else // 2
         {
           h = 2+b/g;
           s = r/255.0;
         }
         v = g/(1-s);
      }
      else
      {
         if (r>=b) // 4
         {
           h = 4+r/b;
           s = b/255.0;
         }
         else // 3
         {
           h = 4-g/b;
           s = r/255.0;
         }
         v = b/(1-s);
      }
   }

   public function getRGB() : Int
   {
      return (r<<16)|(g<<8)|b;
   }

   public static function hsv2rgb(h:Float, s:Float, v:Float ) : Int
   {
      var r = 0.0;
      var g = 0.0;
      var b = 0.0;

      switch(Std.int(h))
      {
         case 0: r=1; g = h;
         case 1: g=1; r = 2-h;
         case 2: g=1; b = h-2;
         case 3: b=1; g = 4-h;
         case 4: b=1; r = h-4;
         case 5: r=1; b = 6-h;
      }
 
      var red =   Std.int((1-(1-r)*s)*v);
      var green = Std.int((1-(1-g)*s)*v);
      var blue =  Std.int((1-(1-b)*s)*v);
      return (red<<16)|(green<<8)|blue;
   }
}

class ColourSlider extends Widget
{
   public static var RED = 0;
   public static var GREEN = 1;
   public static var BLUE = 2;
   public static var HUE = 3;
   public static var SATURATION = 4;
   public static var VALUE = 5;
   public static var ALPHA = 6;

   public var onChange:Float->Void;

   var mMode:Int;
   var mVertical:Bool;
   var mWidth:Float;
   var mHeight:Float;
   var mColour:Int;
   var mPos:Float;

   var watcher:MouseWatcher;

   public function new(inMode:Int,inVertical:Bool)
   {
      super();
      watcher = MouseWatcher.create(this, onMouse, onMouse, onMouse );
      mMode = inMode;
      mVertical = inVertical;
      mColour = 0xff0000;
      mPos = 1;
      mWidth = mHeight = 1;
      var layout = getLayout();
      layout.minWidth = 20;
      layout.minHeight = 20;
      layout.setBestSize(20,20);
      layout.setBorders(2,2,2,2);
      layout.mAlign = inVertical ? Layout.AlignCenterX : Layout.AlignCenterY;
   }

   public function getValue() : Float
   {
      return mMode==VALUE ? mPos*255 : mPos;
   }

   function onMouse(inEvent:MouseEvent)
   {
      var val = 1-inEvent.localY/mHeight;
      if (val<0) val = 0;
      if (val>1) val = 1;
      mPos = val;

      if (onChange!=null)
         onChange(getValue());
   }

   public override function layout(inWidth:Float,inHeight:Float)
   {
      if (mWidth!=inWidth || mHeight!=inHeight)
      {
         mWidth = inWidth;
         mHeight = inHeight;
         redraw();
      }
   }

   public function updateComponents(inCol:RGBHSV)
   {
      if (mMode==VALUE)
      {
         mColour = RGBHSV.hsv2rgb( inCol.h, inCol.s, 255 );
      }
      else if (mMode==ALPHA)
      {
         mColour = inCol.getRGB();
         //mPos = inCol.alpha; 
      }
      redraw();
   }

   public function gradientBox()
   {
      var mtx = new Matrix();
      mtx.createGradientBox(mWidth, mHeight, mVertical ? Math.PI*0.5 : 0.0);
      return mtx;
   }

   function redraw()
   {
      var gfx = graphics;
      gfx.clear();

      if (mMode==ALPHA)
      {
         gfx.beginFill(0xffffff);
         gfx.drawRect(0,0,mWidth,mHeight);
         gfx.beginFill(0x808080);
         var x = 0;
         var y = 0;
         while(x<mWidth)
         {
            var w = x+10.0;
            if (w>mWidth-1) w = mWidth-1;
            gfx.drawRect(x,y,w-x,10);
            x+=10;
            y=10-y;
         }
	      var cols:Array<Int> = [mColour, mColour];
         var alphas:Array<Float> = [0.0, 1.0];
         var ratio:Array<Int> = [0, 255];
         gfx.beginGradientFill(GradientType.LINEAR, cols, alphas, ratio, gradientBox() );
      }
      else if (mMode==VALUE)
      {
	      var cols:Array<Int> = [mColour,0];
         var alphas:Array<Float> = [1.0, 1.0];
         var ratio:Array<Int> = [0, 255];
         gfx.beginGradientFill(GradientType.LINEAR, cols, alphas, ratio, gradientBox() );
      }
      else
      {
         gfx.beginFill(mColour);
      }
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(0,0,mWidth,mHeight);
   }
}

class ColourWheel extends Widget
{
   public var onChange:RGBHSV->Void;
   public var colour(get_colour,set_colour):RGBHSV;

   var mWidth :Float;
   var mHeight : Float;
   var bitmap:Bitmap;
   var background:Bitmap;
   var saturator:Bitmap;

   var value:Float;
   var saturation:Float;
   var hue:Float;

   var externValue:Bool;
   var radius:Float;

   var watcher:MouseWatcher;

   public function new(inCol:Int, inAlpha:Float)
   {
      super();
      watcher = MouseWatcher.create(this, onMouse, onMouse, onMouse );
      background = new Bitmap();
      background.x = -2;
      background.y = -2;
      addChild(background);
      bitmap = new Bitmap();
      addChild(bitmap);
      mWidth = 100;
      mHeight = 100;
      var layout = getLayout();
      layout.minWidth = 32;
      layout.minHeight = 32;
      layout.mAlign = Layout.AlignKeepAspect | Layout.AlignStretch;
      value = 255.0;
      saturation = 0.0;
      externValue = true;
   }

   function onMouse(inEvent:MouseEvent)
   {
      var x_ = inEvent.localX-radius;
      var y_ = inEvent.localY-radius;
      var h = Math.atan2(-y_,x_);
      if (h<0) h += 6;
      var len = Math.sqrt(x_*x_+y_*y_)/radius;
      if (len>1) len = 1;

      hue = h;
      if (externValue)
         saturation = len;
      else
         value = len*255;

      if (onChange!=null)
         onChange( new RGBHSV().setHSV(hue,saturation,value) );
   }



   public function setValue(inValue:Float)
   {
      value = inValue;
      if (!externValue)
      {
         externValue = true;
         buildBmp();
      }
      updateAlpha();
   }

   public function setSaturation(inSat:Float)
   {
      saturation = inSat;
      if (externValue)
      {
         externValue = false;
         buildBmp();
      }
      updateAlpha();
   }

   public function get_colour() : RGBHSV
   {
      return new RGBHSV().setHSV(hue, saturation, value);
   }

   function updateAlpha()
   {
      if (externValue)
      {
         if (bitmap!=null)
            bitmap.alpha = value/255.0;
      }
      else
      {
         if (saturator!=null)
            saturator.alpha = saturation;
      }
   }
 
   public function set_colour(inHSV:RGBHSV) : RGBHSV
   {
      hue = inHSV.h;
      saturation = inHSV.s;
      value = inHSV.v;
      updateAlpha();
      return inHSV;
   }




   /*
    Green    
        +---+ 
       /2\1/0\
      +---+---+  Red
       \3/4\5/          
        +---+          
    Blue  

   */

   function emptyBmp(w:Int, h:Int)
   {
      #if neko
      return  new BitmapData(w,h,true,{rgb:0, a:0} );
      #else
      return  new BitmapData(w,h,true,0x000000);
      #end
   }

   function buildBmp()
   {
      var rad = Std.int(mWidth/2 - 1);
      radius = rad;
      var vscale = 255.0/rad;

      var w = rad*2+1;
      //var y0 = Std.int(rad*Math.sqrt(3.0)*0.5);
      var y0 = rad;
      var h = y0*2+1;
      if (w<1 || h<1)
         return;
      var bmp = emptyBmp(w,h);
      bitmap.bitmapData = bmp;

      var pixels = new nme.utils.ByteArray();
      for(y in 0...h)
      {
         var y_ = y0-y;
         for(x in 0...w)
         {
            var x_ = x-rad;
            var len = Math.sqrt(x_*x_+y_*y_);
            if (len<=rad+1)
            {
               var theta = Math.atan2(y_,x_)*3/Math.PI;
               if (theta<0) theta += 6;
               var r = 0.0;
               var g = 0.0;
               var b = 0.0;
               var sat = (externValue ? len/rad : 0.0);
               var val = externValue ? 255.0 : len*vscale;
               var alpha = 0xff000000;
               if (len>rad)
               {
                  alpha = Std.int((rad+1-len)*255)<<24;
                  if (sat>1) sat = 1;
                  if (val>255) val = 255;
               }

               switch(Std.int(theta))
               {
                  case 0: r=1; g = theta;
                  case 1: g=1; r = 2-theta;
                  case 2: g=1; b = theta-2;
                  case 3: b=1; g = 4-theta;
                  case 4: b=1; r = theta-4;
                  case 5: r=1; b = 6-theta;
               }
 
               var red =   Std.int((1-(1-r)*sat)*val);
               var green = Std.int((1-(1-g)*sat)*val);
               var blue =  Std.int((1-(1-b)*sat)*val);
               pixels.writeInt(alpha|(red<<16)|(green<<8)|blue);
            }
            else if (len<rad+1)
            {
               var alpha = Std.int((rad+1-len)*255);
               pixels.writeInt(alpha<<24);
            }
            else
               pixels.writeInt(0);
         }
      }
      pixels.position = 0;
      bmp.setPixels(new Rectangle(0,0,w,h),pixels);
      
      var s = new Shape();
      var gfx = s.graphics;
      gfx.clear();
      gfx.beginFill(0x000000);
      gfx.drawCircle(rad+2.5,y0+2.5,rad+2);
      var bmp = emptyBmp(w+4,h+4);
      bmp.draw(s);
      background.bitmapData = bmp;
      updateAlpha();
   }


   public override function layout(inWidth:Float,inHeight:Float)
   {
      if (mWidth!=inWidth || mHeight!=inHeight)
      {
         mWidth = inWidth;
         mHeight = inHeight;
         buildBmp();
      }
   }
}

class RGBBox extends Widget
{
   var textField:TextField;
   var mWidth:Float;
   var mHeight:Float;
   var mCol:Int;
   var mAlpha:Float;

   public function new(inCol:Int, inAlpha:Float)
   {
      super();
      mCol = inCol;
      mAlpha = inAlpha;
      mWidth = mHeight = 32;
      getLayout().setMinSize(20,32);

      var fmt = new nme.text.TextFormat();
      fmt.align = nme.text.TextFormatAlign.CENTER;

      textField = new TextField( );
      textField.border = true;
      textField.defaultTextFormat = fmt;
      textField.borderColor = 0x000000;
      textField.background = true;
      addChild(textField);
      redraw();
   }

   public function setColour(inCol:Int)
   {
      mCol = inCol;
      redraw();
   }

   function redraw()
   {
      textField.width = mWidth;
      textField.height = mHeight;
      textField.backgroundColor = mCol;
      textField.text = StringTools.hex(mCol,6);
   }

   public override function layout(inWidth:Float,inHeight:Float)
   {
      mWidth = inWidth;
      mHeight = inHeight;
      redraw();
   }
}

class ColourControl extends Widget
{
   var wheel:ColourWheel;
   var box:RGBBox;
   var valueSlider:ColourSlider;
   var alphaSlider:ColourSlider;
   var updateLockout:Int;
   public var onColourChange:Int->Float->Void;

   public function new(inCol:Int, inAlpha:Float)
   {
      super();
  
      updateLockout = 0;

      var all =  new GridLayout(1,"All",0);
      all.setColStretch(0,1);
      all.setRowStretch(1,1);
      all.setSpacing(0,0);

      box = new RGBBox(inCol,inAlpha);
      addChild(box);
      all.add(box.getLayout().setAlignment( Layout.AlignStretch).setBorders(2,2,2,2));

      // Wheel and slider...
      var layout = new GridLayout(2,"ColourGrid",0);
      layout.setColStretch(1,1);
      layout.setRowStretch(0,1);
      layout.setSpacing(0,0);
      layout.setMinSize(100,100);

      valueSlider = new ColourSlider(ColourSlider.VALUE, true);
      valueSlider.onChange = onValue;
      addChild(valueSlider);
      layout.add(valueSlider.getLayout());

      wheel = new ColourWheel(inCol,inAlpha);
      wheel.onChange = onWheel;
      addChild(wheel);
      layout.add(wheel.getLayout());

      layout.add(null);

      alphaSlider = new ColourSlider(ColourSlider.ALPHA, false);
      alphaSlider.onChange = onAlpha;
      addChild(alphaSlider);
      layout.add(alphaSlider.getLayout());

      all.add(layout.setAlignment(Layout.AlignStretch | Layout.AlignKeepAspect));

      mLayout = all;
   }

   public function setColour(inCol:Int, inAlpha:Float)
   {
      if (updateLockout>0) return;

      var col = new RGBHSV(inCol);
      box.setColour(inCol);
      valueSlider.updateComponents(col);
      alphaSlider.updateComponents(col);
      wheel.colour = col;
   }

   function send()
   {
      if (onColourChange!=null)
      {
         updateLockout++;
         var col = wheel.get_colour();
         onColourChange(col.getRGB(), alphaSlider.getValue() );
         updateLockout--;
      }
   }


   public function onWheel(inCol:RGBHSV)
   {
      box.setColour(inCol.getRGB());
      valueSlider.updateComponents(inCol);
      alphaSlider.updateComponents(inCol);
      send();
   }

   public function onAlpha(inValue:Float)
   {
      send();
   }

   public function onValue(inValue:Float)
   {
      wheel.setValue(inValue);
      var col = wheel.get_colour();
      box.setColour(col.getRGB());
      alphaSlider.updateComponents(col);
      send();
   }

   public function setValue(inValue:Float)
   {
      wheel.setValue(inValue);
   }

   public function setSaturation(inValue:Float)
   {
      wheel.setSaturation(inValue);
   }



   public override function layout(inWidth:Float,inHeight:Float)
   {
      super.layout(inWidth,inHeight);
   }
}


