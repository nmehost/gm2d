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
   public var bmp(default,null):BitmapData;
   public var inner(default,null):Rectangle;
   public var lastUsed(default,null):Float;


   public function new(inLineStyle:LineStyle, inFillStyle:FillStyle, inDepth:Float, inFlags:Int,
                       inBmp:BitmapData, inInner:Rectangle )
   {
      lineStyle = inLineStyle;
      fillStyle = inFillStyle;
      depth = inDepth;
      flags = inFlags;
      bmp = inBmp;
      inner = inInner;
   }

   public function matches(inLineStyle:LineStyle, inFillStyle:FillStyle, inDepth:Float, inFlags:Int)
   {
      return depth==inDepth && flags==inFlags &&
             Type.enumEq(lineStyle, inLineStyle) &&
             Type.enumEq(fillStyle, inFillStyle);
   }

   public function use(timestamp:Float) lastUsed = timestamp;
}

