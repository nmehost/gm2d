package gm2d.skin;

import nme.display.BitmapData;
import nme.geom.Rectangle;

class ShadowInstance
{
   //var type;
   public var fillStyle(default,null):FillStyle;
   public var lineStyle(default,null):LineStyle;
   public var depth(default,null):Float;
   public var flags(default,null):Int;
   public var rad(default,null):Float;
   public var bmp(default,null):BitmapData;
   public var inner(default,null):Rectangle;
   public var lastUsed(default,null):Float;


   public function new(inLineStyle:LineStyle, inFillStyle:FillStyle, inDepth:Float, inFlags:Int, inRad:Float,
                       inBmp:BitmapData, inInner:Rectangle )
   {
      lineStyle = inLineStyle;
      fillStyle = inFillStyle;
      depth = inDepth;
      flags = inFlags;
      rad = inRad;
      bmp = inBmp;
      inner = inInner;
   }

   public function matches(inLineStyle:LineStyle, inFillStyle:FillStyle, inDepth:Float, inFlags:Int, inRad:Float)
   {
      return depth==inDepth && flags==inFlags && rad==inRad &&
             Type.enumEq(lineStyle, inLineStyle) &&
             Type.enumEq(fillStyle, inFillStyle);
   }

   public function use(timestamp:Float) lastUsed = timestamp;
}

