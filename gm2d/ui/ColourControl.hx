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
import gm2d.geom.Point;
import gm2d.events.MouseEvent;
import gm2d.skin.Skin;
import gm2d.RGBHSV;


class ColourSlider extends Widget
{
   public var onChange:Float->Void;

   var mMode:Int;
   var mVertical:Bool;
   var mWidth:Float;
   var mHeight:Float;
   var mColour:RGBHSV;
   var mPos:Float;

   var watcher:MouseWatcher;

   public function new(inMode:Int,inVertical:Bool)
   {
      super();
      watcher = MouseWatcher.create(this, onMouse, onMouse, onMouse );
      mMode = inMode;
      mVertical = inVertical;
      mColour = new RGBHSV(0xff0000);
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
      return mPos * RGBHSV.getRange(mMode);
   }

   function onMouse(inEvent:MouseEvent)
   {
      var local = globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
      var val = 1-local.y/mHeight;
      if (val<0) val = 0;
      if (val>=1) val = 0.999999;
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

   public function setColour(inCol:RGBHSV)
   {
      mColour = inCol.clone();
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

      if (mMode==RGBHSV.ALPHA)
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
	      var cols:Array<CInt> = [mColour.getRGB(), mColour.getRGB()];
         var alphas:Array<Float> = [0.0, 1.0];
         var ratio:Array<Int> = [0, 255];
         gfx.beginGradientFill(GradientType.LINEAR, cols, alphas, ratio, gradientBox() );
      }
      else if (mMode==RGBHSV.VALUE)
      {
	      var rgb = mColour.with(mMode,255).getRGB();
	      var cols:Array<CInt> = [rgb,0];
         var alphas:Array<Float> = [1.0, 1.0];
         var ratio:Array<Int> = [0, 255];
         gfx.beginGradientFill(GradientType.LINEAR, cols, alphas, ratio, gradientBox() );
      }
      else
      {
         gfx.beginFill(mColour.getRGB());
      }
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(0,0,mWidth,mHeight);
   }
}



class ColourWheel extends Widget
{
   public var onChange:RGBHSV->Void;

   var mWidth :Float;
   var mHeight : Float;
   var bitmap:Bitmap;
   var background:Bitmap;

   var mMode:Int;
   var radius:Float;
   var mColour:RGBHSV;

   var watcher:MouseWatcher;
   var marker:Bitmap;

   public static var markerBitmap:BitmapData;

   public function new(inColour:RGBHSV)
   {
      super();
      if (markerBitmap==null)
      {
         markerBitmap = emptyBmp(15,15);
         var s = new Shape();
         var gfx = s.graphics;
         gfx.lineStyle(4,0xffffff);
         gfx.drawCircle(7.5,7.5,5);
         gfx.lineStyle(2,0x000000);
         gfx.drawCircle(7.5,7.5,5);
         markerBitmap.draw(s);
      }
      watcher = MouseWatcher.create(this, onMouse, onMouse, onMouse );
      mColour = inColour.clone();
      background = new Bitmap();
      background.x = -2;
      background.y = -2;
      addChild(background);
      bitmap = new Bitmap();
      addChild(bitmap);
      marker = new Bitmap(markerBitmap);
      addChild(marker);
      mWidth = 100;
      mHeight = 100;
      var layout = getLayout();
      layout.minWidth = 32;
      layout.minHeight = 32;
      layout.mAlign = Layout.AlignKeepAspect | Layout.AlignStretch;
      mMode = RGBHSV.VALUE;
   }

   function onMouse(inEvent:MouseEvent)
   {
      var local = globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
      var x_ = local.x-radius;
      var y_ = local.y-radius;
      var h = Math.atan2(-y_,x_) * 180.0 / Math.PI;
      if (h<0) h += 360;
      var len = Math.sqrt(x_*x_+y_*y_)/radius;
      if (len>1) len = 1;

      switch(mMode)
      {
         case RGBHSV.VALUE: mColour.setH(h).setS(len);
         case RGBHSV.SATURATION: mColour.setH(h).setV(len*255);
      }
      updateMarker();

      if (onChange!=null)
         onChange( mColour.clone() );
   }

   public function get_colour() : RGBHSV
   {
      return mColour.clone();
   }

   public function setColour(inColour:RGBHSV)
   {
      if (inColour.compare(mColour)!=0)
      {
         mColour = inColour.clone();
         updateOverlays();
      }
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
      return  new BitmapData(w,h,true,gm2d.RGB.CLEAR);
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
               var sat = mMode==RGBHSV.VALUE ? len/rad : 0.0;
               var val = mMode==RGBHSV.VALUE ? 255.0 : len*vscale;
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
      updateOverlays();
   }

   function updateMarker()
   {
      switch(mMode)
      {
         case RGBHSV.VALUE:
            var theta = mColour.h * Math.PI/180.0;
            marker.x = radius - markerBitmap.width*0.5 + Math.cos(theta) * radius * mColour.s;
            marker.y = radius - markerBitmap.height*0.5 - Math.sin(theta) * radius * mColour.s;
      }
   }


   function updateOverlays()
   {
      switch(mMode)
      {
         case RGBHSV.VALUE:
            if (bitmap!=null)
               bitmap.alpha = mColour.v/255.0;
      }
      updateMarker();
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
   var mColour:RGBHSV;
   var updateLockout:Int;

   public function new(inColour:RGBHSV)
   {
      super();
      mColour = inColour.clone();
      mWidth = mHeight = 32;
      updateLockout = 0;
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

   public function setColour(inCol:RGBHSV)
   {
      if (inCol.compare(mColour)!=0)
      {
         mColour = inCol.clone();
         redraw();
      }
   }

   function redraw()
   {
      textField.width = mWidth;
      textField.height = mHeight;
      textField.backgroundColor = mColour.getRGB();
      updateLockout++;
      textField.text = StringTools.hex(mColour.getRGB(),6);
      updateLockout--;
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
   var mColour:RGBHSV;
   var wheel:ColourWheel;
   var box:RGBBox;
   var valueSlider:ColourSlider;
   var alphaSlider:ColourSlider;

   var redIn:NumericInput;
   var greenIn:NumericInput;
   var blueIn:NumericInput;
   var hueIn:NumericInput;
   var saturationIn:NumericInput;
   var valueIn:NumericInput;

   var updateLockout:Int;
   public var onColourChange:Int->Float->Void;

   public function new(inCol:Int, inAlpha:Float)
   {
      super();

      mColour = new RGBHSV(inCol,inAlpha);
  
      updateLockout = 1;

      var all =  new GridLayout(3,"All",0);
      all.add( createNumberBoxes() );

      valueSlider = new ColourSlider(RGBHSV.VALUE, true);
      valueSlider.onChange = onValue;
      addChild(valueSlider);
      all.add(valueSlider.getLayout());

      wheel = new ColourWheel(mColour);
      wheel.onChange = onWheel;
      addChild(wheel);
      all.add(wheel.getLayout());

      box = new RGBBox(mColour);
      addChild(box);
      all.add(box.getLayout().setAlignment( Layout.AlignStretch).setBorders(2,2,2,2));

      all.add(null);

      alphaSlider = new ColourSlider(RGBHSV.ALPHA, false);
      alphaSlider.onChange = onAlpha;
      addChild(alphaSlider);
      all.add(alphaSlider.getLayout());

      all.setColStretch(2,1);

      setAll();
      updateLockout = 0;

      mLayout = all;
   }

   function setComponent(inWhich:Int, inVal:Float)
   {
      if (updateLockout==0)
      {
         mColour.set(inWhich,inVal);
         setAll();
      }
   }

   function setAll()
   {
      updateLockout++;
      wheel.setColour(mColour);
      box.setColour(mColour);
      valueSlider.setColour(mColour);
      alphaSlider.setColour(mColour);
      redIn.setValue(mColour.r);
      greenIn.setValue(mColour.g);
      blueIn.setValue(mColour.b);
      hueIn.setValue(mColour.h);
      saturationIn.setValue(mColour.s);
      valueIn.setValue(mColour.v);
      updateLockout--;
   }

   function makeInput(inMode:Int,inMax:Float=255.0)
   {
      var delta = inMax<= 100 ? 0.01 : 1;
      var result = new NumericInput(inMax*0.5,inMax>100,0,inMax,delta,
         function(f)
         {
            if (updateLockout==0)
               setComponent(inMode,f);
         });
      result.setTextWidth(60);
      //result.addEventListener( MouseEvent.MOUSE_DOWN, function(_) setMode(inMode) );
      return result;
   }

   function createNumberBoxes()
   {
      var panel = new Panel("Values");
      addChild(panel);
      panel.addLabelObj("R",redIn   = makeInput( RGBHSV.RED ) );
      panel.addLabelObj("G",greenIn = makeInput( RGBHSV.GREEN) );
      panel.addLabelObj("B",blueIn   = makeInput( RGBHSV.BLUE) );

      panel.addLabelObj("H",hueIn         = makeInput( RGBHSV.HUE,359) );
      panel.addLabelObj("S",saturationIn  = makeInput( RGBHSV.SATURATION,1 ) );
      panel.addLabelObj("V",valueIn       = makeInput( RGBHSV.VALUE ) );
      return panel.getLayout();
   }

   public function setColour(inCol:Int, inAlpha:Float)
   {
      mColour = new RGBHSV(inCol,inAlpha);
      setAll();
   }

   public function getRGB() { return mColour.getRGB(); }

   public function getAlpha() { return mColour.a; }

   function send()
   {
      if (onColourChange!=null)
      {
         updateLockout++;
         onColourChange(mColour.getRGB(), mColour.a);
         updateLockout--;
      }
   }


   public function onWheel(inCol:RGBHSV)
   {
      mColour = inCol.clone();
      setAll();
      send();
   }

   public function onAlpha(inValue:Float)
   {
      send();
   }

   public function onValue(inValue:Float)
   {
      mColour.setV(inValue);
      setAll();
      send();
   }

   public function setSaturation(inValue:Float)
   {
      mColour.setS(inValue);
      setAll();
      send();
   }

   /*
   public override function layout(inWidth:Float,inHeight:Float)
   {
      super.layout(inWidth,inHeight);
   }
   */
}


