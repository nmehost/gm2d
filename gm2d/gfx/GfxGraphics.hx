package gm2d.gfx;

import nme.display.GradientType;
import nme.display.SpreadMethod;
import nme.display.InterpolationMethod;
import nme.display.CapsStyle;
import nme.display.JointStyle;
import nme.display.LineScaleMode;
import nme.display.Graphics;
import nme.display.BitmapData;
import gm2d.svg.Text;

import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.text.TextFormat;

import nme.geom.Matrix;

class GfxGraphics extends Gfx
{
   var graphics : Graphics;

   public function new(inGraphics:Graphics)
   {
     super();
     graphics = inGraphics;
   }

   override public function beginGradientFill(grad:Gradient)
   {
      graphics.beginGradientFill(grad.type,grad.colors,grad.alphas,grad.ratios,grad.matrix,grad.spread,grad.interp,grad.focus);
   }

	override public function beginFill(color:Int, alpha:Float) { graphics.beginFill(color,alpha); }
   override public function endFill() { graphics.endFill(); }

   override public function lineStyle(style:LineStyle)
   {
      graphics.lineStyle(style.thickness,style.color,style.alpha,style.pixelHinting,style.scaleMode,style.capsStyle,style.jointStyle,style.miterLimit);
   }
   override public function endLineStyle() { graphics.lineStyle(); }

   override public function moveTo(inX:Float, inY:Float) { graphics.moveTo(inX,inY); }
   override public function lineTo(inX:Float, inY:Float) { graphics.lineTo(inX,inY); }
   override public function curveTo(inCX:Float, inCY:Float,inX:Float,inY:Float)
     { graphics.curveTo(inCX,inCY,inX,inY); }
   override public function renderText(text:Text, m:Matrix)
   {
      switch(text.fill)
      {
         case  FillSolid(colour):
            var scale = Math.sqrt(m.a*m.a + m.c*m.c);
            var textField = new TextField();
            textField.autoSize = TextFieldAutoSize.LEFT;
            var fmt = new TextFormat();
            fmt.size = text.font_size * scale;
            fmt.color = colour;
            textField.defaultTextFormat = fmt;
            textField.text=text.text;
            var tw = Std.int(textField.width + 0.99);
            var th = Std.int(textField.height + 0.99);
            if (tw>0 && th>0)
            {
               var bmp = new BitmapData(tw,th,true,0x00000000);
               bmp.draw(textField);
               var mapper = m.clone();
               //mapper.invert();
               //mapper.tx -= text.x;
               //mapper.ty -= text.y;
               graphics.beginBitmapFill(bmp,mapper,true,true);
               for(c in 0...4)
               {
                  var x = text.x + ( (c==1 || c==2) ? tw/scale : 0);
                  var y = text.y - th/scale + ( (c==2 || c==3) ? th/scale : 0);
                  var tx =  x*m.a + y*m.c + m.tx;
                  var ty =  x*m.b + y*m.d + m.ty;
                  if (c==0)
                     graphics.moveTo(tx,ty);
                  else
                     graphics.lineTo(tx,ty);
               }
               graphics.endFill();
            }

         default: trace("Hmmm");
      }
   /*

   public var name:String;
   public var x:Float;
   public var y:Float;
   public var matrix:Matrix;
   public var text:String;
   public var fill:FillType;
   public var fill_alpha:Float;
   public var stroke_alpha:Float;
   public var stroke_colour:Null<Int>;
   public var stroke_width:Float;
   public var font_family:String;
   public var font_size:Float;
   public var kerning:Float;
   public var letter_spacing:Float;
   */

   }
}

