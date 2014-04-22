package gm2d.skin;

import nme.display.DisplayObject;
import nme.display.BitmapData;

enum BitmapStyle
{
   BitmapBitmap(bmp:BitmapData);
   BitmapFactory(factory:String->Int->BitmapData);
   BitmapAndDisable(bmp:BitmapData,bmpDisabled:BitmapData);
}
