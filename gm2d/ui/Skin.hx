package gm2d.ui;

import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;

class Skin
{
   public static var current:Skin = new Skin();

   public var textFormat:gm2d.text.TextFormat;

   public function new()
	{
		textFormat = new gm2d.text.TextFormat();
      textFormat.size = 16;
      textFormat.font = "Arial";
	}

	public function renderCurrent(inWidget:Widget)
	{
      var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
      inWidget.filters = [ glow ];
	}
	public function clearCurrent(inWidget:Widget)
	{
      inWidget.filters = null;
	}

   public function renderMenubar(inObject:gm2d.display.DisplayObject,inW:Float, inH:Float)
	{
	   var gfx = inObject.graphics;
		gfx.clear();
		var mtx = new gm2d.geom.Matrix();
		mtx.createGradientBox(inH,inH,Math.PI * 0.5);
	   //gfx.beginFill(0xe0e0d0);
		var cols:Array<Int> = [0xf0f0e0, 0xe0e0d0, 0xa0a090];
		var alphas:Array<Float> = [1.0, 1.0, 1.0];
		var ratio:Array<Int> = [0, 128, 255];
	   gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,inW,inH);
	}

	public function styleMenu(inItem:Button)
	{
	   inItem.getLabel().backgroundColor = 0x4040a0;
      inItem.getLabel().textColor = 0x000000;
   }

	public function styleText(inText:gm2d.text.TextField)
	{
	   inText.defaultTextFormat = textFormat;
	}
}

