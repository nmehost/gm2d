package gm2d.skin;

import nme.filters.BitmapFilter;

enum BitmapFilterStyle
{
   FilterDropShadow(distance:Float, angle:Float, blur:Float, colour:FillStyle, alpha:Float);
   FilterGlow(colour:FillStyle, blur:Float, alpha:Float);
   // Escape hatch so all filter customization still goes through the skin's named slots,
   // rather than attribSet ever holding a concrete BitmapFilter directly.
   FilterCustom(filter:BitmapFilter);
}
