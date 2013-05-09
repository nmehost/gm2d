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

   var gradient:Gradient;

   public function new( )
   {
      super();

      updateLockout = 1;

      gradBox = new Sprite();
      mWidth = mHeight = 32;
      addChild(gradBox);
      var layout = new DisplayLayout(gradBox,Layout.AlignCenterY|Layout.AlignStretch,32,32);
      layout.setPadding(8,0);
      layout.onLayout = renderGradBox;

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
      var vstack = new GridLayout(1);
      vstack.add(swatches);
      vstack.add(layout);
      vstack.setAlignment(Layout.AlignStretch).setSpacing(0,4);
      updateLockout = 0;

      mLayout = vstack;
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
      gfx.drawRect(0,0,mWidth,mHeight);
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
      gradient.beginFillBox(gfx,0,0,mWidth,mHeight);
      gfx.drawRect(0,0,mWidth,mHeight);
   }

   public function setGradient(inGrad:Gradient)
   {
      gradient = inGrad.clone();
      render();
   }
}


