package gm2d.ui;

import gm2d.filters.BitmapFilter;
import gm2d.filters.BitmapFilterType;
import gm2d.filters.DropShadowFilter;
import gm2d.filters.GlowFilter;

class Skin
{
   public static var current:Skin = new Skin();

   public function new()
	{
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
	public function styleMenu(inItem:Button)
	{
	   inItem.getLabel().backgroundColor = 0x4040a0;
      inItem.getLabel().textColor = 0x000000;
   }
}

