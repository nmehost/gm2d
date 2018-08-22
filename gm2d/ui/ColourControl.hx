package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.utils.ByteArray;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.text.TextField;
import gm2d.ui.MouseWatcher;
import gm2d.ui.Layout;
import nme.display.GradientType;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.events.MouseEvent;
import gm2d.skin.Skin;
import gm2d.RGBHSV;


class ColourSlider extends Widget
{
   public var onChange:Float->Int->Void;
   public var onEnter:Float->Int->Void;

   var mMode:Int;
   var mVertical:Bool;
   var mColour:RGBHSV;
   var mPos:Float;

   var watcher:MouseWatcher;
   public static var markerBitmap:BitmapData;
   var marker:Bitmap;

   static var minHeight = Skin.scale(20);

   public function new(inMode:Int,inVertical:Bool)
   {
      super();
      if (markerBitmap==null)
      {
         markerBitmap = new BitmapData(Skin.scale(28),minHeight>>1,true,gm2d.RGB.CLEAR);
         var s = new Shape();
         var gfx = s.graphics;
         gfx.lineStyle(Skin.scale(4),0xffffff);
         var off = Skin.scale(2.5);
         gfx.drawRect(off,off,Skin.scale(24),Skin.scale(6));
         gfx.lineStyle(Skin.scale(2),0x000000);
         gfx.drawRect(off,off,Skin.scale(24),Skin.scale(6));
         markerBitmap.draw(s);
      }
      marker = new Bitmap(markerBitmap);
      addChild(marker);
 

      watcher = MouseWatcher.create(this, onMouse, onMouse, onMouseUp );
      mMode = inMode;
      mVertical = inVertical;
      if (!mVertical)
         marker.rotation = 90;
      mColour = new RGBHSV(0xff0000);
      mPos = 1;

      var layout = new Layout();
      layout.minWidth = minHeight;
      layout.minHeight = minHeight;
      layout.setBestSize(minHeight,minHeight);
      layout.setBorders(2,2,2,2);
      setItemLayout(layout);
      getLayout().setAlignment(inVertical ? Layout.AlignCenterX : Layout.AlignCenterY);
      updateMarker();
      //build();
   }

   public function setInputMode(inMode:Int)
   {
      mMode = inMode;
      redraw();
   }


   function updateMarker()
   {
      if (mVertical)
      {
         marker.x = -minHeight*0.25;
         marker.y = mRect.height * (1.0-mPos) - minHeight*0.25;
      }
      else
      {
         marker.x = mRect.width * mPos + minHeight*0.25;
         marker.y = -minHeight*0.25;
      }
   }
   public function getValue() : Float
   {
      return mPos * RGBHSV.getRange(mMode);
   }

   function onMouse(inEvent:MouseEvent)
   {
      var local = globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
      var val = mVertical ? 1-local.y/mRect.height  : local.x/mRect.width;
      if (val<0) val = 0;
      if (val>=1) val = mMode==RGBHSV.ALPHA ? 1.0 : 0.999999;
      mPos = val;
      updateMarker();

      if (onChange!=null)
         onChange(getValue(), Phase.fromMouseEvent(inEvent) );
   }
   function onMouseUp(inEvent:MouseEvent)
   {
      if (onEnter!=null)
         onEnter(getValue(), Phase.fromMouseEvent(inEvent));
   }

   public function setColour(inCol:RGBHSV)
   {
      mColour = inCol.clone();
      mPos = mColour.get(mMode) / RGBHSV.getRange(mMode);
      redraw();
   }

   public function gradientBox()
   {
      var mtx = new Matrix();
      mtx.createGradientBox(mRect.width, mRect.height, mVertical ? Math.PI*0.5 : 0.0);
      return mtx;
   }

   override public function redraw()
   {
      var gfx = graphics;
      gfx.clear();

      if (mMode==RGBHSV.ALPHA)
      {
         gfx.beginFill(0xffffff);
         gfx.drawRect(0,0,mRect.width,mRect.height);
         gfx.beginFill(0x808080);
         var x = 0.0;
         var y = 0.0;
         while(x<mRect.width)
         {
            var w = x+minHeight/2;
            if (w>mRect.width-1) w = mRect.width-1;
            gfx.drawRect(x,y,w-x,minHeight/2);
            x+=minHeight/2;
            y=minHeight/2-y;
         }
	      var cols:Array<CInt> = [mColour.getRGB(), mColour.getRGB()];
         var alphas:Array<Float> = [0.0, 1.0];
         var ratio:Array<Int> = [0, 255];
         gfx.beginGradientFill(GradientType.LINEAR, cols, alphas, ratio, gradientBox() );
      }
      else if (mMode==RGBHSV.HUE)
      {
	      var bmp = RGBHSV.getSpectrum();
         var mtx = new Matrix();
         mtx.d = -mRect.height/bmp.height;
         mtx.ty = mRect.height;
         gfx.beginBitmapFill(bmp,mtx);
      }
      else
      {
	      var rgb1 = mColour.with(mMode, RGBHSV.getRange(mMode) ).getRGB();
	      var rgb0 = mColour.with(mMode, 0 ).getRGB();
	      var cols:Array<CInt> = [rgb1,rgb0];
         var alphas:Array<Float> = [1.0, 1.0];
         var ratio:Array<Int> = [0, 255];
         gfx.beginGradientFill(GradientType.LINEAR, cols, alphas, ratio, gradientBox() );
      }

      gfx.drawRect(0,0,mRect.width,mRect.height);
      gfx.endFill();

      gfx.lineStyle(1,0x000000);
      gfx.drawRect(-0.5,-0.5,mRect.width+1,mRect.height+1);
      updateMarker();
   }
}




class SwatchBox extends Sprite
{
   var swatch:Swatch;
   public function new(inSwatch:Swatch, inControl:ColourControl,inSize:Int)
   {
      super();
      swatch = inSwatch;
      var gfx = graphics;
      gfx.beginBitmapFill(swatch.bitmapData);
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(0.5,0.5,inSize,inSize);
      addEventListener(MouseEvent.MOUSE_DOWN, function(_) inControl.applyColour(inSwatch.colour) );
   }
   public function getLayout() {
      var o = new DisplayLayout(this);
      return o;
   }
   public function dropColour(inCol:RGBHSV)
   {
     swatch.setColour(inCol);
   }
}

class Swatch
{
   public var colour(default,null):RGBHSV;
   public var bitmapData:BitmapData;
   public function new(index:Int, of:Int)
   {
      var cycle = of>>1;
      var idx = index % cycle;
      if (idx==0)
         colour = new RGBHSV( index==0 ? 0x000000 : 0xffffff);
      else
      {
         idx--;
         cycle--;
         colour = new RGBHSV(0xffffff);
         colour.setHSV( idx/cycle * 360, 1.0, (index<of/2) ? 255 : 128 );
      }
      bitmapData = new BitmapData(1,1,true, colour.getRGBA());
   }
   public function setColour(inCol:RGBHSV)
   {
      colour = inCol.clone();
      bitmapData.setPixel32(0,0,colour.getRGBA());
   }
}



class ColourWheel extends Widget
{
   public var onChange:RGBHSV->Int->Void;

   var mWidth :Float;
   var mHeight : Float;
   var mContainer:Sprite;
   var bitmap:Bitmap;
   var background:Bitmap;

   var mMode:Int;
   var radius:Float;
   var mColour:RGBHSV;

   var watcher:MouseWatcher;
   var marker:Bitmap;
   var markerSize = Skin.scale(15);

   public static var markerBitmap:BitmapData;

   public function new(inColour:RGBHSV)
   {
      super();
      if (markerBitmap==null)
      {
         markerBitmap = emptyBmp(markerSize,markerSize);
         var s = new Shape();
         var gfx = s.graphics;
         gfx.lineStyle(4,0xffffff);
         gfx.drawCircle(markerSize/2,markerSize/2,markerSize/3);
         gfx.lineStyle(2,0x000000);
         gfx.drawCircle(markerSize/2,markerSize/2,markerSize/3);
         markerBitmap.draw(s);
      }
      mContainer = new Sprite();
      addChild(mContainer);

      watcher = MouseWatcher.create(this, onMouse, onMouse, onMouse );
      mColour = inColour.clone();
      background = new Bitmap();
      background.x = -2;
      background.y = -2;
      mContainer.addChild(background);
      bitmap = new Bitmap();
      mContainer.addChild(bitmap);
      marker = new Bitmap(markerBitmap);
      mContainer.addChild(marker);
      mWidth = Skin.scale(100);
      mHeight = Skin.scale(100);
      var layout = new Layout();
      layout.minWidth = Skin.scale(32);
      layout.minHeight = Skin.scale(32);
      layout.mAlign = Layout.AlignKeepAspect | Layout.AlignStretch;
      layout.name = "colour";
      layout.onLayout = onBmpLayout;
      setItemLayout(layout);
      getLayout().setAlignment(Layout.AlignStretch);
      mMode = RGBHSV.VALUE;
      //build();
   }

   function onMouse(inEvent:MouseEvent)
   {
      var local = mContainer.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
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
         case RGBHSV.HUE: mColour.setS(local.x/mWidth).setV( 255*(1-local.y/(mHeight-1)) );
         default:
            var c0 = getC0();
            var c1 = getC1();
            mColour.set(c0, 255*(1-local.y/(mHeight-1) ) ).set(c1,255 * local.x/(mWidth-1) );

      }
      updateMarker();

      if (onChange!=null)
      {
         onChange( mColour.clone(), Phase.fromMouseEvent(inEvent)  );
      }
   }

   function getC0()
   {
      if ( mMode==RGBHSV.GREEN )
         return RGBHSV.BLUE;
      else if ( mMode==RGBHSV.BLUE )
         return RGBHSV.RED;

      return RGBHSV.GREEN;
   }

   function getC1()
   {
      if ( mMode==RGBHSV.GREEN )
         return RGBHSV.RED;
      else if ( mMode==RGBHSV.BLUE )
         return RGBHSV.GREEN;

      return RGBHSV.BLUE;
   }


   public function get_colour() : RGBHSV
   {
      return mColour.clone();
   }

   public function setColour(inColour:RGBHSV,inFinal:Bool)
   {
      if (inColour.compare(mColour)!=0 || inFinal)
      {
         mColour = inColour.clone();
         if ( mMode!=RGBHSV.VALUE && inFinal)
            buildBmp();
         updateOverlays();
      }
      else if (inColour.a != mColour.a)
         mColour = inColour.clone();
   }

   public function setInputMode(inMode:Int)
   {
      mMode = inMode;
      buildBmp();
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
      return new BitmapData(w,h,true,gm2d.RGB.CLEAR);
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
      var bmp = new BitmapData(w,h,false,0);
      bitmap.bitmapData = bmp;

      var pixels:ByteArray = null;

      if ( mMode==RGBHSV.VALUE || mMode==RGBHSV.SATURATION )
      {
         pixels = new ByteArray();
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
                  var sat = mMode==RGBHSV.VALUE ? len/rad : mColour.s;
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
      }
      else if ( mMode==RGBHSV.HUE )
      {
         var col = new RGBHSV();
         col.setH( mColour.h );
         if (false)
         {
            pixels = new ByteArray();
            for(y in 0...h)
            {
               col.setV( 256*(h-y-1)/h );
               for(x in 0...w)
               {
                  col.setS( x/(w-1) );
                  pixels.writeInt(0xff000000|col.getRGB());
               }
            }
         }
         else
         {
            var tiny = new BitmapData(2,2,false,0);
            for(v in 0...2)
               for(s in 0...2)
               {
                 col.setV(v*255);
                 col.setS(s*255);
                 tiny.setPixel32(s,1-v,col.getRGB()|0xff000000);
               }
            var mtx = new Matrix();
            mtx.a = w;
            mtx.d = h;
            mtx.tx = -w*0.5;
            mtx.ty = -h*0.5;
            bmp.draw(tiny,mtx,null, null, null, true);
         }
      }
      else
      {
         pixels = new ByteArray();
         var c0 = getC0();
         var c1 = getC1();
         var col = mColour.clone();
         for(y in 0...h)
         {
            col.set(c0, 256*(h-y-1)/h );
            for(x in 0...w)
            {
               col.set(c1, 256 * x/w );
               pixels.writeInt(0xff000000|col.getRGB());
            }
         }
      }
 
 

      if (pixels!=null)
      {
         pixels.position = 0;
         bmp.setPixels(new Rectangle(0,0,w,h),pixels);
      }

      var s = new Shape();
      var gfx = s.graphics;
      gfx.clear();
      gfx.beginFill(0x000000);
      
      if ( mMode==RGBHSV.VALUE || mMode==RGBHSV.SATURATION )
         gfx.drawCircle(rad+2.5,y0+2.5,rad+2);
      else
         gfx.drawRect(1,1,w+2,h+2);
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
         case RGBHSV.SATURATION:
            var theta = mColour.h * Math.PI/180.0;
            marker.x = radius - markerBitmap.width*0.5 + Math.cos(theta) * radius * mColour.v/255.0;
            marker.y = radius - markerBitmap.height*0.5 - Math.sin(theta) * radius * mColour.v/255.0;
         case RGBHSV.HUE:
            marker.x = mWidth * mColour.s - markerBitmap.width*0.5 ;
            marker.y = mHeight * (1- mColour.v/255.0) - markerBitmap.height*0.5  ;

         default:
            var c0 = getC0();
            var c1 = getC1();
            marker.x = mWidth * mColour.get(c1)/255.0 - markerBitmap.width*0.5 ;
            marker.y = mHeight * (255-mColour.get(c0)) / 255.0 - markerBitmap.height*0.5 ;
      }
   }


   function updateOverlays()
   {
      if (bitmap!=null)
         bitmap.alpha = 1.0;
      switch(mMode)
      {
         case RGBHSV.VALUE:
            if (bitmap!=null)
               bitmap.alpha = mColour.v/255.0;
      }
      updateMarker();
   }
 



   public function onBmpLayout(x:Float, y:Float, inWidth:Float, inHeight:Float)
   {
      if (mWidth!=inWidth || mHeight!=inHeight)
      {
         mWidth = inWidth;
         mHeight = inHeight;
         buildBmp();
      }
      mContainer.x = x;
      mContainer.y = y;
   }
}

class ColourControl extends Widget
{
   var mMode:Int;
   var mColour:RGBHSV;
   var wheel:ColourWheel;
   var box:RGBBox;
   var mainSlider:ColourSlider;
   var alphaSlider:ColourSlider;

   var redIn:NumericInput;
   var greenIn:NumericInput;
   var blueIn:NumericInput;
   var hueIn:NumericInput;
   var saturationIn:NumericInput;
   var valueIn:NumericInput;
   var dragShape:Sprite;


   var updateLockout:Int;
   public var onColourChange:RGBHSV->Int->Void;

   public function new(inColour:RGBHSV, ?inOnChange:RGBHSV->Int->Void,?inAttribs:{})
   {
      super(null,inAttribs);

      mColour = inColour.clone();
      onColourChange = inOnChange;
  
      updateLockout = 1;
      mMode = RGBHSV.HUE;

      var all =  new GridLayout(3,"All");
      all.setDebugOwner(this);
      all.add( createNumberBoxes() );

      mainSlider = new ColourSlider(mMode, true);
      mainSlider.onChange = onMainChange;
      mainSlider.onEnter = onMainEnter;
      addChild(mainSlider);
      all.add(mainSlider.getLayout());

      wheel = new ColourWheel(mColour);
      wheel.getLayout().setBestSize( Skin.scale(140),Skin.scale(140) );
      wheel.onChange = onWheel;
      addChild(wheel);
      all.add(wheel.getLayout().setBorders(0,0,Skin.scale(6),0));

      box = new RGBBox(mColour,true, false, null, mRenderer.getDynamic("rgbBox"));
      addChild(box);
      new MouseWatcher(box,null,onRGBDrag,onRGBDrop,0,0,true);
      var b = Skin.scale(2);
      all.add(box.getLayout().setAlignment( Layout.AlignStretch).setBorders(b,b,b,b));
      all.setAlignment( Layout.AlignStretch);

      all.add(null);

      alphaSlider = new ColourSlider(RGBHSV.ALPHA, false);
      alphaSlider.onChange = onAlpha;
      addChild(alphaSlider);
      all.add(alphaSlider.getLayout().setBorders(0,0,6,0));

      all.setSpacing(10,10);
      all.setColStretch(0,0);
      all.setColStretch(1,0);
      all.setColStretch(2,1);
      all.setRowStretch(0,0);
      all.setRowStretch(1,0);

      var swatches = new GridLayout(10,"Swatches");
      swatches.setSpacing(4,4);
      var swatchSize = Skin.scale(16);
      for(i in 0...20)
      {
         var swatch = new Swatch(i,20);
         var box = new SwatchBox(swatch,this,swatchSize);
         addChild(box);
         swatches.add(box.getLayout());
      }

      var vstack = new GridLayout(1);
      vstack.add(swatches);
      vstack.add(all);
      vstack.setAlignment(Layout.AlignStretch | Layout.AlignTop).setSpacing(0,4);

      setInputMode(mMode);
      setAll();
      updateLockout = 0;

      setItemLayout(vstack);

      //build();
   }

   function onRGBDrag(e:MouseEvent)
   {
      if (e.target == box)
      {
         if (dragShape!=null)
         {
            removeChild(dragShape);
            dragShape = null;
         }
      }
      else
      {
         if (dragShape==null)
         {
            dragShape = new Sprite();
            dragShape.mouseEnabled = false;
            var gfx = dragShape.graphics;
            gfx.beginFill(mColour.getRGB());
            gfx.lineStyle(1,0x000000);
            gfx.drawCircle(0,0,7);
            stage.addChild(dragShape);
         }
         dragShape.x = e.stageX;
         dragShape.y = e.stageY;
      }
   }

   function onRGBDrop(e:MouseEvent)
   {
      if (dragShape!=null)
      {
         stage.removeChild(dragShape);
         dragShape = null;
      }
      var swbox:SwatchBox = Std.is(e.target,SwatchBox) ? e.target : null;
      if (swbox!=null)
         swbox.dropColour(mColour);
   }

   function setComponent(inWhich:Int, inVal:Float,inPhase:Int)
   {
      if (updateLockout==0)
      {
         mColour.set(inWhich,inVal);
         setAll(inPhase==Phase.END);
         send(inPhase);
      }
   }

   function setAll(inFinal:Bool = false)
   {
      updateLockout++;
      wheel.setColour(mColour,inFinal);
      box.setColour(mColour);
      mainSlider.setColour(mColour);
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
      var result = new NumericInput(inMax*0.5,
         function(f,phase)  if (updateLockout==0) setComponent(inMode,f,phase),
         { isInteger:inMax>100,  maxValue:inMax, step:delta } );
      result.setTextWidth(50);
      result.addEventListener( MouseEvent.MOUSE_DOWN, function(_) setInputMode(inMode) );
      return result;
   }

   function setInputMode(inMode:Int)
   {
      mMode = inMode;
      wheel.setInputMode(inMode);
      mainSlider.setInputMode(inMode);
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

   public function applyColour(inCol:RGBHSV)
   {
      mColour = inCol.clone();
      setAll(true);
      send();
   }


   public function setColour(inColour:RGBHSV)
   {
      mColour = inColour.clone();
      setAll();
   }
   public function getColour( )
   {
      return mColour.clone();
   }

   public function getRGB() { return mColour.getRGB(); }

   public function getAlpha() { return mColour.a; }

   function send(inPhase:Int = Phase.ALL)
   {
      if (onColourChange!=null)
      {
         updateLockout++;
         onColourChange(mColour.clone(),inPhase);
         updateLockout--;
      }
   }


   public function onWheel(inCol:RGBHSV,inPhase:Int)
   {
      mColour = inCol.clone();
      setAll();
      send(inPhase);
   }

   public function onAlpha(inValue:Float,inPhase:Int)
   {
      mColour.setA(inValue);
      box.setColour(mColour);
      wheel.setColour(mColour,false);
      send(inPhase);
   }

   public function onMainChange(inValue:Float, inPhase:Int)
   {
      mColour.set(mMode,inValue);
      setAll(false);
      send(inPhase);
   }

   public function onMainEnter(inValue:Float, inPhase:Int)
   {
      mColour.set(mMode,inValue);
      setAll(true);
      send(inPhase);
   }

}


