package gm2d.ui;

import gm2d.display.DisplayObject;
import gm2d.display.BitmapData;
import gm2d.display.Shape;
import gm2d.display.Sprite;
import gm2d.display.Bitmap;
import gm2d.geom.Rectangle;
import gm2d.Gradient;
import gm2d.text.TextField;
import gm2d.ui.MouseWatcher;
import gm2d.ui.Layout;
import gm2d.ui.HitBoxes;
import gm2d.display.GradientType;
import gm2d.display.InterpolationMethod;
import gm2d.geom.Matrix;
import gm2d.geom.Point;
import gm2d.events.MouseEvent;
import gm2d.skin.Skin;
import gm2d.RGBHSV;


class GradSwatchBox extends Widget
{
   var swatch:GradSwatch;
   var control:GradientControl;
   public function new(inControl:GradientControl, inSwatch:GradSwatch, inSize:Int)
   {
      super();
      control = inControl;
      swatch = inSwatch;
      var gfx = graphics;
      gfx.beginBitmapFill(swatch.bitmapData);
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(0.5,0.5,inSize,inSize);
      addEventListener(MouseEvent.MOUSE_DOWN, function(_) inControl.setGradient(inSwatch.gradient) );
   }
}

class GradSwatch
{
   public var gradient:Gradient;
   public var bitmapData:BitmapData;

   public function new(index:Int, of:Int)
   {
      var cycle = of>>1;
      var idx = index % cycle;
      var colour0 : RGBHSV = null;
      gradient = new Gradient();
      if (idx==0)
         colour0 = new RGBHSV( index==0 ? 0x000000 : 0xffffff);
      else
      {
         idx--;
         cycle--;
         colour0 = new RGBHSV(0xffffff);
         colour0.setHSV( idx/cycle * 360, 1.0, (index<of/2) ? 255 : 128 );
      }
      gradient.addStop(colour0,0);
      var colour1 = new RGBHSV(0xffffff, 0);
      gradient.addStop(colour1,1);

      bitmapData = new BitmapData(32,32,true,gm2d.RGB.WHITE);
      setData();
   }

   function setData()
   {
      var s = new Shape();
      var gfx = s.graphics;
      gradient.beginFillBox(gfx, 0,0,32,32,45);
      gfx.drawRect(0,0,32,32);
      bitmapData.draw(s);
   }
}



class GradientControl extends Widget
{
   var updateLockout:Int;
   public var onChange:Gradient->Void;
   public var gradBox:Sprite;
   var mWidth:Float;
   var mHeight:Float;
   var colourBox:RGBBox;
   var position:NumericInput;
   var stopX0:Float;
   var stopW:Float;

   var gradient:Gradient;
   var currentId:Int;

   public function new( )
   {
      super();

      updateLockout = 1;
      stopX0 = 0;
      stopW = 1;

      gradBox = new Sprite();
      mWidth = mHeight = 32;
      addChild(gradBox);
      var gradLayout = new DisplayLayout(gradBox,Layout.AlignCenterY|Layout.AlignStretch,32,64);
      gradLayout.setPadding(8,0);
      gradLayout.onLayout = renderGradBox;
      gradBox.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);

      var stopControls = new GridLayout(1);
      colourBox = new RGBBox(new RGBHSV(0xff00ff,1), false, true, onGradColour);
      addChild(colourBox);
      stopControls.add(colourBox.getLayout().setMinSize(64,28));

      position = new NumericInput(0.0, false, 0, 1, 0.004);
      addChild(position);
      position.setTextWidth(64);
      stopControls.add(position.getLayout());
      var skin = Skin.current;
      var addRemoveLayout = new GridLayout(2,0);
      addRemoveLayout.setSpacing(0,0);
      var addStop = Button.BMPButton(skin.getButtonBitmapData(MiniButton.ADD,0),0,0,onAddStop);
      addChild(addStop);
      addStop.getItemLayout().setBorders(5,5,5,5);
      addRemoveLayout.add(addStop.getLayout().setBorders(5,5,5,5));
      var removeStop = Button.BMPButton(skin.getButtonBitmapData(MiniButton.REMOVE,0),0,0,onRemoveStop);
      addChild(removeStop);
      removeStop.getItemLayout().setBorders(5,5,5,5);
      addRemoveLayout.add(removeStop.getLayout().setBorders(5,5,5,5));
      stopControls.add(addRemoveLayout);
      stopControls.setSpacing(4,4);

      var controls = new GridLayout(2,0);
      controls.add(stopControls);
      controls.add(gradLayout);
      controls.setColStretch(1,1);
      controls.setAlignment(Layout.AlignStretch);

      var swatches = new GridLayout(10);
      swatches.setSpacing(4,4);
      for(i in 0...20)
      {
         var swatch = new GradSwatch(i,20);
         var box = new GradSwatchBox(this,swatch,16);
         addChild(box);
         swatches.add(box.getLayout());
      }

      gradient = (new GradSwatch(0,20)).gradient.clone();
      var vstack = new GridLayout(1,0);
      vstack.add(swatches);
      vstack.add(controls);
      vstack.setColStretch(0,1);
      vstack.setAlignment(Layout.AlignStretch).setSpacing(0,4);
      updateLockout = 0;

      mLayout = vstack;

      setCurrentStop(0);
   }

   public function onGradColour(inColour:RGBHSV)
   {
      if (currentId>=0 && currentId<gradient.stops.length)
      {
         gradient.stops[currentId].colour = inColour;
         render();
      }
   }

   public function setCurrentStop(stopId:Int)
   {
      currentId = stopId;
      var stop = gradient.stops[stopId];
      if (stop!=null)
      {
         colourBox.setColour( stop.colour );
         position.setValue( stop.position );
      }
   }

   function onMouse(ev:MouseEvent)
   {
      if (ev.localY>32)
      {
         var stop = Std.int((ev.localX-stopX0)/stopW);
         if (stop>=0 && stop<gradient.stops.length)
            setCurrentStop(stop);
      }
   }

   function onAddStop()
   {
      var pos = gradient.stops[currentId].position;
      var col = gradient.stops[currentId].colour;

      if (currentId+1 < gradient.stops.length )
         pos = (pos + gradient.stops[currentId+1].position) * 0.5;
      else if (pos<1.0)
         pos = 1.0;
      else if (currentId>0)
         pos = (pos + gradient.stops[currentId-1].position) * 0.5;
      else
         pos = 0;

      setCurrentStop( gradient.add( new GradStop(col, pos) ) );
      render();
   }
   function onRemoveStop()
   {
   }

   function renderGradBox(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      mWidth = inW;
      mHeight = inH;
      render();
   }

   function render()
   {
      var gfx = gradBox.graphics;
      gfx.clear();
      gradient.beginFill(gfx);

      gfx.beginFill(0xffffff);
      gfx.drawRect(0,0,mWidth,32);
      gfx.beginFill(0x808080);
      var x = 0;
      var y = 0;
      while(x<mWidth)
      {
         var w = x+16.0;
         if (w>mWidth-1) w = mWidth-1;
         gfx.drawRect(x,y,w-x,16);
         x+=16;
         y=16-y;
      }
      gfx.lineStyle(1,0x000000);
      gradient.beginFillBox(gfx,0,0,mWidth,32);
      gfx.drawRect(0,0,mWidth,32);

      stopW = Std.int(mWidth/gradient.stops.length);
      if (stopW>32)
         stopW = 32;
      stopX0 = Std.int((mWidth - stopW*gradient.stops.length) * 0.5) + 4.5;
      var x = stopX0;
      for(i in 0...gradient.stops.length)
      {
         var stop = gradient.stops[i];
         gfx.beginFill(stop.colour.getRGB());
         gfx.drawRect(x,36,stopW-8,24);
         x+=stopW;
      }
   }

   public function setGradient(inGrad:Gradient)
   {
      gradient = inGrad.clone();
      render();
      setCurrentStop(0);
   }
}


