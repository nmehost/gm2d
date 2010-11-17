package gm2d.ui;

import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;
import gm2d.display.Sprite;
import gm2d.text.TextField;
import gm2d.geom.Point;

class Skin
{
   public static var current:Skin = new Skin();

   public var textFormat:gm2d.text.TextFormat;
   public var menuHeight:Float;

   public function new()
   {
      textFormat = new gm2d.text.TextFormat();
      textFormat.size = 16;
      textFormat.font = "Arial";
      menuHeight = 24;
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

   public function renderMenubar(inObject:gm2d.display.Sprite,inW:Float, inH:Float)
   {
      var gfx = inObject.graphics;
      gfx.clear();
      var mtx = new gm2d.geom.Matrix();
      mtx.createGradientBox(inH,inH,Math.PI * 0.5);
      var cols:Array<Int> = [0xf0f0e0, 0xe0e0d0, 0xa0a090];
      var alphas:Array<Float> = [0.8, 0.8, 0.8];
      var ratio:Array<Int> = [0, 128, 255];
      gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,inW,inH);
   }

   public function styleMenu(inItem:Button)
   {
      inItem.getLabel().backgroundColor = 0x4040a0;
      inItem.getLabel().textColor = 0x000000;
      inItem.onCurrentChangedFunc = function(_) { };
   }

	public function styleLabelText(label:TextField)
   {
      label.defaultTextFormat = textFormat;
      label.textColor = Panel.labelColor;
      label.autoSize = gm2d.text.TextFieldAutoSize.LEFT;
      label.selectable = false;
  }

   public function styleButtonText(label:TextField)
   {
	   styleLabelText(label);
   }


   public function styleText(inText:gm2d.text.TextField)
   {
      inText.defaultTextFormat = textFormat;
   }

   public function renderMDI(inMDI:Widget)
   {
      var gfx = inMDI.graphics;
      gfx.clear();
      var rect = inMDI.scrollRect;
      if (rect!=null)
      {
         gfx.beginFill(0x404040);
         gfx.drawRect(rect.x, rect.y, rect.width, rect.height );
      }
   }

   static var title_h = 22;
	static var borders = 3;

   public function getFrameClientOffset() : Point
	{
	   return new Point(borders,borders+title_h);
	}
   public function renderFrame(inObj:Sprite, inW:Float, inH:Float)
   {
      var gfx = inObj.graphics;
      gfx.clear();

      var mtx = new gm2d.geom.Matrix();
      mtx.createGradientBox(title_h+borders,title_h+borders,Math.PI * 0.5);
      var cols:Array<Int> = [0xf0f0e0, 0xe0e0d0, 0xa0a090];
      var alphas:Array<Float> = [1.0, 1.0, 1.0];
      var ratio:Array<Int> = [0, 128, 255];
      gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );

      gfx.lineStyle(1,0xf0f0e0);
      gfx.drawRoundRect(0.5,0.5,inW+borders*2, inH+borders*2+title_h, 3,3 );
		gfx.endFill();
      gfx.drawRect(borders-0.5,title_h+borders-0.5,inW+1, inH+1 );

      //var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 3, 3, false, false);
      //inObj.filters = [ glow ];
   }


}

