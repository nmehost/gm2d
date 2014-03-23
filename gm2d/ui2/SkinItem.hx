package gm2d.ui;

import nme.display.DisplayObject;
import nme.display.BitmapData;
import nme.geom.Rectangle;



enum SkinItem
{
  ITEM_BITMAPDATA(data:BitmapData);
  ITEM_BITMAP(name:String);
  ITEM_ICON(icon:gm2d.icons.Icon,scale:Float);
  ITEM_OBJECT(object:DisplayObject);
  ITEM_CUSTOM(factory:Skin->DisplayObject);
  ITEM_LAYOUT(layout:Layout);
}

